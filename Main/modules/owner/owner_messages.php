<?php
require_once __DIR__ . '/../../auth/auth.php';
require_role('owner');
require_once __DIR__ . '/../../config.php';

// Enable error reporting for debugging
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

$page_title = "Messages";
$owner_id = $_SESSION['user']['user_id'];

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['send_message'])) {
    $receiver_id = intval($_POST['receiver_id']);
    $dorm_id = intval($_POST['dorm_id'] ?? 0) ?: null;
    $body = trim($_POST['body']);

    if ($receiver_id && $body) {
        try {
            $stmt = $pdo->prepare("
                INSERT INTO messages (sender_id, receiver_id, dorm_id, body, created_at)
                VALUES (?, ?, ?, ?, NOW())
            ");
            $stmt->execute([$owner_id, $receiver_id, $dorm_id, $body]);
            header("Location: " . $_SERVER['PHP_SELF'] . "?" . http_build_query(['dorm_id' => $dorm_id, 'student_id' => $receiver_id]));
            exit;
        } catch (Exception $e) {
            error_log("Message send error: " . $e->getMessage());
        }
    }
}

// Optimized query: Get distinct student-dorm combinations from bookings first
try {
    $threads_sql = "
        SELECT DISTINCT
            d.dorm_id, 
            d.name AS dorm_name,
            b.student_id, 
            u.name AS student_name,
            u.email AS student_email,
            (SELECT COUNT(*) FROM messages 
             WHERE receiver_id = ? AND sender_id = b.student_id AND dorm_id = d.dorm_id AND read_at IS NULL) AS unread,
            (SELECT MAX(created_at) FROM messages 
             WHERE dorm_id = d.dorm_id AND ((sender_id = ? AND receiver_id = b.student_id) OR (sender_id = b.student_id AND receiver_id = ?))) AS last_message_at
        FROM bookings b
        JOIN rooms r ON b.room_id = r.room_id
        JOIN dormitories d ON r.dorm_id = d.dorm_id
        JOIN users u ON b.student_id = u.user_id
        WHERE d.owner_id = ?
        ORDER BY last_message_at DESC, b.created_at DESC
        LIMIT 50
    ";
    $threads = $pdo->prepare($threads_sql);
    $threads->execute([$owner_id, $owner_id, $owner_id, $owner_id]);
    $threads = $threads->fetchAll(PDO::FETCH_ASSOC);
} catch (Exception $e) {
    error_log("Threads error: " . $e->getMessage());
    $threads = [];
}

$active_dorm_id = intval($_GET['dorm_id'] ?? 0);
$active_student_id = intval($_GET['student_id'] ?? $_GET['recipient_id'] ?? 0);

// If student_id is provided but not in the threads list, add them manually
if ($active_student_id && $active_dorm_id) {
    $found = false;
    foreach ($threads as $t) {
        if ($t['student_id'] == $active_student_id && $t['dorm_id'] == $active_dorm_id) {
            $found = true;
            break;
        }
    }
    
    // If not found in existing threads, fetch this student's info and add to list
    if (!$found) {
        try {
            $student_sql = "
                SELECT 
                    d.dorm_id,
                    d.name AS dorm_name,
                    u.user_id AS student_id,
                    u.name AS student_name,
                    u.email AS student_email,
                    0 AS unread,
                    NULL AS last_message_at
                FROM users u
                JOIN dormitories d ON d.dorm_id = ?
                WHERE u.user_id = ?
            ";
            $student_stmt = $pdo->prepare($student_sql);
            $student_stmt->execute([$active_dorm_id, $active_student_id]);
            $student_data = $student_stmt->fetch(PDO::FETCH_ASSOC);
            
            if ($student_data) {
                // Add to beginning of threads array
                array_unshift($threads, $student_data);
            }
        } catch (Exception $e) {
            error_log("Student fetch error: " . $e->getMessage());
        }
    }
}

// If recipient_id is provided without dorm_id, find the most recent dorm for this student
if ($active_student_id && !$active_dorm_id) {
    try {
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
    } catch (Exception $e) {
        error_log("Find dorm error: " . $e->getMessage());
    }
}

// Include header AFTER all data processing
include __DIR__ . '/../../partials/header.php';
?>

<div class="page-header">
  <h1>Messages</h1>
  <p>Communicate with students who booked your dorms</p>
</div>

<?php 
// Debug: Show counts
echo "<!-- Debug: Found " . count($threads) . " conversations -->";
echo "<!-- Active: dorm_id=$active_dorm_id, student_id=$active_student_id -->";
?>

<div class="messages-container">
  <!-- Conversations Sidebar -->
  <div class="conversations-sidebar">
    <div class="sidebar-header">
      <h3>💬 Your Conversations</h3>
    </div>
    <div class="conversations-list">
      <?php if ($threads): ?>
        <?php foreach ($threads as $t): 
          $is_active = ($t['dorm_id'] == $active_dorm_id && $t['student_id'] == $active_student_id);
        ?>
          <a href="?dorm_id=<?= $t['dorm_id'] ?>&student_id=<?= $t['student_id'] ?>"
             class="conversation-item <?= $is_active ? 'active' : '' ?>">
            <div class="conversation-avatar">
              <?= strtoupper(substr($t['student_name'], 0, 2)) ?>
            </div>
            <div class="conversation-details">
              <div class="conversation-name"><?= htmlspecialchars($t['student_name']) ?></div>
              <div class="conversation-dorm">🏠 <?= htmlspecialchars($t['dorm_name']) ?></div>
            </div>
            <?php if ($t['unread'] > 0): ?>
              <div class="unread-badge"><?= $t['unread'] ?></div>
            <?php endif; ?>
          </a>
        <?php endforeach; ?>
      <?php else: ?>
        <div class="empty-conversations">
          <div class="empty-icon">💬</div>
          <p>No conversations yet</p>
          <small>Contact students from Booking Management</small>
        </div>
      <?php endif; ?>
    </div>
  </div>

  <!-- Chat Area -->
  <div class="chat-area">
    <?php if ($active_dorm_id && $active_student_id): ?>
      <?php 
        // Get active conversation details
        $active_student_name = 'Student';
        $active_dorm_name = 'Dorm';
        foreach ($threads as $t) {
          if ($t['student_id'] == $active_student_id && $t['dorm_id'] == $active_dorm_id) {
            $active_student_name = $t['student_name'];
            $active_dorm_name = $t['dorm_name'];
            break;
          }
        }
      ?>
      <div class="chat-header">
        <div class="chat-header-info">
          <div class="chat-avatar">
            <?= strtoupper(substr($active_student_name, 0, 2)) ?>
          </div>
          <div>
            <h3><?= htmlspecialchars($active_student_name) ?></h3>
            <p>🏠 <?= htmlspecialchars($active_dorm_name) ?></p>
          </div>
        </div>
      </div>
      
      <div id="chat-box" class="chat-messages">
        <p class="loading-messages">Loading messages...</p>
      </div>

      <form method="post" id="message-form" class="chat-input-form">
        <input type="hidden" name="receiver_id" value="<?= $active_student_id ?>">
        <input type="hidden" name="dorm_id" value="<?= $active_dorm_id ?>">
        <textarea name="body" required placeholder="Type your message..." rows="3"></textarea>
        <button type="submit" name="send_message" class="btn-send">
          <span>📤</span> Send Message
        </button>
      </form>
    <?php else: ?>
      <div class="chat-empty-state">
        <div class="empty-chat-icon">💬</div>
        <h3>Select a Conversation</h3>
        <p>Choose a student from the list to start messaging</p>
      </div>
    <?php endif; ?>
  </div>
</div>

<script>
let chatBox = document.getElementById('chat-box');
let dormId = <?= json_encode($active_dorm_id) ?>;
let studentId = <?= json_encode($active_student_id) ?>;

console.log('Chat initialized:', { dormId, studentId });

function fetchMessages() {
  if (!dormId || !studentId) {
    console.log('Missing dormId or studentId');
    return;
  }
  
  const url = `fetch_messages.php?dorm_id=${dormId}&other_id=${studentId}`;
  console.log('Fetching messages from:', url);
  
  fetch(url)
    .then(res => {
      console.log('Response received:', res.status);
      return res.json();
    })
    .then(data => {
      console.log('Messages data:', data);
      if (data.messages && Array.isArray(data.messages)) {
        if (data.messages.length === 0) {
          chatBox.innerHTML = '<p style="text-align:center;color:#6c757d;padding:20px;"><em>No messages yet. Start the conversation!</em></p>';
        } else {
          chatBox.innerHTML = '';
          data.messages.forEach(msg => {
            let div = document.createElement('div');
            div.className = msg.sender_id == <?= $owner_id ?> ? 'message-bubble owner' : 'message-bubble student';
            
            div.innerHTML = `
              <div class="message-sender">${msg.sender_name}</div>
              <div class="message-body">${msg.body}</div>
              <div class="message-time">${msg.created_at}</div>
            `;
            
            chatBox.appendChild(div);
          });
        }
        chatBox.scrollTop = chatBox.scrollHeight;
      } else {
        console.error('Invalid data format:', data);
        chatBox.innerHTML = '<p style="text-align:center;color:#dc3545;padding:20px;">Error loading messages. Please refresh the page.</p>';
      }
    })
    .catch(error => {
      console.error('Fetch error:', error);
      chatBox.innerHTML = '<p style="text-align:center;color:#dc3545;padding:20px;">Error loading messages. Please check your connection.</p>';
    });
}

// Poll every 5 seconds instead of 1 to reduce server load
if (dormId && studentId) {
  setInterval(fetchMessages, 5000);
  fetchMessages();
} else {
  console.log('No active conversation selected');
}
</script>

<style>
/* ===== Page Header ===== */
.page-header {
  margin-bottom: 30px;
}

.page-header h1 {
  margin: 0 0 8px 0;
  font-size: 2rem;
  color: #2c3e50;
}

.page-header p {
  margin: 0;
  color: #6c757d;
  font-size: 1rem;
}

/* ===== Messages Container ===== */
.messages-container {
  display: grid;
  grid-template-columns: 380px 1fr;
  gap: 0;
  height: calc(100vh - 200px);
  min-height: 600px;
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 12px rgba(0,0,0,0.08);
}

/* ===== Conversations Sidebar ===== */
.conversations-sidebar {
  background: #f8f9fa;
  border-right: 1px solid #e9ecef;
  display: flex;
  flex-direction: column;
  height: 100%;
}

.sidebar-header {
  padding: 20px;
  background: white;
  border-bottom: 2px solid #6f42c1;
}

.sidebar-header h3 {
  margin: 0;
  font-size: 1.2rem;
  color: #2c3e50;
  display: flex;
  align-items: center;
  gap: 8px;
}

.conversations-list {
  flex: 1;
  overflow-y: auto;
  padding: 10px 0;
}

/* ===== Conversation Item ===== */
.conversation-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 15px 20px;
  text-decoration: none;
  color: inherit;
  transition: all 0.2s;
  border-left: 3px solid transparent;
  position: relative;
}

.conversation-item:hover {
  background: white;
  border-left-color: #6f42c1;
}

.conversation-item.active {
  background: white;
  border-left-color: #6f42c1;
  box-shadow: inset 0 0 10px rgba(111, 66, 193, 0.1);
}

.conversation-avatar {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  background: linear-gradient(135deg, #6f42c1, #a06cd5);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  font-size: 1.1rem;
  flex-shrink: 0;
  box-shadow: 0 2px 8px rgba(111, 66, 193, 0.3);
}

.conversation-details {
  flex: 1;
  min-width: 0;
}

.conversation-name {
  font-weight: 600;
  color: #2c3e50;
  font-size: 1rem;
  margin-bottom: 4px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.conversation-dorm {
  font-size: 0.85rem;
  color: #6c757d;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.unread-badge {
  background: #6f42c1;
  color: white;
  border-radius: 12px;
  padding: 4px 10px;
  font-size: 0.75rem;
  font-weight: 600;
  min-width: 24px;
  text-align: center;
}

/* ===== Empty Conversations ===== */
.empty-conversations {
  text-align: center;
  padding: 60px 20px;
  color: #6c757d;
}

.empty-icon {
  font-size: 3rem;
  margin-bottom: 15px;
  opacity: 0.5;
}

.empty-conversations p {
  margin: 10px 0 5px 0;
  font-weight: 600;
  color: #495057;
}

.empty-conversations small {
  color: #6c757d;
  font-size: 0.85rem;
}

/* ===== Chat Area ===== */
.chat-area {
  display: flex;
  flex-direction: column;
  height: 100%;
  background: white;
}

.chat-header {
  padding: 20px;
  background: white;
  border-bottom: 2px solid #e9ecef;
  flex-shrink: 0;
}

.chat-header-info {
  display: flex;
  align-items: center;
  gap: 15px;
}

.chat-avatar {
  width: 55px;
  height: 55px;
  border-radius: 50%;
  background: linear-gradient(135deg, #6f42c1, #a06cd5);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  font-size: 1.2rem;
  box-shadow: 0 3px 10px rgba(111, 66, 193, 0.3);
}

.chat-header h3 {
  margin: 0 0 5px 0;
  font-size: 1.3rem;
  color: #2c3e50;
}

.chat-header p {
  margin: 0;
  font-size: 0.9rem;
  color: #6c757d;
}

/* ===== Chat Messages Area ===== */
.chat-messages {
  flex: 1;
  overflow-y: auto;
  padding: 20px;
  background: linear-gradient(to bottom, #f8f9fa 0%, #ffffff 100%);
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.loading-messages {
  text-align: center;
  color: #6c757d;
  padding: 40px 20px;
  font-style: italic;
}

/* ===== Message Bubbles ===== */
.message-bubble {
  max-width: 70%;
  padding: 12px 16px;
  border-radius: 18px;
  margin-bottom: 8px;
  box-shadow: 0 1px 2px rgba(0,0,0,0.1);
  animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

.message-bubble.owner {
  background: linear-gradient(135deg, #6f42c1, #8b5cf6);
  color: white;
  align-self: flex-end;
  border-bottom-right-radius: 4px;
}

.message-bubble.student {
  background: white;
  color: #2c3e50;
  align-self: flex-start;
  border-bottom-left-radius: 4px;
  border: 1px solid #e9ecef;
}

.message-sender {
  font-weight: 600;
  font-size: 0.85rem;
  margin-bottom: 6px;
  opacity: 0.9;
}

.message-bubble.owner .message-sender {
  color: rgba(255,255,255,0.9);
}

.message-bubble.student .message-sender {
  color: #6f42c1;
}

.message-body {
  margin: 0;
  line-height: 1.5;
  word-wrap: break-word;
}

.message-time {
  font-size: 0.7rem;
  margin-top: 6px;
  opacity: 0.7;
  text-align: right;
}

/* ===== Chat Input Form ===== */
.chat-input-form {
  padding: 20px;
  background: white;
  border-top: 2px solid #e9ecef;
  flex-shrink: 0;
}

.chat-input-form textarea {
  width: 100%;
  padding: 15px;
  border: 2px solid #e9ecef;
  border-radius: 12px;
  font-size: 0.95rem;
  font-family: inherit;
  resize: none;
  transition: all 0.2s;
  margin-bottom: 12px;
}

.chat-input-form textarea:focus {
  outline: none;
  border-color: #6f42c1;
  box-shadow: 0 0 0 3px rgba(111, 66, 193, 0.1);
}

.btn-send {
  background: linear-gradient(135deg, #6f42c1, #8b5cf6);
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 10px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  gap: 8px;
  width: 100%;
  justify-content: center;
}

.btn-send:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(111, 66, 193, 0.4);
}

.btn-send:active {
  transform: translateY(0);
}

/* ===== Chat Empty State ===== */
.chat-empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  color: #6c757d;
  text-align: center;
  padding: 40px;
}

.empty-chat-icon {
  font-size: 5rem;
  margin-bottom: 20px;
  opacity: 0.3;
}

.chat-empty-state h3 {
  margin: 0 0 10px 0;
  color: #2c3e50;
  font-size: 1.5rem;
}

.chat-empty-state p {
  margin: 0;
  font-size: 1rem;
}

/* ===== Scrollbar Styling ===== */
.conversations-list::-webkit-scrollbar,
.chat-messages::-webkit-scrollbar {
  width: 8px;
}

.conversations-list::-webkit-scrollbar-track,
.chat-messages::-webkit-scrollbar-track {
  background: #f1f1f1;
}

.conversations-list::-webkit-scrollbar-thumb,
.chat-messages::-webkit-scrollbar-thumb {
  background: #6f42c1;
  border-radius: 4px;
}

.conversations-list::-webkit-scrollbar-thumb:hover,
.chat-messages::-webkit-scrollbar-thumb:hover {
  background: #5a32a3;
}

/* ===== Responsive Design ===== */
@media (max-width: 968px) {
  .messages-container {
    grid-template-columns: 300px 1fr;
  }
}

@media (max-width: 768px) {
  .messages-container {
    grid-template-columns: 1fr;
  }
  
  .conversations-sidebar {
    display: none;
  }
  
  .chat-area {
    display: flex;
  }
  
  .message-bubble {
    max-width: 85%;
  }
}
</style>

<?php include __DIR__ . '/../../partials/footer.php'; ?>
