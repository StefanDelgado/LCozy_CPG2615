<?php
// Main/modules/owner/owner_management.php

require_once __DIR__ . '/../../auth/auth.php';
require_role(['admin', 'superadmin']);

require_once __DIR__ . '/../../config.php';

$page_title = "Owner Management";
$current = current_user();
$is_superadmin = ($current['role'] === 'superadmin');

// Filter/search parameters
$q = trim($_GET['q'] ?? '');
$status_filter = $_GET['status'] ?? 'all'; // options: all, pending, verified, rejected

$sql = "
    SELECT 
      u.user_id,
      u.name,
      u.email,
      u.phone,
      u.address,
      u.license_no,
      u.verified,
      u.created_at
    FROM users u
    WHERE u.role = 'owner'
";
$params = [];

if ($q !== '') {
    $sql .= " AND (u.name LIKE ? OR u.email LIKE ? OR u.license_no LIKE ?)";
    $like = "%{$q}%";
    $params[] = $like;
    $params[] = $like;
    $params[] = $like;
}

if ($status_filter === 'pending') {
    $sql .= " AND u.verified = 0";
} elseif ($status_filter === 'verified') {
    $sql .= " AND u.verified = 1";
} elseif ($status_filter === 'rejected') {
    $sql .= " AND u.verified = -1";
}

$sql .= " ORDER BY u.created_at DESC";

$stmt = $pdo->prepare($sql);
$stmt->execute($params);
$owners = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Count pending verification requests
$pendingCount = 0;
try {
    $pc = $pdo->prepare("SELECT COUNT(*) FROM owner_verification_requests WHERE status = 'pending'");
    $pc->execute();
    $pendingCount = (int) $pc->fetchColumn();
} catch (\Exception $e) {
    // Table might not exist yet
    $pendingCount = 0;
}

require_once __DIR__ . '/../../partials/header.php';
?>

<div class="page-header">
  <h1>Owner Management</h1>
  <p>Pending verifications: <?= $pendingCount ?></p>
</div>

<div class="card">
  <form method="get" style="display:flex; gap: 8px; align-items: center; margin-bottom: 16px;">
    <input type="text" name="q" placeholder="Search owners…" value="<?= htmlspecialchars($q) ?>" style="flex:1; padding:8px;">
    <select name="status" style="padding:8px;">
      <option value="all" <?= $status_filter === 'all' ? 'selected' : '' ?>>All</option>
      <option value="pending" <?= $status_filter === 'pending' ? 'selected' : '' ?>>Pending</option>
      <option value="verified" <?= $status_filter === 'verified' ? 'selected' : '' ?>>Verified</option>
      <option value="rejected" <?= $status_filter === 'rejected' ? 'selected' : '' ?>>Rejected</option>
    </select>
    <button type="submit" class="btn-primary">Filter</button>
    <a href="owner_requests.php" class="btn">Requests</a>
  </form>

  <?php if (empty($owners)): ?>
    <p>No owners found.</p>
  <?php else: ?>
    <table class="table">
      <thead>
        <tr>
          <th>Name</th>
          <th>Email</th>
          <th>Phone</th>
          <th>License #</th>
          <th>Verified</th>
          <th>Joined</th>
          <th>Actions</th>
        </tr>
      </thead>
      <tbody>
        <?php foreach ($owners as $o): ?>
          <tr>
            <td><?= htmlspecialchars($o['name']) ?></td>
            <td><?= htmlspecialchars($o['email']) ?></td>
            <td><?= htmlspecialchars($o['phone'] ?? '') ?></td>
            <td><?= htmlspecialchars($o['license_no'] ?? '') ?></td>
            <td>
              <?php
                if ($o['verified'] == 1) {
                  echo '<span class="badge" style="background: #28a745; color: #fff;">Verified</span>';
                } elseif ($o['verified'] == -1) {
                  echo '<span class="badge" style="background: #dc3545; color: #fff;">Rejected</span>';
                } else {
                  echo '<span class="badge" style="background: #ffc107; color: #333;">Pending</span>';
                }
              ?>
            </td>
            <td><?= htmlspecialchars(date('M d, Y', strtotime($o['created_at']))) ?></td>
            <td>
              <a class="btn btn-secondary" href="owner_profile.php?id=<?= (int)$o['user_id'] ?>">View</a>
              <?php if ($is_superadmin): ?>
                <a class="btn btn-danger"
                   href="process_owner_request.php?action=revoke&user_id=<?= (int)$o['user_id'] ?>"
                   onclick="return confirm('Revoke this owner?');">
                  Revoke
                </a>
              <?php endif; ?>
            </td>
          </tr>
        <?php endforeach; ?>
      </tbody>
    </table>
  <?php endif; ?>
</div>

<?php
require_once __DIR__ . '/../../partials/footer.php';
