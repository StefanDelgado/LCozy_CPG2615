<?php
require_once __DIR__ . '/../../auth/auth.php';
require_role('owner');
require_once __DIR__ . '/../../config.php';

$page_title = "Tenant Management";
include __DIR__ . '/../../partials/header.php';

$owner_id = $_SESSION['user']['user_id'];
$flash = null;

// Get active tab (default: current)
$active_tab = $_GET['tab'] ?? 'current';

// ─── Fetch Current Tenants ───
$current_tenants_stmt = $pdo->prepare("
    SELECT 
        t.tenant_id,
        t.booking_id,
        t.student_id,
        u.name AS tenant_name,
        u.email AS tenant_email,
        u.phone AS tenant_phone,
        d.name AS dorm_name,
        r.room_type,
        r.room_id,
        t.check_in_date,
        t.expected_checkout,
        DATEDIFF(t.expected_checkout, CURDATE()) AS days_remaining,
        t.total_paid,
        t.outstanding_balance,
        b.booking_type,
        (SELECT COUNT(*) FROM payments p 
         WHERE p.booking_id = t.booking_id AND p.status IN ('pending','submitted')) AS pending_payments,
        (SELECT COUNT(*) FROM payments p 
         WHERE p.booking_id = t.booking_id AND p.status IN ('paid','verified')) AS completed_payments
    FROM tenants t
    JOIN users u ON t.student_id = u.user_id
    JOIN dormitories d ON t.dorm_id = d.dorm_id AND d.owner_id = ?
    JOIN rooms r ON t.room_id = r.room_id
    JOIN bookings b ON t.booking_id = b.booking_id
    WHERE t.status = 'active'
    ORDER BY t.check_in_date DESC
");
$current_tenants_stmt->execute([$owner_id]);
$current_tenants = $current_tenants_stmt->fetchAll(PDO::FETCH_ASSOC);

// ─── Fetch Past Tenants ───
$past_tenants_stmt = $pdo->prepare("
    SELECT 
        t.tenant_id,
        t.booking_id,
        t.student_id,
        u.name AS tenant_name,
        u.email AS tenant_email,
        u.phone AS tenant_phone,
        d.name AS dorm_name,
        r.room_type,
        r.room_id,
        t.check_in_date,
        t.check_out_date,
        t.expected_checkout,
        DATEDIFF(t.check_out_date, t.check_in_date) AS days_stayed,
        t.total_paid,
        t.outstanding_balance,
        b.booking_type,
        t.status
    FROM tenants t
    JOIN users u ON t.student_id = u.user_id
    JOIN dormitories d ON t.dorm_id = d.dorm_id AND d.owner_id = ?
    JOIN rooms r ON t.room_id = r.room_id
    JOIN bookings b ON t.booking_id = b.booking_id
    WHERE t.status IN ('completed', 'terminated')
    ORDER BY t.check_out_date DESC
    LIMIT 100
");
$past_tenants_stmt->execute([$owner_id]);
$past_tenants = $past_tenants_stmt->fetchAll(PDO::FETCH_ASSOC);

// Calculate statistics
$total_current = count($current_tenants);
$total_past = count($past_tenants);
$total_revenue = array_sum(array_column($current_tenants, 'total_paid'));
$pending_amount = array_sum(array_map(function($tenant) use ($pdo) {
    $stmt = $pdo->prepare("SELECT COALESCE(SUM(amount), 0) FROM payments WHERE booking_id = ? AND status IN ('pending','submitted')");
    $stmt->execute([$tenant['booking_id']]);
    return $stmt->fetchColumn();
}, $current_tenants));
?>

<style>
.tenants-header {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    padding: 30px;
    border-radius: 12px;
    color: white;
    margin-bottom: 30px;
}

.tenants-header h1 {
    margin: 0 0 10px 0;
    font-size: 28px;
}

.tenants-header p {
    margin: 0;
    opacity: 0.9;
}

.stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 20px;
    margin-bottom: 30px;
}

.stat-card {
    background: white;
    padding: 20px;
    border-radius: 10px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    text-align: center;
}

.stat-card h3 {
    font-size: 32px;
    margin: 0 0 5px 0;
    color: #667eea;
}

.stat-card p {
    margin: 0;
    color: #666;
    font-size: 14px;
}

.tabs {
    display: flex;
    gap: 10px;
    margin-bottom: 20px;
    border-bottom: 2px solid #e0e0e0;
}

.tab {
    padding: 12px 24px;
    border: none;
    background: none;
    cursor: pointer;
    font-size: 16px;
    color: #666;
    border-bottom: 3px solid transparent;
    transition: all 0.3s;
}

.tab:hover {
    color: #667eea;
}

.tab.active {
    color: #667eea;
    border-bottom-color: #667eea;
    font-weight: 600;
}

.tenant-card {
    background: white;
    border-radius: 10px;
    padding: 20px;
    margin-bottom: 15px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    transition: transform 0.2s, box-shadow 0.2s;
}

.tenant-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
}

.tenant-header {
    display: flex;
    justify-content: space-between;
    align-items: start;
    margin-bottom: 15px;
}

.tenant-info h3 {
    margin: 0 0 5px 0;
    font-size: 20px;
    color: #333;
}

.tenant-info .subtitle {
    color: #666;
    font-size: 14px;
}

.badge {
    padding: 5px 12px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 600;
}

.badge.active {
    background: #d4edda;
    color: #155724;
}

.badge.completed {
    background: #d1ecf1;
    color: #0c5460;
}

.badge.overdue {
    background: #f8d7da;
    color: #721c24;
}

.badge.warning {
    background: #fff3cd;
    color: #856404;
}

.tenant-details {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 15px;
    margin-bottom: 15px;
    padding: 15px;
    background: #f8f9fa;
    border-radius: 8px;
}

.detail-item {
    display: flex;
    flex-direction: column;
}

.detail-item label {
    font-size: 12px;
    color: #666;
    margin-bottom: 3px;
    text-transform: uppercase;
    font-weight: 600;
}

.detail-item span {
    font-size: 14px;
    color: #333;
}

.tenant-actions {
    display: flex;
    gap: 10px;
    flex-wrap: wrap;
}

.btn-sm {
    padding: 8px 16px;
    font-size: 14px;
    border-radius: 6px;
    border: none;
    cursor: pointer;
    text-decoration: none;
    display: inline-flex;
    align-items: center;
    gap: 5px;
    transition: all 0.2s;
}

.btn-primary {
    background: #667eea;
    color: white;
}

.btn-primary:hover {
    background: #5568d3;
}

.btn-secondary {
    background: #6c757d;
    color: white;
}

.btn-secondary:hover {
    background: #5a6268;
}

.btn-success {
    background: #28a745;
    color: white;
}

.btn-success:hover {
    background: #218838;
}

.empty-state {
    text-align: center;
    padding: 60px 20px;
    color: #666;
}

.empty-state svg {
    width: 100px;
    height: 100px;
    margin-bottom: 20px;
    opacity: 0.3;
}

.search-box {
    margin-bottom: 20px;
}

.search-box input {
    width: 100%;
    max-width: 400px;
    padding: 12px 20px;
    border: 1px solid #ddd;
    border-radius: 8px;
    font-size: 14px;
}

.search-box input:focus {
    outline: none;
    border-color: #667eea;
    box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}
</style>

<div class="tenants-header">
    <h1>🏠 Tenant Management</h1>
    <p>Track and manage your current and past tenants</p>
</div>

<!-- Statistics -->
<div class="stats-grid">
    <div class="stat-card">
        <h3><?= $total_current ?></h3>
        <p>Current Tenants</p>
    </div>
    <div class="stat-card">
        <h3><?= $total_past ?></h3>
        <p>Past Tenants</p>
    </div>
    <div class="stat-card">
        <h3>₱<?= number_format($total_revenue, 2) ?></h3>
        <p>Total Revenue (Current)</p>
    </div>
    <div class="stat-card">
        <h3>₱<?= number_format($pending_amount, 2) ?></h3>
        <p>Pending Payments</p>
    </div>
</div>

<!-- Tabs -->
<div class="tabs">
    <a href="?tab=current" class="tab <?= $active_tab === 'current' ? 'active' : '' ?>">
        Current Tenants (<?= $total_current ?>)
    </a>
    <a href="?tab=past" class="tab <?= $active_tab === 'past' ? 'active' : '' ?>">
        Past Tenants (<?= $total_past ?>)
    </a>
</div>

<!-- Search Box -->
<div class="search-box">
    <input type="text" id="searchTenant" placeholder="🔍 Search by name, dorm, or room type...">
</div>

<!-- Current Tenants Tab -->
<?php if ($active_tab === 'current'): ?>
    <?php if (empty($current_tenants)): ?>
        <div class="empty-state">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
                <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
            </svg>
            <h3>No Current Tenants</h3>
            <p>You don't have any active tenants at the moment.</p>
        </div>
    <?php else: ?>
        <div id="tenantsContainer">
            <?php foreach ($current_tenants as $tenant): 
                $days_left = (int)$tenant['days_remaining'];
                $is_near_checkout = $days_left <= 30 && $days_left > 0;
                $is_overdue = $days_left < 0;
            ?>
                <div class="tenant-card" data-tenant-name="<?= strtolower(htmlspecialchars($tenant['tenant_name'])) ?>" 
                     data-dorm="<?= strtolower(htmlspecialchars($tenant['dorm_name'])) ?>"
                     data-room="<?= strtolower(htmlspecialchars($tenant['room_type'])) ?>">
                    <div class="tenant-header">
                        <div class="tenant-info">
                            <h3><?= htmlspecialchars($tenant['tenant_name']) ?></h3>
                            <div class="subtitle">
                                <?= htmlspecialchars($tenant['dorm_name']) ?> • <?= htmlspecialchars($tenant['room_type']) ?> Room
                            </div>
                        </div>
                        <div>
                            <?php if ($is_overdue): ?>
                                <span class="badge overdue">Overdue</span>
                            <?php elseif ($is_near_checkout): ?>
                                <span class="badge warning"><?= $days_left ?> days left</span>
                            <?php else: ?>
                                <span class="badge active">Active</span>
                            <?php endif; ?>
                        </div>
                    </div>

                    <div class="tenant-details">
                        <div class="detail-item">
                            <label>Email</label>
                            <span><?= htmlspecialchars($tenant['tenant_email']) ?></span>
                        </div>
                        <div class="detail-item">
                            <label>Phone</label>
                            <span><?= htmlspecialchars($tenant['tenant_phone'] ?: 'Not provided') ?></span>
                        </div>
                        <div class="detail-item">
                            <label>Check-in Date</label>
                            <span><?= date('M d, Y', strtotime($tenant['check_in_date'])) ?></span>
                        </div>
                        <div class="detail-item">
                            <label>Expected Checkout</label>
                            <span><?= date('M d, Y', strtotime($tenant['expected_checkout'])) ?></span>
                        </div>
                        <div class="detail-item">
                            <label>Total Paid</label>
                            <span>₱<?= number_format($tenant['total_paid'], 2) ?></span>
                        </div>
                        <div class="detail-item">
                            <label>Payments</label>
                            <span>
                                <?= $tenant['completed_payments'] ?> paid, 
                                <?= $tenant['pending_payments'] ?> pending
                            </span>
                        </div>
                    </div>

                    <div class="tenant-actions">
                        <a href="../shared/messaging.php?user_id=<?= $tenant['student_id'] ?>" class="btn-sm btn-primary">
                            💬 Message
                        </a>
                        <a href="../owner/owner_payments.php?booking_id=<?= $tenant['booking_id'] ?>" class="btn-sm btn-success">
                            💳 View Payments
                        </a>
                        <a href="../shared/dorm_details.php?id=<?= $tenant['dorm_name'] ?>" class="btn-sm btn-secondary">
                            🏠 View Dorm
                        </a>
                    </div>
                </div>
            <?php endforeach; ?>
        </div>
    <?php endif; ?>
<?php endif; ?>

<!-- Past Tenants Tab -->
<?php if ($active_tab === 'past'): ?>
    <?php if (empty($past_tenants)): ?>
        <div class="empty-state">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
                <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/>
            </svg>
            <h3>No Past Tenants</h3>
            <p>You don't have any completed tenancies yet.</p>
        </div>
    <?php else: ?>
        <div id="tenantsContainer">
            <?php foreach ($past_tenants as $tenant): ?>
                <div class="tenant-card" data-tenant-name="<?= strtolower(htmlspecialchars($tenant['tenant_name'])) ?>" 
                     data-dorm="<?= strtolower(htmlspecialchars($tenant['dorm_name'])) ?>"
                     data-room="<?= strtolower(htmlspecialchars($tenant['room_type'])) ?>">
                    <div class="tenant-header">
                        <div class="tenant-info">
                            <h3><?= htmlspecialchars($tenant['tenant_name']) ?></h3>
                            <div class="subtitle">
                                <?= htmlspecialchars($tenant['dorm_name']) ?> • <?= htmlspecialchars($tenant['room_type']) ?> Room
                            </div>
                        </div>
                        <span class="badge completed">
                            <?= ucfirst($tenant['status']) ?>
                        </span>
                    </div>

                    <div class="tenant-details">
                        <div class="detail-item">
                            <label>Email</label>
                            <span><?= htmlspecialchars($tenant['tenant_email']) ?></span>
                        </div>
                        <div class="detail-item">
                            <label>Check-in</label>
                            <span><?= date('M d, Y', strtotime($tenant['check_in_date'])) ?></span>
                        </div>
                        <div class="detail-item">
                            <label>Check-out</label>
                            <span><?= date('M d, Y', strtotime($tenant['check_out_date'])) ?></span>
                        </div>
                        <div class="detail-item">
                            <label>Duration</label>
                            <span><?= $tenant['days_stayed'] ?> days</span>
                        </div>
                        <div class="detail-item">
                            <label>Total Paid</label>
                            <span>₱<?= number_format($tenant['total_paid'], 2) ?></span>
                        </div>
                        <?php if ($tenant['outstanding_balance'] > 0): ?>
                        <div class="detail-item">
                            <label>Outstanding</label>
                            <span class="text-danger">₱<?= number_format($tenant['outstanding_balance'], 2) ?></span>
                        </div>
                        <?php endif; ?>
                    </div>

                    <div class="tenant-actions">
                        <a href="../owner/owner_payments.php?booking_id=<?= $tenant['booking_id'] ?>" class="btn-sm btn-secondary">
                            📄 View Payment History
                        </a>
                    </div>
                </div>
            <?php endforeach; ?>
        </div>
    <?php endif; ?>
<?php endif; ?>

<script>
// Search functionality
document.getElementById('searchTenant').addEventListener('input', function(e) {
    const searchTerm = e.target.value.toLowerCase();
    const tenantCards = document.querySelectorAll('.tenant-card');
    
    tenantCards.forEach(card => {
        const name = card.dataset.tenantName;
        const dorm = card.dataset.dorm;
        const room = card.dataset.room;
        
        const matches = name.includes(searchTerm) || 
                       dorm.includes(searchTerm) || 
                       room.includes(searchTerm);
        
        card.style.display = matches ? 'block' : 'none';
    });
});
</script>

<?php include __DIR__ . '/../../partials/footer.php'; ?>
