<?php
require_once __DIR__ . '/../../../config.php';
require_once __DIR__ . '/../shared/cors.php';

header('Content-Type: application/json');

try {
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);

    // Validate required fields
    if (!isset($data['owner_email']) || !isset($data['dorm_id']) || 
        !isset($data['room_type']) || !isset($data['capacity']) || 
        !isset($data['price'])) {
        echo json_encode(['error' => 'Missing required fields']);
        exit;
    }

    // Verify owner owns this dorm
    $stmt = $pdo->prepare("
        SELECT u.user_id 
        FROM users u
        JOIN dormitories d ON u.user_id = d.owner_id
        WHERE u.email = ? AND u.role = 'owner' 
        AND d.dorm_id = ?
    ");
    $stmt->execute([$data['owner_email'], $data['dorm_id']]);
    $owner = $stmt->fetch();

    if (!$owner) {
        echo json_encode(['error' => 'Unauthorized']);
        exit;
    }

    // Add new room
    $stmt = $pdo->prepare("
        INSERT INTO rooms (
            dorm_id, room_type, capacity, 
            price, status, created_at
        ) VALUES (?, ?, ?, ?, 'vacant', NOW())
    ");
    
    $stmt->execute([
        $data['dorm_id'],
        $data['room_type'],
        $data['capacity'],
        $data['price']
    ]);

    echo json_encode([
        'ok' => true,
        'message' => 'Room added successfully',
        'room_id' => $pdo->lastInsertId()
    ]);

} catch (Exception $e) {
    error_log('Add room API error: ' . $e->getMessage());
    echo json_encode(['error' => 'Server error: ' . $e->getMessage()]);
}