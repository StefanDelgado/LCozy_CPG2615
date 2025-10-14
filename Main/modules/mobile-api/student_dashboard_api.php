<?php
require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/cors.php';

header('Content-Type: application/json');

if (!isset($_GET['student_email'])) {
    echo json_encode(['error' => 'Student email required']);
    exit;
}

$student_email = $_GET['student_email'];

try {
    // Get student ID
    $stmt = $pdo->prepare("SELECT user_id FROM users WHERE email = ? AND role = 'student'");
    $stmt->execute([$student_email]);
    $student = $stmt->fetch();

    if (!$student) {
        echo json_encode(['error' => 'Student not found']);
        exit;
    }

    $student_id = $student['user_id'];

    // Get stats
    $stats = [
        'active_reservations' => $pdo->prepare("
            SELECT COUNT(*) FROM bookings 
            WHERE student_id = ? AND status = 'approved'
        ")->execute([$student_id])->fetchColumn(),

        'payments_due' => $pdo->prepare("
            SELECT COALESCE(SUM(amount), 0)
            FROM payments 
            WHERE student_id = ? AND status = 'pending'
        ")->execute([$student_id])->fetchColumn(),

        'unread_messages' => $pdo->prepare("
            SELECT COUNT(*) FROM messages
            WHERE receiver_id = ? AND status = 'unread'
        ")->execute([$student_id])->fetchColumn(),

        'active_bookings' => $pdo->prepare("
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
        ")->execute([$student_id])->fetchAll(PDO::FETCH_ASSOC)
    ];

    echo json_encode([
        'ok' => true,
        'stats' => $stats
    ]);

} catch (Exception $e) {
    error_log('Student dashboard API error: ' . $e->getMessage());
    echo json_encode(['error' => 'Server error']);
}