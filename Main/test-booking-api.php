<?php
/**
 * Owner Bookings API Test
 * Upload to: http://cozydorms.life/test-booking-api.php
 * 
 * Usage:
 * http://cozydorms.life/test-booking-api.php?owner_email=YOUR_EMAIL
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

echo "=== OWNER BOOKINGS API TEST ===\n\n";

$ownerEmail = $_GET['owner_email'] ?? '';

if (empty($ownerEmail)) {
    echo json_encode([
        'error' => 'Please provide owner_email parameter',
        'example' => 'test-booking-api.php?owner_email=your@email.com'
    ], JSON_PRETTY_PRINT);
    exit;
}

echo "Testing with owner email: $ownerEmail\n\n";

// Test 1: Check if API file exists
$apiFile = __DIR__ . '/modules/mobile-api/owner/owner_bookings_api.php';
echo "Step 1: Checking if API file exists...\n";
echo "Path: $apiFile\n";

if (!file_exists($apiFile)) {
    echo "❌ ERROR: File does not exist!\n";
    echo json_encode(['status' => 'FILE_NOT_FOUND'], JSON_PRETTY_PRINT);
    exit;
}
echo "✅ File exists\n";
echo "File size: " . filesize($apiFile) . " bytes\n\n";

// Test 2: Check if file is readable
echo "Step 2: Checking if file is readable...\n";
if (!is_readable($apiFile)) {
    echo "❌ ERROR: File is not readable!\n";
    echo json_encode(['status' => 'FILE_NOT_READABLE'], JSON_PRETTY_PRINT);
    exit;
}
echo "✅ File is readable\n\n";

// Test 3: Try to include the file and capture output
echo "Step 3: Testing API call...\n";
echo "URL: /modules/mobile-api/owner/owner_bookings_api.php?owner_email=$ownerEmail\n\n";

// Set up the GET parameter
$_GET['owner_email'] = $ownerEmail;

// Capture output
ob_start();
try {
    require $apiFile;
    $output = ob_get_clean();
    
    echo "API Response:\n";
    echo "=====================================\n";
    echo $output;
    echo "\n=====================================\n\n";
    
    // Try to decode as JSON
    $json = json_decode($output, true);
    if (json_last_error() === JSON_ERROR_NONE) {
        echo "✅ Valid JSON response\n";
        echo "Response structure:\n";
        echo "  - ok: " . ($json['ok'] ?? 'not set') . "\n";
        echo "  - success: " . ($json['success'] ?? 'not set') . "\n";
        if (isset($json['bookings'])) {
            echo "  - bookings: " . count($json['bookings']) . " items\n";
        }
        if (isset($json['error'])) {
            echo "  - error: " . $json['error'] . "\n";
        }
    } else {
        echo "⚠️  Response is not valid JSON\n";
        echo "JSON error: " . json_last_error_msg() . "\n";
    }
    
} catch (Exception $e) {
    $output = ob_get_clean();
    echo "❌ ERROR occurred:\n";
    echo $e->getMessage() . "\n\n";
    echo "Output before error:\n";
    echo $output;
}

echo "\n=== TEST COMPLETE ===\n";
?>
