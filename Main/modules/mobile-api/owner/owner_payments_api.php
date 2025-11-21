<?php
require_once __DIR__ . '/../../../config.php';
require_once __DIR__ . '/../shared/cors.php';

header('Content-Type: application/json');
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Handle POST requests for payment actions
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($input['action']) || !isset($input['payment_id']) || !isset($input['owner_email'])) {
        echo json_encode(['ok' => false, 'error' => 'Missing required fields']);
        exit;
    }
    
    $action = $input['action'];
    $payment_id = $input['payment_id'];
    $owner_email = $input['owner_email'];
    
    try {
        // Verify owner exists and owns the payment
        $stmt = $pdo->prepare("
            SELECT p.payment_id, p.status, d.owner_id
            FROM payments p
            JOIN bookings b ON p.booking_id = b.booking_id
            JOIN rooms r ON b.room_id = r.room_id
            JOIN dormitories d ON r.dorm_id = d.dorm_id
            JOIN users u ON d.owner_id = u.user_id
            WHERE p.payment_id = ? AND u.email = ?
        ");
        $stmt->execute([$payment_id, $owner_email]);
        $payment = $stmt->fetch();
        
        if (!$payment) {
            http_response_code(403);
            echo json_encode(['ok' => false, 'error' => 'Payment not found or access denied']);
            exit;
        }
        
        if ($action === 'complete') {
            // Mark payment as completed/paid
            $stmt = $pdo->prepare("
                UPDATE payments 
                SET status = 'paid', 
                    payment_date = NOW(),
                    updated_at = NOW()
                WHERE payment_id = ?
            ");
            $stmt->execute([$payment_id]);

            // Also set related booking to completed
            $getBooking = $pdo->prepare("SELECT booking_id FROM payments WHERE payment_id = ? LIMIT 1");
            $getBooking->execute([$payment_id]);
            $booking_id = $getBooking->fetchColumn();
            if ($booking_id) {
                $updateBooking = $pdo->prepare("UPDATE bookings SET status = 'active' WHERE booking_id = ?");
                $updateBooking->execute([$booking_id]);
            }

            // Prevent payment from being set to expired if already paid
            $preventExpire = $pdo->prepare("UPDATE payments SET status = 'paid' WHERE payment_id = ? AND status != 'paid'");
            $preventExpire->execute([$payment_id]);

            error_log("Payment $payment_id marked as paid by owner");
            echo json_encode(['ok' => true, 'message' => 'Payment marked as completed']);
            
        } elseif ($action === 'reject') {
            // Mark payment as rejected/failed
            $stmt = $pdo->prepare("
                UPDATE payments 
                SET status = 'rejected',
                    updated_at = NOW()
                WHERE payment_id = ?
            ");
            $stmt->execute([$payment_id]);
            
            error_log("Payment $payment_id rejected by owner");
            echo json_encode(['ok' => true, 'message' => 'Payment rejected']);
            
        } else {
            echo json_encode(['ok' => false, 'error' => 'Invalid action']);
        }
        
    } catch (Exception $e) {
        error_log('Payment action error: ' . $e->getMessage());
        http_response_code(500);
        echo json_encode(['ok' => false, 'error' => 'Server error', 'debug' => $e->getMessage()]);
    }
    exit;
}

// Handle GET requests for fetching payments
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

    // Get total revenue (all paid payments, matching web)
    $revenueStmt = $pdo->prepare("
        SELECT COALESCE(SUM(p.amount), 0) as total_revenue
        FROM payments p
        JOIN bookings b ON p.booking_id = b.booking_id
        JOIN rooms r ON b.room_id = r.room_id
        JOIN dormitories d ON r.dorm_id = d.dorm_id
        WHERE d.owner_id = ? 
        AND p.status = 'paid'
    ");
    $revenueStmt->execute([$owner_id]);
    $total_revenue = $revenueStmt->fetchColumn();

    // Get pending amount - use the stored amount in payments table
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

    // Format amounts to float with 2 decimals
    foreach ($payments as &$payment) {
        $payment['amount'] = round(floatval($payment['amount']), 2);
    }

    echo json_encode([
        'ok' => true,
        'stats' => [
            'monthly_revenue' => round(floatval($total_revenue ?? 0), 2),
            'pending_amount' => round(floatval($pending_amount ?? 0), 2)
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