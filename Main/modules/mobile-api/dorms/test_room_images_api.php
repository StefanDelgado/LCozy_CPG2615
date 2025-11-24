<?php
require_once __DIR__ . '/../../../config.php';
require_once __DIR__ . '/../shared/cors.php';

header('Content-Type: application/json');

try {
    $dorm_id = $_GET['dorm_id'] ?? 8; // Default to dorm 8 (Anna's Haven)
    
    // Test 1: Check if room_images table has data
    $imageCountStmt = $pdo->query("SELECT COUNT(*) FROM room_images");
    $totalImages = $imageCountStmt->fetchColumn();
    
    // Test 2: Get rooms with the exact query from dorm_details_api.php
    $roomsStmt = $pdo->prepare("
        SELECT 
            r.room_id,
            r.room_type,
            r.room_number,
            r.capacity,
            r.price,
            r.status,
            (SELECT GROUP_CONCAT(image_path SEPARATOR ',')
             FROM room_images ri
             WHERE ri.room_id = r.room_id
             LIMIT 3) as room_images
        FROM rooms r
        WHERE r.dorm_id = ?
        ORDER BY r.price ASC
    ");
    $roomsStmt->execute([$dorm_id]);
    $rooms = $roomsStmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Test 3: Get sample images from room_images table
    $sampleImagesStmt = $pdo->query("SELECT room_id, image_path FROM room_images LIMIT 10");
    $sampleImages = $sampleImagesStmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Format rooms like the actual API does
    $formatted_rooms = array_map(function($room) {
        $room_images = [];
        if (!empty($room['room_images'])) {
            $images = explode(',', $room['room_images']);
            foreach ($images as $img) {
                $room_images[] = SITE_URL . '/uploads/rooms/' . trim($img);
            }
        }
        
        return [
            'room_id' => (int)$room['room_id'],
            'room_type' => $room['room_type'],
            'room_number' => $room['room_number'],
            'capacity' => (int)$room['capacity'],
            'price' => (float)$room['price'],
            'status' => $room['status'],
            'room_images_raw' => $room['room_images'], // Show raw data for debugging
            'images' => $room_images
        ];
    }, $rooms);
    
    echo json_encode([
        'ok' => true,
        'debug_info' => [
            'dorm_id' => $dorm_id,
            'total_room_images_in_db' => $totalImages,
            'site_url' => SITE_URL,
        ],
        'sample_room_images_from_db' => $sampleImages,
        'rooms' => $formatted_rooms
    ], JSON_PRETTY_PRINT);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'ok' => false,
        'error' => $e->getMessage()
    ], JSON_PRETTY_PRINT);
}
