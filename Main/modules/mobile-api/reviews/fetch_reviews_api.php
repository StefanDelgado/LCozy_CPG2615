<?php
require_once __DIR__ . '/../../../config.php';
require_once __DIR__ . '/../shared/cors.php';
header('Content-Type: application/json');

$dorm_id = isset($_GET['dorm_id']) ? intval($_GET['dorm_id']) : 0;
if ($dorm_id <= 0) {
    echo json_encode(['success' => false, 'error' => 'Missing or invalid dorm_id']);
    exit;
}

// Fetch approved reviews
$stmt = $pdo->prepare("SELECT r.review_id, r.rating, r.comment, r.created_at, u.name FROM reviews r JOIN users u ON r.student_id = u.user_id WHERE r.dorm_id = ? AND r.status = 'approved' ORDER BY r.created_at DESC");
$stmt->execute([$dorm_id]);
$reviews = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Calculate average rating and total reviews
$stats_stmt = $pdo->prepare("SELECT AVG(rating) AS avg_rating, COUNT(*) AS total_reviews FROM reviews WHERE dorm_id = ? AND status = 'approved'");
$stats_stmt->execute([$dorm_id]);
$stats = $stats_stmt->fetch(PDO::FETCH_ASSOC);

$avg_rating = isset($stats['avg_rating']) ? round((float)$stats['avg_rating'], 1) : 0.0;
$total_reviews = isset($stats['total_reviews']) ? (int)$stats['total_reviews'] : 0;

echo json_encode([
    'success' => true,
    'reviews' => $reviews,
    'avg_rating' => $avg_rating,
    'total_reviews' => $total_reviews
]);
