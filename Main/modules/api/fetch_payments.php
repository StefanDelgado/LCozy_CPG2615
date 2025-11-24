<?php
require_once __DIR__ . '/../../auth/auth.php';
require_once __DIR__ . '/../../config.php';

header('Content-Type: application/json');

if (!isset($_SESSION['user'])) {
    echo json_encode(['error' => 'Not logged in']);
    exit;
}

$user = $_SESSION['user'];
$role = $user['role'];
$user_id = $user['user_id'];

// 🕒 Automatically mark overdue payments before fetching
$pdo->exec("
    UPDATE payments 
    SET status = 'overdue' 
    WHERE status IN ('pending', 'submitted') 
      AND due_date < CURDATE()
");

// Fetch payments based on user role
switch ($role) {
    case 'owner':
        $sql = "
            SELECT 
                p.payment_id,
                p.amount,
                p.status,
                p.due_date,
                p.payment_date,
                p.receipt_image,
                p.created_at,
                u.user_id AS student_id,
                u.name AS student_name,
                d.name AS dorm_name,
                r.room_type,
                r.capacity,
                r.price as room_base_price,
                b.booking_type
            FROM payments p
            JOIN bookings b ON p.booking_id = b.booking_id
            JOIN rooms r ON b.room_id = r.room_id
            JOIN dormitories d ON r.dorm_id = d.dorm_id
            JOIN users u ON b.student_id = u.user_id
            WHERE d.owner_id = ?
            ORDER BY 
                CASE 
                    WHEN p.status = 'submitted' THEN 1
                    WHEN p.status = 'pending' THEN 2
                    WHEN p.status = 'overdue' THEN 3
                    WHEN p.status = 'paid' THEN 4
                    ELSE 5
                END,
                p.due_date ASC
        ";
        $params = [$user_id];
        break;

    case 'student':
        $sql = "
            SELECT 
                p.payment_id, p.amount, p.status, p.due_date, p.payment_date, 
                d.name AS dorm_name, r.room_type
            FROM payments p
            JOIN bookings b ON p.booking_id = b.booking_id
            JOIN rooms r ON b.room_id = r.room_id
            JOIN dormitories d ON r.dorm_id = d.dorm_id
            WHERE b.student_id = ?
            ORDER BY p.due_date ASC
        ";
        $params = [$user_id];
        break;

    case 'admin':
        $sql = "
            SELECT 
                p.payment_id, p.amount, p.status, p.due_date, p.payment_date,
                u.name AS student_name, d.name AS dorm_name, r.room_type,
                o.name AS owner_name
            FROM payments p
            JOIN bookings b ON p.booking_id = b.booking_id
            JOIN rooms r ON b.room_id = r.room_id
            JOIN dormitories d ON r.dorm_id = d.dorm_id
            JOIN users u ON b.student_id = u.user_id
            JOIN users o ON d.owner_id = o.user_id
            ORDER BY p.due_date ASC
        ";
        $params = [];
        break;

    default:
        echo json_encode([]);
        exit;
}

$stmt = $pdo->prepare($sql);
$stmt->execute($params);
$payments = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Calculate display price for owner role based on booking type
if ($role === 'owner') {
    foreach ($payments as &$payment) {
        $booking_type = strtolower($payment['booking_type'] ?? 'shared');
        $display_amount = $payment['amount'];
        
        // If shared room, divide by capacity
        if ($booking_type === 'shared' && isset($payment['capacity']) && $payment['capacity'] > 0) {
            $display_amount = $payment['room_base_price'] / $payment['capacity'];
        }
        
        // Round to 2 decimal places and update amount
        $payment['amount'] = round($display_amount, 2);
        $payment['display_amount'] = round($display_amount, 2);
    }
}

echo json_encode($payments);
