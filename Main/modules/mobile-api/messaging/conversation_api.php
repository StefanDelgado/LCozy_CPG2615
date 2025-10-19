<?php
require_once __DIR__ . '/../../../config.php';
require_once __DIR__ . '/../shared/cors.php';

header('Content-Type: application/json');

if (!isset($_GET['user_email']) || !isset($_GET['user_role'])) {
    http_response_code(400);
    echo json_encode(['ok' => false, 'error' => 'User email and role required']);
    exit;
}

$user_email = trim($_GET['user_email']);
$user_role = $_GET['user_role'];

try {
    // Get user ID
    $stmt = $pdo->prepare("SELECT user_id FROM users WHERE email = ? AND role = ?");
    $stmt->execute([$user_email, $user_role]);
    $user = $stmt->fetch();

    if (!$user) {
        http_response_code(404);
        echo json_encode(['ok' => false, 'error' => 'User not found']);
        exit;
    }

    $user_id = $user['user_id'];

    if ($user_role === 'student') {
        // Get conversations for student (with owners)
        $stmt = $pdo->prepare("
            SELECT 
                d.dorm_id,
                d.name AS dorm_name,
                u.user_id AS other_user_id,
                u.name AS other_user_name,
                u.email AS other_user_email,
                MAX(m.created_at) AS last_message_at,
                (SELECT body FROM messages 
                 WHERE dorm_id = d.dorm_id 
                 AND ((sender_id = ? AND receiver_id = u.user_id) 
                      OR (sender_id = u.user_id AND receiver_id = ?))
                 ORDER BY created_at DESC LIMIT 1) AS last_message,
                (SELECT COUNT(*) FROM messages 
                 WHERE dorm_id = d.dorm_id 
                 AND sender_id = u.user_id 
                 AND receiver_id = ? 
                 AND read_at IS NULL) AS unread_count
            FROM messages m
            JOIN dormitories d ON m.dorm_id = d.dorm_id
            JOIN users u ON d.owner_id = u.user_id
            WHERE (m.sender_id = ? OR m.receiver_id = ?)
            GROUP BY d.dorm_id, u.user_id
            ORDER BY last_message_at DESC
        ");
        $stmt->execute([$user_id, $user_id, $user_id, $user_id, $user_id]);
    } else if ($user_role === 'owner') {
        // Get conversations for owner (with students)
        $stmt = $pdo->prepare("
            SELECT 
                d.dorm_id,
                d.name AS dorm_name,
                u.user_id AS other_user_id,
                u.name AS other_user_name,
                u.email AS other_user_email,
                MAX(m.created_at) AS last_message_at,
                (SELECT body FROM messages 
                 WHERE dorm_id = d.dorm_id 
                 AND ((sender_id = ? AND receiver_id = u.user_id) 
                      OR (sender_id = u.user_id AND receiver_id = ?))
                 ORDER BY created_at DESC LIMIT 1) AS last_message,
                (SELECT COUNT(*) FROM messages 
                 WHERE dorm_id = d.dorm_id 
                 AND sender_id = u.user_id 
                 AND receiver_id = ? 
                 AND read_at IS NULL) AS unread_count
            FROM messages m
            JOIN dormitories d ON m.dorm_id = d.dorm_id
            JOIN users u ON m.sender_id = u.user_id OR m.receiver_id = u.user_id
            WHERE d.owner_id = ?
            AND u.user_id != ?
            AND u.role = 'student'
            GROUP BY d.dorm_id, u.user_id
            ORDER BY last_message_at DESC
        ");
        $stmt->execute([$user_id, $user_id, $user_id, $user_id, $user_id]);
    } else {
        http_response_code(400);
        echo json_encode(['ok' => false, 'error' => 'Invalid role']);
        exit;
    }

    $conversations = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Format the response
    $formatted_conversations = array_map(function($conv) {
        return [
            'dorm_id' => (int)$conv['dorm_id'],
            'dorm_name' => $conv['dorm_name'],
            'other_user_id' => (int)$conv['other_user_id'],
            'other_user_name' => $conv['other_user_name'],
            'other_user_email' => $conv['other_user_email'],
            'last_message' => $conv['last_message'] ?: 'No messages yet',
            'last_message_at' => $conv['last_message_at'],
            'unread_count' => (int)$conv['unread_count']
        ];
    }, $conversations);

    echo json_encode([
        'ok' => true,
        'conversations' => $formatted_conversations
    ]);

} catch (PDOException $e) {
    error_log('Conversations API error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['ok' => false, 'error' => 'Database error']);
}