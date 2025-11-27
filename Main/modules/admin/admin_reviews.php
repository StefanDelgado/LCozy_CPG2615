<?php
require_once __DIR__ . '/../../auth/auth.php';
require_role(['admin','superadmin']);
require_once __DIR__ . '/../../config.php';

$page_title = "Review Moderation";
include __DIR__ . '/../../partials/header.php';

if (isset($_GET['action'], $_GET['id'])) {
    $id = intval($_GET['id']);
    $action = $_GET['action'] === 'approve' ? 'approved' : 'rejected';
    $stmt = $pdo->prepare("UPDATE reviews SET status = ? WHERE review_id = ?");
    $stmt->execute([$action, $id]);
}

$stmt = $pdo->query("
    SELECT r.*, u.name AS student_name, d.name AS dorm_name
    FROM reviews r
    JOIN users u ON r.student_id = u.user_id
    JOIN dormitories d ON r.dorm_id = d.dorm_id
    ORDER BY r.created_at DESC
");
$reviews = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

<div class="page-header">
  <h1>Review Moderation</h1>
  <p>Approve or reject student reviews</p>
</div>

<table class="data-table">
  <thead>
    <tr>
      <th>Dorm</th>
      <th>Student</th>
      <th>Rating</th>
      <th>Comment</th>
      <th>Status</th>
      <th>Actions</th>
    </tr>
  </thead>
  <tbody>
    <?php foreach ($reviews as $r): ?>
      <tr>
        <td><?= htmlspecialchars($r['dorm_name']) ?></td>
        <td><?= htmlspecialchars($r['student_name']) ?></td>
        <td>⭐ <?= $r['rating'] ?>/5</td>
        <td><?= nl2br(htmlspecialchars($r['comment'])) ?></td>
        <td><?= htmlspecialchars($r['status']) ?></td>
        <td>
          <a href="?action=approve&id=<?= $r['review_id'] ?>" class="btn-success">Approve</a>
          <a href="?action=reject&id=<?= $r['review_id'] ?>" class="btn-danger">Reject</a>
        </td>
      </tr>
    <?php endforeach; ?>
  </tbody>
</table>

<?php include __DIR__ . '/../../partials/footer.php'; ?>
