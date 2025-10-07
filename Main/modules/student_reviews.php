<?php
require_once __DIR__ . '/../auth.php';
require_role('student');
require_once __DIR__ . '/../config.php';

$page_title = "My Reviews";
include __DIR__ . '/../partials/header.php';

$student_id = $_SESSION['user']['user_id'];

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['submit_review'])) {
    $booking_id = intval($_POST['booking_id']);
    $rating = intval($_POST['rating']);
    $comment = trim($_POST['comment']);

    $stmt = $pdo->prepare("
        INSERT INTO reviews (booking_id, student_id, dorm_id, rating, comment)
        SELECT b.booking_id, b.student_id, r.dorm_id, ?, ?
        FROM bookings b
        JOIN rooms r ON b.room_id = r.room_id
        WHERE b.booking_id = ? AND b.student_id = ?
    ");
    $stmt->execute([$rating, $comment, $booking_id, $student_id]);
}

$stmt = $pdo->prepare("
    SELECT b.booking_id, d.name AS dorm_name, r2.review_id, r2.rating, r2.comment, r2.status
    FROM bookings b
    JOIN rooms r ON b.room_id = r.room_id
    JOIN dormitories d ON r.dorm_id = d.dorm_id
    LEFT JOIN reviews r2 ON b.booking_id = r2.booking_id
    WHERE b.student_id = ? AND b.status = 'completed'
    ORDER BY b.booking_id DESC
");
$stmt->execute([$student_id]);
$bookings = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

<div class="page-header">
  <h1>My Reviews</h1>
  <p>Leave feedback on dorms you’ve stayed at</p>
</div>

<div class="reviews-list">
  <?php foreach ($bookings as $b): ?>
    <div class="review-card">
      <h3><?= htmlspecialchars($b['dorm_name']) ?></h3>
      <?php if ($b['review_id']): ?>
        <p>⭐ <?= $b['rating'] ?>/5</p>
        <p><?= nl2br(htmlspecialchars($b['comment'])) ?></p>
        <small>Status: <?= htmlspecialchars($b['status']) ?></small>
      <?php else: ?>
        <form method="POST">
          <input type="hidden" name="booking_id" value="<?= $b['booking_id'] ?>">
          <label>Rating:</label>
          <select name="rating" required>
            <option value="">Select</option>
            <?php for ($i=1; $i<=5; $i++): ?>
              <option value="<?= $i ?>"><?= $i ?></option>
            <?php endfor; ?>
          </select>
          <textarea name="comment" placeholder="Leave a comment"></textarea>
          <button type="submit" name="submit_review" class="btn-primary">Submit Review</button>
        </form>
      <?php endif; ?>
    </div>
  <?php endforeach; ?>
</div>

<?php include __DIR__ . '/../partials/footer.php'; ?>