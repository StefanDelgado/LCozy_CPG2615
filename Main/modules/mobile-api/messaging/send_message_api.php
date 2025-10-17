<?php
require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/cors.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['ok' => false, 'error' => 'Method not allowed']);
    exit;
}

try {
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);

    if (!isset($data['sender_email']) || !isset($data['receiver_id']) || 
        !isset($data['dorm_id']) || !isset($data['message'])) {
        http_response_code(400);
        echo json_encode(['ok' => false, 'error' => 'Missing required fields']);
        exit;
    }

    $sender_email = trim($data['sender_email']);
    $receiver_id = (int)$data['receiver_id'];
    $dorm_id = (int)$data['dorm_id'];
    $message = trim($data['message']);

    if (empty($message)) {
        http_response_code(400);
        echo json_encode(['ok' => false, 'error' => 'Message cannot be empty']);
        exit;
    }

    // Get sender ID
    $stmt = $pdo->prepare("SELECT user_id FROM users WHERE email = ?");
    $stmt->execute([$sender_email]);
    $sender = $stmt->fetch();

    if (!$sender) {
        http_response_code(404);
        echo json_encode(['ok' => false, 'error' => 'Sender not found']);
        exit;
    }

    $sender_id = $sender['user_id'];

    // Insert message
    $stmt = $pdo->prepare("
        INSERT INTO messages (sender_id, receiver_id, dorm_id, body, created_at)
        VALUES (?, ?, ?, ?, NOW())
    ");
    $stmt->execute([$sender_id, $receiver_id, $dorm_id, $message]);

    $message_id = $pdo->lastInsertId();

    // Get the created message
    $stmt = $pdo->prepare("
        SELECT 
            m.message_id,
            m.sender_id,
            m.receiver_id,
            m.body,
            m.created_at,
            u.name AS sender_name
        FROM messages m
        JOIN users u ON m.sender_id = u.user_id
        WHERE m.message_id = ?
    ");
    $stmt->execute([$message_id]);
    $msg = $stmt->fetch(PDO::FETCH_ASSOC);

    echo json_encode([
        'ok' => true,
        'message' => 'Message sent successfully',
        'data' => [
            'message_id' => (int)$msg['message_id'],
            'sender_id' => (int)$msg['sender_id'],
            'receiver_id' => (int)$msg['receiver_id'],
            'sender_name' => $msg['sender_name'],
            'body' => $msg['body'],
            'created_at' => $msg['created_at'],
            'is_mine' => true
        ]
    ]);

} catch (PDOException $e) {
    error_log('Send message API error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['ok' => false, 'error' => 'Database error']);
}