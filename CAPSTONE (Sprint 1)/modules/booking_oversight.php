<?php 
require_once __DIR__ . '/../partials/header.php'; 
require_role('admin');
require_once __DIR__ . '/../config.php';

$page_title = "Booking & Reservation";

$sql = "
    SELECT b.booking_id, b.status, b.start_date, b.end_date,
           u.name AS student_name, d.name AS dorm_name
    FROM bookings b
    JOIN users u ON b.student_id = u.user_id
    JOIN rooms r ON b.room_id = r.room_id
    JOIN dormitories d ON r.dorm_id = d.dorm_id
    ORDER BY b.created_at DESC
";
$bookings = $pdo->query($sql)->fetchAll(PDO::FETCH_ASSOC);
?>

<div class="page-header">
  <h1>Booking & Reservation</h1>
  <p>Monitor reservation activities, booking trends, and review requests</p>
</div>

<div class="stats-grid">
  <div class="stat-card">
    <h3><?= count(array_filter($bookings, fn($b) => $b['status']==='pending')) ?></h3>
    <p>Pending Requests</p>
  </div>
  <div class="stat-card">
    <h3><?= count($bookings) ?></h3>
    <p>Total Reservations</p>
  </div>
  <div class="stat-card">
    <h3>
      <?php 
      $approved = count(array_filter($bookings, fn($b) => $b['status']==='approved'));
      echo count($bookings) ? round(($approved / count($bookings)) * 100) . "%" : "0%";
      ?>
    </h3>
    <p>Approval Rate</p>
  </div>
  <div class="stat-card">
    <h3><?= count(array_filter($bookings, fn($b) => $b['status']==='cancelled')) ?></h3>
    <p>Cancellations</p>
  </div>
</div>

<div class="section">
  <h2>Review Bookings</h2>
  <table class="data-table">
    <thead>
      <tr>
        <th>ID</th>
        <th>Student</th>
        <th>Dorm</th>
        <th>Start</th>
        <th>End</th>
        <th>Status</th>
        <th>Actions</th>
      </tr>
    </thead>
    <tbody>
      <?php foreach ($bookings as $b): ?>
        <tr>
          <td><?= htmlspecialchars($b['booking_id']) ?></td>
          <td><?= htmlspecialchars($b['student_name']) ?></td>
          <td><?= htmlspecialchars($b['dorm_name']) ?></td>
          <td><?= htmlspecialchars($b['start_date']) ?></td>
          <td><?= htmlspecialchars($b['end_date']) ?></td>
          <td>
            <span class="status <?= $b['status'] ?>">
              <?= ucfirst($b['status']) ?>
            </span>
          </td>
          <td>
            <?php if ($b['status'] === 'pending'): ?>
              <form method="post" style="display:inline">
                <input type="hidden" name="approve_id" value="<?= $b['booking_id'] ?>">
                <button class="btn-primary">Approve</button>
              </form>
              <form method="post" style="display:inline">
                <input type="hidden" name="reject_id" value="<?= $b['booking_id'] ?>">
                <button class="btn-secondary">Reject</button>
              </form>
            <?php else: ?>
              <button class="btn-secondary">View</button>
            <?php endif; ?>
          </td>
        </tr>
      <?php endforeach; ?>
    </tbody>
  </table>
</div>

<?php require_once __DIR__ . '/../partials/footer.php'; ?>