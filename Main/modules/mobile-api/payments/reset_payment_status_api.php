<?php
require_once __DIR__ . '/../../../config.php';
require_once __DIR__ . '/../shared/cors.php';

header('Content-Type: application/json');
error_reporting(E_ALL);
ini_set('display_errors', 1);

if (!isset($pdo) || $pdo === null) {
    http_response_code(500);
    echo json_encode(['ok' => false, 'error' => 'Database connection not initialized']);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['ok' => false, 'error' => 'Method not allowed']);
    exit;
}

$data = json_decode(file_get_contents('php://input'), true);

if (!isset($data['payment_id']) || !isset($data['student_email'])) {
    http_response_code(400);
    echo json_encode(['ok' => false, 'error' => 'Payment ID and student email required']);
    exit;
}

$payment_id = intval($data['payment_id']);
$student_email = $data['student_email'];

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

    // Verify payment belongs to student and is rejected
    $stmt = $pdo->prepare("
        SELECT p.* 
        FROM payments p
        JOIN bookings b ON p.booking_id = b.booking_id
        WHERE p.payment_id = ? 
        AND b.student_id = ?
        AND p.status = 'rejected'
    ");
    $stmt->execute([$payment_id, $student_id]);
    $payment = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$payment) {
        http_response_code(404);
        echo json_encode(['ok' => false, 'error' => 'Payment not found or not rejected']);
        exit;
    }

    // Reset status to pending and clear receipt image
    $stmt = $pdo->prepare("
        UPDATE payments 
        SET status = 'pending', receipt_image = NULL, rejection_reason = NULL, updated_at = NOW() 
        WHERE payment_id = ?
    ");
    $stmt->execute([$payment_id]);

    echo json_encode([
        'ok' => true,
        'message' => 'Payment status reset to pending. You can upload again.',
        'payment_id' => $payment_id
    ]);

} catch (PDOException $e) {
    error_log('Reset payment status API PDO error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'ok' => false, 
        'error' => 'Database error', 
        'debug' => $e->getMessage()
    ]);
} catch (Exception $e) {
    error_log('Reset payment status API error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'ok' => false, 
        'error' => $e->getMessage()
    ]);
}
