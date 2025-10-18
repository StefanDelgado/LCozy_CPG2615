<?php
require_once __DIR__ . '/../../auth/auth.php';
require_role('admin');
require_once __DIR__ . '/../../config.php';

$page_title = "Dorm Listings";
include __DIR__ . '/../../partials/header.php';

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
           d.cover_image, d.features,
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

    <?php if (!empty($dorm['cover_image'])): ?>
      <img src="../uploads/<?= htmlspecialchars($dorm['cover_image']) ?>" 
           alt="<?= htmlspecialchars($dorm['dorm_name']) ?>" 
           style="width:100%;max-height:200px;object-fit:cover;border-radius:8px;margin-bottom:10px;">
    <?php else: ?>
      <div style="width:100%;height:200px;background:#eee;display:flex;align-items:center;justify-content:center;border-radius:8px;">
        <span>No Image Available</span>
      </div>
    <?php endif; ?>

    <p><strong>Address:</strong> <?= htmlspecialchars($dorm['address']) ?></p>
    <p><strong>Owner:</strong> <?= htmlspecialchars($dorm['owner_name']) ?></p>
    <p><?= nl2br(htmlspecialchars($dorm['description'])) ?></p>

    <?php if (!empty($dorm['features'])): ?>
      <p><strong>Features:</strong> <?= htmlspecialchars($dorm['features']) ?></p>
    <?php endif; ?>

    <h3>Rooms</h3>
    <table class="data-table">
      <thead>
        <tr>
          <th>Room #</th>
          <th>Type</th>
          <th>Capacity</th>
          <th>Price (₱)</th>
          <th>Status</th>
        </tr>
      </thead>
      <tbody>
        <?php
        $room_sql = "SELECT room_id, room_number, room_type, capacity, price, status FROM rooms WHERE dorm_id = ?";
        $room_stmt = $pdo->prepare($room_sql);
        $room_stmt->execute([$dorm['dorm_id']]);
        $rooms = $room_stmt->fetchAll(PDO::FETCH_ASSOC);
        ?>
        <?php if ($rooms): ?>
          <?php foreach ($rooms as $room): ?>
          <tr>
            <td><?= htmlspecialchars($room['room_number'] ?? '-') ?></td>
            <td><?= htmlspecialchars($room['room_type']) ?></td>
            <td><?= htmlspecialchars($room['capacity']) ?></td>
            <td><?= number_format($room['price'], 2) ?></td>
            <td>
              <?php if ($room['status'] === 'vacant'): ?>
                <span class="badge success">Vacant</span>
              <?php else: ?>
                <span class="badge error">Occupied</span>
              <?php endif; ?>
            </td>
          </tr>
          <?php endforeach; ?>
        <?php else: ?>
          <tr><td colspan="5"><em>No rooms listed</em></td></tr>
        <?php endif; ?>
      </tbody>
    </table>

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

<?php include __DIR__ . '/../../partials/footer.php'; ?>
