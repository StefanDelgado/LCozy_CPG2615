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
            SELECT 
                p.amount,
                b.booking_type,
                r.capacity,
                r.price as room_base_price
            FROM payments p
            LEFT JOIN bookings b ON p.booking_id = b.booking_id
            LEFT JOIN rooms r ON b.room_id = r.room_id
            WHERE p.student_id = ? 
            AND p.status IN ('pending', 'overdue')
        ");
        $paymentsStmt->execute([$student_id]);
        $pending_payments = $paymentsStmt->fetchAll(PDO::FETCH_ASSOC);
        
        // Calculate total with proper shared room pricing
        $payments_due = 0;
        foreach ($pending_payments as $payment) {
            $booking_type = strtolower($payment['booking_type'] ?? 'shared');
            $amount = (float)$payment['amount'];
            
            if ($booking_type === 'shared' && $payment['capacity'] > 0 && $payment['room_base_price'] > 0) {
                $amount = $payment['room_base_price'] / $payment['capacity'];
            }
            
            $payments_due += $amount;
        }
        
        $payments_due = round($payments_due, 2);
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
            b.booking_type,
            b.start_date,
            b.end_date,
            b.created_at,
            b.owner_contract_copy,
            b.student_contract_copy,
            b.owner_contract_uploaded_at,
            b.student_contract_uploaded_at,
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
        AND b.status IN ('pending', 'approved', 'active', 'completed', 'cancelled', 'rejected', 'ongoing', 'checkout_requested', 'checkout_approved')
        ORDER BY b.created_at DESC
        LIMIT 10
    ");
    $bookingsStmt->execute([$student_id]);
    $active_bookings = $bookingsStmt->fetchAll(PDO::FETCH_ASSOC);

    // Format the bookings data
    $formatted_bookings = array_map(function($booking) {
        // Calculate display price based on booking type
        $booking_type = strtolower($booking['booking_type'] ?? 'shared');
        $display_price = (float)$booking['price'];
        
        // If shared room, divide by capacity
        if ($booking_type === 'shared' && $booking['capacity'] > 0) {
            $display_price = $booking['price'] / $booking['capacity'];
        }
        
        // Round to 2 decimal places
        $display_price = round($display_price, 2);
        
        return [
            'booking_id' => (int)$booking['booking_id'],
            'status' => $booking['status'],
            'booking_type' => $booking['booking_type'],
            'start_date' => $booking['start_date'],
            'end_date' => $booking['end_date'],
            'created_at' => $booking['created_at'],
            'days_until_checkin' => (int)$booking['days_until_checkin'],
            'owner_contract_copy' => $booking['owner_contract_copy'],
            'student_contract_copy' => $booking['student_contract_copy'],
            'owner_contract_uploaded_at' => $booking['owner_contract_uploaded_at'],
            'student_contract_uploaded_at' => $booking['student_contract_uploaded_at'],
            'dorm' => [
                'dorm_id' => (int)$booking['dorm_id'],
                'name' => $booking['dorm_name'],
                'address' => $booking['dorm_address'],
                'cover_image' => $booking['cover_image'] ? 
                    SITE_URL . '/uploads/' . $booking['cover_image'] : null,
            ],
            'room' => [
                'room_id' => (int)$booking['room_id'],
                'room_type' => $booking['room_type'],
                'capacity' => (int)$booking['capacity'],
                'price' => $display_price,
            ],
            'owner' => [
                'owner_id' => (int)$booking['owner_id'],
                'name' => $booking['owner_name'],
                'email' => $booking['owner_email'],
            ]
        ];
    }, $active_bookings);

    // Get recent messages (last 5 unread)
    try {
        $messagesStmt = $pdo->prepare("
            SELECT 
                m.message_id,
                m.sender_id,
                m.body,
                m.created_at,
                m.urgency,
                u.name as sender_name,
                d.name as dorm_name,
                'message' as notification_type
            FROM messages m
            LEFT JOIN users u ON m.sender_id = u.user_id
            LEFT JOIN dormitories d ON m.dorm_id = d.dorm_id
            WHERE m.receiver_id = ? 
            AND m.read_at IS NULL
            ORDER BY m.created_at DESC
            LIMIT 5
        ");
        $messagesStmt->execute([$student_id]);
        $recent_messages = $messagesStmt->fetchAll(PDO::FETCH_ASSOC);
    } catch (PDOException $e) {
        error_log('Messages query error: ' . $e->getMessage());
        $recent_messages = [];
    }

    // Get recent booking updates (last 7 days)
    try {
        $bookingUpdatesStmt = $pdo->prepare("
            SELECT 
                b.booking_id,
                b.status,
                b.updated_at as created_at,
                d.name as dorm_name,
                r.room_type,
                'booking_update' as notification_type,
                CASE 
                    WHEN b.status = 'approved' THEN 'Your booking has been approved!'
                    WHEN b.status = 'rejected' THEN 'Your booking has been rejected'
                    WHEN b.status = 'checkout_approved' THEN 'Your checkout request has been approved'
                    WHEN b.status = 'checkout_requested' THEN 'Your checkout request is pending'
                    WHEN b.status = 'completed' THEN 'Your booking has been completed'
                    WHEN b.status = 'cancelled' THEN 'Your booking has been cancelled'
                    ELSE CONCAT('Booking status: ', b.status)
                END as body,
                CASE 
                    WHEN b.status IN ('rejected', 'cancelled') THEN 'urgent'
                    ELSE 'normal'
                END as urgency
            FROM bookings b
            JOIN rooms r ON b.room_id = r.room_id
            JOIN dormitories d ON r.dorm_id = d.dorm_id
            WHERE b.student_id = ?
            AND b.updated_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
            AND b.status IN ('approved', 'rejected', 'checkout_approved', 'checkout_requested', 'completed', 'cancelled')
            ORDER BY b.updated_at DESC
            LIMIT 5
        ");
        $bookingUpdatesStmt->execute([$student_id]);
        $booking_updates = $bookingUpdatesStmt->fetchAll(PDO::FETCH_ASSOC);
    } catch (PDOException $e) {
        error_log('Booking updates query error: ' . $e->getMessage());
        $booking_updates = [];
    }

    // Combine and sort notifications
    $all_notifications = array_merge($recent_messages, $booking_updates);
    usort($all_notifications, function($a, $b) {
        return strtotime($b['created_at']) - strtotime($a['created_at']);
    });
    $all_notifications = array_slice($all_notifications, 0, 5);

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
            'active_bookings' => $formatted_bookings,
            'recent_messages' => $all_notifications
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