<?php
require_once __DIR__ . '/../auth.php';
require_role('student');
require_once __DIR__ . '/../config.php';

$page_title = "Available Dorms";
include __DIR__ . '/../partials/header.php';

$flash = null;

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['book_room_id'])) {
    $room_id = intval($_POST['book_room_id']);
    $student_id = $_SESSION['user']['user_id'];
    $start_date = date('Y-m-d');
    $end_date = date('Y-m-d', strtotime('+6 months'));

    try {
        $stmt = $pdo->prepare("
            INSERT INTO bookings (room_id, student_id, start_date, end_date, status, created_at)
            VALUES (?, ?, ?, ?, 'pending', NOW())
        ");
        $stmt->execute([$room_id, $student_id, $start_date, $end_date]);

        $flash = ['type'=>'success','msg'=>'Booking request submitted successfully!'];
    } catch (Exception $e) {
        $flash = ['type'=>'error','msg'=>'Error: Could not complete booking.'];
    }
}

$search = trim($_GET['search'] ?? '');
$address = trim($_GET['address'] ?? '');

$sql = "
    SELECT d.dorm_id, d.name AS dorm_name, d.address, d.description,
           u.name AS owner_name
    FROM dormitories d
    JOIN users u ON d.owner_id = u.user_id
    WHERE 1=1
";
$params = [];

if ($search) {
    $sql .= " AND (d.name LIKE ? OR d.address LIKE ?)";
    $params[] = "%$search%";
    $params[] = "%$search%";
}

$stmt = $pdo->prepare($sql);
$stmt->execute($params);
$dorms = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

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

<div class="page-header">
  <p>Browse and filter dormitories with available rooms</p>
</div>

<div class="grid-2">
<?php foreach ($dorms as $dorm): ?>
  <div class="card">
    <h2><?=htmlspecialchars($dorm['dorm_name'])?></h2>
    <p><strong>Address:</strong> <?=htmlspecialchars($dorm['address'])?></p>
    <p><strong>Owner:</strong> <?=htmlspecialchars($dorm['owner_name'])?></p>
    <p><?=nl2br(htmlspecialchars($dorm['description']))?></p>

    <h3>Rooms</h3>
    <table>
      <thead>
        <tr>
          <th>Room Type</th>
          <th>Capacity</th>
          <th>Price (₱)</th>
          <th>Status</th>
          <th>Action</th>
        </tr>
      </thead>
      <tbody>
        <?php
        $room_sql = "SELECT * FROM rooms WHERE dorm_id = ?";
        $rooms = $pdo->prepare($room_sql);
        $rooms->execute([$dorm['dorm_id']]);
        $rooms = $rooms->fetchAll(PDO::FETCH_ASSOC);
        ?>
        <?php if ($rooms): ?>
          <?php foreach ($rooms as $room): ?>
          <tr>
            <td><?=htmlspecialchars($room['room_type'])?></td>
            <td><?=htmlspecialchars($room['capacity'])?></td>
            <td><?=number_format($room['price'], 2)?></td>
            <td>
              <?php if ($room['status'] === 'vacant'): ?>
                <span class="badge success">Vacant</span>
              <?php else: ?>
                <span class="badge error">Occupied</span>
              <?php endif; ?>
            </td>
            <td>
              <?php if ($room['status'] === 'vacant'): ?>
                <form method="POST" style="display:inline;">
                  <input type="hidden" name="book_room_id" value="<?= $room['room_id'] ?>">
                  <button type="submit" class="btn-primary">Book</button>
                </form>
              <?php else: ?>
                <em>N/A</em>
              <?php endif; ?>
            </td>
          </tr>
          <?php endforeach; ?>
        <?php else: ?>
          <tr><td colspan="5"><em>No rooms available</em></td></tr>
        <?php endif; ?>
      </tbody>
    </table>
  </div>
<?php endforeach; ?>
</div>

<?php include __DIR__ . '/../partials/footer.php'; ?>