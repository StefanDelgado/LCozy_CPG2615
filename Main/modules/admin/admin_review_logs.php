<?php
require_once __DIR__ . '/../../auth/auth.php';
require_role(['admin','superadmin']);
require_once __DIR__ . '/../../config.php';

$page_title = "Review Moderation Logs";
include __DIR__ . '/../../partials/header.php';

// Fetch logs
$stmt = $pdo->query("
    SELECT l.*, 
           r.comment AS review_comment, 
           r.rating,
           u.name AS student_name,
           d.name AS dorm_name,
           a.name AS admin_name
    FROM review_moderation_logs l
    LEFT JOIN reviews r ON l.review_id = r.review_id
    LEFT JOIN users u ON r.student_id = u.user_id
    LEFT JOIN dormitories d ON r.dorm_id = d.dorm_id
    LEFT JOIN users a ON l.admin_id = a.user_id
    ORDER BY l.action_timestamp DESC
");
$logs = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

<div class="page-header">
  <h1>Review Moderation Logs</h1>
  <p>Every approval/disapproval performed by admins is recorded here.</p>
</div>

<table class="data-table">
  <thead>
    <tr>
      <th>Timestamp</th>
      <th>Admin</th>
      <th>Dorm</th>
      <th>Student</th>
      <th>Rating</th>
      <th>Comment</th>
      <th>Previous Status</th>
      <th>New Status</th>
    </tr>
  </thead>

  <tbody>
    <?php foreach ($logs as $log): ?>
      <tr>
        <td><?= htmlspecialchars($log['action_timestamp']) ?></td>
        <td><?= htmlspecialchars($log['admin_name'] ?? 'Unknown') ?></td>
        <td><?= htmlspecialchars($log['dorm_name'] ?? 'N/A') ?></td>
        <td><?= htmlspecialchars($log['student_name'] ?? 'N/A') ?></td>
        <td>⭐ <?= htmlspecialchars($log['rating']) ?>/5</td>
        <td><?= nl2br(htmlspecialchars($log['review_comment'] ?? '')) ?></td>
        <td><?= htmlspecialchars($log['previous_status']) ?></td>
        <td><?= htmlspecialchars($log['new_status']) ?></td>
      </tr>
    <?php endforeach; ?>
  </tbody>
</table>

<?php include __DIR__ . '/../../partials/footer.php'; ?>