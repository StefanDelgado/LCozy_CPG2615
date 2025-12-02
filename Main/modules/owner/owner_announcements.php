<?php
require_once __DIR__ . '/../../auth/auth.php';
require_role(['owner', 'superadmin']);
require_once __DIR__ . '/../../config.php';

$page_title = "Dorm Announcement System";
include __DIR__ . '/../../partials/header.php';

$owner_id = $_SESSION['user']['user_id'];

// Fetch the owner’s dorms
$stmt = $pdo->prepare("SELECT dorm_id, name FROM dormitories WHERE owner_id = ?");
$stmt->execute([$owner_id]);
$dorms = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Handle create announcement
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['create'])) {
    $title = trim($_POST['title']);
    $message = trim($_POST['message']);
    $dorm_id = (int)$_POST['dorm_id'];

    if ($title && $message && $dorm_id) {
        $stmt = $pdo->prepare("
            INSERT INTO owner_announcements (owner_id, dorm_id, title, message)
            VALUES (?, ?, ?, ?)
        ");
        $stmt->execute([$owner_id, $dorm_id, $title, $message]);

        $success = "Announcement sent successfully!";
    } else {
        $error = "All fields are required.";
    }
}

// Handle delete
if (isset($_GET['delete'])) {
    $id = (int)$_GET['delete'];
    $stmt = $pdo->prepare("DELETE FROM owner_announcements WHERE id = ? AND owner_id = ?");
    $stmt->execute([$id, $owner_id]);
    $success = "Announcement deleted!";
}

// Get announcement history
$stmt = $pdo->prepare("
    SELECT a.*, d.name AS dorm_name 
    FROM owner_announcements a
    JOIN dormitories d ON a.dorm_id = d.dorm_id
    WHERE a.owner_id = ?
    ORDER BY a.created_at DESC
");
$stmt->execute([$owner_id]);
$announcements = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

<div class="page-header">
    <h1>Dorm Announcement System</h1>
    <p>Send announcements directly to tenants staying in your dormitory.</p>
</div>

<?php if (!empty($success)): ?>
<div class="alert success"><?= htmlspecialchars($success) ?></div>
<?php endif; ?>

<?php if (!empty($error)): ?>
<div class="alert error"><?= htmlspecialchars($error) ?></div>
<?php endif; ?>

<div class="form-area">
    <h2>Create Announcement</h2>

    <form method="POST">
        <input type="hidden" name="create" value="1">

        <label>Dormitory</label>
        <select name="dorm_id" required>
            <option value="">Select dorm…</option>
            <?php foreach ($dorms as $d): ?>
                <option value="<?= $d['dorm_id'] ?>"><?= htmlspecialchars($d['name']) ?></option>
            <?php endforeach; ?>
        </select>

        <label>Title</label>
        <input type="text" name="title" placeholder="Enter title…" required>

        <label>Message</label>
        <textarea name="message" rows="4" placeholder="Write your announcement…" required></textarea>

        <div class="actions">
            <button type="submit" class="btn-primary">Send</button>
            <button type="reset" class="btn-secondary">Clear</button>
        </div>
    </form>
</div>

<div class="section">
    <h2>Your Announcement History</h2>

    <?php if ($announcements): ?>
        <ul class="history-list">
            <?php foreach ($announcements as $a): ?>
                <li>
                    <strong><?= htmlspecialchars($a['title']) ?></strong>  
                    <small>
                        to <?= htmlspecialchars($a['dorm_name']) ?> •
                        <?= htmlspecialchars($a['created_at']) ?>
                    </small>

                    <p><?= nl2br(htmlspecialchars($a['message'])) ?></p>

                    <div class="actions">
                        <a href="?delete=<?= $a['id'] ?>" class="btn-danger"
                           onclick="return confirm('Delete this announcement?')">Delete</a>
                    </div>
                </li>
            <?php endforeach; ?>
        </ul>
    <?php else: ?>
        <p><em>You have not created any announcements yet.</em></p>
    <?php endif; ?>
</div>

<?php include __DIR__ . '/../../partials/footer.php'; ?>
