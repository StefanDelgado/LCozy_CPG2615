<?php
require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/cors.php';

header('Content-Type: application/json');
error_reporting(E_ALL);
ini_set('display_errors', 1);

if (!isset($_GET['owner_email'])) {
    echo json_encode(['error' => 'Owner email required']);
    exit;
}

$owner_email = $_GET['owner_email'];

try {
    // Get owner details
    $stmt = $pdo->prepare("SELECT user_id FROM users WHERE email = ? AND role = 'owner'");
    $stmt->execute([$owner_email]);
    $owner = $stmt->fetch();

    if (!$owner) {
        echo json_encode(['error' => 'Owner not found']);
        exit;
    }

    $owner_id = $owner['user_id'];

    // Get monthly revenue
    $revenueStmt = $pdo->prepare("
        SELECT COALESCE(SUM(p.amount), 0) as monthly_revenue
        FROM payments p
        JOIN bookings b ON p.booking_id = b.booking_id
        JOIN rooms r ON b.room_id = r.room_id
        JOIN dormitories d ON r.dorm_id = d.dorm_id
        WHERE d.owner_id = ? 
        AND p.status = 'paid'
        AND p.payment_date >= DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY)
    ");
    $revenueStmt->execute([$owner_id]);
    $monthly_revenue = $revenueStmt->fetchColumn();

    // Get pending amount
    $pendingStmt = $pdo->prepare("
        SELECT COALESCE(SUM(p.amount), 0) as pending_amount
        FROM payments p
        JOIN bookings b ON p.booking_id = b.booking_id
        JOIN rooms r ON b.room_id = r.room_id
        JOIN dormitories d ON r.dorm_id = d.dorm_id
        WHERE d.owner_id = ? 
        AND p.status IN ('pending', 'submitted')
    ");
    $pendingStmt->execute([$owner_id]);
    $pending_amount = $pendingStmt->fetchColumn();

    // Get payments list
    $paymentsStmt = $pdo->prepare("
        SELECT 
            p.payment_id,
            u.name as tenant_name,
            d.name as dorm_name,
            r.room_type,
            p.amount,
            p.status,
            DATE_FORMAT(p.due_date, '%Y-%m-%d') as due_date,
            DATE_FORMAT(p.payment_date, '%Y-%m-%d') as payment_date,
            p.receipt_image,
            DATE_FORMAT(p.created_at, '%Y-%m-%d %H:%i:%s') as created_at
        FROM payments p
        JOIN bookings b ON p.booking_id = b.booking_id
        JOIN rooms r ON b.room_id = r.room_id
        JOIN dormitories d ON r.dorm_id = d.dorm_id
        JOIN users u ON b.student_id = u.user_id
        WHERE d.owner_id = ?
        ORDER BY p.created_at DESC
    ");
    $paymentsStmt->execute([$owner_id]);
    $payments = $paymentsStmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        'ok' => true,
        'stats' => [
            'monthly_revenue' => floatval($monthly_revenue),
            'pending_amount' => floatval($pending_amount)
        ],
        'payments' => $payments
    ]);

} catch (Exception $e) {
    error_log('Owner payments API error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'ok' => false,
        'error' => 'Server error',
        'debug' => $e->getMessage()
    ]);
}