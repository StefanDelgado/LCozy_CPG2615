<?php
require_once __DIR__ . '/../partials/header.php'; 
require_role('student');
require_once __DIR__ . '/../config.php';

$student_id = current_user()['user_id'];

$stmt = $pdo->prepare("
    SELECT COUNT(*) 
    FROM bookings 
    WHERE student_id = ? 
      AND status IN ('pending', 'approved')
");
$stmt->execute([$student_id]);
$active_reservations = $stmt->fetchColumn();

$stmt = $pdo->prepare("
    SELECT COALESCE(SUM(amount), 0) 
    FROM payments 
    WHERE student_id = ? 
      AND status = 'pending'
");
$stmt->execute([$student_id]);
$total_due = $stmt->fetchColumn();

try {
    $stmt = $pdo->prepare("
        SELECT COUNT(*) 
        FROM messages 
        WHERE receiver_id = ? 
          AND (status = 'unread' OR status IS NULL)
    ");
    $stmt->execute([$student_id]);
    $unread_messages = $stmt->fetchColumn();
} catch (PDOException $e) {
    $unread_messages = 0;
}

$stmt = $pdo->prepare("
    SELECT COUNT(*) 
    FROM announcements 
    WHERE recipient_type IN ('all', 'students')
       OR audience IN ('All', 'All Hosts', 'Students')
");
$stmt->execute();
$announcement_count = $stmt->fetchColumn();

$stmt = $pdo->prepare("
    SELECT 
        b.booking_id, b.start_date, b.end_date, b.status, 
        d.name AS dorm_name, 
        u.name AS owner_name
    FROM bookings b
    JOIN rooms r ON b.room_id = r.room_id
    JOIN dormitories d ON r.dorm_id = d.dorm_id
    JOIN users u ON d.owner_id = u.user_id
    WHERE b.student_id = ?
    ORDER BY b.created_at DESC
    LIMIT 5
");
$stmt->execute([$student_id]);
$recent_reservations = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

<div class="page-header">
  <h1>Student Dashboard</h1>
  <p>Welcome back, <?= htmlspecialchars(current_user()['name']) ?>! Here’s your latest activity summary.</p>
</div>

<div class="stats-grid">
  <div class="stat-card">
    <h3><?= htmlspecialchars($active_reservations) ?></h3>
    <p>Active Reservations</p>
  </div>
  <div class="stat-card">
    <h3>₱<?= number_format($total_due, 2) ?></h3>
    <p>Payments Due</p>
  </div>
  <div class="stat-card">
    <h3><?= htmlspecialchars($unread_messages) ?></h3>
    <p>Unread Messages</p>
  </div>
  <div class="stat-card">
    <h3><?= htmlspecialchars($announcement_count) ?></h3>
    <p>Active Announcements</p>
  </div>
</div>

<div class="section">
  <h2>Quick Actions</h2>
  <div class="actions">
    <a href="../modules/student/student_reservations.php" class="btn-primary">My Reservations</a>
    <a href="../modules/student/student_payments.php" class="btn-secondary">Payments</a>
    <a href="../modules/student/student_messages.php" class="btn-secondary">Messages</a>
    <a href="../modules/student/student_announcements.php" class="btn-secondary">Announcements</a>
  </div>
</div>

<div class="section">
  <h2>Recent Reservations</h2>
  <table class="data-table">
    <thead>
      <tr>
        <th>Dorm</th>
        <th>Owner</th>
        <th>Status</th>
        <th>Check-in</th>
        <th>Check-out</th>
      </tr>
    </thead>
    <tbody>
      <?php if ($recent_reservations): ?>
        <?php foreach ($recent_reservations as $r): ?>
          <tr>
            <td><?= htmlspecialchars($r['dorm_name']) ?></td>
            <td><?= htmlspecialchars($r['owner_name']) ?></td>
            <td>
              <span class="status <?= htmlspecialchars($r['status']) ?>">
                <?= ucfirst($r['status']) ?>
              </span>
            </td>
            <td><?= htmlspecialchars($r['start_date']) ?></td>
            <td><?= htmlspecialchars($r['end_date']) ?></td>
          </tr>
        <?php endforeach; ?>
      <?php else: ?>
        <tr><td colspan="5"><em>No reservations found.</em></td></tr>
      <?php endif; ?>
    </tbody>
  </table>
</div>

<style>
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
  margin-bottom: 2rem;
}
.stat-card {
  background: #fff;
  padding: 1.5rem;
  border-radius: 12px;
  text-align: center;
  box-shadow: 0 4px 10px rgba(0,0,0,0.05);
}
.stat-card h3 {
  font-size: 2rem;
  margin: 0;
  color: #6a5acd;
}
.stat-card p {
  color: #555;
}
.status {
  padding: 4px 8px;
  border-radius: 5px;
  color: #fff;
  font-size: 0.9em;
}
.status.pending { background: #ffc107; }
.status.approved { background: #28a745; }
.status.completed { background: #007bff; }
.status.cancelled { background: #dc3545; }
</style>

<?php require_once __DIR__ . '/../partials/footer.php'; ?>
