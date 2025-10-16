<?php
require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/cors.php';

header('Content-Type: application/json');

try {
    // Handle both JSON and POST data
    $data = $_POST;
    if (empty($data)) {
        $json = file_get_contents('php://input');
        $data = json_decode($json, true);
    }

    if (!isset($data['owner_email'])) {
        echo json_encode([
            'success' => false,
            'error' => 'Owner email required',
            'message' => 'Owner email is required'
        ]);
        exit;
    }

    // Get owner ID
    $stmt = $pdo->prepare("SELECT user_id FROM users WHERE email = ? AND role = 'owner'");
    $stmt->execute([$data['owner_email']]);
    $owner = $stmt->fetch();

    if (!$owner) {
        echo json_encode([
            'success' => false,
            'error' => 'Owner not found',
            'message' => 'Owner account not found'
        ]);
        exit;
    }

    // Insert new dorm with latitude/longitude
    $stmt = $pdo->prepare("
        INSERT INTO dormitories (
            owner_id, name, address, description, 
            features, latitude, longitude, verified, created_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, 0, NOW())
    ");
    
    $stmt->execute([
        $owner['user_id'],
        $data['name'],
        $data['address'],
        $data['description'],
        $data['features'] ?? '',
        $data['latitude'] ?? null,
        $data['longitude'] ?? null
    ]);

    echo json_encode([
        'success' => true,
        'message' => 'Dorm added successfully',
        'dorm_id' => $pdo->lastInsertId()
    ]);

} catch (Exception $e) {
    error_log('Add dorm API error: ' . $e->getMessage());
    echo json_encode([
        'success' => false,
        'error' => 'Server error',
        'message' => 'An error occurred while adding the dorm'
    ]);
}