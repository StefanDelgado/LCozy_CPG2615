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

    // Check if booking is cancelled
    if ($booking['status'] !== 'cancelled') {
        echo json_encode(['success' => false, 'error' => 'Booking is not cancelled']);
        exit;
    }

    // Check if already acknowledged
    if ($booking['cancellation_acknowledged'] == 1) {
        echo json_encode(['success' => false, 'error' => 'Cancellation already acknowledged']);
        exit;
    }

    // Acknowledge the cancellation
    $stmt = $pdo->prepare("
        UPDATE bookings 
        SET cancellation_acknowledged = 1,
            cancellation_acknowledged_at = NOW(),
            cancellation_acknowledged_by = ?,
            updated_at = NOW()
        WHERE booking_id = ?
    ");
    $stmt->execute([$owner_id, $booking_id]);

    echo json_encode([
        'success' => true,
        'message' => "Cancellation acknowledged for {$booking['student_name']}'s booking",
        'booking_id' => $booking_id
    ]);

} catch (PDOException $e) {
    error_log('Database error in acknowledge_cancellation.php: ' . $e->getMessage());
    error_log('Stack trace: ' . $e->getTraceAsString());
    echo json_encode(['success' => false, 'error' => 'Database error: ' . $e->getMessage()]);
} catch (Exception $e) {
    error_log('Error in acknowledge_cancellation.php: ' . $e->getMessage());
    error_log('Stack trace: ' . $e->getTraceAsString());
    echo json_encode(['success' => false, 'error' => 'Error: ' . $e->getMessage()]);
}
