<?php
require_once __DIR__ . '/../../config.php';
session_start();

// Check if user is logged in and is an owner
if (!isset($_SESSION['user']) || $_SESSION['user']['role'] !== 'owner') {
    http_response_code(403);
    echo json_encode(['error' => 'Unauthorized']);
    exit;
}

$owner_id = $_SESSION['user']['user_id'];
$room_id = isset($_GET['room_id']) ? (int)$_GET['room_id'] : 0;

if (!$room_id) {
    echo json_encode(['images' => []]);
    exit;
}

// Verify the room belongs to this owner
$stmt = $pdo->prepare("
    SELECT ri.image_id, ri.image_path, ri.uploaded_at
    FROM room_images ri
    JOIN rooms r ON ri.room_id = r.room_id
    JOIN dormitories d ON r.dorm_id = d.dorm_id
    WHERE r.room_id = ? AND d.owner_id = ?
    ORDER BY ri.uploaded_at DESC
");
$stmt->execute([$room_id, $owner_id]);
$images = $stmt->fetchAll(PDO::FETCH_ASSOC);

header('Content-Type: application/json');
echo json_encode(['images' => $images]);
