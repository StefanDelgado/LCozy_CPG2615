<?php
require_once __DIR__ . '/../../auth/auth.php';
require_role('owner');
require_once __DIR__ . '/../../config.php';

$page_title = "Messages";
include __DIR__ . '/../../partials/header.php';

$owner_id = $_SESSION['user']['user_id'];

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['send_message'])) {
    $receiver_id = intval($_POST['receiver_id']);
    $dorm_id = intval($_POST['dorm_id'] ?? 0) ?: null;
    $body = trim($_POST['body']);

    if ($receiver_id && $body) {
        $stmt = $pdo->prepare("
            INSERT INTO messages (sender_id, receiver_id, dorm_id, body, created_at)
            VALUES (?, ?, ?, ?, NOW())
        ");
        $stmt->execute([$owner_id, $receiver_id, $dorm_id, $body]);
    }
}

// Optimized query: Get distinct student-dorm combinations from bookings first
$threads_sql = "
    SELECT DISTINCT
        d.dorm_id, 
        d.name AS dorm_name,
        b.student_id, 
        u.name AS student_name,
        (SELECT COUNT(*) FROM messages 
         WHERE receiver_id = ? AND sender_id = b.student_id AND dorm_id = d.dorm_id AND read_at IS NULL) AS unread,
        (SELECT MAX(created_at) FROM messages 
         WHERE dorm_id = d.dorm_id AND ((sender_id = ? AND receiver_id = b.student_id) OR (sender_id = b.student_id AND receiver_id = ?))) AS last_message_at
    FROM bookings b
    JOIN rooms r ON b.room_id = r.room_id
    JOIN dormitories d ON r.dorm_id = d.dorm_id
    JOIN users u ON b.student_id = u.user_id
    WHERE d.owner_id = ?
      AND b.status IN ('approved', 'active')
    ORDER BY last_message_at DESC NULLS LAST
    LIMIT 50
";
$threads = $pdo->prepare($threads_sql);
$threads->execute([$owner_id, $owner_id, $owner_id, $owner_id]);
$threads = $threads->fetchAll(PDO::FETCH_ASSOC);

$active_dorm_id = intval($_GET['dorm_id'] ?? 0);
$active_dorm_id = intval($_GET['dorm_id'] ?? 0);
$active_student_id = intval($_GET['student_id'] ?? $_GET['recipient_id'] ?? 0);

// If recipient_id is provided without dorm_id, find the most recent dorm for this student
if ($active_student_id && !$active_dorm_id) {
    $find_dorm = $pdo->prepare("
        SELECT d.dorm_id 
        FROM bookings b
        JOIN rooms r ON b.room_id = r.room_id
        JOIN dormitories d ON r.dorm_id = d.dorm_id
        WHERE b.student_id = ? AND d.owner_id = ?
        ORDER BY b.created_at DESC
        LIMIT 1
    ");
    $find_dorm->execute([$active_student_id, $owner_id]);
    $result = $find_dorm->fetch(PDO::FETCH_ASSOC);
    if ($result) {
        $active_dorm_id = $result['dorm_id'];
    }
}
?>

<div class="page-header">
  <h1>Messages</h1>
  <p>Communicate with students who booked your dorms</p>
</div>

<div class="grid-2">
  <div class="card">
    <h3>Your Conversations</h3>
    <ul class="list">
      <?php foreach ($threads as $t): ?>
        <li>
          <a href="?dorm_id=<?= $t['dorm_id'] ?>&student_id=<?= $t['student_id'] ?>"
             data-dorm="<?= $t['dorm_id'] ?>"
             data-student="<?= $t['student_id'] ?>"
             class="thread-link">
            <?= htmlspecialchars($t['student_name']) ?> (Dorm: <?= htmlspecialchars($t['dorm_name']) ?>)
            <?php if ($t['unread'] > 0): ?>
              <span class="badge warning"><?= $t['unread'] ?> new</span>
            <?php endif; ?>
          </a>
        </li>
      <?php endforeach; ?>
      <?php if (!$threads): ?>
        <li><em>No conversations yet.</em></li>
      <?php endif; ?>
    </ul>
  </div>

  <div class="card">
    <?php if ($active_dorm_id && $active_student_id): ?>
      <h3>Conversation</h3>
      <div id="chat-box" class="chat-box" 
           style="max-height:300px;overflow-y:auto;padding:10px;border:1px solid #ddd;">
        <p><em>Loading messages...</em></p>
      </div>

      <form method="post" style="margin-top:10px;" id="message-form">
        <input type="hidden" name="receiver_id" value="<?= $active_student_id ?>">
        <input type="hidden" name="dorm_id" value="<?= $active_dorm_id ?>">
        <textarea name="body" required placeholder="Type your message..."></textarea>
        <button type="submit" name="send_message" class="btn-primary">Send</button>
      </form>
    <?php else: ?>
      <p><em>Select a conversation to view messages.</em></p>
    <?php endif; ?>
  </div>
</div>

<script>
let chatBox = document.getElementById('chat-box');
let dormId = <?= json_encode($active_dorm_id) ?>;
let studentId = <?= json_encode($active_student_id) ?>;

function fetchMessages() {
  if (!dormId || !studentId) return;
  fetch(`fetch_messages.php?dorm_id=${dormId}&other_id=${studentId}`)
    .then(res => res.json())
    .then(data => {
      if (data.messages) {
        chatBox.innerHTML = '';
        data.messages.forEach(msg => {
          let div = document.createElement('div');
          div.style.marginBottom = '10px';
          if (msg.sender_id == <?= $owner_id ?>) {
            div.style.textAlign = 'right';
          }
          div.innerHTML = `
            <strong>${msg.sender_name}:</strong>
            <p>${msg.body}</p>
            <small>${msg.created_at}</small>
          `;
          chatBox.appendChild(div);
        });
        chatBox.scrollTop = chatBox.scrollHeight;
      }
    });
}

// Poll every 5 seconds instead of 1 to reduce server load
setInterval(fetchMessages, 5000);
fetchMessages();
</script>

<?php include __DIR__ . '/../../partials/footer.php'; ?>
