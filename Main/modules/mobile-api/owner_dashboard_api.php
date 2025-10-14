<?php
require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/cors.php';

header('Content-Type: application/json');

if (!isset($_GET['owner_email'])) {
    http_response_code(400);
    echo json_encode(['error' => 'Owner email required']);
    exit;
}

$owner_email = $_GET['owner_email'];

try {
    // Get owner ID
    $stmt = $pdo->prepare("SELECT user_id FROM users WHERE email = ? AND role = 'owner'");
    $stmt->execute([$owner_email]);
    $owner = $stmt->fetch();

    if (!$owner) {
        http_response_code(404);
        echo json_encode(['error' => 'Owner not found']);
        exit;
    }

    $owner_id = $owner['user_id'];

    // Fetch dashboard statistics
    $stats = [
        'rooms' => $pdo->prepare("
            SELECT COUNT(*) FROM rooms r 
            JOIN dormitories d ON r.dorm_id = d.dorm_id 
            WHERE d.owner_id = ?
        ")->execute([$owner_id])->fetchColumn(),

        'tenants' => $pdo->prepare("
            SELECT COUNT(DISTINCT b.student_id) 
            FROM bookings b
            JOIN rooms r ON b.room_id = r.room_id
            JOIN dormitories d ON r.dorm_id = d.dorm_id
            WHERE d.owner_id = ? AND b.status = 'active'
        ")->execute([$owner_id])->fetchColumn(),

        'monthly_revenue' => $pdo->prepare("
            SELECT COALESCE(SUM(p.amount), 0)
            FROM payments p
            JOIN bookings b ON p.booking_id = b.booking_id
            JOIN rooms r ON b.room_id = r.room_id
            JOIN dormitories d ON r.dorm_id = d.dorm_id
            WHERE d.owner_id = ?
            AND p.status = 'paid'
            AND p.payment_date >= DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY)
        ")->execute([$owner_id])->fetchColumn(),

        'recent_activities' => $pdo->prepare("
            (SELECT 
                'payment' as type,
                p.amount,
                u.name as student_name,
                d.name as dorm_name,
                p.created_at
            FROM payments p
            JOIN bookings b ON p.booking_id = b.booking_id
            JOIN rooms r ON b.room_id = r.room_id
            JOIN dormitories d ON r.dorm_id = d.dorm_id
            JOIN users u ON b.student_id = u.user_id
            WHERE d.owner_id = ? AND p.status = 'paid'
            ORDER BY p.created_at DESC LIMIT 5)
            UNION
            (SELECT 
                'booking' as type,
                NULL as amount,
                u.name as student_name,
                d.name as dorm_name,
                b.created_at
            FROM bookings b
            JOIN rooms r ON b.room_id = r.room_id
            JOIN dormitories d ON r.dorm_id = d.dorm_id
            JOIN users u ON b.student_id = u.user_id
            WHERE d.owner_id = ?
            ORDER BY b.created_at DESC LIMIT 5)
            ORDER BY created_at DESC LIMIT 5
        ")->execute([$owner_id, $owner_id])->fetchAll(PDO::FETCH_ASSOC)
    ];

    echo json_encode([
        'ok' => true,
        'stats' => $stats,
        'owner_name' => $pdo->prepare("SELECT name FROM users WHERE user_id = ?")->execute([$owner_id])->fetchColumn()
    ]);

} catch (Exception $e) {
    error_log('Owner dashboard API error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['error' => 'Server error']);
}