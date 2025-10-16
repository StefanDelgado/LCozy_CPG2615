<?php
require_once __DIR__ . '/../config.php';
require_once __DIR__ . '/../auth.php';
require_role('admin');

// Date inputs (normalize)
$raw_start = $_GET['start_date'] ?? '';
$raw_end = $_GET['end_date'] ?? '';
$start_date = $raw_start ? date('Y-m-d', strtotime($raw_start)) : date('Y-m-01');
$end_date = $raw_end ? date('Y-m-d', strtotime($raw_end)) : date('Y-m-d');
$end_date_time = $end_date . ' 23:59:59';

$stats = [];
$trends = [];
$top_dorms = [];
$payment_stats = [];
$error = null;

try {
    // Summary statistics (match schema in cozydorm.sql)
    $stmt = $pdo->prepare("SELECT
        (SELECT COUNT(*) FROM bookings) AS total_bookings,
        (SELECT COUNT(*) FROM bookings WHERE status = 'approved') AS approved_bookings,
        (SELECT COUNT(DISTINCT student_id) FROM bookings WHERE status NOT IN ('cancelled','rejected')) AS active_students,
        (SELECT COUNT(*) FROM users WHERE role = 'owner' AND verified = 1) AS verified_owners,
        (SELECT COALESCE(SUM(amount),0) FROM payments WHERE status = 'paid') AS total_revenue,
        (SELECT COUNT(*) FROM dormitories) AS total_dorms,
        (SELECT COUNT(*) FROM rooms) AS total_rooms,
        (SELECT COUNT(*) FROM reviews WHERE status = 'approved') AS total_reviews
    ");
    $stmt->execute();
    $stats = $stmt->fetch(PDO::FETCH_ASSOC) ?: [];

    // Monthly booking trends grouped by YYYY-MM (MySQL DATE_FORMAT)
    $trendsStmt = $pdo->prepare("SELECT
        DATE_FORMAT(created_at, '%Y-%m') AS month,
        COUNT(*) AS bookings,
        COUNT(DISTINCT student_id) AS unique_students,
        SUM(status = 'approved') AS approved,
        SUM(status = 'cancelled') AS cancelled
        FROM bookings
        WHERE created_at BETWEEN :start AND :end
        GROUP BY DATE_FORMAT(created_at, '%Y-%m')
        ORDER BY month ASC");
    $trendsStmt->execute([':start' => $start_date . ' 00:00:00', ':end' => $end_date_time]);
    $trends = $trendsStmt->fetchAll(PDO::FETCH_ASSOC);

    // Top performing dorms (by bookings) and average rating (reviews.rating exists)
    $topStmt = $pdo->prepare("SELECT
        d.dorm_id,
        d.name,
        COUNT(b.booking_id) AS total_bookings,
        COALESCE(AVG(r.rating),0) AS avg_rating,
        COUNT(r.review_id) AS review_count
        FROM dormitories d
        LEFT JOIN rooms rm ON rm.dorm_id = d.dorm_id
        LEFT JOIN bookings b ON b.room_id = rm.room_id
        LEFT JOIN reviews r ON r.booking_id = b.booking_id AND r.status = 'approved'
        GROUP BY d.dorm_id, d.name
        ORDER BY total_bookings DESC
        LIMIT 5");
    $topStmt->execute();
    $top_dorms = $topStmt->fetchAll(PDO::FETCH_ASSOC);

    // Revenue by payment status and simple grouping by status (payments.payment_date exists)
    $payStmt = $pdo->prepare("SELECT
        status AS payment_status,
        COUNT(*) AS count,
        COALESCE(SUM(amount),0) AS total,
        COALESCE(AVG(amount),0) AS average
        FROM payments
        WHERE payment_date BETWEEN :start AND :end
        GROUP BY status");
    $payStmt->execute([':start' => $start_date . ' 00:00:00', ':end' => $end_date_time]);
    $payment_stats = $payStmt->fetchAll(PDO::FETCH_ASSOC);

} catch (PDOException $e) {
    error_log($e->getMessage());
    $error = 'An error occurred while generating the report.';
}

$page_title = "Reports & Analytics";
require_once __DIR__ . '/../partials/header.php';
?>

<div class="page-header">
    <div class="date-filter">
        <form method="GET" class="form-inline">
            <label for="start_date">Start</label>
            <input id="start_date" type="date" name="start_date" value="<?= htmlspecialchars($start_date) ?>">
            <label for="end_date">End</label>
            <input id="end_date" type="date" name="end_date" value="<?= htmlspecialchars($end_date) ?>">
            <button type="submit" class="btn">Filter</button>
        </form>
    </div>
</div>

<?php if ($error): ?>
    <div class="alert" style="margin:1rem;background:#f8d7da;padding:1rem;border-radius:6px;color:#721c24"><?= htmlspecialchars($error) ?></div>
<?php endif; ?>

<!-- Summary Cards -->
<div class="stats-grid">
    <div class="stat-card">
        <h3><?= number_format($stats['total_bookings'] ?? 0) ?></h3>
        <p>Total Bookings</p>
        <small><?= number_format($stats['approved_bookings'] ?? 0) ?> approved</small>
    </div>
    <div class="stat-card">
        <h3>₱<?= number_format($stats['total_revenue'] ?? 0, 2) ?></h3>
        <p>Total Revenue (paid)</p>
    </div>
    <div class="stat-card">
        <h3><?= number_format($stats['active_students'] ?? 0) ?></h3>
        <p>Active Students</p>
    </div>
    <div class="stat-card">
        <h3><?= number_format($stats['verified_owners'] ?? 0) ?></h3>
        <p>Verified Owners</p>
        <small><?= number_format($stats['total_dorms'] ?? 0) ?> dorms listed</small>
    </div>
</div>

<!-- Charts Section -->
<div class="reports-grid">
    <!-- Booking Trends -->
    <div class="chart-card">
        <h2>Monthly Booking Trends</h2>
        <canvas id="bookingTrends"></canvas>
    </div>
    
    <!-- Revenue by Payment Status -->
    <div class="chart-card">
        <h2>Revenue by Payment Status</h2>
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

<script>
const trends = <?= json_encode($trends ?? []) ?>;
const payments = <?= json_encode($payment_stats ?? []) ?>;

// Booking Trends Chart
if (typeof Chart !== 'undefined') {
    new Chart(document.getElementById('bookingTrends').getContext('2d'), {
        type: 'line',
        data: {
            labels: trends.map(t => t.month),
            datasets: [{
                label: 'Total Bookings',
                data: trends.map(t => parseInt(t.bookings) || 0),
                borderColor: '#4A3AFF',
                backgroundColor: 'rgba(74,58,255,0.1)',
                fill: true
            }, {
                label: 'Approved',
                data: trends.map(t => parseInt(t.approved) || 0),
                borderColor: '#28a745',
                backgroundColor: 'rgba(40,167,69,0.1)',
                fill: true
            }]
        },
        options: { responsive: true }
    });

    // Payment Status Chart (doughnut)
    new Chart(document.getElementById('paymentStats').getContext('2d'), {
        type: 'doughnut',
        data: {
            labels: payments.map(p => p.payment_status || p.status || 'Unknown'),
            datasets: [{
                data: payments.map(p => parseFloat(p.total) || 0),
                backgroundColor: ['#4A3AFF', '#28a745', '#ffc107', '#dc3545']
            }]
        },
        options: { responsive: true }
    });
}
</script>

<!-- Basic inline styles (short-term) -->
<style>
.stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 1rem; margin-bottom: 2rem; }
.stat-card { background: white; padding: 1.5rem; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }
.stat-card h3 { margin: 0; font-size: 1.8rem; color: #4A3AFF; }
.reports-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(400px, 1fr)); gap: 2rem; margin: 2rem 0; }
.chart-card { background: white; padding: 1.5rem; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }
.date-filter { display: flex; gap: 1rem; align-items: center; margin: 1rem 0; }
.table { width: 100%; border-collapse: collapse; }
.table th, .table td { padding: 0.75rem; border-bottom: 1px solid #eee; }
.table th { background: #f8f9fa; font-weight: 600; }
.table-responsive { overflow-x: auto; }
</style>

<?php require_once __DIR__ . '/../partials/footer.php'; ?>
<?php
require_once __DIR__ . '/../config.php';
require_once __DIR__ . '/../auth.php';
require_role('admin');

// Validate and normalize date inputs
$raw_start = $_GET['start_date'] ?? '';
$raw_end = $_GET['end_date'] ?? '';
$start_date = $raw_start ? date('Y-m-d', strtotime($raw_start)) : date('Y-m-01');
$end_date = $raw_end ? date('Y-m-d', strtotime($raw_end)) : date('Y-m-d');
$end_date_time = $end_date . ' 23:59:59';

$stats = [];
$trends = [];
$top_dorms = [];
$payment_stats = [];
$error = null;

try {
    // Summary statistics
    $stmt = $pdo->prepare("SELECT
        (SELECT COUNT(*) FROM bookings) AS total_bookings,
        (SELECT COUNT(*) FROM bookings WHERE status = 'completed') AS completed_bookings,
        (SELECT COUNT(DISTINCT student_id) FROM bookings WHERE status NOT IN ('cancelled','rejected')) AS active_students,
        (SELECT COUNT(*) FROM users WHERE role = 'owner' AND verified = 1) AS verified_owners,
        (SELECT COALESCE(SUM(amount),0) FROM payments WHERE status = 'paid') AS total_revenue,
        (SELECT COUNT(*) FROM dormitories WHERE COALESCE(is_deleted,0)=0) AS total_dorms,
        (SELECT COUNT(*) FROM rooms WHERE COALESCE(is_deleted,0)=0) AS total_rooms,
        (SELECT COUNT(*) FROM reviews WHERE status = 'approved') AS total_reviews
    ");
    $stmt->execute();
    $stats = $stmt->fetch(PDO::FETCH_ASSOC) ?: [];

    // Monthly trends grouped by YYYY-MM (MySQL DATE_FORMAT)
    $trendsStmt = $pdo->prepare("SELECT
        DATE_FORMAT(created_at, '%Y-%m') AS month,
        COUNT(*) AS bookings,
        COUNT(DISTINCT student_id) AS unique_students,
        SUM(status = 'completed') AS completed,
        SUM(status = 'cancelled') AS cancelled
        FROM bookings
        WHERE created_at BETWEEN :start AND :end
        GROUP BY DATE_FORMAT(created_at, '%Y-%m')
        ORDER BY month ASC");
    $trendsStmt->execute([':start' => $start_date . ' 00:00:00', ':end' => $end_date_time]);
    $trends = $trendsStmt->fetchAll(PDO::FETCH_ASSOC);

    // Top performing dorms
    $topStmt = $pdo->prepare("SELECT
        d.dorm_id,
        d.name,
        COUNT(b.booking_id) AS total_bookings,
        COALESCE(AVG(r.rating),0) AS avg_rating,
        COUNT(r.rating) AS review_count
        FROM dormitories d
        LEFT JOIN rooms rm ON rm.dorm_id = d.dorm_id AND COALESCE(rm.is_deleted,0)=0
        LEFT JOIN bookings b ON b.room_id = rm.room_id
        LEFT JOIN reviews r ON r.booking_id = b.booking_id AND r.status = 'approved'
        WHERE COALESCE(d.is_deleted,0)=0
        GROUP BY d.dorm_id, d.name
        ORDER BY total_bookings DESC
        LIMIT 5");
    $topStmt->execute();
    $top_dorms = $topStmt->fetchAll(PDO::FETCH_ASSOC);

    // Revenue by payment method
    $payStmt = $pdo->prepare("SELECT
        payment_method,
        COUNT(*) AS count,
        COALESCE(SUM(amount),0) AS total,
        COALESCE(AVG(amount),0) AS average
        FROM payments
        WHERE status = 'paid' AND created_at BETWEEN :start AND :end
        GROUP BY payment_method");
    $payStmt->execute([':start' => $start_date . ' 00:00:00', ':end' => $end_date_time]);
    $payment_stats = $payStmt->fetchAll(PDO::FETCH_ASSOC);

} catch (PDOException $e) {
    error_log($e->getMessage());
    $error = 'An error occurred while generating the report.';
}

$page_title = "Reports & Analytics";
require_once __DIR__ . '/../partials/header.php';
?>

<div class="page-header">
    <div class="date-filter">
        <form method="GET" class="form-inline">
            <input type="date" name="start_date" value="<?= htmlspecialchars($start_date) ?>">
            <input type="date" name="end_date" value="<?= htmlspecialchars($end_date) ?>">
            <button type="submit" class="btn">Filter</button>
        </form>
    </div>
</div>

<?php if ($error): ?>
    <div class="alert" style="margin:1rem;background:#f8d7da;padding:1rem;border-radius:6px;color:#721c24"><?= htmlspecialchars($error) ?></div>
<?php endif; ?>

<!-- Summary Cards -->
<div class="stats-grid">
    <div class="stat-card">
        <h3><?= number_format($stats['total_bookings'] ?? 0) ?></h3>
        <p>Total Bookings</p>
        <small><?= number_format($stats['completed_bookings'] ?? 0) ?> completed</small>
    </div>
    <div class="stat-card">
        <h3>₱<?= number_format($stats['total_revenue'] ?? 0, 2) ?></h3>
        <p>Total Revenue</p>
    </div>
    <div class="stat-card">
        <h3><?= number_format($stats['active_students'] ?? 0) ?></h3>
        <p>Active Students</p>
    </div>
    <div class="stat-card">
        <h3><?= number_format($stats['verified_owners'] ?? 0) ?></h3>
        <p>Verified Owners</p>
        <small><?= number_format($stats['total_dorms'] ?? 0) ?> dorms listed</small>
    </div>
</div>

<!-- Charts Section -->
<div class="reports-grid">
    <!-- Booking Trends -->
    <div class="chart-card">
        <h2>Monthly Booking Trends</h2>
        <canvas id="bookingTrends"></canvas>
    </div>
    
    <!-- Revenue by Payment Method -->
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

<script>
// Convert PHP data for charts (fallback to empty arrays)
const trends = <?= json_encode($trends ?? []) ?>;
const payments = <?= json_encode($payment_stats ?? []) ?>;

// Booking Trends Chart
new Chart(document.getElementById('bookingTrends').getContext('2d'), {
    type: 'line',
    data: {
        labels: trends.map(t => t.month),
        datasets: [{
            label: 'Total Bookings',
            data: trends.map(t => parseInt(t.bookings) || 0),
            borderColor: '#4A3AFF',
            backgroundColor: 'rgba(74,58,255,0.1)',
            fill: true
        }, {
            label: 'Completed',
            data: trends.map(t => parseInt(t.completed) || 0),
            borderColor: '#28a745',
            backgroundColor: 'rgba(40,167,69,0.1)',
            fill: true
        }]
    },
    options: {
        responsive: true,
        plugins: {
            title: { display: true, text: 'Monthly Booking Trends' }
        }
    }
});

// Payment Methods Chart
new Chart(document.getElementById('paymentStats').getContext('2d'), {
    type: 'doughnut',
    data: {
        labels: payments.map(p => p.payment_method || 'Unknown'),
        datasets: [{
            data: payments.map(p => parseFloat(p.total) || 0),
            backgroundColor: [
                '#4A3AFF', '#28a745', '#ffc107', '#dc3545'
            ]
        }]
    },
    options: {
        responsive: true,
        plugins: {
            title: { display: true, text: 'Revenue by Payment Method' }
        }
    }
});
</script>

<!-- Additional styling -->
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

.stat-card h3 {
    margin: 0;
    font-size: 1.8rem;
    color: #4A3AFF;
}

.stat-card p {
    margin: 0.5rem 0;
    color: #666;
}

.stat-card small {
    color: #999;
    font-size: 0.9rem;
}

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

.date-filter {
    display: flex;
    gap: 1rem;
    align-items: center;
}

.table {
    width: 100%;
    border-collapse: collapse;
}

.table th,
.table td {
    padding: 0.75rem;
    border-bottom: 1px solid #eee;
}

.table th {
    background: #f8f9fa;
    font-weight: 600;
}

.table-responsive {
    overflow-x: auto;
}
</style>

<?php require_once __DIR__ . '/../partials/footer.php'; ?>
        GROUP BY d.dorm_id, d.name
        ORDER BY total_bookings DESC
        LIMIT 5");
    $topStmt->execute();
    $top_dorms = $topStmt->fetchAll(PDO::FETCH_ASSOC);

    // Revenue by payment method within date range
    $payStmt = $pdo->prepare("SELECT
        payment_method,
        COUNT(*) AS count,
        COALESCE(SUM(amount),0) AS total,
        COALESCE(AVG(amount),0) AS average
        FROM payments
        WHERE status = 'paid' AND created_at BETWEEN :start AND :end
        GROUP BY payment_method");
    $payStmt->execute([':start' => $start_date . ' 00:00:00', ':end' => $end_date_time]);
    $payment_stats = $payStmt->fetchAll(PDO::FETCH_ASSOC);

} catch (PDOException $e) {
    error_log($e->getMessage());
    $error = 'An error occurred while generating the report.';
}

$page_title = "Reports & Analytics";
require_once __DIR__ . '/../partials/header.php';
?>
// Booking Trends Chart
new Chart(document.getElementById('bookingTrends').getContext('2d'), {
    type: 'line',
    data: {
        labels: trends.map(t => t.month),
        datasets: [{
            label: 'Total Bookings',
            data: trends.map(t => t.bookings),
            borderColor: '#4A3AFF',
            backgroundColor: 'rgba(74,58,255,0.1)',
            fill: true
        }, {
            label: 'Completed',
            data: trends.map(t => t.completed),
            borderColor: '#28a745',
            backgroundColor: 'rgba(40,167,69,0.1)',
            fill: true
        }]
    },
    options: {
        responsive: true,
        plugins: {
            title: { display: true, text: 'Monthly Booking Trends' }
        }
    }
});

// Payment Methods Chart
new Chart(document.getElementById('paymentStats').getContext('2d'), {
    type: 'doughnut',
    data: {
        labels: payments.map(p => p.payment_method),
        datasets: [{
            data: payments.map(p => p.total),
            backgroundColor: [
                '#4A3AFF', '#28a745', '#ffc107', '#dc3545'
            ]
        }]
    },
    options: {
        responsive: true,
        plugins: {
            title: { display: true, text: 'Revenue by Payment Method' }
        }
    }
});
</script>

<!-- Additional styling -->
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

.stat-card h3 {
    margin: 0;
    font-size: 1.8rem;
    color: #4A3AFF;
}

.stat-card p {
    margin: 0.5rem 0;
    color: #666;
}

.stat-card small {
    color: #999;
    font-size: 0.9rem;
}

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

.date-filter {
    display: flex;
    gap: 1rem;
    align-items: center;
}

.table {
    width: 100%;
    border-collapse: collapse;
}

.table th,
.table td {
    padding: 0.75rem;
    border-bottom: 1px solid #eee;
}

.table th {
    background: #f8f9fa;
    font-weight: 600;
}

.table-responsive {
    overflow-x: auto;
}
</style>

<?php require_once __DIR__ . '/../partials/footer.php'; ?>