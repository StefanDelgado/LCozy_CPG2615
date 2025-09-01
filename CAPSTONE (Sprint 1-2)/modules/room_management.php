<?php 
require_once __DIR__ . '/../partials/header.php'; 
require_role('admin');
require_once __DIR__ . '/../config.php';

$flash = null;

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['add_room'])) {
        $dorm_id = (int)$_POST['dorm_id'];
        $room_type = $_POST['room_type_select'] === 'Custom' ? trim($_POST['room_type']) : $_POST['room_type_select'];
        $capacity = (int)$_POST['capacity'];
        $price = (float)$_POST['price'];
        $status = $_POST['status'];

        $stmt = $pdo->prepare("INSERT INTO rooms (dorm_id, room_type, capacity, price, status, created_at) VALUES (?, ?, ?, ?, ?, NOW())");
        $stmt->execute([$dorm_id, $room_type, $capacity, $price, $status]);

        $flash = ['type'=>'success','msg'=>'Room added successfully!'];
    }

    if (isset($_POST['edit_room'])) {
        $id = (int)$_POST['room_id'];
        $room_type = $_POST['room_type_select'] === 'Custom' ? trim($_POST['room_type']) : $_POST['room_type_select'];
        $capacity = (int)$_POST['capacity'];
        $price = (float)$_POST['price'];
        $status = $_POST['status'];

        $stmt = $pdo->prepare("UPDATE rooms SET room_type=?, capacity=?, price=?, status=? WHERE room_id=?");
        $stmt->execute([$room_type, $capacity, $price, $status, $id]);

        $flash = ['type'=>'success','msg'=>'Room updated successfully!'];
    }

    if (isset($_POST['delete_room'])) {
        $id = (int)$_POST['room_id'];
        $stmt = $pdo->prepare("DELETE FROM rooms WHERE room_id=?");
        $stmt->execute([$id]);

        $flash = ['type'=>'error','msg'=>'Room deleted successfully!'];
    }
}

$sql = "
    SELECT r.room_id, r.room_type, r.capacity, r.price, r.status, 
           d.name AS dorm_name, u.name AS owner_name
    FROM rooms r
    JOIN dormitories d ON r.dorm_id = d.dorm_id
    JOIN users u ON d.owner_id = u.user_id
";
$rooms = $pdo->query($sql)->fetchAll(PDO::FETCH_ASSOC);

$dorms = $pdo->query("SELECT dorm_id, name FROM dormitories")->fetchAll(PDO::FETCH_ASSOC);
?>

<div class="page-header">
  <h1>Dorm Room Management</h1>
  <p>Manage available rooms, pricing, and status</p>
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

<div class="section">
  <h2>Add Room</h2>
  <form method="post" class="form-inline">
    <select name="dorm_id" required>
      <option value="">Select Dorm</option>
      <?php foreach ($dorms as $d): ?>
        <option value="<?=$d['dorm_id']?>"><?=htmlspecialchars($d['name'])?></option>
      <?php endforeach; ?>
    </select>

    <select id="roomTypeSelectAdd" name="room_type_select" onchange="toggleCustomRoomType(this, 'customRoomTypeAdd', 'priceAdd')" required>
      <option value="">Select Room Type</option>
      <option value="Single">Single</option>
      <option value="Double">Double</option>
      <option value="Shared">Shared</option>
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
  <h2>Rooms</h2>
  <table class="data-table">
    <thead>
      <tr><th>ID</th><th>Type</th><th>Owner</th><th>Dorm</th><th>Capacity</th><th>Status</th><th>Price</th><th>Actions</th></tr>
    </thead>
    <tbody>
      <?php foreach ($rooms as $r): ?>
      <tr>
        <td><?=$r['room_id']?></td>
        <td><?=htmlspecialchars($r['room_type'])?></td>
        <td><?=htmlspecialchars($r['owner_name'])?></td>
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

            <select onchange="toggleCustomRoomType(this, 'customRoomTypeEdit<?=$r['room_id']?>', 'priceEdit<?=$r['room_id']?>')" name="room_type_select">
              <option value="Single" <?=$r['room_type']==='Single'?'selected':''?>>Single</option>
              <option value="Double" <?=$r['room_type']==='Double'?'selected':''?>>Double</option>
              <option value="Shared" <?=$r['room_type']==='Shared'?'selected':''?>>Shared</option>
              <option value="Suite" <?=$r['room_type']==='Suite'?'selected':''?>>Suite</option>
              <option value="Custom" <?=(!in_array($r['room_type'], ['Single','Double','Shared','Suite'])?'selected':'')?>>Custom</option>
            </select>
            <input type="text" id="customRoomTypeEdit<?=$r['room_id']?>" name="room_type" value="<?=(!in_array($r['room_type'], ['Single','Double','Shared','Suite'])?htmlspecialchars($r['room_type']):'')?>" placeholder="Custom Room Type" style="<?=(!in_array($r['room_type'], ['Single','Double','Shared','Suite'])?'display:inline-block':'display:none')?>">

            <input type="number" name="capacity" value="<?=$r['capacity']?>" required>
            <input type="number" step="0.01" id="priceEdit<?=$r['room_id']?>" name="price" value="<?=$r['price']?>" required>
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

<script>
const defaultPrices = {
  "Single": 5000,
  "Double": 8000,
  "Shared": 3000,
  "Suite": 12000
};

function toggleCustomRoomType(select, inputId, priceId) {
    const customInput = document.getElementById(inputId);
    const priceInput = document.getElementById(priceId);
    if (select.value === "Custom") {
        customInput.style.display = "inline-block";
        customInput.required = true;
        if(priceInput) priceInput.value = "";
    } else {
        customInput.style.display = "none";
        customInput.required = false;
        customInput.value = select.value;
        if(priceInput && defaultPrices[select.value]){
          priceInput.value = defaultPrices[select.value];
        }
    }
}
</script>

<?php require_once __DIR__ . '/../partials/footer.php'; ?>