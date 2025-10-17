<?php
require_once __DIR__ . '/../auth/auth.php';
login_required();
require_once __DIR__ . '/../config.php';

$user_id = $_SESSION['user']['user_id'] ?? null;
$dorm_id = intval($_GET['dorm_id'] ?? 0);
$other_id = intval($_GET['other_id'] ?? 0);

if (!$user_id || !$dorm_id || !$other_id) {
    echo json_encode(['messages' => []]);
    exit;
}

$stmt = $pdo->prepare("
    SELECT m.message_id, m.sender_id, m.receiver_id, m.body, m.created_at, u.name AS sender_name
    FROM messages m
    JOIN users u ON m.sender_id = u.user_id
    WHERE m.dorm_id = :dorm
      AND (
          (m.sender_id = :user AND m.receiver_id = :other)
          OR (m.sender_id = :other AND m.receiver_id = :user)
      )
    ORDER BY m.created_at ASC
");
$stmt->execute([
    ':dorm' => $dorm_id,
    ':user' => $user_id,
    ':other' => $other_id
]);
$messages = $stmt->fetchAll(PDO::FETCH_ASSOC);

$markRead = $pdo->prepare("
    UPDATE messages
    SET read_at = NOW()
    WHERE dorm_id = :dorm AND receiver_id = :user AND sender_id = :other AND read_at IS NULL
");
$markRead->execute([
    ':dorm' => $dorm_id,
    ':user' => $user_id,
    ':other' => $other_id
]);

header('Content-Type: application/json');
echo json_encode(['messages' => $messages]);
