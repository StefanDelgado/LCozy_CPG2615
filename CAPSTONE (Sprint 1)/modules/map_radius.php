<?php
require_once __DIR__ . '/../auth.php';
require_role('admin');
require_once __DIR__ . '/../config.php';

$page_title = "Map & Radius Management";

if (isset($_POST['verify_dorm'])) {
    $stmt = $pdo->prepare("UPDATE dormitories SET status = 'verified' WHERE dorm_id = ?");
    $stmt->execute([$_POST['verify_dorm']]);
}
if (isset($_POST['reject_dorm'])) {
    $stmt = $pdo->prepare("UPDATE dormitories SET status = 'error' WHERE dorm_id = ?");
    $stmt->execute([$_POST['reject_dorm']]);
}

$sql = "
  SELECT d.dorm_id, d.name AS dorm_name, d.address, d.latitude, d.longitude,
         d.status, d.updated_at, u.name AS owner_name
  FROM dormitories d
  JOIN users u ON d.owner_id = u.user_id
";
$dorms = $pdo->query($sql)->fetchAll(PDO::FETCH_ASSOC);

include __DIR__ . '/../partials/header.php';
?>

<div class="page-header">
  <div class="header-actions">
    <button class="btn" onclick="document.getElementById('mapSettings').style.display='block'">
      <i class="fa fa-cog"></i> Map Settings
    </button>
    <button class="btn" onclick="document.getElementById('verifyModal').style.display='block'">
      <i class="fa fa-check-circle"></i> Verify Locations
    </button>
  </div>
</div>

<div class="grid-4">
  <div class="card stat"><h3><?=count($dorms)?></h3><p>Total Dorms</p></div>
  <div class="card stat"><h3><?=count(array_filter($dorms, fn($d)=>$d['status']==='verified'))?></h3><p>Verified</p></div>
  <div class="card stat"><h3><?=count(array_filter($dorms, fn($d)=>$d['status']==='pending'))?></h3><p>Pending</p></div>
  <div class="card stat error"><h3><?=count(array_filter($dorms, fn($d)=>$d['status']==='error'))?></h3><p>Errors</p></div>
</div>

<div class="card full">
  <h2>Google Maps Integration</h2>
  <div id="map" class="map-placeholder" style="height:400px"></div>
</div>

<div class="card full">
  <h2>Dorm Location Management</h2>
  <table>
    <thead>
      <tr>
        <th>Dorm</th>
        <th>Owner</th>
        <th>Address</th>
        <th>Status</th>
        <th>Coordinates</th>
        <th>Updated</th>
        <th>Actions</th>
      </tr>
    </thead>
    <tbody>
      <?php foreach ($dorms as $d): ?>
        <tr>
          <td><?=htmlspecialchars($d['dorm_name'])?></td>
          <td><?=htmlspecialchars($d['owner_name'])?></td>
          <td><?=htmlspecialchars($d['address'])?></td>
          <td>
            <?php if ($d['status'] === 'verified'): ?>
              <span class="badge success">Verified</span>
            <?php elseif ($d['status'] === 'pending'): ?>
              <span class="badge warning">Pending</span>
            <?php else: ?>
              <span class="badge error">Error</span>
            <?php endif; ?>
          </td>
          <td><?=htmlspecialchars($d['latitude'])?>, <?=htmlspecialchars($d['longitude'])?></td>
          <td><?=htmlspecialchars($d['updated_at'])?></td>
          <td>
            <form method="post" style="display:inline;">
              <button class="btn">View</button>
            </form>
            <?php if ($d['status'] === 'pending'): ?>
              <form method="post" style="display:inline;">
                <input type="hidden" name="verify_dorm" value="<?= $d['dorm_id'] ?>">
                <button class="btn success">Approve</button>
              </form>
              <form method="post" style="display:inline;">
                <input type="hidden" name="reject_dorm" value="<?= $d['dorm_id'] ?>">
                <button class="btn error">Reject</button>
              </form>
            <?php endif; ?>
          </td>
        </tr>
      <?php endforeach; ?>
    </tbody>
  </table>
</div>

<div id="mapSettings" class="modal" style="display:none;">
  <div class="modal-content">
    <h2>Map Settings</h2>
    <form method="post">
      <label>Default Search Radius (km)</label>
      <input type="number" name="default_radius" value="10"><br>
      <label>Maximum Search Radius (km)</label>
      <input type="number" name="max_radius" value="30"><br>
      <label><input type="checkbox" name="auto_detect" checked> Auto-detect User Location</label><br>
      <label><input type="checkbox" name="high_accuracy"> High Accuracy Mode</label><br>
      <button type="submit" class="btn">Save</button>
      <button type="button" class="btn error" onclick="document.getElementById('mapSettings').style.display='none'">Close</button>
    </form>
  </div>
</div>

<div id="verifyModal" class="modal" style="display:none;">
  <div class="modal-content">
    <h2>Pending Dorms for Verification</h2>
    <table>
      <thead><tr><th>Dorm</th><th>Owner</th><th>Address</th><th>Actions</th></tr></thead>
      <tbody>
        <?php foreach ($dorms as $d): if ($d['status']==='pending'): ?>
        <tr>
          <td><?=htmlspecialchars($d['dorm_name'])?></td>
          <td><?=htmlspecialchars($d['owner_name'])?></td>
          <td><?=htmlspecialchars($d['address'])?></td>
          <td>
            <form method="post" style="display:inline;">
              <input type="hidden" name="verify_dorm" value="<?= $d['dorm_id'] ?>">
              <button class="btn success">Approve</button>
            </form>
            <form method="post" style="display:inline;">
              <input type="hidden" name="reject_dorm" value="<?= $d['dorm_id'] ?>">
              <button class="btn error">Reject</button>
            </form>
          </td>
        </tr>
        <?php endif; endforeach; ?>
      </tbody>
    </table>
    <button type="button" class="btn" onclick="document.getElementById('verifyModal').style.display='none'">Close</button>
  </div>
</div>

<script>
const dorms = <?=json_encode($dorms)?>;

function initMap() {
  const map = new google.maps.Map(document.getElementById("map"), {
    center: { lat: 10.6765, lng: 122.9509 },
    zoom: 13,
  });

  dorms.forEach(d => {
    if (!d.latitude || !d.longitude) return;
    new google.maps.Marker({
      position: { lat: parseFloat(d.latitude), lng: parseFloat(d.longitude) },
      map,
      title: d.dorm_name
    });
  });
}
</script>
<script async defer src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY&callback=initMap"></script>

<?php include __DIR__ . '/../partials/footer.php'; ?>