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

    // Log the student information
    error_log("=== STUDENT PAYMENTS API DEBUG ===");
    error_log("Student Email: $student_email");
    error_log("Student ID: $student_id");

    // First, check how many payments exist for this student
    $count_stmt = $pdo->prepare("SELECT COUNT(*) as total FROM payments WHERE student_id = ?");
    $count_stmt->execute([$student_id]);
    $count_result = $count_stmt->fetch(PDO::FETCH_ASSOC);
    error_log("Total payments in payments table for this student: " . $count_result['total']);

    // Check payments without joins to see if join is causing the issue
    $raw_stmt = $pdo->prepare("
        SELECT payment_id, booking_id, amount, status, due_date
        FROM payments 
        WHERE student_id = ?
        ORDER BY created_at DESC
    ");
    $raw_stmt->execute([$student_id]);
    $raw_payments = $raw_stmt->fetchAll(PDO::FETCH_ASSOC);
    error_log("Raw payments (no joins): " . json_encode($raw_payments));

    // Fetch payments with booking and room details
    // Using LEFT JOINs to ensure all payments are returned even if related data is missing
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
        LEFT JOIN bookings b ON p.booking_id = b.booking_id
        LEFT JOIN rooms r ON b.room_id = r.room_id
        LEFT JOIN dormitories d ON r.dorm_id = d.dorm_id
        LEFT JOIN users u ON p.owner_id = u.user_id
        WHERE p.student_id = ?
        ORDER BY p.created_at DESC
    ");

    $stmt->execute([$student_id]);
    $payments = $stmt->fetchAll(PDO::FETCH_ASSOC);

    error_log("Payments after joins: " . count($payments));
    if (count($payments) < $count_result['total']) {
        error_log("WARNING: JOIN is filtering out payments!");
        error_log("Missing: " . ($count_result['total'] - count($payments)) . " payment(s)");
    }

    // Calculate payment statistics
    $total_due = 0;
    $paid_amount = 0;
    $pending_count = 0;
    $overdue_count = 0;

    $current_date = date('Y-m-d');

    foreach ($payments as &$payment) {
        // Provide defaults for NULL values from LEFT JOINs
        $payment['dorm_name'] = $payment['dorm_name'] ?? 'Unknown Dorm';
        $payment['dorm_address'] = $payment['dorm_address'] ?? 'N/A';
        $payment['room_type'] = $payment['room_type'] ?? 'Unknown Room';
        $payment['room_number'] = $payment['room_number'] ?? null;
        
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

    error_log("Final payment count being returned: " . count($payments));
    error_log("Payment IDs being returned: " . implode(', ', array_column($payments, 'payment_id')));
    error_log("Statistics: Pending=$pending_count, Overdue=$overdue_count, Total_due=$total_due, Paid=$paid_amount");
    error_log("=== END STUDENT PAYMENTS API DEBUG ===");

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
