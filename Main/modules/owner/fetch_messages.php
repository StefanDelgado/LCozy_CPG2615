<?php
require_once __DIR__ . '/../../auth/auth.php';
require_once __DIR__ . '/../../config.php';

header('Content-Type: application/json');

$user_id = $_SESSION['user']['user_id'];
$dorm_id = intval($_GET['dorm_id'] ?? 0);
$other_id = intval($_GET['other_id'] ?? 0);

if (!$dorm_id || !$other_id) {
    echo json_encode(['messages' => []]);
    exit;
}

// Fetch messages for this conversation
$stmt = $pdo->prepare("
    SELECT 
        m.message_id,
        m.sender_id,
        m.body,
        m.created_at,
        u.name AS sender_name
    FROM messages m
    JOIN users u ON m.sender_id = u.user_id
    WHERE m.dorm_id = ?
      AND ((m.sender_id = ? AND m.receiver_id = ?) 
           OR (m.sender_id = ? AND m.receiver_id = ?))
    ORDER BY m.created_at ASC
    LIMIT 100
");
$stmt->execute([$dorm_id, $user_id, $other_id, $other_id, $user_id]);
$messages = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Mark messages as read
$pdo->prepare("
    UPDATE messages 
    SET read_at = NOW() 
    WHERE receiver_id = ? 
      AND sender_id = ? 
      AND dorm_id = ? 
      AND read_at IS NULL
")->execute([$user_id, $other_id, $dorm_id]);

echo json_encode(['messages' => $messages]);
