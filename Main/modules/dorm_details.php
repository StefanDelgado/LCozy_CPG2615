<?php
require_once __DIR__ . '/../auth.php';
require_role('student');
require_once __DIR__ . '/../config.php';

$dorm_id = intval($_GET['id'] ?? 0);
$student_id = $_SESSION['user']['user_id'];

if (!$dorm_id) {
    header("Location: available_dorms.php");
    exit;
}

$page_title = "Dorm Details";
include __DIR__ . '/../partials/header.php';

$flash = null;

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['submit_review'])) {
    $rating = intval($_POST['rating']);
    $review_text = trim($_POST['review_text']);

    if ($rating >= 1 && $rating <= 5 && $review_text) {
        try {
            $stmt = $pdo->prepare("
                INSERT INTO reviews (dorm_id, student_id, rating, review, status, created_at)
                VALUES (?, ?, ?, ?, 'pending', NOW())
            ");
            $stmt->execute([$dorm_id, $student_id, $rating, $review_text]);

            $flash = ['type'=>'success','msg'=>'Your review has been submitted and is awaiting approval.'];
        } catch (Exception $e) {
            $flash = ['type'=>'error','msg'=>'Error: Could not submit review.'];
        }
    } else {
        $flash = ['type'=>'error','msg'=>'Please provide a rating and review text.'];
    }
}

$stmt = $pdo->prepare("
    SELECT d.*, u.name AS owner_name,
           COALESCE(AVG(r.rating), 0) AS avg_rating,
           COUNT(r.review_id) AS total_reviews
    FROM dormitories d
    JOIN users u ON d.owner_id = u.user_id
    LEFT JOIN reviews r ON d.dorm_id = r.dorm_id AND r.status = 'approved'
    WHERE d.dorm_id = ?
    GROUP BY d.dorm_id
");
$stmt->execute([$dorm_id]);
$dorm = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$dorm) {
    echo "<p><em>Dorm not found.</em></p>";
    include __DIR__ . '/../partials/footer.php';
    exit;
}

$stmt = $pdo->prepare("
    SELECT r.*, s.name AS student_name
    FROM reviews r
    JOIN users s ON r.student_id = s.user_id
    WHERE r.dorm_id = ? AND r.status = 'approved'
    ORDER BY r.created_at DESC
");
$stmt->execute([$dorm_id]);
$reviews = $stmt->fetchAll(PDO::FETCH_ASSOC);

$stmt = $pdo->prepare("
    SELECT COUNT(*) FROM bookings b
    JOIN rooms r ON b.room_id = r.room_id
    WHERE b.student_id = ? AND r.dorm_id = ? AND b.status IN ('active','completed')
");
$stmt->execute([$student_id, $dorm_id]);
$can_review = $stmt->fetchColumn() > 0;
?>

<?php if ($flash): ?>
<div class="alert <?= $flash['type'] ?>"><?= htmlspecialchars($flash['msg']) ?></div>
<?php endif; ?>

<div class="page-header">
  <h1><?= htmlspecialchars($dorm['name']) ?></h1>
  <p><strong>Owner:</strong> <?= htmlspecialchars($dorm['owner_name']) ?></p>
  <p><strong>Address:</strong> <?= htmlspecialchars($dorm['address']) ?></p>
  <p><?= nl2br(htmlspecialchars($dorm['description'])) ?></p>

  <div class="rating">
    <?php if ($dorm['total_reviews'] > 0): ?>
      ⭐ <?= number_format($dorm['avg_rating'], 1) ?>/5 
      (<?= $dorm['total_reviews'] ?> reviews)
    <?php else: ?>
      <em>No reviews yet</em>
    <?php endif; ?>
  </div>
</div>

<div class="section">
  <h2>Student Reviews</h2>
  <?php if ($reviews): ?>
    <?php foreach ($reviews as $rev): ?>
      <div class="review-card">
        <div class="review-header">
          <strong><?= htmlspecialchars($rev['student_name']) ?></strong>
          <span class="stars">⭐ <?= $rev['rating'] ?>/5</span>
        </div>
        <p><?= nl2br(htmlspecialchars($rev['review'])) ?></p>
        <small><?= htmlspecialchars(date("M d, Y H:i", strtotime($rev['created_at']))) ?></small>
      </div>
    <?php endforeach; ?>
  <?php else: ?>
    <p><em>No reviews yet. Be the first to leave one!</em></p>
  <?php endif; ?>
</div>

<?php if ($can_review): ?>
<div class="section">
  <h2>Leave a Review</h2>
  <form method="post" class="review-form">
    <label for="rating">Rating</label>
    <select name="rating" id="rating" required>
      <option value="">Select</option>
      <?php for ($i=1; $i<=5; $i++): ?>
        <option value="<?= $i ?>"><?= $i ?> Star<?= $i>1?'s':'' ?></option>
      <?php endfor; ?>
    </select>

    <label for="review_text">Your Review</label>
    <textarea name="review_text" id="review_text" rows="4" required></textarea>

    <button type="submit" name="submit_review" class="btn-primary">Submit Review</button>
  </form>
</div>
<?php else: ?>
<div class="section">
  <p><em>You must have booked this dorm to leave a review.</em></p>
</div>
<?php endif; ?>

<style>
.review-card {
  border: 1px solid #eee;
  padding: 12px;
  margin-bottom: 12px;
  border-radius: 8px;
  background: #fafafa;
}
.review-header {
  display: flex;
  justify-content: space-between;
  font-weight: bold;
}
.stars {
  color: #ff9800;
}
.review-form {
  display: flex;
  flex-direction: column;
  gap: 10px;
}
.review-form select, .review-form textarea {
  padding: 8px;
  border-radius: 6px;
  border: 1px solid #ccc;
}
</style>

<?php include __DIR__ . '/../partials/footer.php'; ?>