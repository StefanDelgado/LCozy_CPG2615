<?php
require_once __DIR__ . '/../../../config.php';
require_once __DIR__ . '/../shared/cors.php';

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

    // Fetch active tenants with their latest payment status
    $current_tenants = $pdo->prepare("
        SELECT 
            u.user_id,
            u.name AS tenant_name,
            u.email,
            u.phone,
            d.name AS dorm_name,
            r.room_type,
            r.room_number,
            b.booking_id,
            b.start_date,
            b.end_date,
            b.booking_type,
            r.price,
            (SELECT p.status 
             FROM payments p 
             WHERE p.booking_id = b.booking_id 
             ORDER BY p.created_at DESC 
             LIMIT 1) as payment_status,
            (SELECT p.payment_date 
             FROM payments p 
             WHERE p.booking_id = b.booking_id 
             ORDER BY p.created_at DESC 
             LIMIT 1) as last_payment_date,
            (SELECT p.due_date 
             FROM payments p 
             WHERE p.booking_id = b.booking_id 
             ORDER BY p.created_at DESC 
             LIMIT 1) as next_due_date
        FROM bookings b
        JOIN users u ON b.student_id = u.user_id
        JOIN rooms r ON b.room_id = r.room_id
        JOIN dormitories d ON r.dorm_id = d.dorm_id
        WHERE d.owner_id = ? 
    AND b.status IN ('approved', 'active', 'completed')
        AND b.end_date >= CURDATE()
        ORDER BY b.start_date DESC
    ");

    $past_tenants = $pdo->prepare("
        SELECT 
            u.name AS tenant_name,
            u.email,
            u.phone,
            d.name AS dorm_name,
            r.room_type,
            b.start_date,
            b.end_date
        FROM bookings b
        JOIN users u ON b.student_id = u.user_id
        JOIN rooms r ON b.room_id = r.room_id
        JOIN dormitories d ON r.dorm_id = d.dorm_id
        WHERE d.owner_id = ? 
        AND (b.status = 'completed' OR b.end_date < CURDATE())
        ORDER BY b.end_date DESC
    ");

    $current_tenants->execute([$owner['user_id']]);
    $past_tenants->execute([$owner['user_id']]);

    echo json_encode([
        'ok' => true,
        'current_tenants' => $current_tenants->fetchAll(),
        'past_tenants' => $past_tenants->fetchAll()
    ]);

} catch (Exception $e) {
    error_log('Owner tenants API error: ' . $e->getMessage());
    echo json_encode(['error' => 'Server error']);
}