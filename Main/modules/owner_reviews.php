<?php
require_once __DIR__ . '/../auth.php';
require_role('owner');
require_once __DIR__ . '/../config.php';

$page_title = "Dorm Reviews";
include __DIR__ . '/../partials/header.php';

$owner_id = $_SESSION['user']['user_id'];

$stmt = $pdo->prepare("
    SELECT r.*, u.name AS student_name, d.name AS dorm_name
    FROM reviews r
    JOIN users u ON r.student_id = u.user_id
    JOIN dormitories d ON r.dorm_id = d.dorm_id
    WHERE d.owner_id = ? AND r.status = 'approved'
    ORDER BY r.created_at DESC
");
$stmt->execute([$owner_id]);
$reviews = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

<div class="page-header">
  <h1>Dorm Reviews</h1>
  <p>Read feedback from students who stayed at your dorms</p>
</div>

<?php if ($reviews): ?>
  <div class="reviews-list">
    <?php foreach ($reviews as $r): ?>
      <div class="review-card">
        <h3><?= htmlspecialchars($r['dorm_name']) ?></h3>
        <p><strong>By:</strong> <?= htmlspecialchars($r['student_name']) ?></p>
        <p>⭐ <?= $r['rating'] ?>/5</p>
        <p><?= nl2br(htmlspecialchars($r['comment'])) ?></p>
        <small><?= date("M d, Y H:i", strtotime($r['created_at'])) ?></small>
      </div>
    <?php endforeach; ?>
  </div>
<?php else: ?>
  <p><em>No reviews available yet.</em></p>
<?php endif; ?>

<style>
.reviews-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}
.review-card {
  border: 1px solid #e9e6ef;
  border-radius: 10px;
  padding: 16px;
  background: #fff;
  box-shadow: 0 4px 10px rgba(0,0,0,0.05);
}
.review-card h3 {
  margin: 0 0 8px 0;
}
.review-card p {
  margin: 4px 0;
}
.review-card small {
  color: #666;
  font-size: 0.85rem;
}
</style>

<?php include __DIR__ . '/../partials/footer.php'; ?>