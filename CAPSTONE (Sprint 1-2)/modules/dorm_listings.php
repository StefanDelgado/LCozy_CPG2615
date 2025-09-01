<?php
require_once __DIR__ . '/../auth.php';
require_role('admin');
require_once __DIR__ . '/../config.php';

$page_title = "Dorm Listings";
include __DIR__ . '/../partials/header.php';

if (isset($_GET['action'], $_GET['id'])) {
    $dorm_id = (int)$_GET['id'];
    $action = $_GET['action'];

    if ($action === 'approve') {
        $stmt = $pdo->prepare("UPDATE dormitories SET verified = 1 WHERE dorm_id = ?");
        $stmt->execute([$dorm_id]);
    } elseif ($action === 'reject') {
        $stmt = $pdo->prepare("UPDATE dormitories SET verified = 0 WHERE dorm_id = ?");
        $stmt->execute([$dorm_id]);
    }

    header("Location: dorm_listings.php");
    exit;
}

$sql = "
    SELECT d.dorm_id, d.name AS dorm_name, d.address, d.description, d.verified,
           u.name AS owner_name
    FROM dormitories d
    JOIN users u ON d.owner_id = u.user_id
    ORDER BY d.created_at DESC
";
$stmt = $pdo->query($sql);
$dorms = $stmt->fetchAll(PDO::FETCH_ASSOC);

$total_dorms = count($dorms);
?>

<div class="page-header">
  <p>Total Dormitories: <strong><?= $total_dorms ?></strong></p>
</div>

<div class="grid-2">
<?php foreach ($dorms as $dorm): ?>
  <div class="card">
    <h2><?= htmlspecialchars($dorm['dorm_name']) ?></h2>
    <p><strong>Address:</strong> <?= htmlspecialchars($dorm['address']) ?></p>
    <p><strong>Owner:</strong> <?= htmlspecialchars($dorm['owner_name']) ?></p>
    <p><?= nl2br(htmlspecialchars($dorm['description'])) ?></p>
    <p>
      <strong>Status:</strong>
      <?php if ($dorm['verified']): ?>
        <span class="badge success">Approved</span>
      <?php else: ?>
        <span class="badge warning">Pending / Rejected</span>
      <?php endif; ?>
    </p>
    <div class="actions">
      <a href="?action=approve&id=<?= $dorm['dorm_id'] ?>" class="btn success">Approve</a>
      <a href="?action=reject&id=<?= $dorm['dorm_id'] ?>" class="btn danger">Reject</a>
    </div>
  </div>
<?php endforeach; ?>
</div>

<?php include __DIR__ . '/../partials/footer.php'; ?>