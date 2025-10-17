<?php 
require_once __DIR__ . '/../partials/header.php'; 
require_role('owner');
require_once __DIR__ . '/../config.php';

$owner_id = $_SESSION['user']['user_id'];
$flash = null;

// ───── Handle Form Submissions ─────
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Add Room
    if (isset($_POST['add_room'])) {
        $dorm_id = (int)$_POST['dorm_id'];
        $room_type = $_POST['room_type_select'] === 'Custom' ? trim($_POST['room_type']) : $_POST['room_type_select'];
        $capacity = (int)$_POST['capacity'];
        $price = (float)$_POST['price'];
        $status = $_POST['status'];

        $stmt = $pdo->prepare("SELECT COUNT(*) FROM dormitories WHERE dorm_id=? AND owner_id=?");
        $stmt->execute([$dorm_id, $owner_id]);
        if ($stmt->fetchColumn() > 0) {
            $stmt = $pdo->prepare("INSERT INTO rooms (dorm_id, room_type, capacity, price, status, created_at)
                                   VALUES (?, ?, ?, ?, ?, NOW())");
            $stmt->execute([$dorm_id, $room_type, $capacity, $price, $status]);
            $flash = ['type'=>'success','msg'=>'Room added successfully!'];
        }
    }

    // Edit Room
    if (isset($_POST['edit_room'])) {
        $id = (int)$_POST['room_id'];
        $room_type = trim($_POST['room_type']);
        $capacity = (int)$_POST['capacity'];
        $price = (float)$_POST['price'];
        $status = $_POST['status'];

        $stmt = $pdo->prepare("
            UPDATE rooms r
            JOIN dormitories d ON r.dorm_id = d.dorm_id
            SET r.room_type=?, r.capacity=?, r.price=?, r.status=?
            WHERE r.room_id=? AND d.owner_id=?
        ");
        $stmt->execute([$room_type, $capacity, $price, $status, $id, $owner_id]);
        $flash = ['type'=>'success','msg'=>'Room updated successfully!'];
    }

    // Delete Room
    if (isset($_POST['delete_room'])) {
        $id = (int)$_POST['room_id'];
        $stmt = $pdo->prepare("
            DELETE r FROM rooms r
            JOIN dormitories d ON r.dorm_id = d.dorm_id
            WHERE r.room_id=? AND d.owner_id=?
        ");
        $stmt->execute([$id, $owner_id]);
        $flash = ['type'=>'error','msg'=>'Room deleted successfully!'];
    }
}

// ───── Fetch Data ─────
$stmt = $pdo->prepare("
    SELECT r.room_id, r.room_type, r.capacity, r.price, r.status, d.name AS dorm_name, r.dorm_id
    FROM rooms r
    JOIN dormitories d ON r.dorm_id = d.dorm_id
    WHERE d.owner_id = ?
    ORDER BY r.room_id DESC
");
$stmt->execute([$owner_id]);
$rooms = $stmt->fetchAll(PDO::FETCH_ASSOC);

$dorms = $pdo->prepare("SELECT dorm_id, name FROM dormitories WHERE owner_id=?");
$dorms->execute([$owner_id]);
$dorms = $dorms->fetchAll(PDO::FETCH_ASSOC);
?>

<div class="page-header">
  <h1>Dorm Room Management</h1>
  <button class="btn" onclick="openAddModal()">+ Add Room</button>
</div>

<?php if ($flash): ?>
  <div class="alert <?=$flash['type']?>"><?= htmlspecialchars($flash['msg']) ?></div>
<?php endif; ?>

<!-- Rooms Table -->
<div class="card">
  <h2>My Rooms</h2>
  <table class="data-table">
    <thead>
      <tr>
        <th>ID</th>
        <th>Type</th>
        <th>Dorm</th>
        <th>Capacity</th>
        <th>Status</th>
        <th>Price</th>
        <th>Actions</th>
      </tr>
    </thead>
    <tbody>
      <?php foreach ($rooms as $r): ?>
      <tr>
        <td><?= $r['room_id'] ?></td>
        <td><?= htmlspecialchars($r['room_type']) ?></td>
        <td><?= htmlspecialchars($r['dorm_name']) ?></td>
        <td><?= $r['capacity'] ?></td>
        <td>
          <span class="status <?= $r['status']==='vacant'?'pending':'active' ?>">
            <?= ucfirst($r['status']) ?>
          </span>
        </td>
        <td>₱<?= number_format($r['price'], 2) ?></td>
        <td>
          <button class="btn-secondary"
            onclick="openEditModal(
              '<?= $r['room_id'] ?>',
              '<?= htmlspecialchars($r['room_type'], ENT_QUOTES) ?>',
              '<?= $r['capacity'] ?>',
              '<?= $r['price'] ?>',
              '<?= $r['status'] ?>'
            )">Edit</button>

          <form method="post" style="display:inline-block" onsubmit="return confirm('Delete this room?')">
            <input type="hidden" name="room_id" value="<?= $r['room_id'] ?>">
            <button type="submit" name="delete_room" class="btn-danger">Delete</button>
          </form>
        </td>
      </tr>
      <?php endforeach; ?>
      <?php if (empty($rooms)): ?>
      <tr><td colspan="7" style="text-align:center;"><em>No rooms found</em></td></tr>
      <?php endif; ?>
    </tbody>
  </table>
</div>

<!-- ADD ROOM MODAL -->
<div id="addModal" class="modal">
  <div class="modal-content">
    <h2>Add New Room</h2>
    <form method="post" class="form-area">
      <div class="form-group">
        <label for="dorm_id">Dormitory</label>
        <select name="dorm_id" id="dorm_id" required>
          <option value="">Select Dorm</option>
          <?php foreach ($dorms as $d): ?>
            <option value="<?= $d['dorm_id'] ?>"><?= htmlspecialchars($d['name']) ?></option>
          <?php endforeach; ?>
        </select>
      </div>

      <div class="form-group">
        <label for="room_type_select">Room Type</label>
        <select name="room_type_select" id="room_type_select" onchange="toggleCustomRoomType(this, 'customRoomTypeAdd')" required>
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
        <label for="capacity">Capacity</label>
        <input type="number" id="capacity" name="capacity" min="1" required>
      </div>

      <div class="form-group">
        <label for="price">Price (₱)</label>
        <input type="number" id="price" name="price" step="0.01" required>
      </div>

      <div class="form-group">
        <label for="status">Status</label>
        <select name="status" id="status">
          <option value="vacant">Vacant</option>
          <option value="occupied">Occupied</option>
        </select>
      </div>

      <div class="modal-actions">
        <button type="submit" name="add_room" class="btn">Add Room</button>
        <button type="button" class="btn-secondary" onclick="closeAddModal()">Cancel</button>
      </div>
    </form>
  </div>
</div>


<!-- EDIT ROOM MODAL -->
<div id="editModal" class="modal">
  <div class="modal-content">
    <h2>Edit Room</h2>
    <form method="post" class="form-area">
      <input type="hidden" name="room_id" id="edit_room_id">

      <div class="form-group">
        <label for="edit_room_type">Room Type</label>
        <input type="text" id="edit_room_type" name="room_type" required>
      </div>

      <div class="form-group">
        <label for="edit_capacity">Capacity</label>
        <input type="number" id="edit_capacity" name="capacity" min="1" required>
      </div>

      <div class="form-group">
        <label for="edit_price">Price (₱)</label>
        <input type="number" id="edit_price" name="price" step="0.01" required>
      </div>

      <div class="form-group">
        <label for="edit_status">Status</label>
        <select id="edit_status" name="status">
          <option value="vacant">Vacant</option>
          <option value="occupied">Occupied</option>
        </select>
      </div>

      <div class="modal-actions">
        <button type="submit" name="edit_room" class="btn">Save Changes</button>
        <button type="button" class="btn-secondary" onclick="closeEditModal()">Cancel</button>
      </div>
    </form>
  </div>
</div>

<script>
function openAddModal() {
  document.getElementById('addModal').style.display = 'flex';
}
function closeAddModal() {
  document.getElementById('addModal').style.display = 'none';
}

function openEditModal(id, type, capacity, price, status) {
  document.getElementById('edit_room_id').value = id;
  document.getElementById('edit_room_type').value = type;
  document.getElementById('edit_capacity').value = capacity;
  document.getElementById('edit_price').value = price;
  document.getElementById('edit_status').value = status;
  document.getElementById('editModal').style.display = 'flex';
}
function closeEditModal() {
  document.getElementById('editModal').style.display = 'none';
}

function toggleCustomRoomType(select, inputId) {
  const input = document.getElementById(inputId);
  input.style.display = (select.value === 'Custom') ? 'block' : 'none';
  if(select.value !== 'Custom') input.value = select.value;
}
</script>

<?php require_once __DIR__ . '/../partials/footer.php'; ?>
