<?php
require_once __DIR__ . '/../auth.php';
require_role('owner');
require_once __DIR__ . '/../config.php';

$page_title = "CozyDorms";
include __DIR__ . '/../partials/header.php';

$owner_id = $_SESSION['user']['user_id'];
$flash = null;

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['add_dorm'])) {
    $name = trim($_POST['name']);
    $address = trim($_POST['address']);
    $description = trim($_POST['description']);
    $features = trim($_POST['features']);
    $cover_image = null;

    if (!empty($_FILES['cover_image']['name'])) {
        $upload_dir = __DIR__ . '/../uploads/';
        if (!file_exists($upload_dir)) mkdir($upload_dir, 0777, true);

        $ext = strtolower(pathinfo($_FILES['cover_image']['name'], PATHINFO_EXTENSION));
        $allowed = ['jpg', 'jpeg', 'png'];
        if (in_array($ext, $allowed)) {
            $cover_image = uniqid('dorm_') . '.' . $ext;
            move_uploaded_file($_FILES['cover_image']['tmp_name'], $upload_dir . $cover_image);
        }
    }

    $stmt = $pdo->prepare("INSERT INTO dormitories (owner_id, name, address, description, features, cover_image, verified, created_at)
                           VALUES (?, ?, ?, ?, ?, ?, 0, NOW())");
    $stmt->execute([$owner_id, $name, $address, $description, $features, $cover_image]);

    $flash = ['type' => 'success', 'msg' => 'Dorm added successfully! Pending admin verification.'];
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['add_room'])) {
    $dorm_id = (int)$_POST['dorm_id'];
    $room_type = $_POST['room_type_select'] === 'Custom' ? trim($_POST['room_type']) : $_POST['room_type_select'];
    $capacity = (int)$_POST['capacity'];
    $price = (float)$_POST['price'];
    $status = $_POST['status'];

    $stmt = $pdo->prepare("INSERT INTO rooms (dorm_id, room_type, capacity, price, status, created_at)
                           VALUES (?, ?, ?, ?, ?, NOW())");
    $stmt->execute([$dorm_id, $room_type, $capacity, $price, $status]);

    $flash = ['type' => 'success', 'msg' => 'Room added successfully!'];
}

$stmt = $pdo->prepare("
    SELECT dorm_id, name, address, description, verified, cover_image, features
    FROM dormitories
    WHERE owner_id = ?
    ORDER BY created_at DESC
");
$stmt->execute([$owner_id]);
$dorms = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

<div class="page-header">
  <p>Manage and add your dorm listings.</p>
</div>

<?php if ($flash): ?>
<div id="flashModal" class="flash-modal <?=$flash['type']?>" onclick="closeFlash()">
  <div class="flash-content" onclick="event.stopPropagation();">
    <p><?=htmlspecialchars($flash['msg'])?></p>
    <button class="close-btn" onclick="closeFlash()">×</button>
  </div>
</div>
<script>
function closeFlash(){ document.getElementById("flashModal").style.display="none"; }
setTimeout(closeFlash,3000);
</script>
<style>
.flash-modal{position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,0.4);display:flex;align-items:center;justify-content:center;z-index:9999;}
.flash-content{position:relative;background:#fff;padding:20px 40px;border-radius:12px;box-shadow:0 6px 20px rgba(0,0,0,0.25);font-size:1.2em;font-weight:bold;}
.flash-modal.success .flash-content{border-left:8px solid green;}
.flash-modal.error .flash-content{border-left:8px solid red;}
.close-btn{position:absolute;top:8px;right:12px;background:none;border:none;font-size:1.5em;cursor:pointer;}
</style>
<?php endif; ?>

<div class="card" style="margin-bottom: 2rem;">
  <h2>Add New Dormitory</h2>
  <form method="post" enctype="multipart/form-data" class="add-dorm-form">
    <label>Dorm Name</label>
    <input type="text" name="name" required>

    <label>Address</label>
    <input type="text" name="address" required>

    <label>Description</label>
    <textarea name="description" rows="3" required></textarea>

    <label>Features (comma separated)</label>
    <input type="text" name="features" placeholder="WiFi, Aircon, Laundry, etc.">

    <label>Cover Image</label>
    <input type="file" name="cover_image" accept=".jpg,.jpeg,.png">

    <button type="submit" name="add_dorm" class="btn-primary">Add Dormitory</button>
  </form>
</div>

<div class="grid-2">
<?php if ($dorms): ?>
  <?php foreach ($dorms as $dorm): ?>
  <div class="card">
    <h2><?=htmlspecialchars($dorm['name'])?></h2>

    <?php if (!empty($dorm['cover_image'])): ?>
      <img src="../uploads/<?=htmlspecialchars($dorm['cover_image'])?>" 
           alt="<?=htmlspecialchars($dorm['name'])?>" 
           style="width:100%;max-height:200px;object-fit:cover;border-radius:8px;margin-bottom:10px;">
    <?php else: ?>
      <div style="width:100%;height:200px;background:#eee;display:flex;align-items:center;justify-content:center;border-radius:8px;">
        <span>No Image</span>
      </div>
    <?php endif; ?>

    <p><strong>Address:</strong> <?=htmlspecialchars($dorm['address'])?></p>
    <p><?=nl2br(htmlspecialchars($dorm['description']))?></p>

    <p><strong>Features:</strong> <?=htmlspecialchars($dorm['features'] ?: 'None listed')?></p>

    <p>
      <strong>Status:</strong>
      <?php if ($dorm['verified'] == 1): ?>
        <span class="badge success">Approved</span>
      <?php elseif ($dorm['verified'] == -1): ?>
        <span class="badge error">Rejected</span>
      <?php else: ?>
        <span class="badge warning">Pending</span>
      <?php endif; ?>
    </p>

    <h3>Rooms</h3>
    <table class="data-table">
      <thead>
        <tr>
          <th>ID</th><th>Type</th><th>Capacity</th><th>Price</th><th>Status</th>
        </tr>
      </thead>
      <tbody>
        <?php
        $room_stmt = $pdo->prepare("SELECT * FROM rooms WHERE dorm_id=?");
        $room_stmt->execute([$dorm['dorm_id']]);
        $rooms = $room_stmt->fetchAll(PDO::FETCH_ASSOC);
        ?>
        <?php if ($rooms): ?>
          <?php foreach ($rooms as $r): ?>
            <tr>
              <td><?=$r['room_id']?></td>
              <td><?=htmlspecialchars($r['room_type'])?></td>
              <td><?=$r['capacity']?></td>
              <td>₱<?=number_format($r['price'],2)?></td>
              <td>
                <?php if ($r['status']==='vacant'): ?>
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

    <form method="post" style="margin-top:10px;">
      <input type="hidden" name="dorm_id" value="<?=$dorm['dorm_id']?>">
      <select name="room_type_select" required>
        <option value="">Select Room Type</option>
        <option value="Single">Single</option>
        <option value="Double">Double</option>
        <option value="Twin">Twin</option>
        <option value="Suite">Suite</option>
        <option value="Custom">Custom</option>
      </select>
      <input type="text" name="room_type" placeholder="Custom Room Type">
      <input type="number" name="capacity" placeholder="Capacity" required>
      <input type="number" step="0.01" name="price" placeholder="Price" required>
      <select name="status">
        <option value="vacant">Vacant</option>
        <option value="occupied">Occupied</option>
      </select>
      <button type="submit" name="add_room" class="btn-primary">Add Room</button>
    </form>
  </div>
  <?php endforeach; ?>
<?php else: ?>
  <p><em>You haven't added any dorms yet.</em></p>
<?php endif; ?>
</div>

<style>
.add-dorm-form input, .add-dorm-form textarea, .add-dorm-form select {
  width: 100%;
  margin-bottom: 10px;
  padding: 8px;
  border-radius: 6px;
  border: 1px solid #ccc;
}
.badge { padding: 4px 8px; border-radius: 6px; color: #fff; font-size: 0.85em; }
.badge.success { background: #28a745; }
.badge.warning { background: #ffc107; color: #000; }
.badge.error { background: #dc3545; }
</style>

<?php include __DIR__ . '/../partials/footer.php'; ?>