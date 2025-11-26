<?php
/**
 * Mobile API: Disapprove Checkout Request (Owner)
 * POST /mobile-api/checkout/disapprove_checkout.php
 * 
 * Request body:
 * {
 *   "request_id": 123,
 *   "owner_id": 456
 * }
 */

header('Content-Type: application/json');
require_once __DIR__ . '/../../../config.php';

// Get JSON input
$input = json_decode(file_get_contents('php://input'), true);

// Validate input
if (!isset($input['request_id'], $input['owner_id'])) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'Missing required fields: request_id, owner_id']);
    exit;
}

$request_id = (int)$input['request_id'];
$owner_id = (int)$input['owner_id'];

try {
    // Verify request belongs to this owner
    $checkStmt = $pdo->prepare("
        SELECT cr.*, b.room_id, d.dorm_id, d.name AS dorm_name
        FROM checkout_requests cr
        JOIN bookings b ON cr.booking_id = b.booking_id
        JOIN rooms r ON b.room_id = r.room_id
        JOIN dormitories d ON r.dorm_id = d.dorm_id
        WHERE cr.id = ? AND cr.owner_id = ?
        LIMIT 1
    ");
    $checkStmt->execute([$request_id, $owner_id]);
    $request = $checkStmt->fetch(PDO::FETCH_ASSOC);

    if (!$request) {
        http_response_code(404);
        echo json_encode(['success' => false, 'error' => 'Checkout request not found or unauthorized']);
        exit;
    }

    // Check if already processed
    if ($request['status'] !== 'requested') {
        http_response_code(400);
        echo json_encode([
            'success' => false, 
            'error' => 'Request already processed',
            'current_status' => $request['status']
        ]);
        exit;
    }

    // Begin transaction
    $pdo->beginTransaction();

    // Update checkout request status to disapproved
    $updateRequest = $pdo->prepare("
        UPDATE checkout_requests 
        SET status = 'disapproved', 
            processed_by = ?, 
            processed_at = NOW(), 
            updated_at = NOW()
        WHERE id = ?
    ");
    $updateRequest->execute([$owner_id, $request_id]);

    // Revert booking status back to active
    $updateBooking = $pdo->prepare("
        UPDATE bookings 
        SET status = 'active', 
            updated_at = NOW()
        WHERE booking_id = ?
    ");
    $updateBooking->execute([$request['booking_id']]);

    // Send notification to tenant
    $message_body = "Your checkout request for booking #{$request['booking_id']} at {$request['dorm_name']} was not approved by the owner.";
    
    $messageStmt = $pdo->prepare("
        INSERT INTO messages (sender_id, receiver_id, dorm_id, body, created_at, urgency)
        VALUES (?, ?, ?, ?, NOW(), 'normal')
    ");
    $messageStmt->execute([
        $owner_id,
        $request['tenant_id'],
        $request['dorm_id'],
        $message_body
    ]);

    $pdo->commit();

    echo json_encode([
        'success' => true,
        'message' => 'Checkout request disapproved',
        'data' => [
            'request_id' => $request_id,
            'booking_id' => (int)$request['booking_id'],
            'status' => 'disapproved',
            'processed_at' => date('Y-m-d H:i:s')
        ]
    ]);

} catch (Exception $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    error_log('Disapprove checkout error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'An error occurred while processing the request']);
}
