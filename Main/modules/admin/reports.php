<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/../../auth/auth.php';
require_role('admin');

// Date range filter (currently not used to restrict queries, but kept for UI)
$start_date = $_GET['start_date'] ?? date('Y-m-01');
$end_date   = $_GET['end_date']   ?? date('Y-m-d');

// Summary statistics
$stats = $pdo->query("
    SELECT 
        (SELECT COUNT(*) FROM bookings) as total_bookings,
        (SELECT COUNT(*) FROM bookings WHERE status = 'completed') as completed_bookings,
        (SELECT COUNT(DISTINCT student_id) FROM bookings WHERE status != 'cancelled') as active_students,
        (SELECT COUNT(*) FROM users WHERE role = 'owner' AND verified = 1) as verified_owners,
        (SELECT COALESCE(SUM(amount), 0) FROM payments WHERE status = 'paid') as total_revenue,
        (SELECT COUNT(*) FROM dormitories) as total_dorms,
        (SELECT COUNT(*) FROM rooms) as total_rooms,
        (SELECT COUNT(*) FROM reviews) as total_reviews
")->fetch(PDO::FETCH_ASSOC);

// Monthly trends (last 12 months)
$trends = $pdo->query("
    SELECT 
        DATE_FORMAT(created_at, '%Y-%m') as month,
        COUNT(*) as bookings,
        COUNT(DISTINCT student_id) as unique_students,
        COALESCE(SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END), 0) as completed,
        COALESCE(SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END), 0) as cancelled
    FROM bookings 
    WHERE created_at >= DATE_SUB(CURRENT_DATE, INTERVAL 12 MONTH)
    GROUP BY DATE_FORMAT(created_at, '%Y-%m')
    ORDER BY month DESC
")->fetchAll(PDO::FETCH_ASSOC);

// Top performing dorms
$top_dorms = $pdo->query("
    SELECT 
        dormitories.name,
        COUNT(bookings.booking_id) AS total_bookings,
        COALESCE(AVG(reviews.rating), 0) AS avg_rating,
        COUNT(DISTINCT reviews.review_id) AS review_count
    FROM dormitories
    LEFT JOIN rooms ON rooms.dorm_id = dormitories.dorm_id
    LEFT JOIN bookings ON bookings.room_id = rooms.room_id
    LEFT JOIN reviews ON reviews.booking_id = bookings.booking_id
    GROUP BY dormitories.dorm_id
    ORDER BY total_bookings DESC
    LIMIT 5
")->fetchAll(PDO::FETCH_ASSOC);

/**
 * Build payments-by-status aggregated data.
 * We will enforce a fixed order & labels so the chart colors do not mix up.
 * Desired order: Paid, Pending, Expired
 */
$fixed_statuses = [
    'Paid'    => '#28a745', // green
    'Pending' => '#ffc107', // yellow
    'Expired' => '#dc3545', // red
];

// fetch counts & totals grouped by raw status value
$raw = $pdo->query("
    SELECT status, COUNT(*) AS cnt, COALESCE(SUM(amount),0) AS total
    FROM payments
    GROUP BY status
")->fetchAll(PDO::FETCH_ASSOC);

// Normalize DB status -> label mapping
// Accept common DB values: 'paid','pending','expired' (case-insensitive)
$map = [
    'paid'    => 'Paid',
    'pending' => 'Pending',
    'expired' => 'Expired'
];

$payment_by_label = [];
foreach ($raw as $r) {
    $s = strtolower(trim($r['status'] ?? ''));
    $label = $map[$s] ?? 'Other';
    if (!isset($payment_by_label[$label])) {
        $payment_by_label[$label] = ['count' => 0, 'total' => 0.0];
    }
    $payment_by_label[$label]['count'] += (int)$r['cnt'];
    $payment_by_label[$label]['total'] += (float)$r['total'];
}

// Ensure all fixed statuses exist in the array (zero if missing)
foreach (array_keys($fixed_statuses) as $st) {
    if (!isset($payment_by_label[$st])) {
        $payment_by_label[$st] = ['count' => 0, 'total' => 0.0];
    }
}

// OPTIONAL: If you want to include "Other" statuses beyond the three, you can aggregate them
$other_total = 0.0;
$other_count = 0;
foreach ($payment_by_label as $label => $vals) {
    if (!array_key_exists($label, $fixed_statuses) && $label !== 'Other') {
        // treat as Other
        $other_total += $vals['total'];
        $other_count += $vals['count'];
        unset($payment_by_label[$label]);
    }
}
if ($other_count > 0) {
    // merge into 'Other' bucket
    if (!isset($payment_by_label['Other'])) {
        $payment_by_label['Other'] = ['count'=>0,'total'=>0.0];
    }
    $payment_by_label['Other']['count'] += $other_count;
    $payment_by_label['Other']['total'] += $other_total;
}

// Prepare arrays in fixed order for Chart.js
$chart_labels = [];
$chart_data   = [];
$chart_colors = [];

// Use fixed order for the three main statuses
foreach (array_keys($fixed_statuses) as $st) {
    $chart_labels[] = $st;
    $chart_data[]   = (float)($payment_by_label[$st]['total'] ?? 0.0);
    $chart_colors[] = $fixed_statuses[$st];
}

// If "Other" has a value, append it at the end with a neutral color
if (isset($payment_by_label['Other']) && $payment_by_label['Other']['total'] > 0) {
    $chart_labels[] = 'Other';
    $chart_data[]   = (float)$payment_by_label['Other']['total'];
    $chart_colors[] = '#6c757d'; // gray for Other
}

require_once __DIR__ . '/../../partials/header.php';
?>

<div class="page-header">
    <h1>Reports & Analytics</h1>
    <div class="date-filter">
        <form method="GET" class="form-inline">
            <input type="date" name="start_date" value="<?= htmlspecialchars($start_date) ?>">
            <input type="date" name="end_date" value="<?= htmlspecialchars($end_date) ?>">
            <button type="submit" class="btn">Filter</button>
        </form>
    </div>
</div>

<!-- Summary Cards -->
<div class="stats-grid">
    <div class="stat-card">
        <h3><?= number_format($stats['total_bookings']) ?></h3>
        <p>Total Bookings</p>
        <small><?= number_format($stats['completed_bookings']) ?> completed</small>
    </div>
    <div class="stat-card">
        <h3>₱<?= number_format($stats['total_revenue'], 2) ?></h3>
        <p>Total Revenue</p>
    </div>
    <div class="stat-card">
        <h3><?= number_format($stats['active_students']) ?></h3>
        <p>Active Students</p>
    </div>
    <div class="stat-card">
        <h3><?= number_format($stats['verified_owners']) ?></h3>
        <p>Verified Owners</p>
        <small><?= number_format($stats['total_dorms']) ?> dorms listed</small>
    </div>
</div>

<!-- Charts Section -->
<div class="reports-grid">
    <div class="chart-card">
        <h2>Monthly Booking Trends</h2>
        <canvas id="bookingTrends"></canvas>
    </div>
    <div class="chart-card">
        <h2>Payments by Status</h2>
        <canvas id="paymentStatus"></canvas>
    </div>
</div>

<!-- Top Performing Dorms -->
<div class="section">
    <h2>Top Performing Dorms</h2>
    <div class="table-responsive">
        <table class="table">
            <thead>
                <tr>
                    <th>Dorm Name</th>
                    <th>Total Bookings</th>
                    <th>Average Rating</th>
                    <th>Reviews</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($top_dorms as $dorm): ?>
                <tr>
                    <td><?= htmlspecialchars($dorm['name']) ?></td>
                    <td><?= number_format($dorm['total_bookings']) ?></td>
                    <td><?= number_format($dorm['avg_rating'], 1) ?> ⭐</td>
                    <td><?= number_format($dorm['review_count']) ?></td>
                </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
const trends = <?= json_encode($trends) ?>;
const paymentLabels = <?= json_encode($chart_labels) ?>;
const paymentData   = <?= json_encode($chart_data) ?>;
const paymentColors = <?= json_encode($chart_colors) ?>;

// Booking Trends Chart
new Chart(document.getElementById('bookingTrends').getContext('2d'), {
    type: 'line',
    data: {
        labels: trends.map(t => t.month),
        datasets: [
            {
                label: 'Total Bookings',
                data: trends.map(t => t.bookings),
                borderColor: '#4A3AFF',
                backgroundColor: 'rgba(74,58,255,0.1)',
                fill: true
            },
            {
                label: 'Completed',
                data: trends.map(t => t.completed),
                borderColor: '#28a745',
                backgroundColor: 'rgba(40,167,69,0.1)',
                fill: true
            }
        ]
    },
    options: {
        responsive: true,
        plugins: { title: { display: true, text: 'Monthly Booking Trends' } }
    }
});

// Payments by Status (fixed color mapping)
new Chart(document.getElementById('paymentStatus').getContext('2d'), {
    type: 'doughnut',
    data: {
        labels: paymentLabels,
        datasets: [{
            data: paymentData,
            backgroundColor: paymentColors
        }]
    },
    options: {
        responsive: true,
        plugins: { title: { display: true, text: 'Payments by Status' } },
        cutout: '70%'
    }
});
</script>

<style>
/* styles unchanged (kept minimal here) */
.stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px,1fr)); gap: 1rem; margin-bottom: 2rem; }
.stat-card { background: white; padding: 1.5rem; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }
.reports-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(400px,1fr)); gap: 2rem; margin: 2rem 0; }
.chart-card { background: white; padding: 1.5rem; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }
.table { width: 100%; border-collapse: collapse; } .table th, .table td { padding: 0.75rem; border-bottom: 1px solid #eee; }
</style>

<?php require_once __DIR__ . '/../../partials/footer.php'; ?>