<?php
require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/cors.php';

header('Content-Type: application/json');

if (!isset($_GET['user_email']) || !isset($_GET['dorm_id']) || !isset($_GET['other_user_id'])) {
    http_response_code(400);
    echo json_encode(['ok' => false, 'error' => 'Missing required parameters']);
    exit;
}

$user_email = trim($_GET['user_email']);
$dorm_id = (int)$_GET['dorm_id'];
$other_user_id = (int)$_GET['other_user_id'];

try {
    // Get user ID
    $stmt = $pdo->prepare("SELECT user_id FROM users WHERE email = ?");
    $stmt->execute([$user_email]);
    $user = $stmt->fetch();

    if (!$user) {
        http_response_code(404);
        echo json_encode(['ok' => false, 'error' => 'User not found']);
        exit;
    }

    $user_id = $user['user_id'];

    // Fetch messages
    $stmt = $pdo->prepare("
        SELECT 
            m.message_id,
            m.sender_id,
            m.receiver_id,
            m.body,
            m.created_at,
            m.read_at,
            u.name AS sender_name
        FROM messages m
        JOIN users u ON m.sender_id = u.user_id
        WHERE m.dorm_id = ?
        AND (
            (m.sender_id = ? AND m.receiver_id = ?)
            OR (m.sender_id = ? AND m.receiver_id = ?)
        )
        ORDER BY m.created_at ASC
    ");
    $stmt->execute([$dorm_id, $user_id, $other_user_id, $other_user_id, $user_id]);
    $messages = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Mark messages as read
    $markRead = $pdo->prepare("
        UPDATE messages
        SET read_at = NOW()
        WHERE dorm_id = ? 
        AND receiver_id = ? 
        AND sender_id = ? 
        AND read_at IS NULL
    ");
    $markRead->execute([$dorm_id, $user_id, $other_user_id]);

    // Format messages
    $formatted_messages = array_map(function($msg) use ($user_id) {
        return [
            'message_id' => (int)$msg['message_id'],
            'sender_id' => (int)$msg['sender_id'],
            'receiver_id' => (int)$msg['receiver_id'],
            'sender_name' => $msg['sender_name'],
            'body' => $msg['body'],
            'created_at' => $msg['created_at'],
            'read_at' => $msg['read_at'],
            'is_mine' => (int)$msg['sender_id'] === $user_id
        ];
    }, $messages);

    echo json_encode([
        'ok' => true,
        'messages' => $formatted_messages
    ]);

} catch (PDOException $e) {
    error_log('Messages API error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['ok' => false, 'error' => 'Database error']);
}