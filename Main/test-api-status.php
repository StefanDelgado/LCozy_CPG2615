<?php
/**
 * Live Server API Diagnostics
 * Upload to: http://cozydorms.life/test-api-status.php
 * Then visit: http://cozydorms.life/test-api-status.php
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

$results = [
    'test_name' => 'Mobile API Diagnostics',
    'server_time' => date('Y-m-d H:i:s'),
    'server_info' => [
        'php_version' => phpversion(),
        'server_software' => $_SERVER['SERVER_SOFTWARE'] ?? 'Unknown',
        'document_root' => $_SERVER['DOCUMENT_ROOT'] ?? 'Unknown',
    ],
    'checks' => []
];

// Check 1: Does owner_bookings_api.php exist?
$ownerBookingsPath = __DIR__ . '/modules/mobile-api/owner/owner_bookings_api.php';
$results['checks']['owner_bookings_file'] = [
    'path' => $ownerBookingsPath,
    'exists' => file_exists($ownerBookingsPath),
    'readable' => file_exists($ownerBookingsPath) && is_readable($ownerBookingsPath),
    'size' => file_exists($ownerBookingsPath) ? filesize($ownerBookingsPath) : 0,
];

// Check 2: Does config.php exist?
$configPath = __DIR__ . '/config.php';
$results['checks']['config_file'] = [
    'path' => $configPath,
    'exists' => file_exists($configPath),
    'readable' => file_exists($configPath) && is_readable($configPath),
];

// Check 3: Does shared/cors.php exist?
$corsPath = __DIR__ . '/modules/mobile-api/shared/cors.php';
$results['checks']['cors_file'] = [
    'path' => $corsPath,
    'exists' => file_exists($corsPath),
    'readable' => file_exists($corsPath) && is_readable($corsPath),
];

// Check 4: List all mobile-api folders
$mobileApiPath = __DIR__ . '/modules/mobile-api/';
if (is_dir($mobileApiPath)) {
    $folders = array_filter(scandir($mobileApiPath), function($item) use ($mobileApiPath) {
        return $item !== '.' && $item !== '..' && is_dir($mobileApiPath . $item);
    });
    $results['checks']['mobile_api_folders'] = array_values($folders);
} else {
    $results['checks']['mobile_api_folders'] = ['error' => 'Directory not found'];
}

// Check 5: Test database connection
try {
    if (file_exists($configPath)) {
        require_once $configPath;
        if (isset($pdo)) {
            $results['checks']['database'] = [
                'status' => 'connected',
                'message' => 'Database connection successful'
            ];
        } else {
            $results['checks']['database'] = [
                'status' => 'error',
                'message' => '$pdo variable not found in config.php'
            ];
        }
    } else {
        $results['checks']['database'] = [
            'status' => 'error',
            'message' => 'config.php not found'
        ];
    }
} catch (Exception $e) {
    $results['checks']['database'] = [
        'status' => 'error',
        'message' => $e->getMessage()
    ];
}

// Check 6: Try to actually call the owner_bookings API
if (file_exists($ownerBookingsPath)) {
    $testUrl = 'http://' . $_SERVER['HTTP_HOST'] . '/modules/mobile-api/owner/owner_bookings_api.php?owner_email=test@test.com';
    
    $results['checks']['api_test'] = [
        'url' => $testUrl,
        'method' => 'Testing via file_get_contents...'
    ];
    
    try {
        $context = stream_context_create([
            'http' => [
                'timeout' => 5,
                'ignore_errors' => true
            ]
        ]);
        
        $response = @file_get_contents($testUrl, false, $context);
        $httpCode = 200;
        
        if (isset($http_response_header)) {
            foreach ($http_response_header as $header) {
                if (preg_match('/^HTTP\/\d\.\d\s+(\d+)/', $header, $matches)) {
                    $httpCode = (int)$matches[1];
                }
            }
        }
        
        $results['checks']['api_test']['status_code'] = $httpCode;
        $results['checks']['api_test']['response'] = $response ? substr($response, 0, 500) : 'Empty response';
        $results['checks']['api_test']['success'] = $httpCode === 200;
        
    } catch (Exception $e) {
        $results['checks']['api_test']['error'] = $e->getMessage();
    }
}

// Overall status
$allGood = true;
if (!$results['checks']['owner_bookings_file']['exists']) $allGood = false;
if (!$results['checks']['config_file']['exists']) $allGood = false;
if (!$results['checks']['cors_file']['exists']) $allGood = false;
if (isset($results['checks']['database']['status']) && $results['checks']['database']['status'] === 'error') $allGood = false;

$results['overall_status'] = $allGood ? 'ALL_SYSTEMS_GO' : 'ISSUES_FOUND';

echo json_encode($results, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
?>
