<?php 
require_once __DIR__ . '/../partials/header.php'; 
require_role('admin');
require_once __DIR__ . '/../config.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $owner_id = intval($_POST['user_id']);
    $action = $_POST['action'];

    if ($action === 'approve') {
        $pdo->prepare("UPDATE users SET verified = 1 WHERE user_id = ? AND role = 'owner'")
            ->execute([$owner_id]);
    } elseif ($action === 'reject') {
        $pdo->prepare("UPDATE users SET verified = -1 WHERE user_id = ? AND role = 'owner'")
            ->execute([$owner_id]);
    }
}

$totalVerified = $pdo->query("SELECT COUNT(*) FROM users WHERE role='owner' AND verified=1")->fetchColumn();
$totalPending  = $pdo->query("SELECT COUNT(*) FROM users WHERE role='owner' AND verified=0")->fetchColumn();
$totalRejected = $pdo->query("SELECT COUNT(*) FROM users WHERE role='owner' AND verified=-1")->fetchColumn();

$status = $_GET['status'] ?? 'pending';
switch ($status) {
    case 'verified':
        $owners = $pdo->query("SELECT * FROM users WHERE role='owner' AND verified=1")->fetchAll();
        break;
    case 'rejected':
        $owners = $pdo->query("SELECT * FROM users WHERE role='owner' AND verified=-1")->fetchAll();
        break;
    default:
        $owners = $pdo->query("SELECT * FROM users WHERE role='owner' AND verified=0")->fetchAll();
        break;
}
?>

<div class="page-header">
  <h1>Dorm Owner Verification</h1>
  <p>Review and manage dorm owner accounts</p>
</div>

<div class="stats-grid">
  <div class="stat-card"><h3><?=$totalVerified?></h3><p>Verified Owners</p></div>
  <div class="stat-card"><h3><?=$totalPending?></h3><p>Pending Owners</p></div>
  <div class="stat-card"><h3><?=$totalRejected?></h3><p>Rejected Owners</p></div>
</div>

<div class="section">
  <h2>Owner Applications</h2>

  <div class="filter-actions">
    <a href="?status=pending" class="btn <?=$status==='pending'?'active':''?>">Pending</a>
    <a href="?status=verified" class="btn <?=$status==='verified'?'active':''?>">Verified</a>
    <a href="?status=rejected" class="btn <?=$status==='rejected'?'active':''?>">Rejected</a>
  </div>

  <table class="data-table">
    <thead>
      <tr><th>ID</th><th>Name</th><th>Email</th><th>Created</th><th>Status</th><th>Actions</th></tr>
    </thead>
    <tbody>
      <?php foreach ($owners as $o): ?>
      <tr>
        <td><?=$o['user_id']?></td>
        <td><?=htmlspecialchars($o['name'])?></td>
        <td><?=htmlspecialchars($o['email'])?></td>
        <td><?=$o['created_at']?></td>
        <td>
          <?php if ($o['verified']==1): ?>
            <span class="badge success">Verified</span>
          <?php elseif ($o['verified']==-1): ?>
            <span class="badge error">Rejected</span>
          <?php else: ?>
            <span class="badge warning">Pending</span>
          <?php endif; ?>
        </td>
        <td>
          <?php if ($o['verified']==0): ?>
            <form method="post" style="display:inline">
              <input type="hidden" name="user_id" value="<?=$o['user_id']?>">
              <button class="btn-primary" name="action" value="approve">Approve</button>
              <button class="btn-secondary" name="action" value="reject">Reject</button>
            </form>
          <?php else: ?>
            <em>No actions</em>
          <?php endif; ?>
        </td>
      </tr>
      <?php endforeach; ?>
    </tbody>
  </table>
</div>

<?php require_once __DIR__ . '/../partials/footer.php'; ?>