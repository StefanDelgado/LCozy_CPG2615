<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/../../auth/auth.php';
require_role('admin');
require_role('superadmin');

// Date range filter
$start_date = $_GET['start_date'] ?? date('Y-m-01'); // First day of current month
$end_date = $_GET['end_date'] ?? date('Y-m-d'); // Today

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

// ✅ Payments grouped by STATUS (with fixed categories)
$payment_status = $pdo->query("
    SELECT 
        CASE 
            WHEN status = 'paid' THEN 'Paid'
            WHEN status = 'pending' THEN 'Pending'
            WHEN status = 'expired' THEN 'Expired'
            ELSE 'Other'
        END AS status_label,
        COUNT(*) AS count,
        COALESCE(SUM(amount), 0) AS total
    FROM payments
    GROUP BY status_label
")->fetchAll(PDO::FETCH_ASSOC);

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
const paymentStatus = <?= json_encode($payment_status) ?>;

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

// ✅ Payments by Status Chart (with fixed 3 colors)
new Chart(document.getElementById('paymentStatus').getContext('2d'), {
    type: 'doughnut',
    data: {
        labels: paymentStatus.map(p => p.status_label),
        datasets: [{
            data: paymentStatus.map(p => p.total),
            backgroundColor: ['#dc3545', '#ffc107', '#28a745']
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
.stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
    gap: 1rem;
    margin-bottom: 2rem;
}
.stat-card {
    background: white;
    padding: 1.5rem;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.05);
}
.stat-card h3 { margin: 0; font-size: 1.8rem; color: #4A3AFF; }
.stat-card p { margin: 0.5rem 0; color: #666; }
.stat-card small { color: #999; font-size: 0.9rem; }
.reports-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
    gap: 2rem;
    margin: 2rem 0;
}
.chart-card {
    background: white;
    padding: 1.5rem;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.05);
}
.date-filter { display: flex; gap: 1rem; align-items: center; }
.table { width: 100%; border-collapse: collapse; }
.table th, .table td { padding: 0.75rem; border-bottom: 1px solid #eee; }
.table th { background: #f8f9fa; font-weight: 600; }
.table-responsive { overflow-x: auto; }
</style>

<?php require_once __DIR__ . '/../../partials/footer.php'; ?>
