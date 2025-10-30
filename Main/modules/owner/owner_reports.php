<?php
require_once __DIR__ . '/../../auth/auth.php';
require_role('owner');
require_once __DIR__ . '/../../config.php';

include __DIR__ . '/../../partials/header.php';

$owner_id = $_SESSION['user']['user_id'];

$summary = [
    'total_income' => 0,
    'active_tenants' => 0,
    'new_bookings' => 0,
    'average_rating' => 0,
];

try {
    // --- BOOKING ANALYTICS ---
    $stmt = $pdo->prepare("
        SELECT COUNT(*) FROM bookings b
        JOIN dormitories d ON b.dorm_id = d.dorm_id
        WHERE d.owner_id = ? 
          AND MONTH(b.created_at) = MONTH(CURDATE()) 
          AND YEAR(b.created_at) = YEAR(CURDATE())
    ");
    $stmt->execute([$owner_id]);
    $summary['new_bookings'] = (int)$stmt->fetchColumn();

    $occupancy_stmt = $pdo->prepare("
        SELECT d.name, 
               COUNT(b.booking_id) AS total_bookings, 
               SUM(CASE WHEN b.status = 'confirmed' THEN 1 ELSE 0 END) AS confirmed_bookings
        FROM dormitories d
        LEFT JOIN bookings b ON d.dorm_id = b.dorm_id
        WHERE d.owner_id = ?
        GROUP BY d.dorm_id
    ");
    $occupancy_stmt->execute([$owner_id]);
    $occupancy_data = $occupancy_stmt->fetchAll(PDO::FETCH_ASSOC);

    $status_stmt = $pdo->prepare("
        SELECT b.status, COUNT(*) AS count
        FROM bookings b
        JOIN dormitories d ON b.dorm_id = d.dorm_id
        WHERE d.owner_id = ?
        GROUP BY b.status
    ");
    $status_stmt->execute([$owner_id]);
    $booking_status_data = $status_stmt->fetchAll(PDO::FETCH_ASSOC);

    // --- PAYMENT REPORTS ---
    $stmt = $pdo->prepare("
        SELECT SUM(amount) as total_income 
        FROM payments p 
        JOIN dormitories d ON p.dorm_id = d.dorm_id 
        WHERE d.owner_id = ? AND p.status = 'paid'
    ");
    $stmt->execute([$owner_id]);
    $summary['total_income'] = (float)($stmt->fetchColumn() ?? 0);

    $income_stmt = $pdo->prepare("
        SELECT DATE_FORMAT(p.created_at, '%b %Y') as month, SUM(p.amount) as total
        FROM payments p
        JOIN dormitories d ON p.dorm_id = d.dorm_id
        WHERE d.owner_id = ? AND p.status = 'paid'
        GROUP BY YEAR(p.created_at), MONTH(p.created_at)
        ORDER BY p.created_at ASC
    ");
    $income_stmt->execute([$owner_id]);
    $income_trends = $income_stmt->fetchAll(PDO::FETCH_ASSOC);

    // --- TENANT REPORTS ---
    $stmt = $pdo->prepare("
        SELECT COUNT(DISTINCT t.tenant_id)
        FROM tenants t
        JOIN dormitories d ON t.dorm_id = d.dorm_id
        WHERE d.owner_id = ? AND t.status = 'active'
    ");
    $stmt->execute([$owner_id]);
    $summary['active_tenants'] = (int)$stmt->fetchColumn();

    $new_tenants_stmt = $pdo->prepare("
        SELECT COUNT(*) FROM tenants t
        JOIN dormitories d ON t.dorm_id = d.dorm_id
        WHERE d.owner_id = ? 
        AND MONTH(t.created_at) = MONTH(CURDATE()) AND YEAR(t.created_at) = YEAR(CURDATE())
    ");
    $new_tenants_stmt->execute([$owner_id]);
    $new_tenants = (int)$new_tenants_stmt->fetchColumn();

    // --- REVIEW SUMMARY ---
    $stmt = $pdo->prepare("
        SELECT ROUND(AVG(r.rating),1) FROM reviews r
        JOIN dormitories d ON r.dorm_id = d.dorm_id
        WHERE d.owner_id = ? AND r.status = 'approved'
    ");
    $stmt->execute([$owner_id]);
    $summary['average_rating'] = (float)($stmt->fetchColumn() ?? 0);

    $rating_stmt = $pdo->prepare("
        SELECT r.rating, COUNT(*) as count
        FROM reviews r
        JOIN dormitories d ON r.dorm_id = d.dorm_id
        WHERE d.owner_id = ? AND r.status = 'approved'
        GROUP BY r.rating
    ");
    $rating_stmt->execute([$owner_id]);
    $rating_data = $rating_stmt->fetchAll(PDO::FETCH_ASSOC);

    // --- RECENT ACTIVITY (Bookings, Payments, Reviews) ---
    $recent_bookings = $pdo->prepare("
        SELECT b.booking_id, u.name AS student_name, d.name AS dorm_name, b.status, b.created_at
        FROM bookings b
        JOIN dormitories d ON b.dorm_id = d.dorm_id
        LEFT JOIN users u ON b.student_id = u.user_id
        WHERE d.owner_id = ?
        ORDER BY b.created_at DESC
        LIMIT 5
    ");
    $recent_bookings->execute([$owner_id]);
    $recent_bookings = $recent_bookings->fetchAll(PDO::FETCH_ASSOC);

    $recent_payments = $pdo->prepare("
        SELECT p.payment_id, p.amount, p.status, d.name AS dorm_name, p.created_at
        FROM payments p
        JOIN dormitories d ON p.dorm_id = d.dorm_id
        WHERE d.owner_id = ?
        ORDER BY p.created_at DESC
        LIMIT 5
    ");
    $recent_payments->execute([$owner_id]);
    $recent_payments = $recent_payments->fetchAll(PDO::FETCH_ASSOC);

    $recent_reviews = $pdo->prepare("
        SELECT r.review_id, u.name AS student_name, d.name AS dorm_name, r.rating, r.comment, r.created_at
        FROM reviews r
        JOIN dormitories d ON r.dorm_id = d.dorm_id
        LEFT JOIN users u ON r.student_id = u.user_id
        WHERE d.owner_id = ? AND r.status = 'approved'
        ORDER BY r.created_at DESC
        LIMIT 5
    ");
    $recent_reviews->execute([$owner_id]);
    $recent_reviews = $recent_reviews->fetchAll(PDO::FETCH_ASSOC);

} catch (Exception $e) {
    error_log("Owner reports error: " . $e->getMessage());
}
?>

<div class="page-header">
  <h1>Reports & Analytics</h1>
  <p>Track performance and insights across your dorms</p>
</div>

<!-- Summary Cards -->
<div class="stats-grid">
  <div class="stat-card">
    <h3>₱<?= number_format($summary['total_income'], 2) ?></h3>
    <p>Total Income (All Time)</p>
  </div>
  <div class="stat-card">
    <h3><?= $summary['active_tenants'] ?></h3>
    <p>Active Tenants</p>
  </div>
  <div class="stat-card">
    <h3><?= $summary['new_bookings'] ?></h3>
    <p>New Bookings (This Month)</p>
  </div>
  <div class="stat-card">
    <h3><?= $summary['average_rating'] ?>★</h3>
    <p>Average Rating</p>
  </div>
</div>

<!-- Charts -->
<div class="charts-section">
  <h2>Income Trend</h2>
  <canvas id="incomeChart"></canvas>

  <h2>Booking Status</h2>
  <canvas id="bookingChart"></canvas>

  <h2>Ratings Distribution</h2>
  <canvas id="ratingChart"></canvas>
</div>

<!-- Recent Activity -->
<div class="section recent-activity">
  <h2>Recent Activity</h2>
  <div class="activity-columns">
    <div class="activity-card">
      <h3>Recent Bookings</h3>
      <?php if ($recent_bookings): ?>
        <ul>
          <?php foreach ($recent_bookings as $b): ?>
            <li>
              <strong><?= htmlspecialchars($b['student_name'] ?? 'Unknown') ?></strong> — 
              <?= htmlspecialchars($b['dorm_name']) ?> (<?= htmlspecialchars($b['status']) ?>)
              <div><small><?= date("M d, Y H:i", strtotime($b['created_at'])) ?></small></div>
            </li>
          <?php endforeach; ?>
        </ul>
      <?php else: ?><p><em>No recent bookings.</em></p><?php endif; ?>
    </div>

    <div class="activity-card">
      <h3>Recent Payments</h3>
      <?php if ($recent_payments): ?>
        <ul>
          <?php foreach ($recent_payments as $p): ?>
            <li>
              <strong><?= htmlspecialchars($p['dorm_name']) ?></strong> — ₱<?= number_format($p['amount'],2) ?> (<?= htmlspecialchars($p['status']) ?>)
              <div><small><?= date("M d, Y H:i", strtotime($p['created_at'])) ?></small></div>
            </li>
          <?php endforeach; ?>
        </ul>
      <?php else: ?><p><em>No recent payments.</em></p><?php endif; ?>
    </div>

    <div class="activity-card">
      <h3>Recent Reviews</h3>
      <?php if ($recent_reviews): ?>
        <ul>
          <?php foreach ($recent_reviews as $r): ?>
            <li>
              <strong><?= htmlspecialchars($r['student_name'] ?? 'Anonymous') ?></strong> — 
              <?= htmlspecialchars($r['dorm_name']) ?> (<?= htmlspecialchars($r['rating']) ?>★)
              <div><em><?= htmlspecialchars(mb_strimwidth($r['comment'], 0, 60, '…')) ?></em></div>
              <div><small><?= date("M d, Y H:i", strtotime($r['created_at'])) ?></small></div>
            </li>
          <?php endforeach; ?>
        </ul>
      <?php else: ?><p><em>No recent reviews.</em></p><?php endif; ?>
    </div>
  </div>
</div>

<!-- Chart.js -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
new Chart(document.getElementById('incomeChart'), {
  type: 'line',
  data: {
    labels: <?= json_encode(array_column($income_trends ?? [], 'month')) ?>,
    datasets: [{
      label: 'Income',
      data: <?= json_encode(array_column($income_trends ?? [], 'total')) ?>,
      borderColor: 'rgba(75,192,192,1)',
      fill: false
    }]
  }
});

new Chart(document.getElementById('bookingChart'), {
  type: 'doughnut',
  data: {
    labels: <?= json_encode(array_column($booking_status_data ?? [], 'status')) ?>,
    datasets: [{
      data: <?= json_encode(array_column($booking_status_data ?? [], 'count')) ?>,
      backgroundColor: ['#36a2eb','#ff6384','#ffcd56']
    }]
  }
});

new Chart(document.getElementById('ratingChart'), {
  type: 'bar',
  data: {
    labels: <?= json_encode(array_column($rating_data ?? [], 'rating')) ?>,
    datasets: [{
      label: 'Reviews',
      data: <?= json_encode(array_column($rating_data ?? [], 'count')) ?>,
      backgroundColor: '#4bc0c0'
    }]
  }
});
</script>

<style>
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 16px;
  margin-bottom: 24px;
}
.stat-card {
  background: #fff;
  padding: 16px;
  border-radius: 10px;
  box-shadow: 0 3px 8px rgba(0,0,0,0.1);
  text-align: center;
}
.charts-section {
  background: #fff;
  padding: 20px;
  border-radius: 10px;
  box-shadow: 0 3px 8px rgba(0,0,0,0.1);
  margin-bottom: 24px;
}
.recent-activity {
  background: #fff;
  padding: 20px;
  border-radius: 10px;
  box-shadow: 0 3px 8px rgba(0,0,0,0.1);
}
.activity-columns {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
}
.activity-card {
  flex: 1 1 300px;
}
.activity-card ul {
  list-style: none;
  padding: 0;
  margin: 0;
}
.activity-card li {
  padding: 6px 0;
  border-bottom: 1px solid #eee;
}
.activity-card li small {
  color: #666;
  font-size: 0.85rem;
}
</style>

<?php include __DIR__ . '/../partials/footer.php'; ?>