<?php
require_once __DIR__ . '/../auth.php';
require_role('student');
require_once __DIR__ . '/../config.php';

$page_title = "Announcements";
include __DIR__ . '/../partials/header.php';

$student_id = $_SESSION['user']['user_id'];

if (isset($_GET['read'])) {
    $announcement_id = (int)$_GET['read'];
    $stmt = $pdo->prepare("
        INSERT INTO announcement_reads (announcement_id, user_id, read_at)
        VALUES (?, ?, NOW())
        ON DUPLICATE KEY UPDATE read_at = NOW()
    ");
    $stmt->execute([$announcement_id, $student_id]);
}

$sql = "
    SELECT a.id, a.title, a.message, a.audience, a.send_option, a.created_at,
           ar.read_at
    FROM announcements a
    LEFT JOIN announcement_reads ar
      ON a.id = ar.announcement_id AND ar.user_id = ?
    WHERE a.audience = 'All Hosts'
       OR a.audience = 'Students'
    ORDER BY a.created_at DESC
";
$stmt = $pdo->prepare($sql);
$stmt->execute([$student_id]);
$announcements = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

<div class="page-header">
  <p>Stay up to date with the latest updates from administrators.</p>
</div>

<div class="announcements-list">
  <?php if ($announcements): ?>
    <?php foreach ($announcements as $a): ?>
      <article class="announcement-card <?= $a['read_at'] ? 'read' : 'unread' ?>">
        <div class="announcement-top">
          <div class="announcement-left">
            <h2 class="announcement-title"><?= htmlspecialchars($a['title']) ?></h2>
            <div class="announcement-meta-small">
              <span class="audience"><?= htmlspecialchars($a['audience']) ?></span>
              <span class="send-option"><?= htmlspecialchars($a['send_option']) ?></span>
            </div>
          </div>
          <div class="announcement-right">
            <time class="announcement-time"><?= htmlspecialchars(date("M d, Y H:i", strtotime($a['created_at']))) ?></time>
          </div>
        </div>

        <div class="announcement-body">
          <p><?= nl2br(htmlspecialchars($a['message'])) ?></p>
        </div>

        <div class="announcement-meta-row">
          <div class="announcement-actions">
            <?php if (!$a['read_at']): ?>
              <a class="btn-primary mark-read" href="?read=<?= $a['id'] ?>">Mark as Read</a>
            <?php else: ?>
              <span class="status-read">✓ Read</span>
            <?php endif; ?>
          </div>
        </div>
      </article>
    <?php endforeach; ?>
  <?php else: ?>
    <p><em>No announcements available at the moment.</em></p>
  <?php endif; ?>
</div>

<style>
.announcements-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}
.announcement-card {
  border: 1px solid #e9e6ef;
  border-radius: 10px;
  padding: 18px;
  background: #ffffff;
  box-shadow: 0 4px 12px rgba(20,12,60,0.03);
  overflow: hidden;
}
.announcement-card.unread {
  border-left: 6px solid #e63946;
  background: #fff7f7;
}
.announcement-card.read {
  border-left: 6px solid #2a9d8f;
  background: #fbfbfb;
}
.announcement-top {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 12px;
}
.announcement-left {
  flex: 1 1 auto;
}
.announcement-title {
  font-size: 1.15rem;
  margin: 0 0 6px 0;
  color: #111;
}
.announcement-meta-small {
  font-size: 0.85rem;
  color: #666;
  display: flex;
  gap: 10px;
}
.announcement-right {
  flex: 0 0 auto;
  text-align: right;
  color: #666;
  font-size: 0.85rem;
}
.announcement-body {
  margin-top: 12px;
  color: #222;
  line-height: 1.5;
}
.announcement-meta-row {
  margin-top: 14px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.announcement-actions {
  display: flex;
  gap: 8px;
  align-items: center;
}
.btn-primary.mark-read {
  display: inline-block;
  background: #6a5acd;
  color: #fff;
  padding: 10px 14px;
  border-radius: 8px;
  text-decoration: none;
  font-weight: 600;
  transition: background .15s ease;
}
.btn-primary.mark-read:hover { background: #5848c2; }
.status-read {
  color: #2a9d8f;
  font-weight: 700;
  font-size: 0.95rem;
}
@media (max-width: 720px) {
  .announcement-top { flex-direction: column; align-items: stretch; }
  .announcement-right { text-align: left; margin-top: 6px; }
  .announcement-meta-row { flex-direction: column; align-items: flex-start; gap: 8px; }
}
</style>

<?php include __DIR__ . '/../partials/footer.php'; ?>