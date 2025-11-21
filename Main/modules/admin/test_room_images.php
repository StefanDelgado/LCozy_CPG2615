<?php
require_once __DIR__ . '/../../config.php';

// Check room 46 (Double) for images
$stmt = $pdo->prepare("SELECT * FROM room_images WHERE room_id = 46");
$stmt->execute();
$images = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo "<h3>Images for Room 46 (Double):</h3>";
echo "<pre>";
print_r($images);
echo "</pre>";

echo "<h3>Count: " . count($images) . "</h3>";
