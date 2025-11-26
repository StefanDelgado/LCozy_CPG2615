<?php
// past_tenants.php
require_once __DIR__ . '/../../auth/auth.php';
require_role('owner');
require_once __DIR__ . '/../../config.php';
include __DIR__ . '/../../partials/header.php';

$owner_id = $_SESSION['user']['user_id'] ?? 0;

$stmt = $pdo->prepare("
    SELECT t.*, u.name AS tenant_name, d.name AS dorm_name, r.room_type
    FROM tenants t
    JOIN bookings b ON t.booking_id = b.booking_id
    JOIN rooms r ON t.room_id = r.room_id
    JOIN dormitories d ON t.dorm_id = d.dorm_id
    JOIN users u ON t.student_id = u.user_id
    WHERE d.owner_id = ? AND t.status = 'completed'
    ORDER BY t.checkout_date DESC
");
$stmt->execute([$owner_id]);
$past = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

<div class="page-header">
  <h1>Past Tenants</h1>
  <p>Tenants who completed checkout.</p>
</div>

<?php if (empty($past)): ?>
  <p>No past tenants recorded yet.</p>
<?php else: ?>
  <?php foreach ($past as $p): ?>
    <div class="card" style="padding:12px;margin-bottom:12px;">
      <strong><?= htmlspecialchars($p['tenant_name']) ?> — <?= htmlspecialchars($p['dorm_name']) ?></strong>
      <div>Check-in: <?= htmlspecialchars($p['check_in_date']) ?> | Checkout: <?= htmlspecialchars($p['checkout_date']) ?></div>
      <div>Total paid: ₱<?= number_format($p['total_paid'] ?? 0,2) ?> | Outstanding: ₱<?= number_format($p['outstanding_balance'] ?? 0,2) ?></div>
    </div>
  <?php endforeach; ?>
<?php endif; ?>

<?php include __DIR__ . '/../../partials/footer.php'; ?>