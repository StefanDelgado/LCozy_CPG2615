<?php 
require_once __DIR__ . '/../../partials/header.php'; 
require_role('admin');
require_once __DIR__ . '/../../config.php';

$page_title = "Broadcast Announcement System";

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['create'])) {
    $title = trim($_POST['title'] ?? '');
    $message = trim($_POST['message'] ?? '');
    $audience = $_POST['audience'] ?? 'All Hosts';
    $sendOption = $_POST['sendOption'] ?? 'Send Now';

    if ($title && $message) {
        $stmt = $pdo->prepare("INSERT INTO announcements (title, message, audience, send_option) VALUES (?, ?, ?, ?)");
        $stmt->execute([$title, $message, $audience, $sendOption]);
        $success = "Announcement created successfully!";
    } else {
        $error = "Both title and message are required.";
    }
}

if (isset($_GET['delete'])) {
    $id = (int) $_GET['delete'];
    $stmt = $pdo->prepare("DELETE FROM announcements WHERE id = ?");
    $stmt->execute([$id]);
    $success = "Announcement deleted successfully!";
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['update'])) {
    $id = (int) $_POST['id'];
    $title = trim($_POST['title']);
    $message = trim($_POST['message']);
    $audience = $_POST['audience'];
    $sendOption = $_POST['sendOption'];

    $stmt = $pdo->prepare("UPDATE announcements SET title=?, message=?, audience=?, send_option=? WHERE id=?");
    $stmt->execute([$title, $message, $audience, $sendOption, $id]);
    $success = "Announcement updated successfully!";
}

$announcements = $pdo->query("SELECT * FROM announcements ORDER BY created_at DESC")->fetchAll(PDO::FETCH_ASSOC);
?>

<div class="page-header">
  <h1>Broadcast Announcement System</h1>
  <p>Send announcements to hosts and manage communications</p>
</div>

<?php if (!empty($success)): ?>
  <div class="alert success"><?=htmlspecialchars($success)?></div>
<?php endif; ?>
<?php if (!empty($error)): ?>
  <div class="alert error"><?=htmlspecialchars($error)?></div>
<?php endif; ?>

<div class="form-area">
  <h2>Create Announcement</h2>
  <form method="POST" action="">
    <input type="hidden" name="create" value="1">

    <label for="title">Title</label>
    <input type="text" id="title" name="title" placeholder="Enter announcement title..." required>

    <label for="message">Message</label>
    <textarea id="message" name="message" rows="4" placeholder="Write your announcement message..." required></textarea>

    <label for="audience">Target Audience</label>
    <select id="audience" name="audience">
      <option value="All Hosts">All Hosts</option>
      <option value="Verified Owners">Verified Owners</option>
      <option value="Pending Owners">Pending Owners</option>
    </select>

    <label for="sendOption">Send Options</label>
    <select id="sendOption" name="sendOption">
      <option value="Send Now">Send Now</option>
      <option value="Schedule">Schedule</option>
    </select>

    <div class="actions">
      <button type="submit" class="btn-primary">Send</button>
      <button type="reset" class="btn-secondary">Clear</button>
    </div>
  </form>
</div>

<div class="section">
  <h2>Announcement History</h2>
  <?php if ($announcements): ?>
    <ul class="history-list">
      <?php foreach ($announcements as $a): ?>
        <li>
          <strong><?=htmlspecialchars($a['title'])?></strong> 
          <small>(<?=htmlspecialchars($a['send_option'])?> • <?=htmlspecialchars($a['created_at'])?>)</small>
          <p><?=nl2br(htmlspecialchars($a['message']))?></p>
          <div class="actions">
            <button onclick="toggleEditForm(<?=$a['id']?>)" class="btn-secondary">Edit</button>
            <a href="?delete=<?=$a['id']?>" class="btn-danger" onclick="return confirm('Delete this announcement?')">Delete</a>
          </div>

          <form method="POST" action="" id="edit-form-<?=$a['id']?>" style="display:none; margin-top:10px;">
            <input type="hidden" name="update" value="1">
            <input type="hidden" name="id" value="<?=$a['id']?>">

            <label>Title</label>
            <input type="text" name="title" value="<?=htmlspecialchars($a['title'])?>" required>

            <label>Message</label>
            <textarea name="message" rows="3" required><?=htmlspecialchars($a['message'])?></textarea>

            <label>Audience</label>
            <select name="audience">
              <option value="All Hosts" <?= $a['audience']==='All Hosts'?'selected':'' ?>>All Hosts</option>
              <option value="Verified Owners" <?= $a['audience']==='Verified Owners'?'selected':'' ?>>Verified Owners</option>
              <option value="Pending Owners" <?= $a['audience']==='Pending Owners'?'selected':'' ?>>Pending Owners</option>
            </select>

            <label>Send Option</label>
            <select name="sendOption">
              <option value="Send Now" <?= $a['send_option']==='Send Now'?'selected':'' ?>>Send Now</option>
              <option value="Schedule" <?= $a['send_option']==='Schedule'?'selected':'' ?>>Schedule</option>
            </select>

            <button type="submit" class="btn-primary">Update</button>
            <button type="button" class="btn-secondary" onclick="toggleEditForm(<?=$a['id']?>)">Cancel</button>
          </form>
        </li>
      <?php endforeach; ?>
    </ul>
  <?php else: ?>
    <p><em>No announcements created yet.</em></p>
  <?php endif; ?>
</div>

<script>
function toggleEditForm(id) {
  const form = document.getElementById('edit-form-' + id);
  form.style.display = form.style.display === 'none' ? 'block' : 'none';
}
</script>

<?php require_once __DIR__ . '/../../partials/footer.php'; ?>
