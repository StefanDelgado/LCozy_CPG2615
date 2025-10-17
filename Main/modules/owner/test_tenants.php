<?php
// Simple diagnostic script to check tenant table
error_reporting(E_ALL);
ini_set('display_errors', 1);

require_once __DIR__ . '/../../config.php';

echo "<h1>Tenant Table Diagnostic</h1>";

try {
    // Check if tenants table exists
    $stmt = $pdo->query("SHOW TABLES LIKE 'tenants'");
    $table_exists = $stmt->rowCount() > 0;
    
    if ($table_exists) {
        echo "<p style='color: green;'>✅ Tenants table EXISTS</p>";
        
        // Check structure
        $stmt = $pdo->query("DESCRIBE tenants");
        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo "<h3>Table Structure:</h3>";
        echo "<table border='1' cellpadding='5'>";
        echo "<tr><th>Column</th><th>Type</th><th>Null</th><th>Key</th></tr>";
        foreach ($columns as $col) {
            echo "<tr>";
            echo "<td>{$col['Field']}</td>";
            echo "<td>{$col['Type']}</td>";
            echo "<td>{$col['Null']}</td>";
            echo "<td>{$col['Key']}</td>";
            echo "</tr>";
        }
        echo "</table>";
        
        // Check data
        $stmt = $pdo->query("SELECT COUNT(*) as count FROM tenants");
        $count = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
        echo "<p>Total records: {$count}</p>";
        
    } else {
        echo "<p style='color: red;'>❌ Tenants table DOES NOT EXIST</p>";
        echo "<p><strong>You need to run the database migration script!</strong></p>";
        echo "<p>Location: <code>database_migrations.sql</code></p>";
        echo "<h3>Quick Fix:</h3>";
        echo "<p>Run this in phpMyAdmin or MySQL client:</p>";
        echo "<pre>mysql -u root -p cozydorms < database_migrations.sql</pre>";
    }
    
    // Check other required tables
    echo "<h3>Other Tables Check:</h3>";
    $tables_to_check = ['bookings', 'payments', 'dormitories', 'rooms', 'users'];
    foreach ($tables_to_check as $table) {
        $stmt = $pdo->query("SHOW TABLES LIKE '$table'");
        $exists = $stmt->rowCount() > 0;
        $status = $exists ? '✅' : '❌';
        $color = $exists ? 'green' : 'red';
        echo "<p style='color: $color;'>$status Table: $table</p>";
    }
    
} catch (PDOException $e) {
    echo "<p style='color: red;'>Database Error: " . htmlspecialchars($e->getMessage()) . "</p>";
}
?>
