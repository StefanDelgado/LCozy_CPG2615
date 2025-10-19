<?php
require_once __DIR__ . '/../../../config.php';
require_once __DIR__ . '/../shared/cors.php';

header('Content-Type: application/json');
error_reporting(E_ALL);
ini_set('display_errors', 0); // Don't show errors in production

if (!isset($_GET['student_email'])) {
    http_response_code(400);
    echo json_encode(['ok' => false, 'error' => 'Student email required']);
    exit;
}

$student_email = trim($_GET['student_email']);

try {
    // Get student ID and verify they exist
    $stmt = $pdo->prepare("SELECT user_id, name FROM users WHERE email = ? AND role = 'student'");
    $stmt->execute([$student_email]);
    $student = $stmt->fetch();

    if (!$student) {
        http_response_code(404);
        echo json_encode(['ok' => false, 'error' => 'Student not found']);
        exit;
    }

    $student_id = $student['user_id'];
    $student_name = $student['name'];

    // Get active reservations count
    $reservationsStmt = $pdo->prepare("
        SELECT COUNT(*) 
        FROM bookings 
        WHERE student_id = ? 
        AND status IN ('approved', 'pending')
    ");
    $reservationsStmt->execute([$student_id]);
    $active_reservations = (int)$reservationsStmt->fetchColumn();

    // Get pending payments amount
    try {
        $paymentsStmt = $pdo->prepare("
            SELECT COALESCE(SUM(amount), 0) 
            FROM payments 
            WHERE student_id = ? 
            AND status IN ('pending', 'overdue')
        ");
        $paymentsStmt->execute([$student_id]);
        $payments_due = (float)$paymentsStmt->fetchColumn();
    } catch (PDOException $e) {
        error_log('Payment query error: ' . $e->getMessage());
        $payments_due = 0;
    }

    // Get unread messages count
    try {
        $messagesStmt = $pdo->prepare("
            SELECT COUNT(*) 
            FROM messages 
            WHERE receiver_id = ? 
            AND read_at IS NULL
        ");
        $messagesStmt->execute([$student_id]);
        $unread_messages = (int)$messagesStmt->fetchColumn();
    } catch (PDOException $e) {
        error_log('Messages query error: ' . $e->getMessage());
        $unread_messages = 0;
    }

    // Get active bookings with details
    $bookingsStmt = $pdo->prepare("
        SELECT 
            b.booking_id,
            b.status,
            b.start_date,
            b.end_date,
            b.created_at,
            d.dorm_id,
            d.name as dorm_name,
            d.address as dorm_address,
            d.cover_image,
            r.room_id,
            r.room_type,
            r.capacity,
            r.price,
            u.user_id as owner_id,
            u.name as owner_name,
            u.email as owner_email,
            DATEDIFF(b.start_date, CURRENT_DATE) as days_until_checkin
        FROM bookings b
        JOIN rooms r ON b.room_id = r.room_id
        JOIN dormitories d ON r.dorm_id = d.dorm_id
        JOIN users u ON d.owner_id = u.user_id
        WHERE b.student_id = ? 
        AND b.status IN ('pending', 'approved')
        ORDER BY b.created_at DESC
        LIMIT 10
    ");
    $bookingsStmt->execute([$student_id]);
    $active_bookings = $bookingsStmt->fetchAll(PDO::FETCH_ASSOC);

    // Format the bookings data
    $formatted_bookings = array_map(function($booking) {
        return [
            'booking_id' => (int)$booking['booking_id'],
            'status' => $booking['status'],
            'start_date' => $booking['start_date'],
            'end_date' => $booking['end_date'],
            'created_at' => $booking['created_at'],
            'days_until_checkin' => (int)$booking['days_until_checkin'],
            'dorm' => [
                'dorm_id' => (int)$booking['dorm_id'],
                'name' => $booking['dorm_name'],
                'address' => $booking['dorm_address'],
                'cover_image' => $booking['cover_image'] ? 
                    'http://cozydorms.life/uploads/dorms/' . $booking['cover_image'] : null,
            ],
            'room' => [
                'room_id' => (int)$booking['room_id'],
                'room_type' => $booking['room_type'],
                'capacity' => (int)$booking['capacity'],
                'price' => (float)$booking['price'],
            ],
            'owner' => [
                'owner_id' => (int)$booking['owner_id'],
                'name' => $booking['owner_name'],
                'email' => $booking['owner_email'],
            ]
        ];
    }, $active_bookings);

    // Return success response
    echo json_encode([
        'ok' => true,
        'student' => [
            'id' => (int)$student_id,
            'name' => $student_name,
            'email' => $student_email
        ],
        'stats' => [
            'active_reservations' => $active_reservations,
            'payments_due' => $payments_due,
            'unread_messages' => $unread_messages,
            'active_bookings' => $formatted_bookings
        ]
    ]);

} catch (PDOException $e) {
    error_log('Student dashboard API error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'ok' => false,
        'error' => 'Database error occurred'
    ]);
} catch (Exception $e) {
    error_log('Student dashboard API error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'ok' => false,
        'error' => 'Server error occurred'
    ]);
}