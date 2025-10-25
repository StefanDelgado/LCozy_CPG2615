<?php
require_once __DIR__ . '/../../auth/auth.php';
require_role('owner');
require_once __DIR__ . '/../../config.php';

$page_title = "Dorm Reviews";
include __DIR__ . '/../../partials/header.php';

$owner_id = $_SESSION['user']['user_id'];

// Debug: show current owner and their dorms (helpful to verify ownership)
$ownerDormsStmt = $pdo->prepare("SELECT dorm_id, name FROM dormitories WHERE owner_id = ?");
$ownerDormsStmt->execute([$owner_id]);
$ownerDorms = $ownerDormsStmt->fetchAll(PDO::FETCH_ASSOC);
// (debug output removed)

// Flash message for actions (persist across redirect)
$flash = null;
if (session_status() !== PHP_SESSION_ACTIVE) { session_start(); }
if (isset($_SESSION['flash'])) {
  $flash = $_SESSION['flash'];
  unset($_SESSION['flash']);
}

// Handle moderation POST (approve/reject) from owner UI
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['review_id'], $_POST['action'])) {
  $postReviewId = intval($_POST['review_id']);
  $postAction = strtolower(trim($_POST['action']));
  if (!in_array($postAction, ['approve', 'reject'])) {
    $_SESSION['flash'] = ['type' => 'danger', 'text' => 'Invalid action'];
  } else {
    // Verify that the review belongs to one of the owner's dorms
    $checkStmt = $pdo->prepare('SELECT dorm_id FROM reviews WHERE review_id = ?');
    $checkStmt->execute([$postReviewId]);
    $row = $checkStmt->fetch(PDO::FETCH_ASSOC);
    if (!$row) {
      $_SESSION['flash'] = ['type' => 'danger', 'text' => 'Review not found'];
    } else {
      $reviewDormId = (int)$row['dorm_id'];
      $ownedDormIds = array_map(function($d){ return (int)$d['dorm_id']; }, $ownerDorms);
      if (!in_array($reviewDormId, $ownedDormIds)) {
        $_SESSION['flash'] = ['type' => 'danger', 'text' => 'You are not authorized to moderate this review'];
      } else {
        $newStatus = $postAction === 'approve' ? 'approved' : 'rejected';
        $up = $pdo->prepare('UPDATE reviews SET status = ? WHERE review_id = ?');
        $up->execute([$newStatus, $postReviewId]);
        $_SESSION['flash'] = ['type' => 'success', 'text' => 'Review ' . $newStatus];
      }
    }
  }
  // Redirect to avoid form resubmission and preserve dorm_id filter
  $redirectUrl = $_SERVER['REQUEST_URI'];
  header('Location: ' . $redirectUrl);
  exit;
}

// Support dorm_id filter
$dorm_id = isset($_GET['dorm_id']) ? (int)$_GET['dorm_id'] : null;

// Build list of dorm IDs owned by this owner
$ownedDormIds = array_map(function($d){ return (int)$d['dorm_id']; }, $ownerDorms);

if (empty($ownedDormIds)) {
    $reviews = [];
    echo "<div class='alert alert-warning'>You don't have any dorms yet.</div>";
} else {
    // If a dorm_id filter was provided, ensure it belongs to the owner
    if ($dorm_id && !in_array($dorm_id, $ownedDormIds)) {
        // invalid dorm_id for this owner -> return empty
        $reviews = [];
    } else {
        // Determine which dorm ids to query: either single dorm or all owned dorms
        $targetDormIds = $dorm_id ? [$dorm_id] : $ownedDormIds;

        // Build placeholders and params
        $placeholders = implode(',', array_fill(0, count($targetDormIds), '?'));
        $params = $targetDormIds; // for dorm ids

        $sql = "SELECT r.*, u.name AS student_name, d.name AS dorm_name, rm.room_type
                FROM reviews r
                LEFT JOIN users u ON r.student_id = u.user_id
                LEFT JOIN dormitories d ON r.dorm_id = d.dorm_id
                LEFT JOIN bookings b ON r.booking_id = b.booking_id
                LEFT JOIN rooms rm ON b.room_id = rm.room_id
                WHERE r.dorm_id IN ($placeholders) AND r.status = 'approved'
                ORDER BY r.created_at DESC";

        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        $reviews = $stmt->fetchAll(PDO::FETCH_ASSOC);

  // (debug output removed)
    }
}

?>

<div class="page-header">
  <h1>Dorm Reviews</h1>
  <p>Read feedback from students who stayed at your dorms</p>
</div>

<?php if ($reviews): ?>
  <?php if (!empty($flash)): ?>
    <div class="alert alert-<?= htmlspecialchars($flash['type']) ?>"><?= htmlspecialchars($flash['text']) ?></div>
  <?php endif; ?>
  <div class="reviews-list">
    <?php foreach ($reviews as $r): ?>
      <div class="review-card">
        <h3><?= htmlspecialchars($r['dorm_name']) ?></h3>
        <p><strong>By:</strong> <?= htmlspecialchars($r['student_name']) ?></p>
        <p><strong>Room:</strong> <?= htmlspecialchars($r['room_type'] ?? 'N/A') ?></p>
        <p>⭐ <?= $r['rating'] ?>/5</p>
        <p><?= nl2br(htmlspecialchars($r['comment'])) ?></p>
        <small><?= date("M d, Y H:i", strtotime($r['created_at'])) ?></small>
        <div class="review-actions">
          <form method="post" style="display:inline-block; margin-right:8px;">
            <input type="hidden" name="review_id" value="<?= (int)$r['review_id'] ?>" />
            <input type="hidden" name="action" value="reject" />
            <button type="submit" class="btn btn-outline-danger">Report</button>
          </form>
          <form method="post" style="display:inline-block;">
            <input type="hidden" name="review_id" value="<?= (int)$r['review_id'] ?>" />
            <input type="hidden" name="action" value="approve" />
            <button type="submit" class="btn btn-primary">Keep</button>
          </form>
        </div>
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
  position: relative;
  z-index: 1;
}
.review-card {
  border: 1px solid #e9e6ef;
  border-radius: 10px;
  padding: 16px;
  background: #fff;
  box-shadow: 0 4px 10px rgba(0,0,0,0.08);
  position: relative;
  z-index: 2;
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
