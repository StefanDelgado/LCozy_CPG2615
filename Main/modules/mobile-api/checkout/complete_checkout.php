<?php
/**
 * Mobile API: Mark Checkout as Complete (Owner)
 * POST /mobile-api/checkout/complete_checkout.php
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

    // Must be approved before completion
    if ($request['status'] !== 'approved') {
        http_response_code(400);
        echo json_encode([
            'success' => false, 
            'error' => 'Only approved requests can be marked as completed',
            'current_status' => $request['status']
        ]);
        exit;
    }

    // Begin transaction
    $pdo->beginTransaction();

    // Mark checkout request as completed
    $updateRequest = $pdo->prepare("
        UPDATE checkout_requests 
        SET status = 'completed', 
            processed_by = ?, 
            processed_at = NOW(), 
            updated_at = NOW()
        WHERE id = ?
    ");
    $updateRequest->execute([$owner_id, $request_id]);

    // Update booking to completed
    $updateBooking = $pdo->prepare("
        UPDATE bookings 
        SET status = 'completed', 
            end_date = COALESCE(end_date, CURDATE()),
            updated_at = NOW()
        WHERE booking_id = ?
    ");
    $updateBooking->execute([$request['booking_id']]);

    // Update tenants table if it exists
    try {
        $updateTenant = $pdo->prepare("
            UPDATE tenants 
            SET status = 'completed', 
                checkout_date = NOW()
            WHERE booking_id = ?
        ");
        $updateTenant->execute([$request['booking_id']]);
    } catch (Exception $ignored) {
        // Table might not exist or no record found - that's ok
    }

    // Send final notification to tenant
    $message_body = "Your checkout for booking #{$request['booking_id']} at {$request['dorm_name']} has been completed. Thank you for staying with us!";
    
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
        'message' => 'Checkout completed successfully. Tenant moved to past tenants.',
        'data' => [
            'request_id' => $request_id,
            'booking_id' => (int)$request['booking_id'],
            'status' => 'completed',
            'processed_at' => date('Y-m-d H:i:s')
        ]
    ]);

} catch (Exception $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    error_log('Complete checkout error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'An error occurred while completing the checkout']);
}
