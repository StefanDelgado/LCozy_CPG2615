<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/../../auth/auth.php';
require_role('owner');

$owner_id = $_SESSION['user']['user_id'];

echo "<h1>Debugging Tenant Queries</h1>";
echo "<p>Owner ID: $owner_id</p>";

try {
    echo "<h2>Test 1: Simple Tenant Query</h2>";
    $stmt = $pdo->prepare("SELECT * FROM tenants WHERE dorm_id IN (SELECT dorm_id FROM dormitories WHERE owner_id = ?)");
    $stmt->execute([$owner_id]);
    $tenants = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "<p>Found " . count($tenants) . " tenants</p>";
    
    echo "<h2>Test 2: Check bookings table structure</h2>";
    $stmt = $pdo->query("DESCRIBE bookings");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "<pre>";
    foreach ($columns as $col) {
        echo $col['Field'] . " - " . $col['Type'] . "\n";
    }
    echo "</pre>";
    
    echo "<h2>Test 3: Full Join Query</h2>";
    $stmt = $pdo->prepare("
        SELECT 
            t.tenant_id,
            t.booking_id,
            u.name AS tenant_name,
            u.email AS tenant_email,
            d.name AS dorm_name,
            r.room_type,
            t.check_in_date,
            t.expected_checkout
        FROM tenants t
        JOIN users u ON t.student_id = u.user_id
        JOIN dormitories d ON t.dorm_id = d.dorm_id
        JOIN rooms r ON t.room_id = r.room_id
        JOIN bookings b ON t.booking_id = b.booking_id
        WHERE d.owner_id = ? AND t.status = 'active'
        LIMIT 5
    ");
    $stmt->execute([$owner_id]);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "<p>Query successful! Found " . count($result) . " results</p>";
    echo "<pre>";
    print_r($result);
    echo "</pre>";
    
    echo "<h2>✅ All tests passed!</h2>";
    
} catch (Exception $e) {
    echo "<div style='color: red; padding: 20px; background: #fee;'>";
    echo "<h2>❌ Error Found!</h2>";
    echo "<p><strong>Error:</strong> " . htmlspecialchars($e->getMessage()) . "</p>";
    echo "<p><strong>File:</strong> " . $e->getFile() . "</p>";
    echo "<p><strong>Line:</strong> " . $e->getLine() . "</p>";
    echo "<pre>" . htmlspecialchars($e->getTraceAsString()) . "</pre>";
    echo "</div>";
}
?>
