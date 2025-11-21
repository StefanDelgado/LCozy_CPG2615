<?php
require_once __DIR__ . '/../../config.php';
session_start();

header('Content-Type: application/json');

// Check if user is logged in and is an owner
if (!isset($_SESSION['user']) || $_SESSION['user']['role'] !== 'owner') {
    echo json_encode(['success' => false, 'message' => 'Unauthorized']);
    exit();
}

$room_id = isset($_GET['room_id']) ? (int)$_GET['room_id'] : 0;
$owner_id = $_SESSION['user']['user_id'];

if ($room_id <= 0) {
    echo json_encode(['success' => false, 'message' => 'Invalid room ID']);
    exit();
}

try {
    // Verify room belongs to the owner
    $stmt = $pdo->prepare("
        SELECT COUNT(*) 
        FROM rooms r
        JOIN dormitories d ON r.dorm_id = d.dorm_id
        WHERE r.room_id = ? AND d.owner_id = ?
    ");
    $stmt->execute([$room_id, $owner_id]);
    
    if ($stmt->fetchColumn() == 0) {
        echo json_encode(['success' => false, 'message' => 'Unauthorized']);
        exit();
    }
    
    // Fetch room images
    $stmt = $pdo->prepare("
        SELECT image_id, image_path, uploaded_at
        FROM room_images
        WHERE room_id = ?
        ORDER BY uploaded_at DESC
    ");
    $stmt->execute([$room_id]);
    $images = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'images' => $images
    ]);
    
} catch (PDOException $e) {
    error_log('Error fetching room images: ' . $e->getMessage());
    echo json_encode([
        'success' => false,
        'message' => 'Database error'
    ]);
}
