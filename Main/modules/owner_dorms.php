<?php
require_once __DIR__ . '/../auth.php';
require_role('owner');
require_once __DIR__ . '/../config.php';

$page_title = "My Dormitories";
include __DIR__ . '/../partials/header.php';

$owner_id = $_SESSION['user']['user_id'];
$flash = null;

// ─── Add Dormitory ───
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

// ─── Add Room ───
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['add_room'])) {
    $dorm_id = (int)$_POST['dorm_id'];
    $room_type = $_POST['room_type_select'] === 'Custom' ? trim($_POST['room_type']) : $_POST['room_type_select'];
    $capacity = (int)$_POST['capacity'];
    $size = trim($_POST['size']);
    $price = (float)$_POST['price'];
    $status = $_POST['status'];

    $stmt = $pdo->prepare("INSERT INTO rooms (dorm_id, room_type, capacity, size, price, status, created_at)
                           VALUES (?, ?, ?, ?, ?, ?, NOW())");
    $stmt->execute([$dorm_id, $room_type, $capacity, $size, $price, $status]);
    $room_id = $pdo->lastInsertId();

    // multiple images
    if (!empty($_FILES['room_images']['name'][0])) {
        $upload_dir = __DIR__ . '/../uploads/';
        if (!file_exists($upload_dir)) mkdir($upload_dir, 0777, true);
        foreach ($_FILES['room_images']['tmp_name'] as $i => $tmp) {
            $ext = strtolower(pathinfo($_FILES['room_images']['name'][$i], PATHINFO_EXTENSION));
            if (in_array($ext, ['jpg','jpeg','png'])) {
                $filename = uniqid('room_') . '.' . $ext;
                move_uploaded_file($tmp, $upload_dir . $filename);
                $pdo->prepare("INSERT INTO room_images (room_id, image_path, uploaded_at) VALUES (?, ?, NOW())")
                    ->execute([$room_id, $filename]);
            }
        }
    }

    $flash = ['type'=>'success','msg'=>'Room added successfully!'];
}

// ─── Fetch Dorms ───
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
  <p>Manage your dorm listings and rooms here.</p>
  <button class="btn" onclick="openModal('addDormModal')">+ Add Dormitory</button>
</div>

<?php if ($flash): ?>
<div class="alert <?= $flash['type'] ?>"><?= htmlspecialchars($flash['msg']) ?></div>
<?php endif; ?>

<div class="grid-2">
<?php if ($dorms): ?>
  <?php foreach ($dorms as $dorm): ?>
  <div class="card">
    <h2><?= htmlspecialchars($dorm['name']) ?></h2>

    <?php if (!empty($dorm['cover_image'])): ?>
      <img src="../uploads/<?= htmlspecialchars($dorm['cover_image']) ?>" 
           alt="<?= htmlspecialchars($dorm['name']) ?>" 
           style="width:100%;max-height:200px;object-fit:cover;border-radius:8px;margin-bottom:10px;">
    <?php else: ?>
      <div class="no-img">No Image</div>
    <?php endif; ?>

    <p><strong>Address:</strong> <?= htmlspecialchars($dorm['address']) ?></p>
    <p><?= nl2br(htmlspecialchars($dorm['description'])) ?></p>
    <p><strong>Features:</strong> <?= htmlspecialchars($dorm['features'] ?: 'None listed') ?></p>

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
        <tr><th>Image</th><th>Type</th><th>Size</th><th>Occupancy</th><th>Price</th><th>Status</th></tr>
      </thead>
      <tbody>
        <?php
        $room_stmt = $pdo->prepare("
          SELECT r.*, 
                 (SELECT COUNT(*) FROM bookings b WHERE b.room_id = r.room_id AND b.status IN ('approved','active')) AS occupants
          FROM rooms r 
          WHERE r.dorm_id = ?
        ");
        $room_stmt->execute([$dorm['dorm_id']]);
        $rooms = $room_stmt->fetchAll(PDO::FETCH_ASSOC);
        ?>
        <?php if ($rooms): foreach ($rooms as $r): ?>
          <?php
            $img_stmt = $pdo->prepare("SELECT image_path FROM room_images WHERE room_id=? LIMIT 1");
            $img_stmt->execute([$r['room_id']]);
            $room_img = $img_stmt->fetchColumn();
          ?>
          <tr>
            <td>
              <?php if ($room_img): ?>
                <img src="../uploads/<?= htmlspecialchars($room_img) ?>" style="width:50px;height:50px;border-radius:6px;object-fit:cover;">
              <?php else: ?><span style="color:#777;">No Img</span><?php endif; ?>
            </td>
            <td><?= htmlspecialchars($r['room_type']) ?></td>
            <td><?= !empty($r['size']) ? htmlspecialchars($r['size']).' sqm' : '—' ?></td>
            <td><?= intval($r['occupants']) ?> / <?= intval($r['capacity']) ?></td>
            <td>₱<?= number_format($r['price'],2) ?></td>
            <td>
              <?php if ($r['occupants'] >= $r['capacity']): ?>
                <span class="badge error">Full</span>
              <?php elseif ($r['status']==='vacant'): ?>
                <span class="badge success">Vacant</span>
              <?php else: ?>
                <span class="badge warning">Occupied</span>
              <?php endif; ?>
            </td>
          </tr>
        <?php endforeach; else: ?>
          <tr><td colspan="6"><em>No rooms listed</em></td></tr>
        <?php endif; ?>
      </tbody>
    </table>

    <button class="btn-secondary" onclick="openRoomModal(<?= $dorm['dorm_id'] ?>, '<?= htmlspecialchars($dorm['name'], ENT_QUOTES) ?>')">+ Add Room</button>
  </div>
  <?php endforeach; ?>
<?php else: ?>
  <p><em>You haven’t added any dorms yet.</em></p>
<?php endif; ?>
</div>

<!-- ADD DORM MODAL -->
<div id="addDormModal" class="modal">
  <div class="modal-content">
    <h2>Add New Dormitory</h2>
    <form method="post" enctype="multipart/form-data" class="form-area">
      <div class="form-group">
        <label>Dorm Name</label>
        <input type="text" name="name" required>
      </div>
      <div class="form-group">
        <label>Address</label>
        <input type="text" name="address" required>
      </div>
      <div class="form-group">
        <label>Description</label>
        <textarea name="description" rows="3" required></textarea>
      </div>
      <div class="form-group">
        <label>Features (comma separated)</label>
        <input type="text" name="features" placeholder="WiFi, Aircon, Laundry, etc.">
      </div>
      <div class="form-group">
        <label>Cover Image</label>
        <input type="file" name="cover_image" accept=".jpg,.jpeg,.png">
      </div>
      <div class="modal-actions">
        <button type="submit" name="add_dorm" class="btn">Add Dormitory</button>
        <button type="button" class="btn-secondary" onclick="closeModal('addDormModal')">Cancel</button>
      </div>
    </form>
  </div>
</div>

<!-- ADD ROOM MODAL -->
<div id="addRoomModal" class="modal">
  <div class="modal-content">
    <h2>Add New Room</h2>
    <form method="post" enctype="multipart/form-data" class="form-area">
      <input type="hidden" name="dorm_id" id="room_dorm_id">

      <div class="form-group">
        <label>Dormitory</label>
        <input type="text" id="room_dorm_name" readonly>
      </div>

      <div class="form-group">
        <label>Room Type</label>
        <select name="room_type_select" onchange="toggleCustomRoomType(this, 'customRoomTypeAdd')" required>
          <option value="">Select Room Type</option>
          <option value="Single">Single</option>
          <option value="Double">Double</option>
          <option value="Twin">Twin</option>
          <option value="Suite">Suite</option>
          <option value="Custom">Custom</option>
        </select>
        <input type="text" id="customRoomTypeAdd" name="room_type" placeholder="Custom Room Type" style="display:none;">
      </div>

      <div class="form-group">
        <label>Room Size (sqm)</label>
        <input type="number" name="size" step="0.1" placeholder="e.g. 15.5">
      </div>

      <div class="form-group">
        <label>Capacity</label>
        <input type="number" name="capacity" min="1" required>
      </div>

      <div class="form-group">
        <label>Price (₱)</label>
        <input type="number" step="0.01" name="price" required>
      </div>

      <div class="form-group">
        <label>Status</label>
        <select name="status">
          <option value="vacant">Vacant</option>
          <option value="occupied">Occupied</option>
        </select>
      </div>

      <div class="form-group">
        <label>Room Images (multiple)</label>
        <input type="file" name="room_images[]" accept=".jpg,.jpeg,.png" multiple>
      </div>

      <div class="modal-actions">
        <button type="submit" name="add_room" class="btn">Add Room</button>
        <button type="button" class="btn-secondary" onclick="closeModal('addRoomModal')">Cancel</button>
      </div>
    </form>
  </div>
</div>

<script>
function openModal(id) {
  document.getElementById(id).style.display = 'flex';
}
function closeModal(id) {
  document.getElementById(id).style.display = 'none';
}
function openRoomModal(dormId, dormName) {
  document.getElementById('addRoomModal').style.display = 'flex';
  document.getElementById('room_dorm_id').value = dormId;
  document.getElementById('room_dorm_name').value = dormName;
}
function toggleCustomRoomType(select, id) {
  const custom = document.getElementById(id);
  custom.style.display = select.value === 'Custom' ? 'block' : 'none';
}
</script>

<style>
.no-img {
  width:100%;height:200px;background:#eee;
  display:flex;align-items:center;justify-content:center;
  border-radius:8px;color:#777;
}
.badge { padding:4px 8px;border-radius:6px;font-size:0.85em;color:#fff; }
.badge.success { background:#28a745; }
.badge.warning { background:#ffc107;color:#000; }
.badge.error { background:#dc3545; }

.modal { display:none;position:fixed;inset:0;background:rgba(0,0,0,0.5);
  justify-content:center;align-items:center;z-index:9999; }
.modal-content { background:#fff;padding:20px;border-radius:10px;width:400px;max-width:90%; }
.form-group { margin-bottom:10px; }
.modal-actions { text-align:right;margin-top:10px; }
</style>

<?php include __DIR__ . '/../partials/footer.php'; ?>