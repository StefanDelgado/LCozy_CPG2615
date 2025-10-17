<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);

echo "Step 1: Starting...<br>";

try {
    require_once __DIR__ . '/../../auth/auth.php';
    require_role('owner');
    require_once __DIR__ . '/../../config.php';
    echo "Step 2: Auth and config loaded<br>";

    $page_title = "Tenant Management Test";
    $owner_id = $_SESSION['user']['user_id'];
    echo "Step 3: Owner ID: $owner_id<br>";
    
    echo "Step 4: Including header...<br>";
    include __DIR__ . '/../../partials/header.php';
    echo "Step 5: Header included<br>";
    
    echo "<h1>Testing Tenant Queries</h1>";
    
    // Test the actual query from owner_tenants.php
    echo "<p>Step 6: Running tenant query...</p>";
    $stmt = $pdo->prepare("
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
            t.status AS tenant_status,
            b.booking_type
        FROM tenants t
        JOIN users u ON t.student_id = u.user_id
        JOIN dormitories d ON t.dorm_id = d.dorm_id AND d.owner_id = ?
        JOIN rooms r ON t.room_id = r.room_id
        JOIN bookings b ON t.booking_id = b.booking_id
        WHERE t.status IN ('active', 'pending')
        ORDER BY t.check_in_date DESC
    ");
    
    echo "<p>Step 7: Query prepared, executing...</p>";
    $stmt->execute([$owner_id]);
    
    echo "<p>Step 8: Fetching results...</p>";
    $tenants = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "<p>Step 9: Found " . count($tenants) . " tenants</p>";
    
    if (!empty($tenants)) {
        echo "<h2>Tenant Data:</h2>";
        echo "<pre>" . print_r($tenants[0], true) . "</pre>";
    }
    
    echo "<h2 style='color: green;'>✅ Query works! Now testing HTML output...</h2>";
    
    // Test rendering a tenant card
    if (!empty($tenants)) {
        $tenant = $tenants[0];
        $days_left = (int)$tenant['days_remaining'];
        ?>
        <div class="card" style="margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 8px;">
            <h3><?= htmlspecialchars($tenant['tenant_name']) ?></h3>
            <p><?= htmlspecialchars($tenant['dorm_name']) ?> • <?= htmlspecialchars($tenant['room_type']) ?> Room</p>
            <p>Status: <?= htmlspecialchars($tenant['tenant_status']) ?></p>
            <p>Days remaining: <?= $days_left ?></p>
        </div>
        <?php
        echo "<p style='color: green;'>✅ HTML rendering works!</p>";
    }
    
    echo "<h2 style='color: green;'>✅ Everything works!</h2>";
    echo "<p>The issue must be something specific in the owner_tenants.php file.</p>";
    
    include __DIR__ . '/../../partials/footer.php';
    
} catch (Exception $e) {
    echo "<div style='color: red; padding: 20px; background: #fee; margin: 20px;'>";
    echo "<h2>❌ Error!</h2>";
    echo "<p><strong>Message:</strong> " . htmlspecialchars($e->getMessage()) . "</p>";
    echo "<p><strong>File:</strong> " . $e->getFile() . "</p>";
    echo "<p><strong>Line:</strong> " . $e->getLine() . "</p>";
    echo "<pre>" . htmlspecialchars($e->getTraceAsString()) . "</pre>";
    echo "</div>";
}
?>
