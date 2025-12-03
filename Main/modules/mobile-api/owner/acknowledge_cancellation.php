<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

require_once '../../../config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['success' => false, 'error' => 'Invalid request method']);
    exit;
}

try {
    // Get request data
    $input = json_decode(file_get_contents('php://input'), true);
    
    $booking_id = isset($input['booking_id']) ? intval($input['booking_id']) : 0;
    $owner_email = isset($input['owner_email']) ? trim($input['owner_email']) : '';

    if (empty($booking_id) || empty($owner_email)) {
        echo json_encode(['success' => false, 'error' => 'Missing required fields']);
        exit;
    }

    // Get owner ID
    $stmt = $pdo->prepare("SELECT user_id FROM users WHERE email = ? AND role = 'owner'");
    $stmt->execute([$owner_email]);
    $owner = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$owner) {
        echo json_encode(['success' => false, 'error' => 'Owner not found']);
        exit;
    }

    $owner_id = $owner['user_id'];

    // Verify booking exists and belongs to this owner's dorm
    $stmt = $pdo->prepare("
        SELECT b.booking_id, b.status, b.cancellation_acknowledged, 
               d.owner_id, s.name as student_name
        FROM bookings b
        JOIN rooms r ON b.room_id = r.room_id
        JOIN dormitories d ON r.dorm_id = d.dorm_id
        JOIN users s ON b.student_id = s.user_id
        WHERE b.booking_id = ?
    ");
    $stmt->execute([$booking_id]);
    $booking = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$booking) {
        echo json_encode(['success' => false, 'error' => 'Booking not found']);
        exit;
    }

    // Verify owner owns this dorm
    if ($booking['owner_id'] != $owner_id) {
        echo json_encode(['success' => false, 'error' => 'Unauthorized: This booking is not from your dorm']);
        exit;
    }

    // Check if booking is in cancellation_requested status
    if ($booking['status'] !== 'cancellation_requested') {
        echo json_encode([
            'success' => false, 
            'error' => 'Booking is not pending cancellation. Current status: ' . $booking['status']
        ]);
        exit;
    }

    // Check if already acknowledged (shouldn't happen if status is cancellation_requested, but double-check)
    if ($booking['cancellation_acknowledged'] == 1) {
        echo json_encode(['success' => false, 'error' => 'Cancellation already acknowledged']);
        exit;
    }

    // Begin transaction
    $pdo->beginTransaction();

    try {
        // Acknowledge the cancellation and change status to cancelled
        $stmt = $pdo->prepare("
            UPDATE bookings 
            SET status = 'cancelled',
                cancellation_acknowledged = 1,
                cancellation_acknowledged_at = NOW(),
                cancellation_acknowledged_by = ?,
                notes = CONCAT(
                    COALESCE(notes, ''),
                    '\nCancellation confirmed by owner on ', DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s')
                ),
                updated_at = NOW()
            WHERE booking_id = ?
        ");
        $stmt->execute([$owner_id, $booking_id]);

        // Cancel any pending payments associated with this booking
        $stmt = $pdo->prepare("
            UPDATE payments 
            SET status = 'rejected',
                notes = CONCAT(
                    COALESCE(notes, ''),
                    IF(COALESCE(notes, '') != '', '\n', ''),
                    'Payment cancelled due to booking cancellation confirmed on ', DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s')
                ),
                updated_at = NOW()
            WHERE booking_id = ? AND status IN ('pending', 'submitted')
        ");
        $stmt->execute([$booking_id]);

        $pdo->commit();

        echo json_encode([
            'success' => true,
            'message' => "Cancellation confirmed for {$booking['student_name']}'s booking",
            'booking_id' => $booking_id
        ]);

    } catch (Exception $e) {
        $pdo->rollBack();
        throw $e;
    }

} catch (PDOException $e) {
    error_log('Database error in acknowledge_cancellation.php: ' . $e->getMessage());
    error_log('Stack trace: ' . $e->getTraceAsString());
    echo json_encode(['success' => false, 'error' => 'Database error: ' . $e->getMessage()]);
} catch (Exception $e) {
    error_log('Error in acknowledge_cancellation.php: ' . $e->getMessage());
    error_log('Stack trace: ' . $e->getTraceAsString());
    echo json_encode(['success' => false, 'error' => 'Error: ' . $e->getMessage()]);
}
