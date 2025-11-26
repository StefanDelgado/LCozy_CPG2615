<?php
/**
 * Mobile API: Request Checkout (Tenant/Student)
 * POST /mobile-api/checkout/request_checkout.php
 * 
 * Request body:
 * {
 *   "booking_id": 123,
 *   "reason": "Optional reason text"
 * }
 */

header('Content-Type: application/json');
require_once __DIR__ . '/../../../config.php';

// Get JSON input
$input = json_decode(file_get_contents('php://input'), true);

// Validate input
if (!isset($input['student_id'], $input['booking_id'])) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'Missing required fields: student_id, booking_id']);
    exit;
}

$student_id = (int)$input['student_id'];
$booking_id = (int)$input['booking_id'];
$reason = trim($input['reason'] ?? '');

try {
    // Verify booking belongs to this student and is active
    $stmt = $pdo->prepare("
        SELECT b.booking_id, b.status, b.room_id, d.owner_id, d.dorm_id, d.name AS dorm_name
        FROM bookings b
        JOIN rooms r ON b.room_id = r.room_id
        JOIN dormitories d ON r.dorm_id = d.dorm_id
        WHERE b.booking_id = ? AND b.student_id = ? 
        LIMIT 1
    ");
    $stmt->execute([$booking_id, $student_id]);
    $booking = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$booking) {
        http_response_code(404);
        echo json_encode(['success' => false, 'error' => 'Booking not found']);
        exit;
    }

    // Check if booking status allows checkout request
    if (!in_array($booking['status'], ['active', 'approved'])) {
        http_response_code(400);
        echo json_encode([
            'success' => false, 
            'error' => 'Cannot request checkout for this booking status',
            'current_status' => $booking['status']
        ]);
        exit;
    }

    // Check if checkout request already exists
    $checkExisting = $pdo->prepare("
        SELECT id, status 
        FROM checkout_requests 
        WHERE booking_id = ? AND status IN ('requested', 'approved')
        LIMIT 1
    ");
    $checkExisting->execute([$booking_id]);
    $existing = $checkExisting->fetch(PDO::FETCH_ASSOC);

    if ($existing) {
        http_response_code(400);
        echo json_encode([
            'success' => false, 
            'error' => 'Checkout request already exists',
            'request_status' => $existing['status']
        ]);
        exit;
    }

    // Begin transaction
    $pdo->beginTransaction();

    // Insert checkout request
    $insertStmt = $pdo->prepare("
        INSERT INTO checkout_requests 
        (booking_id, tenant_id, owner_id, request_reason, status, created_at, updated_at) 
        VALUES (?, ?, ?, ?, 'requested', NOW(), NOW())
    ");
    $insertStmt->execute([$booking_id, $student_id, $booking['owner_id'], $reason]);
    $request_id = $pdo->lastInsertId();

    // Update booking status
    $updateBooking = $pdo->prepare("
        UPDATE bookings 
        SET status = 'checkout_requested', updated_at = NOW() 
        WHERE booking_id = ?
    ");
    $updateBooking->execute([$booking_id]);

    // Create notification message for owner
    $message_body = "Tenant requested checkout for booking #{$booking_id} at {$booking['dorm_name']}.";
    if ($reason) {
        $message_body .= " Reason: {$reason}";
    }

    $messageStmt = $pdo->prepare("
        INSERT INTO messages (sender_id, receiver_id, dorm_id, body, created_at, urgency) 
        VALUES (?, ?, ?, ?, NOW(), 'normal')
    ");
    $messageStmt->execute([
        $student_id, 
        $booking['owner_id'], 
        $booking['dorm_id'], 
        $message_body
    ]);

    $pdo->commit();

    echo json_encode([
        'success' => true,
        'message' => 'Checkout request submitted successfully',
        'data' => [
            'request_id' => $request_id,
            'booking_id' => $booking_id,
            'status' => 'requested',
            'created_at' => date('Y-m-d H:i:s')
        ]
    ]);

} catch (Exception $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    error_log('Checkout request error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'An error occurred while processing your request']);
}
