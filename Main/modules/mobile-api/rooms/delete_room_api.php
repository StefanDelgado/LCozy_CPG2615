<?php
require_once __DIR__ . '/../../../config.php';
require_once __DIR__ . '/../shared/cors.php';

header('Content-Type: application/json');

try {
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);

    if (!isset($data['owner_email']) || !isset($data['room_id'])) {
        echo json_encode(['error' => 'Missing required fields']);
        exit;
    }

    // Verify owner owns this room
    $stmt = $pdo->prepare("
        SELECT u.user_id 
        FROM users u
        JOIN dormitories d ON u.user_id = d.owner_id
        JOIN rooms r ON d.dorm_id = r.dorm_id
        WHERE u.email = ? AND r.room_id = ?
    ");
    $stmt->execute([$data['owner_email'], $data['room_id']]);
    
    if (!$stmt->fetch()) {
        echo json_encode(['error' => 'Unauthorized']);
        exit;
    }

    $stmt = $pdo->prepare("DELETE FROM rooms WHERE room_id = ?");
    $stmt->execute([$data['room_id']]);

    echo json_encode([
        'ok' => true,
        'message' => 'Room deleted successfully'
    ]);

} catch (Exception $e) {
    error_log('Delete room API error: ' . $e->getMessage());
    echo json_encode(['error' => 'Server error']);
}