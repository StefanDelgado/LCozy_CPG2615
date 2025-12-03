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
    $student_email = isset($input['student_email']) ? trim($input['student_email']) : '';

    if (empty($booking_id) || empty($student_email)) {
        echo json_encode(['success' => false, 'error' => 'Missing required fields']);
        exit;
    }

    // Get student ID
    $stmt = $pdo->prepare("SELECT user_id FROM users WHERE email = ? AND role = 'student'");
    $stmt->execute([$student_email]);
    $student = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$student) {
        echo json_encode(['success' => false, 'error' => 'Student not found']);
        exit;
    }

    $student_id = $student['user_id'];

    // Get booking details and verify ownership
    $stmt = $pdo->prepare("
        SELECT b.booking_id, b.status, b.student_id
        FROM bookings b
        WHERE b.booking_id = ?
    ");
    $stmt->execute([$booking_id]);
    $booking = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$booking) {
        echo json_encode(['success' => false, 'error' => 'Booking not found']);
        exit;
    }

    // Verify student owns this booking
    if ($booking['student_id'] != $student_id) {
        echo json_encode(['success' => false, 'error' => 'Unauthorized: This is not your booking']);
        exit;
    }

    // Check if booking is in cancellation_requested status
    $current_status = $booking['status'];

    if ($current_status !== 'cancellation_requested') {
        echo json_encode([
            'success' => false, 
            'error' => "Cannot cancel cancellation request. Current status: $current_status. Only cancellation_requested bookings can be reverted."
        ]);
        exit;
    }

    // Begin transaction
    $pdo->beginTransaction();

    try {
        // Revert booking status back to pending
        $stmt = $pdo->prepare("
            UPDATE bookings 
            SET status = 'pending',
                notes = CONCAT(
                    COALESCE(notes, ''),
                    '\nCancellation request cancelled by student on ', 
                    DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s')
                ),
                updated_at = NOW()
            WHERE booking_id = ?
        ");
        $stmt->execute([$booking_id]);

        $pdo->commit();

        echo json_encode([
            'success' => true,
            'message' => 'Cancellation request cancelled successfully. Booking reverted to pending status.',
            'booking_id' => $booking_id,
            'status' => 'pending'
        ]);

    } catch (Exception $e) {
        $pdo->rollBack();
        throw $e;
    }

} catch (PDOException $e) {
    error_log('Database error in cancel_cancellation_request.php: ' . $e->getMessage());
    error_log('Stack trace: ' . $e->getTraceAsString());
    echo json_encode(['success' => false, 'error' => 'Database error: ' . $e->getMessage()]);
} catch (Exception $e) {
    error_log('Error in cancel_cancellation_request.php: ' . $e->getMessage());
    error_log('Stack trace: ' . $e->getTraceAsString());
    echo json_encode(['success' => false, 'error' => 'Error: ' . $e->getMessage()]);
}
