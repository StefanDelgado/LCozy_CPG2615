<?php
// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

session_start();

header('Content-Type: application/json');

try {
    require_once __DIR__ . '/../../config.php';
    
    // Debug session
    if (!isset($_SESSION['user'])) {
        echo json_encode(['error' => 'No session user', 'session' => isset($_SESSION) ? 'exists' : 'missing']);
        exit;
    }
    
    if ($_SESSION['user']['role'] !== 'owner') {
        echo json_encode(['error' => 'Not owner', 'role' => $_SESSION['user']['role']]);
        exit;
    }

    $owner_id = $_SESSION['user']['user_id'];
    $room_id = isset($_GET['room_id']) ? (int)$_GET['room_id'] : 0;

    if (!$room_id) {
        echo json_encode(['images' => [], 'debug' => 'No room_id provided']);
        exit;
    }

    // Test query
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

    echo json_encode([
        'images' => $images, 
        'success' => true,
        'debug' => [
            'room_id' => $room_id,
            'owner_id' => $owner_id,
            'count' => count($images)
        ]
    ]);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'error' => 'Exception caught',
        'message' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine()
    ]);
}
