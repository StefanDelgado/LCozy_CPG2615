<?php
require_once __DIR__ . '/../../auth/auth.php';
require_role(['admin','superadmin']);
require_once __DIR__ . '/../../config.php';

$page_title = "Review Moderation";
include __DIR__ . '/../../partials/header.php';

/* ============================================================
   BAD WORD DETECTOR
   ============================================================ */
$bad_words = ['fuck','shit','bitch','asshole','puta','gago','tangina']; 
function highlight_bad_words($text, $bad_words) {
    foreach ($bad_words as $bad) {
        $pattern = '/' . preg_quote($bad, '/') . '/i';
        $text = preg_replace($pattern, '<span style="background:#ffcccc;color:#900;font-weight:bold;">'.$bad.'</span>', $text);
    }
    return $text;
}

/* ============================================================
   HANDLE APPROVE / DISAPPROVE ACTIONS
   ============================================================ */
if (isset($_GET['action'], $_GET['id'])) {
    $id = intval($_GET['id']);

    if ($_GET['action'] === 'approve') {
        $new_status = 'approved';
    } else {
        $new_status = 'disapproved';
    }

    // Ensure review exists
    $check = $pdo->prepare("SELECT review_id FROM reviews WHERE review_id = ?");
    $check->execute([$id]);

    if ($check->rowCount() > 0) {
        // Update review status
        $stmt = $pdo->prepare("UPDATE reviews SET status = ? WHERE review_id = ?");
        $stmt->execute([$new_status, $id]);

        // Log moderation action
        $log = $pdo->prepare("
            INSERT INTO review_moderation_logs (review_id, moderator_id, action)
            VALUES (?, ?, ?)
        ");
        $log->execute([$id, $_SESSION['user']['user_id'], $new_status]);
    }

    header("Location: admin_reviews.php");
    exit;
}

/* ============================================================
   FILTER (Pending Only Toggle)
   ============================================================ */
$filter_sql = "";
if (isset($_GET['filter']) && $_GET['filter'] === 'pending') {
    $filter_sql = "WHERE r.status = 'pending'";
}

/* ============================================================
   FETCH REVIEWS
   ============================================================ */
$stmt = $pdo->query("
    SELECT r.*, 
           u.name AS student_name, 
           d.name AS dorm_name
    FROM reviews r
    JOIN users u ON r.student_id = u.user_id
    JOIN dormitories d ON r.dorm_id = d.dorm_id
    $filter_sql
    ORDER BY r.created_at DESC
");
$reviews = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

<div class="page-header">
  <h1>Review Moderation</h1>
  <p>Approve or disapprove student reviews</p>
</div>

<div style="margin-bottom:15px;">
    <?php if (isset($_GET['filter']) && $_GET['filter'] === 'pending'): ?>
        <a href="admin_reviews.php" class="btn-primary">Show All Reviews</a>
    <?php else: ?>
        <a href="admin_reviews.php?filter=pending" class="btn-secondary">Show Pending Only</a>
    <?php endif; ?>
</div>

<?php if (empty($reviews)): ?>
    <p><em>No reviews found.</em></p>
<?php else: ?>

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
      <?php
        $comment_display = highlight_bad_words(
            nl2br(htmlspecialchars($r['comment'])),
            $bad_words
        );
      ?>
      <tr>
        <td><?= htmlspecialchars($r['dorm_name']) ?></td>
        <td><?= htmlspecialchars($r['student_name']) ?></td>
        <td>⭐ <?= (int)$r['rating'] ?>/5</td>
        <td><?= $comment_display ?></td>
        <td><?= htmlspecialchars($r['status']) ?></td>
        <td>
          <a href="admin_reviews.php?action=approve&id=<?= $r['review_id'] ?>" class="btn-success">Approve</a>
          <a href="admin_reviews.php?action=reject&id=<?= $r['review_id'] ?>" class="btn-danger">Disapprove</a>
        </td>
      </tr>
    <?php endforeach; ?>
  </tbody>
</table>

<?php endif; ?>

<?php include __DIR__ . '/../../partials/footer.php'; ?>