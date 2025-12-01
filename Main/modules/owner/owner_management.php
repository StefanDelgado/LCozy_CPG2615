<?php
// /Main/modules/owner/owner_management.php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

require_once __DIR__ . '/../../auth/auth.php';
require_role('superadmin');

require_once __DIR__ . '/../../config.php';

$msg = $_GET['msg'] ?? null;

// -----------------------------
// Fetch Owners (3 groups by verified state)
// -----------------------------

// Pending = verified = 0
$pendingStmt = $pdo->prepare("
    SELECT user_id, name, email, phone, created_at, id_document, profile_pic
    FROM users
    WHERE role = 'owner' AND verified = 0
    ORDER BY created_at DESC
");
$pendingStmt->execute();
$pendingOwners = $pendingStmt->fetchAll(PDO::FETCH_ASSOC);

// Verified = verified = 1
$verifiedStmt = $pdo->prepare("
    SELECT user_id, name, email, phone, created_at, id_document, profile_pic
    FROM users
    WHERE role = 'owner' AND verified = 1
    ORDER BY created_at DESC
");
$verifiedStmt->execute();
$verifiedOwners = $verifiedStmt->fetchAll(PDO::FETCH_ASSOC);

// Disapproved = verified = -1
$rejectedStmt = $pdo->prepare("
    SELECT user_id, name, email, phone, created_at, id_document, profile_pic
    FROM users
    WHERE role = 'owner' AND verified = -1
    ORDER BY created_at DESC
");
$rejectedStmt->execute();
$rejectedOwners = $rejectedStmt->fetchAll(PDO::FETCH_ASSOC);
?>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Owner Management — Super Admin</title>
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <link rel="stylesheet" href="../../assets/css/admin.css">
  <style>
    body { background:#f3f4f6; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto; margin:0; }
    .top-nav { background:linear-gradient(135deg,#667eea,#764ba2); color:#fff; padding:16px 24px; display:flex; justify-content:space-between; }
    .container { max-width:1200px; margin:28px auto; padding:0 18px; }
    .card { background:white; padding:18px; border-radius:10px; box-shadow:0 4px 14px rgba(0,0,0,0.06); margin-bottom:18px; }
    .tab-btn { padding:10px 14px; border-radius:8px; border:none; cursor:pointer; background:#eef2ff; font-weight:600; }
    .tab-btn.active { background:#4c3bcf; color:#fff; }
    table { width:100%; border-collapse:collapse; margin-top:10px; }
    th, td { padding:12px 10px; border-bottom:1px solid #eef1f6; font-size:14px; }
    th { background:#f9fafb; }
    .btn { padding:8px 12px; border-radius:8px; text-decoration:none; display:inline-block; }
    .btn-success { background:#10b981; color:white; }
    .btn-danger { background:#ef4444; color:white; }
    .btn-view { background:#3b82f6; color:white; }
    .muted { color:#6b7280; font-size:13px; }
  </style>
</head>
<body>

<div class="top-nav">
  <h3 style="margin:0;">Super Admin — Owner Management</h3>
  <div>
    <a href="../../dashboards/superadmin_dashboard.php" class="btn" style="background:rgba(255,255,255,0.1);color:white;">Back</a>
    <a href="../../auth/logout.php" class="btn btn-danger">Logout</a>
  </div>
</div>

<div class="container">

<?php if ($msg): ?>
  <div class="card"><strong><?php echo htmlspecialchars($msg); ?></strong></div>
<?php endif; ?>

<div class="card">

  <div style="display:flex;justify-content:space-between;margin-bottom:14px;">
    <h2>Owner Management</h2>
    <div>
      <button class="tab-btn" id="tab-pending-btn">Pending</button>
      <button class="tab-btn" id="tab-verified-btn">Verified</button>
      <button class="tab-btn" id="tab-rejected-btn">Disapproved</button>
    </div>
  </div>

  <!-- Pending -->
  <div id="tab-pending" class="tab" style="display:block;">
    <h3>Pending Owners</h3>

    <?php if (empty($pendingOwners)): ?>
      <p class="muted">No pending owners.</p>
    <?php else: ?>
      <table>
        <thead>
          <tr>
            <th>Name</th><th>Email</th><th>Phone</th><th>ID Document</th><th>Registered</th><th>Actions</th>
          </tr>
        </thead>
        <tbody>
        <?php foreach ($pendingOwners as $o): ?>
          <tr>
            <td><?= htmlspecialchars($o['name']) ?></td>
            <td><?= htmlspecialchars($o['email']) ?></td>
            <td><?= htmlspecialchars($o['phone'] ?? '—') ?></td>
            <td>
              <?php if ($o['id_document']): ?>
                <a class="btn-view" href="/uploads/id_documents/<?= htmlspecialchars($o['id_document']) ?>" target="_blank">View</a>
              <?php else: ?>
                <span class="muted">No ID</span>
              <?php endif; ?>
            </td>
            <td><?= date('M d, Y', strtotime($o['created_at'])) ?></td>
            <td>
              <a class="btn btn-success" href="process_owner_request.php?id=<?= $o['user_id'] ?>&action=approve">Approve</a>
              <a class="btn btn-danger" href="process_owner_request.php?id=<?= $o['user_id'] ?>&action=disapprove">Disapprove</a>
            </td>
          </tr>
        <?php endforeach; ?>
        </tbody>
      </table>
    <?php endif; ?>
  </div>

  <!-- Verified -->
  <div id="tab-verified" class="tab" style="display:none;">
    <h3>Verified Owners</h3>

    <?php if (empty($verifiedOwners)): ?>
      <p class="muted">No verified owners.</p>
    <?php else: ?>
      <table>
        <thead>
          <tr><th>Name</th><th>Email</th><th>Phone</th><th>ID Document</th><th>Verified</th></tr>
        </thead>
        <tbody>
        <?php foreach ($verifiedOwners as $o): ?>
          <tr>
            <td><?= htmlspecialchars($o['name']) ?></td>
            <td><?= htmlspecialchars($o['email']) ?></td>
            <td><?= htmlspecialchars($o['phone'] ?? '—') ?></td>
            <td>
              <?php if ($o['id_document']): ?>
                <a class="btn-view" href="/uploads/id_documents/<?= htmlspecialchars($o['id_document']) ?>" target="_blank">View</a>
              <?php else: ?>
                <span class="muted">No ID</span>
              <?php endif; ?>
            </td>
            <td><?= date('M d, Y', strtotime($o['created_at'])) ?></td>
          </tr>
        <?php endforeach; ?>
        </tbody>
      </table>
    <?php endif; ?>
  </div>

  <!-- Rejected -->
  <div id="tab-rejected" class="tab" style="display:none;">
    <h3>Disapproved Owners</h3>

    <?php if (empty($rejectedOwners)): ?>
      <p class="muted">No disapproved owners.</p>
    <?php else: ?>
      <table>
        <thead>
          <tr><th>Name</th><th>Email</th><th>Phone</th><th>ID Document</th><th>Registered</th></tr>
        </thead>
        <tbody>
        <?php foreach ($rejectedOwners as $o): ?>
          <tr>
            <td><?= htmlspecialchars($o['name']) ?></td>
            <td><?= htmlspecialchars($o['email']) ?></td>
            <td><?= htmlspecialchars($o['phone'] ?? '—') ?></td>
            <td>
              <?php if ($o['id_document']): ?>
                <a class="btn-view" href="/uploads/id_documents/<?= htmlspecialchars($o['id_document']) ?>" target="_blank">View</a>
              <?php else: ?>
                <span class="muted">No ID</span>
              <?php endif; ?>
            </td>
            <td><?= date('M d, Y', strtotime($o['created_at'])) ?></td>
          </tr>
        <?php endforeach; ?>
        </tbody>
      </table>
    <?php endif; ?>
  </div>

</div>
</div>

<script>
  const tabs = {
    pending: document.getElementById('tab-pending'),
    verified: document.getElementById('tab-verified'),
    rejected: document.getElementById('tab-rejected')
  };
  const btns = {
    pending: document.getElementById('tab-pending-btn'),
    verified: document.getElementById('tab-verified-btn'),
    rejected: document.getElementById('tab-rejected-btn')
  };
  function showTab(name) {
    for (const t in tabs) tabs[t].style.display = 'none';
    for (const b in btns) btns[b].classList.remove('active');
    tabs[name].style.display = 'block';
    btns[name].classList.add('active');
  }
  btns.pending.onclick = () => showTab('pending');
  btns.verified.onclick = () => showTab('verified');
  btns.rejected.onclick = () => showTab('rejected');
  showTab('pending');
</script>

</body>
</html>
