<?php
require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/cors.php';

header('Content-Type: application/json');
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Check if PDO is initialized
if (!isset($pdo) || $pdo === null) {
    http_response_code(500);
    echo json_encode(['ok' => false, 'error' => 'Database connection not initialized']);
    exit;
}

// Get student email from query parameter
if (!isset($_GET['student_email'])) {
    http_response_code(400);
    echo json_encode(['ok' => false, 'error' => 'Student email required']);
    exit;
}

$student_email = $_GET['student_email'];

try {
    // Get student ID from email
    $stmt = $pdo->prepare("SELECT user_id FROM users WHERE email = ? AND role = 'student'");
    $stmt->execute([$student_email]);
    $student = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$student) {
        http_response_code(404);
        echo json_encode(['ok' => false, 'error' => 'Student not found']);
        exit;
    }

    $student_id = $student['user_id'];

    // Fetch payments with booking and room details
    $stmt = $pdo->prepare("
        SELECT 
            p.payment_id, 
            p.amount, 
            p.status, 
            p.payment_date, 
            p.due_date, 
            p.receipt_image, 
            p.notes,
            p.created_at,
            d.name AS dorm_name, 
            d.address AS dorm_address,
            r.room_type,
            r.room_number,
            b.booking_id, 
            b.start_date, 
            b.end_date,
            u.name AS owner_name,
            u.email AS owner_email,
            u.phone AS owner_phone
        FROM payments p
        JOIN bookings b ON p.booking_id = b.booking_id
        JOIN rooms r ON b.room_id = r.room_id
        JOIN dormitories d ON r.dorm_id = d.dorm_id
        LEFT JOIN users u ON p.owner_id = u.user_id
        WHERE p.student_id = ?
        ORDER BY p.created_at DESC
    ");

    $stmt->execute([$student_id]);
    $payments = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Calculate payment statistics
    $total_due = 0;
    $paid_amount = 0;
    $pending_count = 0;
    $overdue_count = 0;

    $current_date = date('Y-m-d');

    foreach ($payments as &$payment) {
        // Check if overdue
        $is_overdue = ($payment['status'] === 'pending' && $payment['due_date'] < $current_date);
        
        if ($payment['status'] === 'pending') {
            $total_due += $payment['amount'];
            $pending_count++;
            if ($is_overdue) {
                $overdue_count++;
            }
        } elseif ($payment['status'] === 'paid') {
            $paid_amount += $payment['amount'];
        }

        // Add computed fields
        $payment['is_overdue'] = $is_overdue;
        $payment['receipt_url'] = $payment['receipt_image'] 
            ? 'http://cozydorms.life/uploads/receipts/' . $payment['receipt_image']
            : null;

        // Format amounts
        $payment['amount'] = (float)$payment['amount'];
        
        // Calculate days until due or days overdue
        $due_timestamp = strtotime($payment['due_date']);
        $today_timestamp = strtotime($current_date);
        $days_diff = floor(($due_timestamp - $today_timestamp) / 86400);
        
        if ($payment['status'] === 'pending') {
            if ($days_diff > 0) {
                $payment['due_in_days'] = $days_diff;
                $payment['due_status'] = "$days_diff days left";
            } elseif ($days_diff === 0) {
                $payment['due_in_days'] = 0;
                $payment['due_status'] = "Due today";
            } else {
                $payment['due_in_days'] = $days_diff;
                $payment['due_status'] = abs($days_diff) . " days overdue";
            }
        } else {
            $payment['due_in_days'] = null;
            $payment['due_status'] = null;
        }
    }

    echo json_encode([
        'ok' => true,
        'statistics' => [
            'pending_count' => $pending_count,
            'overdue_count' => $overdue_count,
            'total_due' => $total_due,
            'paid_amount' => $paid_amount,
            'total_payments' => count($payments)
        ],
        'payments' => $payments
    ]);

} catch (PDOException $e) {
    error_log('Student payments API PDO error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'ok' => false, 
        'error' => 'Database error', 
        'debug' => $e->getMessage()
    ]);
} catch (Exception $e) {
    error_log('Student payments API error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'ok' => false, 
        'error' => 'Server error',
        'debug' => $e->getMessage()
    ]);
}
