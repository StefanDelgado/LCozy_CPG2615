<?php 
require_once __DIR__ . '/partials/header.php'; 
require_role('owner');
require_once __DIR__ . '/config.php';

$user_id = current_user()['user_id'];

$stmt = $pdo->prepare("SELECT COUNT(*) FROM dormitories WHERE owner_id = ?");
$stmt->execute([$user_id]);
$dorm_count = (int)$stmt->fetchColumn();

$stmt = $pdo->prepare("SELECT COUNT(*) FROM bookings b JOIN rooms r ON b.room_id = r.room_id JOIN dormitories d ON r.dorm_id = d.dorm_id WHERE d.owner_id = ? AND b.status = 'pending'");
$stmt->execute([$user_id]);
$pending_bookings = (int)$stmt->fetchColumn();

$stmt = $pdo->prepare("SELECT COUNT(*) FROM bookings b JOIN rooms r ON b.room_id = r.room_id JOIN dormitories d ON r.dorm_id = d.dorm_id WHERE d.owner_id = ? AND b.status = 'approved'");
$stmt->execute([$user_id]);
$active_bookings = (int)$stmt->fetchColumn();

$stmt = $pdo->prepare("SELECT COALESCE(SUM(amount),0) FROM payments p JOIN bookings b ON p.booking_id = b.booking_id JOIN rooms r ON b.room_id = r.room_id JOIN dormitories d ON r.dorm_id = d.dorm_id WHERE d.owner_id = ? AND p.status = 'pending'");
$stmt->execute([$user_id]);
$payments_due = (float)$stmt->fetchColumn();

$stmt = $pdo->prepare("SELECT COUNT(*) FROM messages WHERE receiver_id = ? AND read_at IS NULL");
$stmt->execute([$user_id]);
$unread_messages = (int)$stmt->fetchColumn();

$stmt = $pdo->prepare("
    SELECT COUNT(*)
    FROM announcements a
    LEFT JOIN announcement_reads ar ON a.id = ar.announcement_id AND ar.user_id = ?
    WHERE ar.read_at IS NULL
      AND (
        a.audience = 'All Hosts'
        OR a.audience IN ('Verified Owners','Pending Owners')
      )
");
$stmt->execute([$user_id]);
$unread_announcements = (int)$stmt->fetchColumn();

$stmt = $pdo->prepare("
    SELECT b.booking_id, b.status, b.start_date, b.end_date,
           u.name AS student_name, r.room_type, d.name AS dorm_name
    FROM bookings b
    JOIN rooms r ON b.room_id = r.room_id
    JOIN dormitories d ON r.dorm_id = d.dorm_id
    JOIN users u ON b.student_id = u.user_id
    WHERE d.owner_id = ?
    ORDER BY b.created_at DESC
    LIMIT 5
");
$stmt->execute([$user_id]);
$recent_bookings = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

<div class="page-header">
  <h1>Owner Dashboard</h1>
  <p>Welcome back, <?= htmlspecialchars(current_user()['name']) ?>! Here’s your management overview.</p>
</div>

<div class="stats-grid">
  <div class="stat-card">
    <h3><?= $dorm_count ?></h3>
    <p>My Dorms</p>
  </div>
  <div class="stat-card">
    <h3><?= $pending_bookings ?></h3>
    <p>Pending Bookings</p>
  </div>
  <div class="stat-card">
    <h3><?= $active_bookings ?></h3>
    <p>Active Bookings</p>
  </div>
  <div class="stat-card">
    <h3>₱<?= number_format($payments_due, 2) ?></h3>
    <p>Payments Due</p>
  </div>
  <div class="stat-card">
    <h3><?= $unread_messages ?></h3>
    <p>Unread Messages</p>
  </div>
  <div class="stat-card">
    <h3><?= $unread_announcements ?></h3>
    <p>Announcements</p>
  </div>
</div>

<div class="section">
  <h2>Quick Actions</h2>
  <div class="actions">
    <a href="/CAPSTONE/modules/owner_dorms.php" class="btn-primary">Manage Dorms</a>
    <a href="/CAPSTONE/modules/owner_bookings.php" class="btn-secondary">Bookings</a>
    <a href="/CAPSTONE/modules/owner_payments.php" class="btn-secondary">Payments</a>
    <a href="/CAPSTONE/modules/owner_messages.php" class="btn-secondary">Messages</a>
    <a href="/CAPSTONE/modules/owner_announcements.php" class="btn-secondary">Announcements</a>
  </div>
</div>

<div class="section">
  <h2>Recent Bookings</h2>
  <?php if ($recent_bookings): ?>
  <table class="data-table">
    <thead>
      <tr>
        <th>Student</th>
        <th>Dorm</th>
        <th>Room</th>
        <th>Status</th>
        <th>Check-in</th>
        <th>Check-out</th>
      </tr>
    </thead>
    <tbody>
      <?php foreach ($recent_bookings as $b): ?>
      <tr>
        <td><?= htmlspecialchars($b['student_name']) ?></td>
        <td><?= htmlspecialchars($b['dorm_name']) ?></td>
        <td><?= htmlspecialchars($b['room_type']) ?></td>
        <td><span class="status <?= htmlspecialchars($b['status']) ?>"><?= ucfirst($b['status']) ?></span></td>
        <td><?= htmlspecialchars($b['start_date']) ?></td>
        <td><?= htmlspecialchars($b['end_date']) ?></td>
      </tr>
      <?php endforeach; ?>
    </tbody>
  </table>
  <?php else: ?>
    <p><em>No recent bookings found.</em></p>
  <?php endif; ?>
</div>

<?php require_once __DIR__ . '/partials/footer.php'; ?>