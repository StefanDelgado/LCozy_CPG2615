<?php
require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/cors.php';

header('Content-Type: application/json');
error_reporting(E_ALL);
ini_set('display_errors', 1);

if (!isset($_GET['student_email'])) {
    echo json_encode(['ok' => false, 'error' => 'Student email required']);
    exit;
}

try {
    // Get student ID
    $stmt = $pdo->prepare("SELECT user_id FROM users WHERE email = ? AND role = 'student'");
    $stmt->execute([$_GET['student_email']]);
    $student = $stmt->fetch();

    if (!$student) {
        echo json_encode(['ok' => false, 'error' => 'Student not found']);
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

    // Get pending payments with proper error handling
    try {
        $paymentsStmt = $pdo->prepare("
            SELECT COALESCE(SUM(amount), 0) 
            FROM payments 
            WHERE student_id = ? AND status = 'pending'
        ");
        $paymentsStmt->execute([$student_id]);
        $payments_due = $paymentsStmt->fetchColumn();
    } catch (PDOException $e) {
        $payments_due = 0;
    }

    // Get unread messages with proper error handling
    try {
        $messagesStmt = $pdo->prepare("
            SELECT COUNT(*) 
            FROM messages 
            WHERE receiver_id = ? AND (status = 'unread' OR status IS NULL)
        ");
        $messagesStmt->execute([$student_id]);
        $unread_messages = $messagesStmt->fetchColumn();
    } catch (PDOException $e) {
        $unread_messages = 0;
    }

    // Get active bookings
    $bookingsStmt = $pdo->prepare("
        SELECT 
            b.booking_id,
            b.status,
            b.start_date,
            b.end_date,
            d.name as dorm_name,
            r.room_type,
            u.name as owner_name
        FROM bookings b
        JOIN rooms r ON b.room_id = r.room_id
        JOIN dormitories d ON r.dorm_id = d.dorm_id
        JOIN users u ON d.owner_id = u.user_id
        WHERE b.student_id = ? AND b.status IN ('pending', 'approved')
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