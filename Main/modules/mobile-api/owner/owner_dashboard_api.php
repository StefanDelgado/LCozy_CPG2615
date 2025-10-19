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

    $owner_id = $owner['user_id'];

    // Get total rooms
    $roomsStmt = $pdo->prepare("
        SELECT COUNT(*) 
        FROM rooms r
        JOIN dormitories d ON r.dorm_id = d.dorm_id
        WHERE d.owner_id = ?
    ");
    $roomsStmt->execute([$owner_id]);
    $total_rooms = $roomsStmt->fetchColumn();

    // Get active tenants
    $tenantsStmt = $pdo->prepare("
        SELECT COUNT(DISTINCT b.student_id)
        FROM bookings b
        JOIN rooms r ON b.room_id = r.room_id
        JOIN dormitories d ON r.dorm_id = d.dorm_id
        WHERE d.owner_id = ? AND b.status = 'approved'
    ");
    $tenantsStmt->execute([$owner_id]);
    $total_tenants = $tenantsStmt->fetchColumn();

    // Get monthly revenue
    $revenueStmt = $pdo->prepare("
        SELECT COALESCE(SUM(p.amount), 0)
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

    // Get recent activities
    $activitiesStmt = $pdo->prepare("
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
        
        UNION ALL
        
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
        WHERE d.owner_id = ? AND b.status = 'pending'
        ORDER BY b.created_at DESC LIMIT 5)
        
        ORDER BY created_at DESC LIMIT 5
    ");
    $activitiesStmt->execute([$owner_id, $owner_id]);
    $recent_activities = $activitiesStmt->fetchAll(PDO::FETCH_ASSOC);

    // Get recent bookings (last 5)
    $recentBookingsStmt = $pdo->prepare("
        SELECT 
            b.booking_id,
            b.status,
            u.name as student_name,
            d.name as dorm_name,
            r.room_number,
            b.created_at
        FROM bookings b
        JOIN rooms r ON b.room_id = r.room_id
        JOIN dormitories d ON r.dorm_id = d.dorm_id
        JOIN users u ON b.student_id = u.user_id
        WHERE d.owner_id = ?
        ORDER BY b.created_at DESC
        LIMIT 5
    ");
    $recentBookingsStmt->execute([$owner_id]);
    $recent_bookings = $recentBookingsStmt->fetchAll(PDO::FETCH_ASSOC);

    // Get recent payments (last 5)
    $recentPaymentsStmt = $pdo->prepare("
        SELECT 
            p.payment_id,
            p.amount,
            p.status,
            u.name as tenant_name,
            d.name as dorm_name,
            p.created_at
        FROM payments p
        JOIN bookings b ON p.booking_id = b.booking_id
        JOIN rooms r ON b.room_id = r.room_id
        JOIN dormitories d ON r.dorm_id = d.dorm_id
        JOIN users u ON b.student_id = u.user_id
        WHERE d.owner_id = ?
        ORDER BY p.created_at DESC
        LIMIT 5
    ");
    $recentPaymentsStmt->execute([$owner_id]);
    $recent_payments = $recentPaymentsStmt->fetchAll(PDO::FETCH_ASSOC);

    // Get recent messages (last 5)
    $recentMessagesStmt = $pdo->prepare("
        SELECT 
            m.message_id,
            m.message,
            m.sent_at,
            m.read_at,
            u.name as sender_name
        FROM messages m
        JOIN users u ON m.sender_id = u.user_id
        WHERE m.receiver_id = ?
        ORDER BY m.sent_at DESC
        LIMIT 5
    ");
    $recentMessagesStmt->execute([$owner_id]);
    $recent_messages = $recentMessagesStmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        'success' => true,
        'data' => [
            'stats' => [
                'rooms' => (int)$total_rooms,
                'tenants' => (int)$total_tenants,
                'monthly_revenue' => (float)$monthly_revenue,
                'recent_activities' => $recent_activities
            ],
            'recent_bookings' => $recent_bookings,
            'recent_payments' => $recent_payments,
            'recent_messages' => $recent_messages
        ]
    ]);

} catch (Exception $e) {
    error_log('Owner dashboard API error: ' . $e->getMessage());
    error_log('Stack trace: ' . $e->getTraceAsString());
    
    // Detailed error for debugging (remove in production)
    echo json_encode([
        'error' => 'Server error',
        'details' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine()
    ]);
}