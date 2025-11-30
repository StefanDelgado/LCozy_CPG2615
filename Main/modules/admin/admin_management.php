<?php
// /Main/modules/admin/admin_management.php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

require_once __DIR__ . '/../../auth/auth.php';
require_role('superadmin');

require_once __DIR__ . '/../../config.php';

// Messages (from actions)
$msg = $_GET['msg'] ?? null;

// -----------------------------
// Fetch Approved Admins (admins only; include superadmin for display but protected)
// -----------------------------
$adminsStmt = $pdo->prepare("
    SELECT 
        u.user_id,
        u.name,
        u.email,
        u.role,
        u.created_at,
        COUNT(DISTINCT ap.privilege_id) AS privilege_count,
        GROUP_CONCAT(DISTINCT ap.privilege_name) AS privileges
    FROM users u
    LEFT JOIN admin_privileges ap ON ap.admin_user_id = u.user_id
    WHERE u.role IN ('admin','superadmin')
    GROUP BY u.user_id
    ORDER BY FIELD(u.role, 'superadmin','admin'), u.created_at DESC
");
$adminsStmt->execute();
$admins = $adminsStmt->fetchAll(PDO::FETCH_ASSOC);

// -----------------------------
// Fetch Pending Admin Requests
// -----------------------------
$requestsStmt = $pdo->prepare("
    SELECT 
        ar.request_id,
        ar.requester_user_id,
        ar.reason,
        ar.status,
        ar.created_at,
        u.name AS requester_name,
        u.email AS requester_email,
        u.role AS requester_role
    FROM admin_approval_requests ar
    JOIN users u ON ar.requester_user_id = u.user_id
    ORDER BY FIELD(ar.status, 'pending','approved','rejected'), ar.created_at DESC
");
$requestsStmt->execute();
$adminRequests = $requestsStmt->fetchAll(PDO::FETCH_ASSOC);

// -----------------------------
// Revoked Admins (optional table)
// -----------------------------
$revokedAdmins = [];
try {
    $revokedStmt = $pdo->prepare("
        SELECT r.*, u.name, u.email, u.created_at AS joined_at
        FROM revoked_admins r
        LEFT JOIN users u ON r.user_id = u.user_id
        ORDER BY r.revoked_at DESC
    ");
    $revokedStmt->execute();
    $revokedAdmins = $revokedStmt->fetchAll(PDO::FETCH_ASSOC);
} catch (Exception $e) {
    $revokedAdmins = [];
}

?>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Admin Management — Super Admin</title>
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <link rel="stylesheet" href="../../assets/css/admin.css">
  <style>
    body { background: #f3f4f6; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Arial; margin:0; padding:0; }
    .top-nav { background: linear-gradient(135deg,#667eea 0%,#764ba2 100%); color:#fff; padding:16px 24px; display:flex; justify-content:space-between; align-items:center; box-shadow:0 2px 6px rgba(0,0,0,0.06); }
    .container { max-width:1200px; margin:28px auto; padding:0 18px; }
    .card { background:white; padding:18px; border-radius:10px; box-shadow:0 4px 14px rgba(0,0,0,0.04); margin-bottom:18px; }
    .tab-btn { padding:10px 14px; border-radius:8px; border:none; cursor:pointer; background:#eef2ff; font-weight:600; }
    .tab-btn.active { background:#4c3bcf; color:#fff; }
    table { width:100%; border-collapse:collapse; margin-top:8px; }
    th, td { padding:12px 10px; border-bottom:1px solid #eef1f6; font-size:14px; }
    th { background:#fbfdff; font-weight:700; color:#374151; }
    .role-badge { padding:6px 10px; border-radius:999px; font-size:13px; display:inline-block; }
    .role-superadmin { background: linear-gradient(135deg,#667eea,#764ba2); color:#fff; }
    .role-admin { background:#e0e7ff; color:#1e40af; }
    .privilege-tag { padding:6px 8px; background:#eef2ff; border-radius:8px; margin:2px; font-size:12px; display:inline-block; }
    .btn { padding:8px 12px; border-radius:8px; border:none; cursor:pointer; text-decoration:none; display:inline-block; }
    .btn-primary { background:#3b82f6; color:#fff; }
    .btn-success { background:#10b981; color:#fff; }
    .btn-danger { background:#ef4444; color:#fff; }
    .muted { color:#6b7280; font-size:13px; }
  </style>
</head>
<body>

  <div class="top-nav">
    <h3 style="margin:0;">Super Admin — Admin Management</h3>
    <div>
      <a href="../../dashboards/superadmin_dashboard.php" class="btn" style="background:rgba(255,255,255,0.14);color:#fff;">Back to Dashboard</a>
      <a href="../../auth/logout.php" class="btn btn-danger">Logout</a>
    </div>
  </div>

  <div class="container">

    <?php if ($msg): ?>
      <div class="card">
        <div class="notice"><?php echo htmlspecialchars(str_replace('+',' ',$msg)); ?></div>
      </div>
    <?php endif; ?>

    <div class="card">

      <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:12px;">
        <h2 style="margin:0;">Admin Management</h2>
        <div>
          <button class="tab-btn" id="tab-admins-btn">Approved Admins</button>
          <button class="tab-btn" id="tab-requests-btn">Pending Requests</button>
          <button class="tab-btn" id="tab-revoked-btn">Revoked Admins</button>
        </div>
      </div>

      <!-- Approved Admins -->
      <div id="tab-admins" class="tab" style="display:block;">
        <h3>Approved Admins</h3>

        <?php if (empty($admins)): ?>
            <p class="muted">No admin accounts found.</p>
        <?php else: ?>
          <table>
            <thead>
              <tr>
                <th>Name</th>
                <th>Email</th>
                <th>Role</th>
                <th>Privileges</th>
                <th>Joined</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
            <?php foreach ($admins as $a): ?>
              <tr>
                <td><strong><?php echo htmlspecialchars($a['name']); ?></strong></td>
                <td><?php echo htmlspecialchars($a['email']); ?></td>
                <td>
                  <span class="role-badge <?php echo $a['role'] === 'superadmin' ? 'role-superadmin' : 'role-admin'; ?>">
                    <?php echo ucfirst($a['role']); ?>
                  </span>
                </td>
                <td>
                  <?php if ($a['role'] === 'superadmin'): ?>
                    <span class="privilege-tag">All Privileges</span>
                  <?php elseif (!empty($a['privileges'])): ?>
                    <?php foreach (explode(',', $a['privileges']) as $p): ?>
                      <span class="privilege-tag"><?php echo htmlspecialchars($p); ?></span>
                    <?php endforeach; ?>
                  <?php else: ?>
                    <span class="muted">No privileges</span>
                  <?php endif; ?>
                </td>
                <td><?php echo date('M d, Y', strtotime($a['created_at'])); ?></td>
                <td>
                  <?php if ($a['role'] === 'superadmin'): ?>
                    <span class="muted">Protected</span>
                  <?php else: ?>
                    <a class="btn btn-primary" href="manage_admin_privileges.php?id=<?php echo (int)$a['user_id']; ?>">Manage Privileges</a>
                    <a class="btn btn-danger" href="revoke_admin.php?id=<?php echo (int)$a['user_id']; ?>" onclick="return confirm('Revoke admin for <?php echo htmlspecialchars(addslashes($a['name'])); ?>?');">Revoke</a>
                  <?php endif; ?>
                </td>
              </tr>
            <?php endforeach; ?>
            </tbody>
          </table>
        <?php endif; ?>
      </div>

      <!-- Pending Requests -->
      <div id="tab-requests" class="tab" style="display:none;">
        <h3>Pending Requests</h3>

        <?php if (empty($adminRequests)): ?>
          <p class="muted">No requests.</p>
        <?php else: ?>
          <table>
            <thead>
              <tr>
                <th>Requester</th>
                <th>Email</th>
                <th>Current Role</th>
                <th>Reason</th>
                <th>Submitted</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
            <?php foreach ($adminRequests as $r): ?>
              <tr>
                <td><strong><?php echo htmlspecialchars($r['requester_name']); ?></strong></td>
                <td><?php echo htmlspecialchars($r['requester_email']); ?></td>
                <td><span class="role-badge"><?php echo ucfirst(htmlspecialchars($r['requester_role'])); ?></span></td>
                <td><?php echo htmlspecialchars($r['reason'] ?? '—'); ?></td>
                <td><?php echo date('M d, Y', strtotime($r['created_at'])); ?></td>
                <td><?php echo ucfirst($r['status']); ?></td>
                <td>
                  <?php if ($r['status'] === 'pending'): ?>
                    <a class="btn btn-success" href="process_admin_request.php?id=<?php echo (int)$r['request_id']; ?>&action=approve">Approve</a>
                    <a class="btn btn-danger" href="process_admin_request.php?id=<?php echo (int)$r['request_id']; ?>&action=reject">Reject</a>
                  <?php else: ?>
                    <span class="muted">Reviewed</span>
                  <?php endif; ?>
                </td>
              </tr>
            <?php endforeach; ?>
            </tbody>
          </table>
        <?php endif; ?>
      </div>

      <!-- Revoked Admins -->
      <div id="tab-revoked" class="tab" style="display:none;">
        <h3>Revoked Admins</h3>

        <?php if (empty($revokedAdmins)): ?>
            <p class="muted">No revoked admin records.</p>
        <?php else: ?>
          <table>
            <thead>
              <tr>
                <th>Name</th>
                <th>Email</th>
                <th>Revoked At</th>
                <th>Reason</th>
              </tr>
            </thead>
            <tbody>
            <?php foreach ($revokedAdmins as $r): ?>
              <tr>
                <td><?php echo htmlspecialchars($r['name'] ?? 'N/A'); ?></td>
                <td><?php echo htmlspecialchars($r['email'] ?? 'N/A'); ?></td>
                <td>
                  <?php 
                    $ts = $r['revoked_at'] ?? date('Y-m-d H:i:s');
                    echo date('M d, Y', strtotime($ts));
                  ?>
                </td>
                <td><?php echo htmlspecialchars($r['reason'] ?? '—'); ?></td>
              </tr>
            <?php endforeach; ?>
            </tbody>
          </table>
        <?php endif; ?>
      </div>

    </div>
  </div>

<script>
  const adminTabBtn = document.getElementById('tab-admins-btn');
  const requestsTabBtn = document.getElementById('tab-requests-btn');
  const revokedTabBtn = document.getElementById('tab-revoked-btn');

  const tabAdmins = document.getElementById('tab-admins');
  const tabRequests = document.getElementById('tab-requests');
  const tabRevoked = document.getElementById('tab-revoked');

  function setActive(btn) {
    [adminTabBtn, requestsTabBtn, revokedTabBtn].forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
  }

  adminTabBtn.addEventListener('click', () => { tabAdmins.style.display='block'; tabRequests.style.display='none'; tabRevoked.style.display='none'; setActive(adminTabBtn); });
  requestsTabBtn.addEventListener('click', () => { tabAdmins.style.display='none'; tabRequests.style.display='block'; tabRevoked.style.display='none'; setActive(requestsTabBtn); });
  revokedTabBtn.addEventListener('click', () => { tabAdmins.style.display='none'; tabRequests.style.display='none'; tabRevoked.style.display='block'; setActive(revokedTabBtn); });

  setActive(adminTabBtn);
</script>

</body>
</html>