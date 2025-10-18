<?php
require_once __DIR__ . '/../../auth/auth.php';
require_role('student');
require_once __DIR__ . '/../../config.php';

// Ensure it's a POST request with required data
if ($_SERVER['REQUEST_METHOD'] !== 'POST' || !isset($_POST['payment_id']) || empty($_FILES['receipt'])) {
    $_SESSION['flash'] = ['type' => 'error', 'msg' => 'Invalid request'];
    header('Location: student_payments.php');
    exit;
}

$payment_id = intval($_POST['payment_id']);
$student_id = $_SESSION['user']['user_id'];

try {
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
    
    if (!$stmt->fetch()) {
        throw new Exception('Invalid payment or not authorized');
    }

    // Validate file
    $file = $_FILES['receipt'];
    $allowed = ['image/jpeg', 'image/png', 'application/pdf'];
    
    if (!in_array($file['type'], $allowed)) {
        throw new Exception('Invalid file type. Please upload JPG, PNG, or PDF');
    }

    if ($file['size'] > 5 * 1024 * 1024) { // 5MB limit
        throw new Exception('File too large. Maximum size is 5MB');
    }

    // Create upload directory if it doesn't exist
    $upload_dir = __DIR__ . '/../uploads/receipts/';
    if (!is_dir($upload_dir)) {
        mkdir($upload_dir, 0777, true);
    }

    // Generate unique filename
    $ext = pathinfo($file['name'], PATHINFO_EXTENSION);
    $filename = 'receipt_' . $payment_id . '_' . time() . '.' . $ext;
    $filepath = $upload_dir . $filename;

    // Move uploaded file
    if (!move_uploaded_file($file['tmp_name'], $filepath)) {
        throw new Exception('Failed to upload file');
    }

    // Update payment record
    $stmt = $pdo->prepare("
        UPDATE payments 
        SET receipt_image = ?, 
            status = 'submitted',
            updated_at = NOW() 
        WHERE payment_id = ?
    ");
    $stmt->execute([$filename, $payment_id]);

    $_SESSION['flash'] = [
        'type' => 'success',
        'msg' => 'Receipt uploaded successfully. Awaiting confirmation.'
    ];

} catch (Exception $e) {
    error_log('Receipt upload error: ' . $e->getMessage());
    $_SESSION['flash'] = ['type' => 'error', 'msg' => $e->getMessage()];
}

// Redirect back to payments page
header('Location: student_payments.php');
exit;
