<?php 
require_once __DIR__ . '/../partials/header.php'; 
require_role('owner');
require_once __DIR__ . '/../config.php';

$owner_id = $_SESSION['user']['user_id'];
$flash = null;

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['add_room'])) {
        $dorm_id = (int)$_POST['dorm_id'];
        $room_type = $_POST['room_type_select'] === 'Custom' ? trim($_POST['room_type']) : $_POST['room_type_select'];
        $capacity = (int)$_POST['capacity'];
        $price = (float)$_POST['price'];
        $status = $_POST['status'];

        $stmt = $pdo->prepare("SELECT COUNT(*) FROM dormitories WHERE dorm_id=? AND owner_id=?");
        $stmt->execute([$dorm_id, $owner_id]);
        if ($stmt->fetchColumn() > 0) {
            $stmt = $pdo->prepare("INSERT INTO rooms (dorm_id, room_type, capacity, price, status, created_at) VALUES (?, ?, ?, ?, ?, NOW())");
            $stmt->execute([$dorm_id, $room_type, $capacity, $price, $status]);
            $flash = ['type'=>'success','msg'=>'Room added successfully!'];
        }
    }

    if (isset($_POST['edit_room'])) {
        $id = (int)$_POST['room_id'];
        $room_type = $_POST['room_type_select'] === 'Custom' ? trim($_POST['room_type']) : $_POST['room_type_select'];
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

$sql = "
    SELECT r.room_id, r.room_type, r.capacity, r.price, r.status, 
           d.name AS dorm_name
    FROM rooms r
    JOIN dormitories d ON r.dorm_id = d.dorm_id
    WHERE d.owner_id = ?
";
$stmt = $pdo->prepare($sql);
$stmt->execute([$owner_id]);
$rooms = $stmt->fetchAll(PDO::FETCH_ASSOC);

$dorms = $pdo->prepare("SELECT dorm_id, name FROM dormitories WHERE owner_id=?");
$dorms->execute([$owner_id]);
$dorms = $dorms->fetchAll(PDO::FETCH_ASSOC);
?>

<div class="page-header">
  <h1>Dorm Room Management</h1>
  <p>Manage rooms in your dormitories</p>
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
<?php endif; ?>

<div class="section">
  <h2>Add Room</h2>
  <form method="post" class="form-inline">
    <select name="dorm_id" required>
      <option value="">Select Dorm</option>
      <?php foreach ($dorms as $d): ?>
        <option value="<?=$d['dorm_id']?>"><?=htmlspecialchars($d['name'])?></option>
      <?php endforeach; ?>
    </select>

    <select name="room_type_select" onchange="toggleCustomRoomType(this, 'customRoomTypeAdd', 'priceAdd')" required>
      <option value="">Select Room Type</option>
      <option value="Single">Single</option>
      <option value="Double">Double</option>
      <option value="Twin">Twin</option>
      <option value="Suite">Suite</option>
      <option value="Custom">Custom</option>
    </select>
    <input type="text" id="customRoomTypeAdd" name="room_type" placeholder="Custom Room Type" style="display:none;">

    <input type="number" name="capacity" placeholder="Capacity" required>
    <input type="number" step="0.01" id="priceAdd" name="price" placeholder="Price" required>
    <select name="status">
      <option value="vacant">Vacant</option>
      <option value="occupied">Occupied</option>
    </select>
    <button type="submit" name="add_room" class="btn-primary">Add Room</button>
  </form>
</div>

<div class="section">
  <h2>My Rooms</h2>
  <table class="data-table">
    <thead>
      <tr><th>ID</th><th>Type</th><th>Dorm</th><th>Capacity</th><th>Status</th><th>Price</th><th>Actions</th></tr>
    </thead>
    <tbody>
      <?php foreach ($rooms as $r): ?>
      <tr>
        <td><?=$r['room_id']?></td>
        <td><?=htmlspecialchars($r['room_type'])?></td>
        <td><?=htmlspecialchars($r['dorm_name'])?></td>
        <td><?=$r['capacity']?></td>
        <td>
          <?php if ($r['status']==='vacant'): ?>
            <span class="status pending">Vacant</span>
          <?php else: ?>
            <span class="status active">Occupied</span>
          <?php endif; ?>
        </td>
        <td>₱<?=number_format($r['price'],2)?></td>
        <td>
          <form method="post" style="display:inline-block">
            <input type="hidden" name="room_id" value="<?=$r['room_id']?>">

            <input type="text" name="room_type" value="<?=htmlspecialchars($r['room_type'])?>" required>
            <input type="number" name="capacity" value="<?=$r['capacity']?>" required>
            <input type="number" step="0.01" name="price" value="<?=$r['price']?>" required>
            <select name="status">
              <option value="vacant" <?=$r['status']==='vacant'?'selected':''?>>Vacant</option>
              <option value="occupied" <?=$r['status']==='occupied'?'selected':''?>>Occupied</option>
            </select>
            <button type="submit" name="edit_room" class="btn-secondary">Update</button>
          </form>

          <form method="post" style="display:inline-block" onsubmit="return confirm('Delete this room?')">
            <input type="hidden" name="room_id" value="<?=$r['room_id']?>"> 
            <button type="submit" name="delete_room" class="btn-danger">Delete</button>
          </form>
        </td>
      </tr>
      <?php endforeach; ?>
    </tbody>
  </table>
</div>

<?php require_once __DIR__ . '/../partials/footer.php'; ?>