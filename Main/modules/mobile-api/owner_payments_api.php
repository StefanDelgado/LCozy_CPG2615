<?php
require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/cors.php';

header('Content-Type: application/json');

if (!isset($_GET['owner_email'])) {
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
        echo json_encode(['error' => 'Owner not found']);
        exit;
    }

    $owner_id = $owner['user_id'];

    // Get payment statistics
    $stats = [
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

        'pending_amount' => $pdo->prepare("
            SELECT COALESCE(SUM(p.amount), 0)
            FROM payments p
            JOIN bookings b ON p.booking_id = b.booking_id
            JOIN rooms r ON b.room_id = r.room_id
            JOIN dormitories d ON r.dorm_id = d.dorm_id
            WHERE d.owner_id = ? AND p.status IN ('pending', 'submitted')
        ")->execute([$owner_id])->fetchColumn()
    ];

    // Get payments list
    $payments = $pdo->prepare("
        SELECT 
            p.payment_id,
            u.name AS tenant_name,
            d.name AS dorm_name,
            r.room_type,
            p.amount,
            p.status,
            p.due_date,
            p.payment_date,
            p.payment_method,
            p.receipt_image,
            p.created_at
        FROM payments p
        JOIN bookings b ON p.booking_id = b.booking_id
        JOIN rooms r ON b.room_id = r.room_id
        JOIN dormitories d ON r.dorm_id = d.dorm_id
        JOIN users u ON b.student_id = u.user_id
        WHERE d.owner_id = ?
        ORDER BY p.created_at DESC
    ")->execute([$owner_id])->fetchAll();

    echo json_encode([
        'ok' => true,
        'stats' => $stats,
        'payments' => $payments
    ]);

} catch (Exception $e) {
    error_log('Owner payments API error: ' . $e->getMessage());
    echo json_encode(['error' => 'Server error']);
}