<?php
header('Content-Type: application/json');
error_reporting(E_ALL);
ini_set('display_errors', 1);

echo json_encode(['step' => 'Starting test...']) . "\n";

// Test 1: Check if config file exists
if (!file_exists(__DIR__ . '/../../config.php')) {
    echo json_encode(['ok' => false, 'error' => 'config.php not found']);
    exit;
}

// Test 2: Include config
require_once __DIR__ . '/../../config.php';
echo json_encode(['step' => 'Config included']) . "\n";

// Test 3: Check PDO
if (!isset($pdo)) {
    echo json_encode(['ok' => false, 'error' => 'PDO variable not set']);
    exit;
}

if ($pdo === null) {
    echo json_encode(['ok' => false, 'error' => 'PDO is null']);
    exit;
}

echo json_encode(['step' => 'PDO is set']) . "\n";

// Test 4: Try a simple query
try {
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM dormitories");
    $result = $stmt->fetch();
    echo json_encode([
        'ok' => true, 
        'message' => 'Database connection successful',
        'total_dorms' => $result['total']
    ]);
} catch (PDOException $e) {
    echo json_encode([
        'ok' => false,
        'error' => 'Query failed',
        'message' => $e->getMessage()
    ]);
}
