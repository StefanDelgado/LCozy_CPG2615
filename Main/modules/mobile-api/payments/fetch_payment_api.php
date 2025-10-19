<?php
require_once __DIR__ . '/../../../config.php';
require_once __DIR__ . '/../shared/cors.php';

// Example: GET /Main/api/fetch_payments.php?role=student&user_id=123
$role = $_GET['role'] ?? null;
$user_id = isset($_GET['user_id']) ? intval($_GET['user_id']) : null;

try {
  if ($role === 'student' && $user_id) {
    $sql = "
      SELECT p.payment_id, p.amount, p.status, p.due_date, p.receipt_image,
             d.name AS dorm_name, r.room_type, p.booking_id
      FROM payments p
      JOIN bookings b ON p.booking_id = b.booking_id
      JOIN rooms r ON b.room_id = r.room_id
      JOIN dormitories d ON r.dorm_id = d.dorm_id
      WHERE p.student_id = ?
      ORDER BY p.created_at DESC
    ";
    $stmt = $pdo->prepare($sql);
    $stmt->execute([$user_id]);
  } elseif ($role === 'owner' && $user_id) {
    $sql = "
      SELECT p.payment_id, p.amount, p.status, p.due_date, p.receipt_image,
             u.user_id AS student_id, u.name AS student_name,
             d.name AS dorm_name, r.room_type
      FROM payments p
      JOIN bookings b ON p.booking_id = b.booking_id
      JOIN rooms r ON b.room_id = r.room_id
      JOIN dormitories d ON r.dorm_id = d.dorm_id
      JOIN users u ON b.student_id = u.user_id
      WHERE d.owner_id = ?
      ORDER BY p.due_date ASC
    ";
    $stmt = $pdo->prepare($sql);
    $stmt->execute([$user_id]);
  } else {
    // Public fallback: return empty or error
    echo json_encode(['ok' => false, 'error' => 'Invalid parameters']);
    exit;
  }

  $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
  echo json_encode(['ok' => true, 'data' => $rows]);
} catch (Exception $e) {
  http_response_code(500);
  error_log('api/fetch_payments error: ' . $e->getMessage());
  echo json_encode(['ok' => false, 'error' => 'Server error']);
}