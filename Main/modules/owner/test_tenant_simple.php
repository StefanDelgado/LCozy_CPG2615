<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);

echo "Step 1: Starting...<br>";

try {
    echo "Step 2: Loading auth...<br>";
    require_once __DIR__ . '/../../auth/auth.php';
    echo "Step 3: Auth loaded<br>";
    
    require_role('owner');
    echo "Step 4: Role checked<br>";
    
    require_once __DIR__ . '/../../config.php';
    echo "Step 5: Config loaded<br>";
    
    $owner_id = $_SESSION['user']['user_id'];
    echo "Step 6: Owner ID: $owner_id<br>";
    
    echo "Step 7: Testing simple query...<br>";
    $stmt = $pdo->query("SELECT COUNT(*) FROM tenants");
    $count = $stmt->fetchColumn();
    echo "Step 8: Found $count tenants in database<br>";
    
    echo "Step 9: Testing tenant query with owner filter...<br>";
    $stmt = $pdo->prepare("SELECT * FROM tenants t JOIN dormitories d ON t.dorm_id = d.dorm_id WHERE d.owner_id = ? LIMIT 1");
    $stmt->execute([$owner_id]);
    $tenant = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "Step 10: Query successful<br>";
    
    if ($tenant) {
        echo "Step 11: Found tenant: <pre>" . print_r($tenant, true) . "</pre>";
    } else {
        echo "Step 11: No tenants found for owner $owner_id<br>";
    }
    
    echo "<h2 style='color: green;'>✅ ALL STEPS PASSED!</h2>";
    echo "<p>The queries work. The issue must be in the full page logic.</p>";
    
} catch (Exception $e) {
    echo "<h2 style='color: red;'>❌ ERROR at current step!</h2>";
    echo "<p><strong>Error:</strong> " . $e->getMessage() . "</p>";
    echo "<p><strong>File:</strong> " . $e->getFile() . "</p>";
    echo "<p><strong>Line:</strong> " . $e->getLine() . "</p>";
    echo "<pre>" . $e->getTraceAsString() . "</pre>";
}
?>
