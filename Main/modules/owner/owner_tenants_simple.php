<?php
require_once __DIR__ . '/../../auth/auth.php';
require_role('owner');
require_once __DIR__ . '/../../config.php';

$page_title = "Tenant Management";
include __DIR__ . '/../../partials/header.php';

$owner_id = $_SESSION['user']['user_id'];
$active_tab = $_GET['tab'] ?? 'current';

// Fetch tenants
$stmt = $pdo->prepare("
    SELECT 
        t.tenant_id,
        t.booking_id,
        u.name AS tenant_name,
        u.email AS tenant_email,
        u.phone AS tenant_phone,
        d.name AS dorm_name,
        r.room_type,
        t.check_in_date,
        t.expected_checkout,
        DATEDIFF(t.expected_checkout, CURDATE()) AS days_remaining,
        t.total_paid,
        t.outstanding_balance,
        t.status AS tenant_status
    FROM tenants t
    JOIN users u ON t.student_id = u.user_id
    JOIN dormitories d ON t.dorm_id = d.dorm_id AND d.owner_id = ?
    JOIN rooms r ON t.room_id = r.room_id
    WHERE t.status IN ('active', 'pending')
    ORDER BY t.check_in_date DESC
");
$stmt->execute([$owner_id]);
$current_tenants = $stmt->fetchAll(PDO::FETCH_ASSOC);

$total_current = count($current_tenants);
$total_revenue = array_sum(array_column($current_tenants, 'total_paid'));
?>

<div class="page-header">
    <div>
        <h1>Tenant Management</h1>
        <p>Track and manage your current and past tenants</p>
    </div>
</div>

<!-- Statistics -->
<div class="stats-grid">
    <div class="stat-card">
        <h3><?= $total_current ?></h3>
        <p>Current Tenants</p>
    </div>
    <div class="stat-card">
        <h3>₱<?= number_format($total_revenue, 2) ?></h3>
        <p>Total Revenue</p>
    </div>
</div>

<div class="section">
    <h2>Current Tenants (<?= $total_current ?>)</h2>
    
    <?php if (empty($current_tenants)): ?>
        <div class="card" style="text-align: center; padding: 60px 20px;">
            <h3 style="color: #666;">No Current Tenants</h3>
            <p style="color: #999;">You don't have any active tenants at the moment.</p>
        </div>
    <?php else: ?>
        <?php foreach ($current_tenants as $tenant): 
            $days_left = (int)$tenant['days_remaining'];
            $is_overdue = $days_left < 0;
        ?>
            <div class="card" style="margin-bottom: 15px;">
                <div style="display: flex; justify-content: space-between; align-items: start; margin-bottom: 15px;">
                    <div>
                        <h3 style="margin: 0 0 5px 0; font-size: 18px;"><?= htmlspecialchars($tenant['tenant_name']) ?></h3>
                        <div style="color: #666; font-size: 14px;">
                            <?= htmlspecialchars($tenant['dorm_name']) ?> • <?= htmlspecialchars($tenant['room_type']) ?> Room
                        </div>
                    </div>
                    <div>
                        <span class="badge success"><?= ucfirst($tenant['tenant_status']) ?></span>
                    </div>
                </div>

                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 12px; padding: 12px; background: #f8f9fa; border-radius: 8px;">
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
                        <label style="font-size: 11px; color: #666; margin-bottom: 3px; text-transform: uppercase; font-weight: 600; display: block;">Days Remaining</label>
                        <span style="font-size: 14px; color: <?= $is_overdue ? '#d9534f' : '#333' ?>;"><?= $days_left ?> days</span>
                    </div>
                    <div>
                        <label style="font-size: 11px; color: #666; margin-bottom: 3px; text-transform: uppercase; font-weight: 600; display: block;">Total Paid</label>
                        <span style="font-size: 14px; color: #333;">₱<?= number_format($tenant['total_paid'], 2) ?></span>
                    </div>
                </div>
            </div>
        <?php endforeach; ?>
    <?php endif; ?>
</div>

<?php include __DIR__ . '/../../partials/footer.php'; ?>
