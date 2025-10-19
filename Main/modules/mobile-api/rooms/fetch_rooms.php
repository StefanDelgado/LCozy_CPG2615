<?php
require_once __DIR__ . '/../../../config.php';
require_once __DIR__ . '/../shared/cors.php';

header('Content-Type: application/json');

if (!isset($_GET['dorm_id'])) {
    echo json_encode(['error' => 'Dorm ID required']);
    exit;
}

$dorm_id = intval($_GET['dorm_id']);

try {
    // Fetch rooms for specific dorm
    $stmt = $pdo->prepare("
        SELECT 
            r.room_id,
            r.room_type,
            r.capacity,
            r.price,
            r.status,
            r.room_number,
            r.features,
            (SELECT COUNT(*) 
             FROM bookings b 
             WHERE b.room_id = r.room_id 
             AND b.status = 'approved') as current_occupants,
            (SELECT COUNT(*) 
             FROM bookings b 
             WHERE b.room_id = r.room_id 
             AND b.status = 'approved') as active_bookings
        FROM rooms r
        WHERE r.dorm_id = ?
        ORDER BY r.created_at DESC
    ");
    
    $stmt->execute([$dorm_id]);
    $rooms = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        'ok' => true,
        'rooms' => $rooms
    ]);

} catch (Exception $e) {
    error_log('Fetch rooms API error: ' . $e->getMessage());
    echo json_encode(['error' => 'Server error']);
}