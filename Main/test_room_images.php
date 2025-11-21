<?php
require_once 'config.php';

echo "=== Testing Room Images ===\n\n";

// Check room_images table
$stmt = $pdo->query("SELECT room_id, image_path FROM room_images LIMIT 10");
$images = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo "Room Images in database:\n";
foreach ($images as $img) {
    echo "Room ID: {$img['room_id']} | Image: {$img['image_path']}\n";
}

$count = $pdo->query("SELECT COUNT(*) FROM room_images")->fetchColumn();
echo "\nTotal room images: $count\n\n";

// Check rooms table
$stmt = $pdo->query("SELECT room_id, room_type, dorm_id FROM rooms LIMIT 5");
$rooms = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo "Sample Rooms:\n";
foreach ($rooms as $room) {
    echo "Room ID: {$room['room_id']} | Type: {$room['room_type']} | Dorm ID: {$room['dorm_id']}\n";
    
    // Check if this room has images
    $imgStmt = $pdo->prepare("SELECT image_path FROM room_images WHERE room_id = ?");
    $imgStmt->execute([$room['room_id']]);
    $roomImages = $imgStmt->fetchAll(PDO::FETCH_COLUMN);
    
    if (empty($roomImages)) {
        echo "  -> No images for this room\n";
    } else {
        echo "  -> Images: " . implode(", ", $roomImages) . "\n";
    }
}

// Test the exact query used in the API
echo "\n=== Testing API Query ===\n";
$dorm_id = 8; // Anna's Haven Dormitory
$roomsStmt = $pdo->prepare("
    SELECT 
        r.room_id,
        r.room_type,
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

echo "Rooms for Dorm ID $dorm_id:\n";
foreach ($rooms as $room) {
    echo "Room ID: {$room['room_id']} | Type: {$room['room_type']} | Images: " . ($room['room_images'] ?? 'NULL') . "\n";
}
