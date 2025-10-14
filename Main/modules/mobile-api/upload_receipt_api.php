<?php
<?php
require_once __DIR__ . '/../config.php';
require_once __DIR__ . 'cors.php';

// POST: payment_id, student_id (for basic auth), file 'receipt'
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
  http_response_code(405);
  echo json_encode(['ok'=>false,'error'=>'Method not allowed']);
  exit;
}

$payment_id = intval($_POST['payment_id'] ?? 0);
$student_id = intval($_POST['student_id'] ?? 0);
if (!$payment_id || !$student_id || empty($_FILES['receipt'])) {
  http_response_code(400);
  echo json_encode(['ok'=>false,'error'=>'Missing parameters']);
  exit;
}

try {
  $check = $pdo->prepare("
    SELECT p.* FROM payments p
    JOIN bookings b ON p.booking_id = b.booking_id
    WHERE p.payment_id = ? AND b.student_id = ? AND p.status = 'pending'
  ");
  $check->execute([$payment_id, $student_id]);
  if (!$check->fetch()) {
    http_response_code(403);
    echo json_encode(['ok'=>false,'error'=>'Not authorized or invalid payment']);
    exit;
  }

  $file = $_FILES['receipt'];
  $allowed = ['image/jpeg','image/png','application/pdf'];
  if (!in_array($file['type'], $allowed)) {
    http_response_code(400);
    echo json_encode(['ok'=>false,'error'=>'Invalid file type']);
    exit;
  }

  $upload_dir = __DIR__ . '/../uploads/receipts/';
  if (!is_dir($upload_dir)) mkdir($upload_dir, 0777, true);

  $ext = pathinfo($file['name'], PATHINFO_EXTENSION);
  $filename = 'receipt_'.$payment_id.'_'.time().'.'.$ext;
  if (!move_uploaded_file($file['tmp_name'], $upload_dir.$filename)) {
    throw new Exception('Upload failed');
  }

  $update = $pdo->prepare("UPDATE payments SET receipt_image = ?, status = 'submitted' WHERE payment_id = ?");
  $update->execute([$filename, $payment_id]);

  echo json_encode(['ok'=>true,'message'=>'Uploaded','file'=>$filename]);
} catch (Exception $e) {
  http_response_code(500);
  error_log('api/upload_receipt error: '.$e->getMessage());
  echo json_encode(['ok'=>false,'error'=>'Server error']);
}