<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

require_once __DIR__ . '/../config.php';
require_once __DIR__ . '/../auth.php';
require_role('admin');

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

// Top performing dorms (NO aliases)
$top_dorms = $pdo->query("
    SELECT 
        dormitories.name,
        COUNT(bookings.booking_id) as total_bookings,
        COALESCE(AVG(reviews.rating), 0) as avg_rating,
        COUNT(DISTINCT reviews.id) as review_count
    FROM dormitories
    LEFT JOIN rooms ON rooms.dorm_id = dormitories.dorm_id
    LEFT JOIN bookings ON bookings.room_id = rooms.room_id
    LEFT JOIN reviews ON reviews.booking_id = bookings.booking_id
    GROUP BY dormitories.dorm_id
    ORDER BY total_bookings DESC
    LIMIT 5
")->fetchAll(PDO::FETCH_ASSOC);

// Revenue by payment type
$payment_stats = $pdo->query("
    SELECT 
        payment_method,
        COUNT(*) as count,
        SUM(amount) as total,
        AVG(amount) as average
    FROM payments 
    WHERE status = 'paid'
    GROUP BY payment_method
")->fetchAll(PDO::FETCH_ASSOC);

$page_title = "Reports & Analytics";
require_once __DIR__ . '/../partials/header.php';
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
        <h3>₱<?= number_format($stats['total_revenue']) ?></h3>
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
        <h2>Revenue by Payment Method</h2>
        <canvas id="paymentStats"></canvas>
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
const payments = <?= json_encode($payment_stats) ?>;

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

new Chart(document.getElementById('paymentStats').getContext('2d'), {
    type: 'doughnut',
    data: {
        labels: payments.map(p => p.payment_method),
        datasets: [{
            data: payments.map(p => p.total),
            backgroundColor: ['#4A3AFF', '#28a745', '#ffc107', '#dc3545']
        }]
    },
    options: {
        responsive: true,
        plugins: { title: { display: true, text: 'Revenue by Payment Method' } }
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

<?php require_once __DIR__ . '/../partials/footer.php'; ?>
