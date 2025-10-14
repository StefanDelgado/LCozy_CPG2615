<?php
require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/cors.php';

header('Content-Type: application/json');

try {
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);

    if (!isset($data['owner_email'])) {
        echo json_encode(['error' => 'Owner email required']);
        exit;
    }

    // Get owner ID
    $stmt = $pdo->prepare("SELECT user_id FROM users WHERE email = ? AND role = 'owner'");
    $stmt->execute([$data['owner_email']]);
    $owner = $stmt->fetch();

    if (!$owner) {
        echo json_encode(['error' => 'Owner not found']);
        exit;
    }

    // Insert new dorm
    $stmt = $pdo->prepare("
        INSERT INTO dormitories (
            owner_id, name, address, description, 
            features, verified, created_at
        ) VALUES (?, ?, ?, ?, ?, 0, NOW())
    ");
    
    $stmt->execute([
        $owner['user_id'],
        $data['name'],
        $data['address'],
        $data['description'],
        $data['features']
    ]);

    echo json_encode([
        'ok' => true,
        'message' => 'Dorm added successfully'
    ]);

} catch (Exception $e) {
    error_log('Add dorm API error: ' . $e->getMessage());
    echo json_encode(['error' => 'Server error']);
}