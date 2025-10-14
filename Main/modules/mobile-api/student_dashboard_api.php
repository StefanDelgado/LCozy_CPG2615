<?php
require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/cors.php';

header('Content-Type: application/json');
error_reporting(E_ALL);
ini_set('display_errors', 1);

if (!isset($_GET['student_email'])) {
    echo json_encode(['error' => 'Student email required']);
    exit;
}

try {
    // Get student ID
    $stmt = $pdo->prepare("SELECT user_id FROM users WHERE email = ? AND role = 'student'");
    $stmt->execute([$_GET['student_email']]);
    $student = $stmt->fetch();

    if (!$student) {
        echo json_encode(['error' => 'Student not found']);
        exit;
    }

    $student_id = $student['user_id'];

    // Get active reservations count
    $reservationsStmt = $pdo->prepare("
        SELECT COUNT(*) 
        FROM bookings 
        WHERE student_id = ? AND status = 'approved'
    ");
    $reservationsStmt->execute([$student_id]);
    $active_reservations = $reservationsStmt->fetchColumn();

    // Get pending payments
    $paymentsStmt = $pdo->prepare("
        SELECT COALESCE(SUM(amount), 0) 
        FROM payments 
        WHERE booking_id IN (SELECT booking_id FROM bookings WHERE student_id = ?)
        AND status = 'pending'
    ");
    $paymentsStmt->execute([$student_id]);
    $payments_due = $paymentsStmt->fetchColumn();

    // Get unread messages count
    $messagesStmt = $pdo->prepare("
        SELECT COUNT(*) 
        FROM messages 
        WHERE receiver_id = ? AND is_read = 0
    ");
    $messagesStmt->execute([$student_id]);
    $unread_messages = $messagesStmt->fetchColumn();

    // Get active bookings
    $bookingsStmt = $pdo->prepare("
        SELECT 
            b.booking_id,
            d.name as dorm_name,
            r.room_type,
            b.status,
            b.start_date,
            b.end_date,
            u.name as owner_name
        FROM bookings b
        JOIN rooms r ON b.room_id = r.room_id
        JOIN dormitories d ON r.dorm_id = d.dorm_id
        JOIN users u ON d.owner_id = u.user_id
        WHERE b.student_id = ?
        ORDER BY b.created_at DESC
        LIMIT 5
    ");
    $bookingsStmt->execute([$student_id]);
    $active_bookings = $bookingsStmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        'ok' => true,
        'stats' => [
            'active_reservations' => (int)$active_reservations,
            'payments_due' => (float)$payments_due,
            'unread_messages' => (int)$unread_messages,
            'active_bookings' => $active_bookings
        ]
    ]);

} catch (Exception $e) {
    error_log('Student dashboard API error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'ok' => false,
        'error' => 'Server error',
        'debug' => $e->getMessage()
    ]);
}