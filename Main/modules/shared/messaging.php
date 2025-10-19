<?php
require_once __DIR__ . '/../../auth.php';
require_role('admin');
require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/../../partials/header.php';

try {
    // 🟢 Count distinct conversation threads (undirected per dorm)
    $stmt = $pdo->query("
        SELECT COUNT(DISTINCT CONCAT(
            LEAST(sender_id, receiver_id), '-', 
            GREATEST(sender_id, receiver_id), '-', 
            dorm_id
        )) AS total_threads
        FROM messages
    ");
    $open_conversations = (int) $stmt->fetchColumn();

    // 🟢 Count unread messages
    $stmt = $pdo->query("SELECT COUNT(*) FROM messages WHERE read_at IS NULL");
    $unanswered = (int) $stmt->fetchColumn();

    // 🟢 Fetch recent inquiries (latest 5 messages)
    $stmt = $pdo->prepare("
        SELECT 
            m.message_id,
            m.body,
            m.created_at,
            m.read_at,
            m.sender_id,
            u.name AS sender_name,
            d.dorm_id,
            d.name AS dorm_name
        FROM messages m
        LEFT JOIN users u ON u.user_id = m.sender_id
        LEFT JOIN dormitories d ON d.dorm_id = m.dorm_id
        ORDER BY m.created_at DESC
        LIMIT 5
    ");
    $stmt->execute();
    $recent = $stmt->fetchAll(PDO::FETCH_ASSOC);

} catch (Exception $e) {
    error_log('Messaging admin fetch error: ' . $e->getMessage());
    $open_conversations = 0;
    $unanswered = 0;
    $recent = [];
}
?>

<div class="page-header">
  <h1>Messaging & Inquiries</h1>
  <p>Monitor messages between students and dorm owners.</p>
</div>

<div class="stats-grid">
  <div class="stat-card">
    <h3><?= htmlspecialchars((string)$open_conversations) ?></h3>
    <p>Open Conversations</p>
  </div>
  <div class="stat-card">
    <h3><?= htmlspecialchars((string)$unanswered) ?></h3>
    <p>Unread Messages</p>
  </div>
</div>

<div class="section">
  <h2>Recent Inquiries</h2>

  <?php if (!empty($recent)): ?>
    <ul class="log-list">
      <?php foreach ($recent as $r): 
        $sender = htmlspecialchars($r['sender_name'] ?? 'Unknown');
        $dorm = htmlspecialchars($r['dorm_name'] ?? '—');
        $excerpt = htmlspecialchars(mb_strimwidth(strip_tags($r['body'] ?? ''), 0, 120, '…'));
        $time = htmlspecialchars(date("M d, Y H:i", strtotime($r['created_at'] ?? 'now')));
        $status = is_null($r['read_at']) 
            ? '<small class="badge warning">Unread</small>' 
            : '<small class="badge success">Read</small>';
      ?>
        <li>
          <strong><?= $sender ?></strong> (<?= $dorm ?>) — 
          <em><?= $excerpt ?></em> <?= $status ?>
          <div><small><?= $time ?></small></div>
        </li>
      <?php endforeach; ?>
    </ul>
  <?php else: ?>
    <p><em>No recent inquiries found.</em></p>
  <?php endif; ?>
</div>

<?php require_once __DIR__ . '/../../partials/footer.php'; ?>

<style>
.page-header h1 { margin-bottom: 0; }
.stats-grid {
  display: flex;
  gap: 1rem;
  margin-bottom: 1.5rem;
}
.stat-card {
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  padding: 20px;
  flex: 1;
  text-align: center;
}
.section h2 { margin-bottom: 10px; }
.log-list {
  list-style: none;
  padding: 0;
}
.log-list li {
  background: #fff;
  border-radius: 10px;
  box-shadow: 0 1px 4px rgba(0,0,0,0.08);
  margin-bottom: 10px;
  padding: 10px 15px;
}
.badge {
  border-radius: 6px;
  padding: 2px 6px;
  font-size: 0.8em;
  color: #fff;
}
.badge.warning { background: #ffc107; }
.badge.success { background: #28a745; }
</style>