<?php
/**
 * Mobile API: Get Owner ID from Email
 * GET /mobile-api/owner/get_owner_id.php?email=owner@email.com
 */

header('Content-Type: application/json');
require_once __DIR__ . '/../../../config.php';
require_once __DIR__ . '/../shared/cors.php';

if (!isset($_GET['email'])) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'Email parameter required']);
    exit;
}

$email = trim($_GET['email']);

try {
    $stmt = $pdo->prepare("SELECT user_id FROM users WHERE email = ? AND role = 'owner' LIMIT 1");
    $stmt->execute([$email]);
    $owner = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$owner) {
        http_response_code(404);
        echo json_encode(['success' => false, 'error' => 'Owner not found']);
        exit;
    }

    echo json_encode([
        'success' => true,
        'owner_id' => (int)$owner['user_id']
    ]);

} catch (Exception $e) {
    error_log('Get owner ID error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Server error']);
}
