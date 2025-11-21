<?php
require_once __DIR__ . '/../../config.php';

// Check Anna's Haven Dormitory rooms
$stmt = $pdo->prepare("
    SELECT r.room_id, r.room_type, r.status, r.capacity,
           (SELECT image_path FROM room_images WHERE room_id = r.room_id LIMIT 1) as image
    FROM rooms r
    JOIN dormitories d ON r.dorm_id = d.dorm_id
    WHERE d.name = 'Anna\'s Haven Dormitory'
    ORDER BY r.room_id
");
$stmt->execute();
$rooms = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo "<h3>Anna's Haven Dormitory - Rooms:</h3>";
echo "<table border='1' style='border-collapse: collapse;'>";
echo "<tr><th>Room ID</th><th>Type</th><th>Status</th><th>Capacity</th><th>Has Image?</th><th>Image Path</th></tr>";
foreach ($rooms as $room) {
    $hasImage = !empty($room['image']) ? '✅ Yes' : '❌ No';
    echo "<tr>";
    echo "<td>{$room['room_id']}</td>";
    echo "<td>{$room['room_type']}</td>";
    echo "<td>{$room['status']}</td>";
    echo "<td>{$room['capacity']}</td>";
    echo "<td>{$hasImage}</td>";
    echo "<td>" . ($room['image'] ?? 'None') . "</td>";
    echo "</tr>";
}
echo "</table>";
