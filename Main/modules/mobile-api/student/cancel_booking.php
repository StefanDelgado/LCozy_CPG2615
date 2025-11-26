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
    $cancellation_reason = isset($input['cancellation_reason']) ? trim($input['cancellation_reason']) : '';

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
        SELECT b.booking_id, b.status, b.student_id,
               COUNT(p.payment_id) as payment_count,
               SUM(CASE WHEN p.status IN ('paid', 'verified') THEN 1 ELSE 0 END) as paid_payments
        FROM bookings b
        LEFT JOIN payments p ON b.booking_id = p.booking_id
        WHERE b.booking_id = ?
        GROUP BY b.booking_id, b.status, b.student_id
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

    // Check if booking can be cancelled
    $current_status = $booking['status'];
    $paid_payments = intval($booking['paid_payments']);

    // Allow cancellation only for pending or approved status, and no paid payments
    if (!in_array($current_status, ['pending', 'approved'])) {
        echo json_encode([
            'success' => false, 
            'error' => "Cannot cancel booking with status: $current_status. Only pending or approved bookings can be cancelled."
        ]);
        exit;
    }

    // Check if any payments have been made
    if ($paid_payments > 0) {
        echo json_encode([
            'success' => false, 
            'error' => 'Cannot cancel booking: Payment has already been made. Please request checkout instead.'
        ]);
        exit;
    }

    // Begin transaction
    $pdo->beginTransaction();

    try {
        // Update booking status to cancelled
        $stmt = $pdo->prepare("
            UPDATE bookings 
            SET status = 'cancelled',
                notes = CONCAT(
                    COALESCE(notes, ''),
                    IF(COALESCE(notes, '') != '', '\n', ''),
                    'Cancelled by student on ', DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s'), 
                    IF(? != '', CONCAT('. Reason: ', ?), '')
                ),
                updated_at = NOW()
            WHERE booking_id = ?
        ");
        $stmt->execute([$cancellation_reason, $cancellation_reason, $booking_id]);

        // Cancel any pending payments associated with this booking
        // Note: Only update status if it's not 'cancelled' already
        $stmt = $pdo->prepare("
            UPDATE payments 
            SET status = 'rejected',
                notes = CONCAT(
                    COALESCE(notes, ''),
                    IF(COALESCE(notes, '') != '', '\n', ''),
                    'Payment cancelled due to booking cancellation on ', DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s')
                ),
                updated_at = NOW()
            WHERE booking_id = ? AND status IN ('pending', 'submitted')
        ");
        $stmt->execute([$booking_id]);

        // Note: Room availability is managed separately based on active bookings
        // We don't automatically set rooms to vacant when a booking is cancelled
        // because there might be other active bookings for the same room (shared rooms)

        $pdo->commit();

        echo json_encode([
            'success' => true,
            'message' => 'Booking cancelled successfully',
            'booking_id' => $booking_id
        ]);

    } catch (Exception $e) {
        $pdo->rollBack();
        throw $e;
    }

} catch (PDOException $e) {
    error_log('Database error in cancel_booking.php: ' . $e->getMessage());
    error_log('Stack trace: ' . $e->getTraceAsString());
    echo json_encode(['success' => false, 'error' => 'Database error: ' . $e->getMessage()]);
} catch (Exception $e) {
    error_log('Error in cancel_booking.php: ' . $e->getMessage());
    error_log('Stack trace: ' . $e->getTraceAsString());
    echo json_encode(['success' => false, 'error' => 'Error: ' . $e->getMessage()]);
}
