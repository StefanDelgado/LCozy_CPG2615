<?php
// Temporarily enable error display
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

require_once __DIR__ . '/../../auth/auth.php';
require_role('owner');
require_once __DIR__ . '/../../config.php';

$page_title = "Tenant Management";
include __DIR__ . '/../../partials/header.php';

$owner_id = $_SESSION['user']['user_id'];
$flash = null;

// Get active tab (default: current)
$active_tab = $_GET['tab'] ?? 'current';

// Initialize arrays
$current_tenants = [];
$past_tenants = [];

try {
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

} catch (PDOException $e) {
    $flash = ['type' => 'error', 'msg' => 'Database error: ' . $e->getMessage()];
    error_log("Tenant query error: " . $e->getMessage());
}

// Calculate statistics
$total_current = count($current_tenants);
$total_past = count($past_tenants);
$total_revenue = array_sum(array_column($current_tenants, 'total_paid'));
$pending_amount = 0;

// Calculate pending payments safely
try {
    foreach ($current_tenants as $tenant) {
        $stmt = $pdo->prepare("SELECT COALESCE(SUM(amount), 0) FROM payments WHERE booking_id = ? AND status IN ('pending','submitted')");
        $stmt->execute([$tenant['booking_id']]);
        $pending_amount += (float)$stmt->fetchColumn();
    }
} catch (PDOException $e) {
    error_log("Pending payment calculation error: " . $e->getMessage());
}
?>

<div class="page-header">
    <div>
        <h1>Tenant Management</h1>
        <p>Track and manage your current and past tenants</p>
    </div>
</div>

<?php if ($flash): ?>
<div class="alert <?= $flash['type'] === 'error' ? 'error' : 'success' ?>" style="padding: 15px; margin-bottom: 20px; border-radius: 8px; background: <?= $flash['type'] === 'error' ? '#fee' : '#efe' ?>; border: 1px solid <?= $flash['type'] === 'error' ? '#fcc' : '#cfc' ?>;">
    <?= htmlspecialchars($flash['msg']) ?>
</div>
<?php endif; ?>

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

<div class="section">
    <div style="display: flex; gap: 10px; margin-bottom: 20px; border-bottom: 2px solid #e0e0e0;">
        <a href="?tab=current" style="padding: 12px 24px; border: none; background: none; cursor: pointer; font-size: 16px; color: <?= $active_tab === 'current' ? '#8b5cf6' : '#666' ?>; border-bottom: 3px solid <?= $active_tab === 'current' ? '#8b5cf6' : 'transparent' ?>; font-weight: <?= $active_tab === 'current' ? '600' : 'normal' ?>; text-decoration: none;">
            Current Tenants (<?= $total_current ?>)
        </a>
        <a href="?tab=past" style="padding: 12px 24px; border: none; background: none; cursor: pointer; font-size: 16px; color: <?= $active_tab === 'past' ? '#8b5cf6' : '#666' ?>; border-bottom: 3px solid <?= $active_tab === 'past' ? '#8b5cf6' : 'transparent' ?>; font-weight: <?= $active_tab === 'past' ? '600' : 'normal' ?>; text-decoration: none;">
            Past Tenants (<?= $total_past ?>)
        </a>
    </div>

    <!-- Search Box -->
    <div style="margin-bottom: 20px;">
        <input type="text" id="searchTenant" placeholder="🔍 Search by name, dorm, or room type..." style="width: 100%; max-width: 400px; padding: 10px 12px; border: 1px solid #ccc; border-radius: 8px; font-size: 14px;">
    </div>


<!-- Current Tenants Tab -->
<?php if ($active_tab === 'current'): ?>
    <?php if (empty($current_tenants)): ?>
        <div class="card" style="text-align: center; padding: 60px 20px;">
            <h3 style="color: #666;">No Current Tenants</h3>
            <p style="color: #999;">You don't have any active tenants at the moment.</p>
        </div>
    <?php else: ?>
        <div id="tenantsContainer">
            <?php foreach ($current_tenants as $tenant): 
                $days_left = (int)$tenant['days_remaining'];
                $is_near_checkout = $days_left <= 30 && $days_left > 0;
                $is_overdue = $days_left < 0;
            ?>
                <div class="card tenant-card" style="margin-bottom: 15px;" data-tenant-name="<?= strtolower(htmlspecialchars($tenant['tenant_name'])) ?>" 
                     data-dorm="<?= strtolower(htmlspecialchars($tenant['dorm_name'])) ?>"
                     data-room="<?= strtolower(htmlspecialchars($tenant['room_type'])) ?>">
                    <div style="display: flex; justify-content: space-between; align-items: start; margin-bottom: 15px;">
                        <div>
                            <h3 style="margin: 0 0 5px 0; font-size: 18px;"><?= htmlspecialchars($tenant['tenant_name']) ?></h3>
                            <div style="color: #666; font-size: 14px;">
                                <?= htmlspecialchars($tenant['dorm_name']) ?> • <?= htmlspecialchars($tenant['room_type']) ?> Room
                            </div>
                        </div>
                        <div>
                            <?php if ($is_overdue): ?>
                                <span class="badge error">Overdue</span>
                            <?php elseif ($is_near_checkout): ?>
                                <span class="badge warning"><?= $days_left ?> days left</span>
                            <?php else: ?>
                                <span class="badge success">Active</span>
                            <?php endif; ?>
                        </div>
                    </div>

                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 12px; padding: 12px; background: #f8f9fa; border-radius: 8px; margin-bottom: 12px;">
                        <div>
                            <label style="font-size: 11px; color: #666; margin-bottom: 3px; text-transform: uppercase; font-weight: 600; display: block;">Email</label>
                            <span style="font-size: 14px; color: #333;"><?= htmlspecialchars($tenant['tenant_email']) ?></span>
                        </div>
                        <div>
                            <label style="font-size: 11px; color: #666; margin-bottom: 3px; text-transform: uppercase; font-weight: 600; display: block;">Phone</label>
                            <span style="font-size: 14px; color: #333;"><?= htmlspecialchars($tenant['tenant_phone'] ?: 'Not provided') ?></span>
                        </div>
                        <div>
                            <label style="font-size: 11px; color: #666; margin-bottom: 3px; text-transform: uppercase; font-weight: 600; display: block;">Check-in Date</label>
                            <span style="font-size: 14px; color: #333;"><?= date('M d, Y', strtotime($tenant['check_in_date'])) ?></span>
                        </div>
                        <div>
                            <label style="font-size: 11px; color: #666; margin-bottom: 3px; text-transform: uppercase; font-weight: 600; display: block;">Expected Checkout</label>
                            <span style="font-size: 14px; color: #333;"><?= date('M d, Y', strtotime($tenant['expected_checkout'])) ?></span>
                        </div>
                        <div>
                            <label style="font-size: 11px; color: #666; margin-bottom: 3px; text-transform: uppercase; font-weight: 600; display: block;">Total Paid</label>
                            <span style="font-size: 14px; color: #333;">₱<?= number_format($tenant['total_paid'], 2) ?></span>
                        </div>
                        <div>
                            <label style="font-size: 11px; color: #666; margin-bottom: 3px; text-transform: uppercase; font-weight: 600; display: block;">Payments</label>
                            <span style="font-size: 14px; color: #333;">
                                <?= $tenant['completed_payments'] ?> paid, 
                                <?= $tenant['pending_payments'] ?> pending
                            </span>
                        </div>
                    </div>

                    <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                        <a href="../shared/messaging.php?user_id=<?= $tenant['student_id'] ?>" class="btn btn-primary" style="padding: 8px 16px; font-size: 14px; text-decoration: none;">
                            💬 Message
                        </a>
                        <a href="../owner/owner_payments.php?booking_id=<?= $tenant['booking_id'] ?>" class="btn" style="padding: 8px 16px; font-size: 14px; text-decoration: none; background: #28a745; color: white;">
                            💳 View Payments
                        </a>
                        <a href="../shared/dorm_details.php?id=<?= $tenant['dorm_name'] ?>" class="btn" style="padding: 8px 16px; font-size: 14px; text-decoration: none; background: #6c757d; color: white;">
                            🏠 View Dorm
                        </a>
                    </div>
                </div>
            <?php endforeach; ?>
        </div>
    <?php endif; ?>
</div>

<!-- Past Tenants Tab -->
<div class="section">
<?php if ($active_tab === 'past'): ?>
    <?php if (empty($past_tenants)): ?>
        <div class="card" style="text-align: center; padding: 60px 20px;">
            <h3 style="color: #666;">No Past Tenants</h3>
            <p style="color: #999;">You don't have any completed tenancies yet.</p>
        </div>
    <?php else: ?>
        <div id="tenantsContainer">
            <?php foreach ($past_tenants as $tenant): ?>
                <div class="card tenant-card" style="margin-bottom: 15px;" data-tenant-name="<?= strtolower(htmlspecialchars($tenant['tenant_name'])) ?>" 
                     data-dorm="<?= strtolower(htmlspecialchars($tenant['dorm_name'])) ?>"
                     data-room="<?= strtolower(htmlspecialchars($tenant['room_type'])) ?>">
                    <div style="display: flex; justify-content: space-between; align-items: start; margin-bottom: 15px;">
                        <div>
                            <h3 style="margin: 0 0 5px 0; font-size: 18px;"><?= htmlspecialchars($tenant['tenant_name']) ?></h3>
                            <div style="color: #666; font-size: 14px;">
                                <?= htmlspecialchars($tenant['dorm_name']) ?> • <?= htmlspecialchars($tenant['room_type']) ?> Room
                            </div>
                        </div>
                        <span class="badge success">
                            <?= ucfirst($tenant['status']) ?>
                        </span>
                    </div>

                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 12px; padding: 12px; background: #f8f9fa; border-radius: 8px; margin-bottom: 12px;">
                        <div>
                            <label style="font-size: 11px; color: #666; margin-bottom: 3px; text-transform: uppercase; font-weight: 600; display: block;">Email</label>
                            <span style="font-size: 14px; color: #333;"><?= htmlspecialchars($tenant['tenant_email']) ?></span>
                        </div>
                        <div>
                            <label style="font-size: 11px; color: #666; margin-bottom: 3px; text-transform: uppercase; font-weight: 600; display: block;">Check-in</label>
                            <span style="font-size: 14px; color: #333;"><?= date('M d, Y', strtotime($tenant['check_in_date'])) ?></span>
                        </div>
                        <div>
                            <label style="font-size: 11px; color: #666; margin-bottom: 3px; text-transform: uppercase; font-weight: 600; display: block;">Check-out</label>
                            <span style="font-size: 14px; color: #333;"><?= date('M d, Y', strtotime($tenant['check_out_date'])) ?></span>
                        </div>
                        <div>
                            <label style="font-size: 11px; color: #666; margin-bottom: 3px; text-transform: uppercase; font-weight: 600; display: block;">Duration</label>
                            <span style="font-size: 14px; color: #333;"><?= $tenant['days_stayed'] ?> days</span>
                        </div>
                        <div>
                            <label style="font-size: 11px; color: #666; margin-bottom: 3px; text-transform: uppercase; font-weight: 600; display: block;">Total Paid</label>
                            <span style="font-size: 14px; color: #333;">₱<?= number_format($tenant['total_paid'], 2) ?></span>
                        </div>
                        <?php if ($tenant['outstanding_balance'] > 0): ?>
                        <div>
                            <label style="font-size: 11px; color: #666; margin-bottom: 3px; text-transform: uppercase; font-weight: 600; display: block;">Outstanding</label>
                            <span style="font-size: 14px; color: #d9534f;">₱<?= number_format($tenant['outstanding_balance'], 2) ?></span>
                        </div>
                        <?php endif; ?>
                    </div>

                    <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                        <a href="../owner/owner_payments.php?booking_id=<?= $tenant['booking_id'] ?>" class="btn" style="padding: 8px 16px; font-size: 14px; text-decoration: none; background: #6c757d; color: white;">
                            📄 View Payment History
                        </a>
                    </div>
                </div>
            <?php endforeach; ?>
        </div>
    <?php endif; ?>
<?php endif; ?>
</div>

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
