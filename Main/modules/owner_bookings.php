<?php
require_once __DIR__ . '/../auth.php';
require_role('owner');
require_once __DIR__ . '/../config.php';

$page_title = "My Bookings";
include __DIR__ . '/../partials/header.php';

$owner_id = $_SESSION['user']['user_id'];

$sql = "
    SELECT 
        b.booking_id,
        b.status,
        b.start_date,
        b.end_date,
        u.user_id AS student_id,
        u.name AS student_name,
        u.email,
        u.phone,
        r.room_type,
        r.capacity,
        d.name AS dorm_name
    FROM bookings b
    JOIN users u ON b.student_id = u.user_id
    JOIN rooms r ON b.room_id = r.room_id
    JOIN dormitories d ON r.dorm_id = d.dorm_id
    WHERE d.owner_id = ?
    ORDER BY FIELD(b.status, 'pending', 'approved', 'rejected', 'cancelled'), b.start_date DESC
";
$stmt = $pdo->prepare($sql);
$stmt->execute([$owner_id]);
$bookings = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

<div class="page-header">
  <p>View all students who have booked, are approved, or currently staying in your dorms.</p>
</div>

<div class="card">
  <table class="data-table">
    <thead>
      <tr>
        <th>Student</th>
        <th>Email</th>
        <th>Phone</th>
        <th>Dorm</th>
        <th>Room Type</th>
        <th>Capacity</th>
        <th>Booking Period</th>
        <th>Status</th>
        <th>Actions</th>
      </tr>
    </thead>
    <tbody>
      <?php if (empty($bookings)): ?>
        <tr><td colspan="9" style="text-align:center;">No bookings found.</td></tr>
      <?php else: ?>
        <?php foreach ($bookings as $b): ?>
        <tr>
          <td><?= htmlspecialchars($b['student_name']) ?></td>
          <td><?= htmlspecialchars($b['email']) ?></td>
          <td><?= htmlspecialchars($b['phone'] ?? 'N/A') ?></td>
          <td><?= htmlspecialchars($b['dorm_name']) ?></td>
          <td><?= htmlspecialchars($b['room_type']) ?></td>
          <td><?= htmlspecialchars($b['capacity']) ?></td>
          <td>
            <?= htmlspecialchars($b['start_date'] ?? '—') ?> 
            <?php if ($b['end_date']): ?> → <?= htmlspecialchars($b['end_date']) ?><?php endif; ?>
          </td>
          <td>
            <span class="badge <?= strtolower($b['status']) ?>">
              <?= ucfirst($b['status']) ?>
            </span>
          </td>
          <td>
            <a href="owner_messages.php?recipient_id=<?= $b['student_id'] ?>" class="btn-secondary">Contact</a>
          </td>
        </tr>
        <?php endforeach; ?>
      <?php endif; ?>
    </tbody>
  </table>
</div>

<style>
.badge {
  padding: 4px 8px;
  border-radius: 6px;
  font-size: 0.9em;
  color: #fff;
}
.badge.pending { background: #ffc107; color: #000; }
.badge.approved { background: #28a745; }
.badge.rejected { background: #dc3545; }
.badge.cancelled { background: #6c757d; }
.badge.completed { background: #17a2b8; }
.btn-secondary {
  background: #007bff;
  color: #fff;
  padding: 4px 8px;
  border-radius: 5px;
  text-decoration: none;
}
.btn-secondary:hover {
  background: #0056b3;
}
</style>

<?php require_once __DIR__ . '/../partials/footer.php'; ?>