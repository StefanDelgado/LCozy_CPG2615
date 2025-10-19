<?php
/**
 * API Test Script - Owner Dashboard
 * 
 * Quick test to verify the owner_dashboard_api.php is working
 * 
 * Usage: Place this file in Main/ folder and access via browser:
 * http://localhost/WebDesign_BSITA-2/2nd sem/Joshan_System/LCozy_CPG2615/Main/test_dashboard_api.php?email=YOUR_EMAIL
 */

require_once __DIR__ . '/config.php';

header('Content-Type: text/html; charset=utf-8');

// Get email from query parameter
$owner_email = $_GET['email'] ?? 'test@example.com';

echo "<!DOCTYPE html>
<html>
<head>
    <title>Dashboard API Test</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; }
        h1 { color: #6B21A8; }
        .section { margin: 20px 0; padding: 15px; background: #f9f9f9; border-left: 4px solid #6B21A8; }
        .success { color: green; }
        .error { color: red; }
        pre { background: #2d2d2d; color: #f8f8f8; padding: 15px; border-radius: 5px; overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; margin: 10px 0; }
        th, td { padding: 10px; text-align: left; border: 1px solid #ddd; }
        th { background: #6B21A8; color: white; }
        .badge { display: inline-block; padding: 3px 8px; border-radius: 3px; font-size: 12px; }
        .badge-success { background: #10B981; color: white; }
        .badge-warning { background: #F59E0B; color: white; }
        .badge-error { background: #EF4444; color: white; }
    </style>
</head>
<body>
    <div class='container'>
        <h1>🔍 Owner Dashboard API Test</h1>
        <p>Testing email: <strong>$owner_email</strong></p>
        <p><a href='?email=$owner_email'>Refresh</a></p>
        <hr>
";

// Test 1: Check if owner exists
echo "<div class='section'>";
echo "<h2>Test 1: Owner Verification</h2>";

try {
    $stmt = $pdo->prepare("SELECT user_id, name, email, role FROM users WHERE email = ? AND role = 'owner'");
    $stmt->execute([$owner_email]);
    $owner = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($owner) {
        echo "<p class='success'>✅ Owner found!</p>";
        echo "<table>";
        echo "<tr><th>Field</th><th>Value</th></tr>";
        foreach ($owner as $key => $value) {
            echo "<tr><td><strong>$key</strong></td><td>$value</td></tr>";
        }
        echo "</table>";
        $owner_id = $owner['user_id'];
    } else {
        echo "<p class='error'>❌ Owner not found! Make sure the email is registered as 'owner' role.</p>";
        $owner_id = null;
    }
} catch (Exception $e) {
    echo "<p class='error'>❌ Database error: " . $e->getMessage() . "</p>";
    $owner_id = null;
}

echo "</div>";

if ($owner_id) {
    // Test 2: Count dormitories
    echo "<div class='section'>";
    echo "<h2>Test 2: Dormitories</h2>";
    
    try {
        $stmt = $pdo->prepare("SELECT dorm_id, name, address FROM dormitories WHERE owner_id = ?");
        $stmt->execute([$owner_id]);
        $dorms = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo "<p>Total Dormitories: <strong>" . count($dorms) . "</strong></p>";
        
        if (count($dorms) > 0) {
            echo "<table>";
            echo "<tr><th>Dorm ID</th><th>Name</th><th>Address</th></tr>";
            foreach ($dorms as $dorm) {
                echo "<tr><td>{$dorm['dorm_id']}</td><td>{$dorm['name']}</td><td>{$dorm['address']}</td></tr>";
            }
            echo "</table>";
        } else {
            echo "<p class='error'>❌ No dormitories found for this owner.</p>";
        }
    } catch (Exception $e) {
        echo "<p class='error'>❌ Error: " . $e->getMessage() . "</p>";
    }
    
    echo "</div>";

    // Test 3: Count rooms
    echo "<div class='section'>";
    echo "<h2>Test 3: Rooms</h2>";
    
    try {
        $stmt = $pdo->prepare("
            SELECT COUNT(*) as total_rooms
            FROM rooms r
            JOIN dormitories d ON r.dorm_id = d.dorm_id
            WHERE d.owner_id = ?
        ");
        $stmt->execute([$owner_id]);
        $total_rooms = $stmt->fetchColumn();
        
        echo "<p>Total Rooms: <strong>$total_rooms</strong> <span class='badge badge-" . ($total_rooms > 0 ? "success" : "warning") . "'>" . ($total_rooms > 0 ? "OK" : "Empty") . "</span></p>";
    } catch (Exception $e) {
        echo "<p class='error'>❌ Error: " . $e->getMessage() . "</p>";
    }
    
    echo "</div>";

    // Test 4: Count tenants
    echo "<div class='section'>";
    echo "<h2>Test 4: Tenants</h2>";
    
    try {
        $stmt = $pdo->prepare("
            SELECT COUNT(DISTINCT b.student_id) as total_tenants
            FROM bookings b
            JOIN rooms r ON b.room_id = r.room_id
            JOIN dormitories d ON r.dorm_id = d.dorm_id
            WHERE d.owner_id = ? AND b.status = 'approved'
        ");
        $stmt->execute([$owner_id]);
        $total_tenants = $stmt->fetchColumn();
        
        echo "<p>Total Tenants: <strong>$total_tenants</strong> <span class='badge badge-" . ($total_tenants > 0 ? "success" : "warning") . "'>" . ($total_tenants > 0 ? "OK" : "Empty") . "</span></p>";
    } catch (Exception $e) {
        echo "<p class='error'>❌ Error: " . $e->getMessage() . "</p>";
    }
    
    echo "</div>";

    // Test 5: Calculate revenue
    echo "<div class='section'>";
    echo "<h2>Test 5: Monthly Revenue</h2>";
    
    try {
        $stmt = $pdo->prepare("
            SELECT COALESCE(SUM(p.amount), 0) as monthly_revenue
            FROM payments p
            JOIN bookings b ON p.booking_id = b.booking_id
            JOIN rooms r ON b.room_id = r.room_id
            JOIN dormitories d ON r.dorm_id = d.dorm_id
            WHERE d.owner_id = ? 
            AND p.status = 'paid'
            AND p.payment_date >= DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY)
        ");
        $stmt->execute([$owner_id]);
        $monthly_revenue = $stmt->fetchColumn();
        
        echo "<p>Monthly Revenue (Last 30 days): <strong>₱" . number_format($monthly_revenue, 2) . "</strong> <span class='badge badge-" . ($monthly_revenue > 0 ? "success" : "warning") . "'>" . ($monthly_revenue > 0 ? "OK" : "No payments") . "</span></p>";
    } catch (Exception $e) {
        echo "<p class='error'>❌ Error: " . $e->getMessage() . "</p>";
    }
    
    echo "</div>";

    // Test 6: Call actual API
    echo "<div class='section'>";
    echo "<h2>Test 6: API Response</h2>";
    
    $api_url = "http://" . $_SERVER['HTTP_HOST'] . dirname($_SERVER['PHP_SELF']) . "/modules/mobile-api/owner/owner_dashboard_api.php?owner_email=" . urlencode($owner_email);
    
    echo "<p>API URL: <code>$api_url</code></p>";
    
    try {
        $ch = curl_init($api_url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_TIMEOUT, 10);
        $api_response = curl_exec($ch);
        $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        if ($http_code == 200) {
            echo "<p class='success'>✅ API returned HTTP 200</p>";
            echo "<h3>Response:</h3>";
            
            $json_data = json_decode($api_response, true);
            if ($json_data) {
                echo "<pre>" . json_encode($json_data, JSON_PRETTY_PRINT) . "</pre>";
                
                if (isset($json_data['success']) && $json_data['success'] === true) {
                    echo "<p class='success'>✅ API returned success=true</p>";
                    
                    if (isset($json_data['data']['stats'])) {
                        $stats = $json_data['data']['stats'];
                        echo "<h3>Stats Summary:</h3>";
                        echo "<table>";
                        echo "<tr><th>Metric</th><th>Value</th><th>Status</th></tr>";
                        echo "<tr><td>Rooms</td><td>{$stats['rooms']}</td><td><span class='badge badge-success'>OK</span></td></tr>";
                        echo "<tr><td>Tenants</td><td>{$stats['tenants']}</td><td><span class='badge badge-success'>OK</span></td></tr>";
                        echo "<tr><td>Revenue</td><td>₱" . number_format($stats['monthly_revenue'], 2) . "</td><td><span class='badge badge-success'>OK</span></td></tr>";
                        echo "</table>";
                    }
                } else {
                    echo "<p class='error'>❌ API returned success=false</p>";
                }
            } else {
                echo "<p class='error'>❌ Invalid JSON response</p>";
                echo "<pre>$api_response</pre>";
            }
        } else {
            echo "<p class='error'>❌ API returned HTTP $http_code</p>";
            echo "<pre>$api_response</pre>";
        }
    } catch (Exception $e) {
        echo "<p class='error'>❌ Error calling API: " . $e->getMessage() . "</p>";
    }
    
    echo "</div>";
}

echo "
        <hr>
        <h2>✅ Test Complete</h2>
        <p>If all tests passed, the API should work correctly in your mobile app!</p>
    </div>
</body>
</html>";
?>
