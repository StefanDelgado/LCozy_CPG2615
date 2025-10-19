<?php
require_once __DIR__ . '/../../../config.php';
require_once __DIR__ . '/../shared/cors.php';

header('Content-Type: application/json');
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Check if PDO is initialized
if (!isset($pdo) || $pdo === null) {
    http_response_code(500);
    echo json_encode(['ok' => false, 'error' => 'Database connection not initialized']);
    exit;
}

// Check if it's a POST request
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['ok' => false, 'error' => 'Method not allowed']);
    exit;
}

// Get POST data
$data = json_decode(file_get_contents('php://input'), true);

if (!isset($data['payment_id']) || !isset($data['student_email'])) {
    http_response_code(400);
    echo json_encode(['ok' => false, 'error' => 'Payment ID and student email required']);
    exit;
}

$payment_id = intval($data['payment_id']);
$student_email = $data['student_email'];
$receipt_base64 = $data['receipt_base64'] ?? null;
$receipt_filename = $data['receipt_filename'] ?? 'receipt.jpg';

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

    // Verify payment belongs to student and is in pending status
    $stmt = $pdo->prepare("
        SELECT p.* 
        FROM payments p
        JOIN bookings b ON p.booking_id = b.booking_id
        WHERE p.payment_id = ? 
        AND b.student_id = ?
        AND p.status = 'pending'
    ");
    $stmt->execute([$payment_id, $student_id]);
    $payment = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$payment) {
        http_response_code(404);
        echo json_encode(['ok' => false, 'error' => 'Payment not found or already processed']);
        exit;
    }

    // Validate and save receipt if provided
    if ($receipt_base64) {
        // Remove data:image/... prefix if present
        if (preg_match('/^data:image\/(\w+);base64,/', $receipt_base64, $type)) {
            $receipt_base64 = substr($receipt_base64, strpos($receipt_base64, ',') + 1);
            $type = strtolower($type[1]); // jpg, png, gif
        } else {
            $type = 'jpg'; // default
        }

        // Decode base64
        $receipt_data = base64_decode($receipt_base64);
        
        if ($receipt_data === false) {
            throw new Exception('Invalid receipt data');
        }

        // Create upload directory if it doesn't exist
        $upload_dir = __DIR__ . '/../../uploads/receipts/';
        if (!is_dir($upload_dir)) {
            mkdir($upload_dir, 0777, true);
        }

        // Generate unique filename
        $ext = pathinfo($receipt_filename, PATHINFO_EXTENSION);
        if (empty($ext)) {
            $ext = $type;
        }
        $filename = 'receipt_' . $payment_id . '_' . time() . '.' . $ext;
        $filepath = $upload_dir . $filename;

        // Save file
        if (file_put_contents($filepath, $receipt_data) === false) {
            throw new Exception('Failed to save receipt file');
        }

        // Update payment record with receipt
        $stmt = $pdo->prepare("
            UPDATE payments 
            SET receipt_image = ?, 
                status = 'submitted',
                updated_at = NOW() 
            WHERE payment_id = ?
        ");
        $stmt->execute([$filename, $payment_id]);

        echo json_encode([
            'ok' => true,
            'message' => 'Receipt uploaded successfully. Awaiting admin confirmation.',
            'payment_id' => $payment_id,
            'receipt_url' => 'http://cozydorms.life/uploads/receipts/' . $filename
        ]);
    } else {
        http_response_code(400);
        echo json_encode(['ok' => false, 'error' => 'Receipt data required']);
    }

} catch (PDOException $e) {
    error_log('Upload receipt API PDO error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'ok' => false, 
        'error' => 'Database error', 
        'debug' => $e->getMessage()
    ]);
} catch (Exception $e) {
    error_log('Upload receipt API error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'ok' => false, 
        'error' => $e->getMessage()
    ]);
}
