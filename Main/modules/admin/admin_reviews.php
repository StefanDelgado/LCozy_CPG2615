<?php
require_once __DIR__ . '/../../auth/auth.php';
require_role(['admin','superadmin']);
require_once __DIR__ . '/../../config.php';

$page_title = "Review Moderation";
include __DIR__ . '/../../partials/header.php';

if (session_status() !== PHP_SESSION_ACTIVE) { session_start(); }

/* ============================================================
   Flash Message System
   ============================================================ */
$flash = null;
if (isset($_SESSION['flash'])) {
    $flash = $_SESSION['flash'];
    unset($_SESSION['flash']);
}

/* ============================================================
   Bad Word Detector
   ============================================================ */
$bad_words = ['fuck','shit','bitch','asshole','puta','gago','tangina'];

function highlight_bad_words($text, $bad_words) {
    foreach ($bad_words as $bad) {
        $pattern = '/' . preg_quote($bad, '/') . '/i';
        $text = preg_replace(
            $pattern,
            '<span style="background:#ffcccc;color:#900;font-weight:bold;">'.$bad.'</span>',
            $text
        );
    }
    return $text;
}

/* ============================================================
   Handle Moderation Actions
   ============================================================ */
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['review_id'], $_POST['action'])) {
    $id = intval($_POST['review_id']);
    $action = strtolower(trim($_POST['action']));

    if (!in_array($action, ['approve', 'disapprove'])) {
        $_SESSION['flash'] = ['type' => 'danger', 'text' => 'Invalid action'];
    } else {
        $newStatus = $action === 'approve' ? 'approved' : 'disapproved';

        // Check if review exists
        $check = $pdo->prepare("SELECT review_id FROM reviews WHERE review_id = ?");
        $check->execute([$id]);

        if ($check->rowCount() === 0) {
            $_SESSION['flash'] = ['type' => 'danger', 'text' => 'Review not found'];
        } else {
            // Update review status
            $update = $pdo->prepare("UPDATE reviews SET status = ? WHERE review_id = ?");
            $update->execute([$newStatus, $id]);

            // Optional: store logs if table exists
            try {
                $log = $pdo->prepare("
                    INSERT INTO review_moderation_logs (review_id, moderator_id, action)
                    VALUES (?, ?, ?)
                ");
                $log->execute([$id, $_SESSION['user']['user_id'], $newStatus]);
            } catch (Exception $e) {
                // ignore if logs table doesn't exist
            }

            $_SESSION['flash'] = ['type' => 'success', 'text' => "Review $newStatus"];
        }
    }
    header("Location: ".$_SERVER['REQUEST_URI']);
    exit;
}

/* ============================================================
   Optional Filters
   ============================================================ */
$dorm_id = isset($_GET['dorm_id']) ? intval($_GET['dorm_id']) : null;
$filter = isset($_GET['filter']) ? $_GET['filter'] : "all";

/* ============================================================
   Fetch Dorm List (for dropdown filter)
   ============================================================ */
$dormsStmt = $pdo->query("SELECT dorm_id, name FROM dormitories WHERE verified = 1");
$allDorms = $dormsStmt->fetchAll(PDO::FETCH_ASSOC);

/* ============================================================
   Build Query
   ============================================================ */
$where = [];
$params = [];

if ($dorm_id) {
    $where[] = "r.dorm_id = ?";
    $params[] = $dorm_id;
}

if ($filter === "pending") {
    $where[] = "r.status = 'pending'";
} elseif ($filter === "approved") {
    $where[] = "r.status = 'approved'";
} elseif ($filter === "disapproved") {
    $where[] = "r.status = 'disapproved'";
}

$whereSQL = $where ? "WHERE " . implode(" AND ", $where) : "";

/* ============================================================
   Final Fetch
   ============================================================ */
$sql = "
    SELECT r.*, 
           u.name AS student_name,
           d.name AS dorm_name,
           rm.room_type
    FROM reviews r
    LEFT JOIN users u ON r.student_id = u.user_id
    LEFT JOIN dormitories d ON r.dorm_id = d.dorm_id
    LEFT JOIN bookings b ON r.booking_id = b.booking_id
    LEFT JOIN rooms rm ON b.room_id = rm.room_id
    $whereSQL
    ORDER BY r.created_at DESC
";

$stmt = $pdo->prepare($sql);
$stmt->execute($params);
$reviews = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

<div class="page-header">
  <h1>Review Moderation</h1>
  <p>View and moderate all reviews submitted across all dormitories.</p>
</div>

<?php if (!empty($flash)): ?>
  <div class="alert alert-<?= htmlspecialchars($flash['type']) ?>">
    <?= htmlspecialchars($flash['text']) ?>
  </div>
<?php endif; ?>

<!-- Filters -->
<form method="get" style="margin-bottom:20px;">
  <label>Select Dorm:</label>
  <select name="dorm_id" onchange="this.form.submit()">
    <option value="">All Dorms</option>
    <?php foreach ($allDorms as $d): ?>
      <option value="<?= $d['dorm_id'] ?>" <?= ($dorm_id == $d['dorm_id']) ? "selected" : "" ?>>
        <?= htmlspecialchars($d['name']) ?>
      </option>
    <?php endforeach; ?>
  </select>

  <label style="margin-left:10px;">Status:</label>
  <select name="filter" onchange="this.form.submit()">
    <option value="all" <?= $filter === "all" ? "selected" : "" ?>>All</option>
    <option value="pending" <?= $filter === "pending" ? "selected" : "" ?>>Pending</option>
    <option value="approved" <?= $filter === "approved" ? "selected" : "" ?>>Approved</option>
    <option value="disapproved" <?= $filter === "disapproved" ? "selected" : "" ?>>Disapproved</option>
  </select>
</form>

<?php if ($reviews): ?>
  <div class="reviews-list">
    <?php foreach ($reviews as $r): ?>
      <div class="review-card">
        <h3><?= htmlspecialchars($r['dorm_name']) ?></h3>
        <p><strong>By:</strong> <?= htmlspecialchars($r['student_name']) ?></p>
        <p><strong>Room:</strong> <?= htmlspecialchars($r['room_type'] ?? 'N/A') ?></p>
        <p>⭐ <?= $r['rating'] ?>/5</p>

        <?php 
          $clean_comment = highlight_bad_words(
              nl2br(htmlspecialchars($r['comment'])),
              $bad_words
          );
        ?>

        <p><?= $clean_comment ?></p>

        <small><?= date("M d, Y H:i", strtotime($r['created_at'])) ?></small>

        <div class="review-actions">
          <form method="post" style="display:inline-block; margin-right:8px;">
            <input type="hidden" name="review_id" value="<?= (int)$r['review_id'] ?>">
            <input type="hidden" name="action" value="disapprove">
            <button type="submit" class="btn btn-outline-danger">Disapprove</button>
          </form>

          <form method="post" style="display:inline-block;">
            <input type="hidden" name="review_id" value="<?= (int)$r['review_id'] ?>">
            <input type="hidden" name="action" value="approve">
            <button type="submit" class="btn btn-primary">Approve</button>
          </form>
        </div>
      </div>
    <?php endforeach; ?>
  </div>
<?php else: ?>
  <p><em>No reviews found.</em></p>
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
  box-shadow: 0 4px 10px rgba(0,0,0,0.08);
}
.review-actions button {
  cursor: pointer;
}
</style>

<?php include __DIR__ . '/../../partials/footer.php'; ?>