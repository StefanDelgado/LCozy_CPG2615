<?php
require_once __DIR__ . '/../../config.php';

// Check the structure of room_images table
$stmt = $pdo->query("DESCRIBE room_images");
$columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo "<h3>room_images table structure:</h3>";
echo "<pre>";
print_r($columns);
echo "</pre>";

// Check data
$stmt = $pdo->query("SELECT * FROM room_images LIMIT 3");
$data = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo "<h3>Sample data:</h3>";
echo "<pre>";
print_r($data);
echo "</pre>";
