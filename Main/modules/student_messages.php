<?php
require_once __DIR__ . '/../auth.php';
require_role('student');
require_once __DIR__ . '/../config.php';

$page_title = "Messages";
include __DIR__ . '/../partials/header.php';

$student_id = $_SESSION['user']['user_id'];

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['send_message'])) {
    $receiver_id = intval($_POST['receiver_id']);
    $dorm_id = intval($_POST['dorm_id'] ?? 0) ?: null;
    $body = trim($_POST['body']);

    if ($receiver_id && $body) {
        $stmt = $pdo->prepare("
            INSERT INTO messages (sender_id, receiver_id, dorm_id, body, created_at)
            VALUES (?, ?, ?, ?, NOW())
        ");
        $stmt->execute([$student_id, $receiver_id, $dorm_id, $body]);
    }
}

$threads_sql = "
    SELECT 
        d.dorm_id, d.name AS dorm_name,
        u.user_id AS owner_id, u.name AS owner_name,
        MAX(m.created_at) AS last_message_at,
        SUM(CASE WHEN m.receiver_id = ? AND m.read_at IS NULL THEN 1 ELSE 0 END) AS unread
    FROM dormitories d
    JOIN users u ON d.owner_id = u.user_id
    LEFT JOIN rooms r ON r.dorm_id = d.dorm_id
    LEFT JOIN bookings b ON b.room_id = r.room_id AND b.student_id = ?
    LEFT JOIN messages m 
        ON ((m.sender_id = ? AND m.receiver_id = u.user_id) OR (m.sender_id = u.user_id AND m.receiver_id = ?))
        AND m.dorm_id = d.dorm_id
    WHERE b.student_id IS NOT NULL
    GROUP BY d.dorm_id, u.user_id
    ORDER BY last_message_at DESC
";
$threads = $pdo->prepare($threads_sql);
$threads->execute([$student_id, $student_id, $student_id, $student_id]);
$threads = $threads->fetchAll(PDO::FETCH_ASSOC);

$active_dorm_id = intval($_GET['dorm_id'] ?? 0);
$owner_id = null;

if ($active_dorm_id) {
    $stmt = $pdo->prepare("SELECT owner_id FROM dormitories WHERE dorm_id = ?");
    $stmt->execute([$active_dorm_id]);
    $owner_id = $stmt->fetchColumn();
}
?>

<div class="page-header">
  <p>Communicate with dorm owners about your bookings</p>
</div>

<div class="grid-2">
  <div class="card">
    <h3>Your Conversations</h3>
    <ul class="list">
      <?php foreach ($threads as $t): ?>
        <li>
          <a href="?dorm_id=<?= $t['dorm_id'] ?>" 
             data-dorm="<?= $t['dorm_id'] ?>" 
             data-owner="<?= $t['owner_id'] ?>" 
             class="thread-link">
            <?= htmlspecialchars($t['dorm_name']) ?> 
            (Owner: <?= htmlspecialchars($t['owner_name']) ?>)
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
    <?php if ($active_dorm_id && $owner_id): ?>
      <h3>Conversation</h3>
      <div id="chat-box" class="chat-box" 
           style="max-height:300px;overflow-y:auto;padding:10px;border:1px solid #ddd;">
        <p><em>Loading messages...</em></p>
      </div>

      <form method="post" style="margin-top:10px;" id="message-form">
        <input type="hidden" name="receiver_id" value="<?= $owner_id ?>">
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
let ownerId = <?= json_encode($owner_id) ?>;

function fetchMessages() {
  if (!dormId || !ownerId) return;
  fetch(`/CAPSTONE/modules/fetch_messages.php?dorm_id=${dormId}&other_id=${ownerId}`)
    .then(res => res.json())
    .then(data => {
      if (data.messages) {
        chatBox.innerHTML = '';
        data.messages.forEach(msg => {
          let div = document.createElement('div');
          div.style.marginBottom = '10px';
          if (msg.sender_id == <?= $student_id ?>) {
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

setInterval(fetchMessages, 3000);
fetchMessages();
</script>

<?php include __DIR__ . '/../partials/footer.php'; ?>