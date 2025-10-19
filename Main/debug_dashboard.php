<?php
/**
 * Quick Debug Script for Owner Dashboard API
 * Access: http://localhost/WebDesign_BSITA-2/2nd%20sem/Joshan_System/LCozy_CPG2615/Main/debug_dashboard.php
 */

// Enable error display
error_reporting(E_ALL);
ini_set('display_errors', 1);

echo "<h1>Dashboard API Debug</h1>";
echo "<hr>";

// Test 1: Config file
echo "<h2>Test 1: Config File</h2>";
$config_path = __DIR__ . '/config.php';
if (file_exists($config_path)) {
    echo "✅ config.php exists<br>";
    require_once $config_path;
    
    if (isset($pdo)) {
        echo "✅ PDO connection successful<br>";
        echo "Connected to: " . $pdo->getAttribute(PDO::ATTR_DRIVER_NAME) . "<br>";
    } else {
        echo "❌ PDO not initialized<br>";
    }
} else {
    echo "❌ config.php NOT found at: $config_path<br>";
}

echo "<hr>";

// Test 2: CORS file
echo "<h2>Test 2: CORS File</h2>";
$cors_path = __DIR__ . '/modules/mobile-api/shared/cors.php';
if (file_exists($cors_path)) {
    echo "✅ cors.php exists<br>";
} else {
    echo "❌ cors.php NOT found at: $cors_path<br>";
}

echo "<hr>";

// Test 3: Test with sample email
if (isset($pdo)) {
    echo "<h2>Test 3: Database Queries</h2>";
    
    $test_email = $_GET['email'] ?? 'test@example.com';
    echo "Testing with email: <strong>$test_email</strong><br><br>";
    
    try {
        // Check if owner exists
        echo "<strong>Query 1: Find Owner</strong><br>";
        $stmt = $pdo->prepare("SELECT user_id, name, email, role FROM users WHERE email = ? AND role = 'owner'");
        $stmt->execute([$test_email]);
        $owner = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($owner) {
            echo "✅ Owner found: " . print_r($owner, true) . "<br>";
            $owner_id = $owner['user_id'];
            
            // Count rooms
            echo "<br><strong>Query 2: Count Rooms</strong><br>";
            $roomsStmt = $pdo->prepare("
                SELECT COUNT(*) as total
                FROM rooms r
                JOIN dormitories d ON r.dorm_id = d.dorm_id
                WHERE d.owner_id = ?
            ");
            $roomsStmt->execute([$owner_id]);
            $total_rooms = $roomsStmt->fetchColumn();
            echo "✅ Total rooms: $total_rooms<br>";
            
            // Count tenants
            echo "<br><strong>Query 3: Count Tenants</strong><br>";
            $tenantsStmt = $pdo->prepare("
                SELECT COUNT(DISTINCT b.student_id) as total
                FROM bookings b
                JOIN rooms r ON b.room_id = r.room_id
                JOIN dormitories d ON r.dorm_id = d.dorm_id
                WHERE d.owner_id = ? AND b.status = 'approved'
            ");
            $tenantsStmt->execute([$owner_id]);
            $total_tenants = $tenantsStmt->fetchColumn();
            echo "✅ Total tenants: $total_tenants<br>";
            
            // Calculate revenue
            echo "<br><strong>Query 4: Calculate Revenue</strong><br>";
            $revenueStmt = $pdo->prepare("
                SELECT COALESCE(SUM(p.amount), 0) as total
                FROM payments p
                JOIN bookings b ON p.booking_id = b.booking_id
                JOIN rooms r ON b.room_id = r.room_id
                JOIN dormitories d ON r.dorm_id = d.dorm_id
                WHERE d.owner_id = ? 
                AND p.status = 'paid'
                AND p.payment_date >= DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY)
            ");
            $revenueStmt->execute([$owner_id]);
            $monthly_revenue = $revenueStmt->fetchColumn();
            echo "✅ Monthly revenue: ₱" . number_format($monthly_revenue, 2) . "<br>";
            
            // Recent bookings
            echo "<br><strong>Query 5: Recent Bookings</strong><br>";
            $recentBookingsStmt = $pdo->prepare("
                SELECT 
                    b.booking_id,
                    b.status,
                    u.name as student_name,
                    d.name as dorm_name,
                    r.room_number,
                    b.created_at
                FROM bookings b
                JOIN rooms r ON b.room_id = r.room_id
                JOIN dormitories d ON r.dorm_id = d.dorm_id
                JOIN users u ON b.student_id = u.user_id
                WHERE d.owner_id = ?
                ORDER BY b.created_at DESC
                LIMIT 5
            ");
            $recentBookingsStmt->execute([$owner_id]);
            $recent_bookings = $recentBookingsStmt->fetchAll(PDO::FETCH_ASSOC);
            echo "✅ Found " . count($recent_bookings) . " recent bookings<br>";
            
            // Recent payments
            echo "<br><strong>Query 6: Recent Payments</strong><br>";
            $recentPaymentsStmt = $pdo->prepare("
                SELECT 
                    p.payment_id,
                    p.amount,
                    p.status,
                    u.name as tenant_name,
                    d.name as dorm_name,
                    p.created_at
                FROM payments p
                JOIN bookings b ON p.booking_id = b.booking_id
                JOIN rooms r ON b.room_id = r.room_id
                JOIN dormitories d ON r.dorm_id = d.dorm_id
                JOIN users u ON b.student_id = u.user_id
                WHERE d.owner_id = ?
                ORDER BY p.created_at DESC
                LIMIT 5
            ");
            $recentPaymentsStmt->execute([$owner_id]);
            $recent_payments = $recentPaymentsStmt->fetchAll(PDO::FETCH_ASSOC);
            echo "✅ Found " . count($recent_payments) . " recent payments<br>";
            
            // Recent messages
            echo "<br><strong>Query 7: Recent Messages</strong><br>";
            $recentMessagesStmt = $pdo->prepare("
                SELECT 
                    m.message_id,
                    m.body as message,
                    m.created_at as sent_at,
                    m.read_at,
                    u.name as sender_name
                FROM messages m
                JOIN users u ON m.sender_id = u.user_id
                WHERE m.receiver_id = ?
                ORDER BY m.created_at DESC
                LIMIT 5
            ");
            $recentMessagesStmt->execute([$owner_id]);
            $recent_messages = $recentMessagesStmt->fetchAll(PDO::FETCH_ASSOC);
            echo "✅ Found " . count($recent_messages) . " recent messages<br>";
            
            // Build final response
            echo "<br><h3>Final JSON Response:</h3>";
            $response = [
                'success' => true,
                'data' => [
                    'stats' => [
                        'rooms' => (int)$total_rooms,
                        'tenants' => (int)$total_tenants,
                        'monthly_revenue' => (float)$monthly_revenue,
                        'recent_activities' => []
                    ],
                    'recent_bookings' => $recent_bookings,
                    'recent_payments' => $recent_payments,
                    'recent_messages' => $recent_messages
                ]
            ];
            echo "<pre>" . json_encode($response, JSON_PRETTY_PRINT) . "</pre>";
            
        } else {
            echo "❌ Owner not found with email: $test_email<br>";
            echo "<br><strong>Available owners:</strong><br>";
            $allOwners = $pdo->query("SELECT user_id, name, email FROM users WHERE role = 'owner' LIMIT 10");
            while ($row = $allOwners->fetch(PDO::FETCH_ASSOC)) {
                echo "- {$row['email']} ({$row['name']})<br>";
            }
        }
        
    } catch (Exception $e) {
        echo "❌ <strong>ERROR:</strong> " . $e->getMessage() . "<br>";
        echo "File: " . $e->getFile() . "<br>";
        echo "Line: " . $e->getLine() . "<br>";
        echo "<pre>" . $e->getTraceAsString() . "</pre>";
    }
}

echo "<hr>";
echo "<h2>✅ Debug Complete</h2>";
echo "<p>Try different email: <a href='?email=test@example.com'>?email=test@example.com</a></p>";
?>
