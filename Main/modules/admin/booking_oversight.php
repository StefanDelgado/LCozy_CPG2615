<?php 
require_once __DIR__ . '/../../partials/header.php'; 
require_role(['admin','superadmin']);
require_once __DIR__ . '/../../config.php';

$page_title = "Booking & Reservation";
$flash = null;

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['edit_booking'])) {
        $booking_id = intval($_POST['booking_id']);
        $start_date = $_POST['start_date'];
        $end_date   = $_POST['end_date'];
        $status     = $_POST['status'];
        $notes      = trim($_POST['notes']);

        $pdo->beginTransaction();
        try {
            $stmt = $pdo->prepare("UPDATE bookings SET start_date=?, end_date=?, status=?, notes=? WHERE booking_id=?");
            $stmt->execute([$start_date, $end_date, $status, $notes, $booking_id]);

            $stmt = $pdo->prepare("SELECT room_id FROM bookings WHERE booking_id=?");
            $stmt->execute([$booking_id]);
            $room_id = $stmt->fetchColumn();

            if ($room_id) {
                if ($status === 'approved') {
                    $pdo->prepare("UPDATE rooms SET status='occupied' WHERE room_id=?")->execute([$room_id]);
                } elseif (in_array($status, ['cancelled','disapproved'])) {
                    $pdo->prepare("UPDATE rooms SET status='vacant' WHERE room_id=?")->execute([$room_id]);
                }
            }

            $pdo->commit();
            $flash = ['type'=>'success','msg'=>'Booking updated successfully!'];
        } catch (Exception $e) {
            $pdo->rollBack();
            $flash = ['type'=>'error','msg'=>'Error: Could not update booking.'];
        }
    }

    if (isset($_POST['delete_booking'])) {
        $booking_id = intval($_POST['booking_id']);

        $pdo->beginTransaction();
        try {
            $stmt = $pdo->prepare("SELECT room_id FROM bookings WHERE booking_id=?");
            $stmt->execute([$booking_id]);
            $room_id = $stmt->fetchColumn();

            $pdo->prepare("DELETE FROM bookings WHERE booking_id=?")->execute([$booking_id]);

            if ($room_id) {
                $pdo->prepare("UPDATE rooms SET status='vacant' WHERE room_id=?")->execute([$room_id]);
            }

            $pdo->commit();
            $flash = ['type'=>'error','msg'=>'Booking deleted successfully.'];
        } catch (Exception $e) {
            $pdo->rollBack();
            $flash = ['type'=>'error','msg'=>'Error: Could not delete booking.'];
        }
    }
}

$sql = "
    SELECT b.booking_id, b.status, b.start_date, b.end_date, b.notes,
           u.name AS student_name, d.name AS dorm_name
    FROM bookings b
    JOIN users u ON b.student_id = u.user_id
    JOIN rooms r ON b.room_id = r.room_id
    JOIN dormitories d ON r.dorm_id = d.dorm_id
    ORDER BY b.created_at DESC
";
$bookings = $pdo->query($sql)->fetchAll(PDO::FETCH_ASSOC);
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
  <h1>Bookings & Reservation</h1>
  <p>Monitor and manage all bookings</p>
</div>

<div class="stats-grid">
  <div class="stat-card">
    <h3><?= count(array_filter($bookings, fn($b) => $b['status']==='pending')) ?></h3>
    <p>Pending Requests</p>
  </div>
  <div class="stat-card">
    <h3><?= count($bookings) ?></h3>
    <p>Total Reservations</p>
  </div>
  <div class="stat-card">
    <h3>
      <?php 
      $approved = count(array_filter($bookings, fn($b) => $b['status']==='approved'));
      echo count($bookings) ? round(($approved / count($bookings)) * 100) . "%" : "0%";
      ?>
    </h3>
    <p>Approval Rate</p>
  </div>
  <div class="stat-card">
    <h3><?= count(array_filter($bookings, fn($b) => $b['status']==='cancelled')) ?></h3>
    <p>Cancellations</p>
  </div>
</div>

<div class="section">
  <h2>Manage Bookings</h2>
  <table class="data-table">
    <thead>
      <tr>
        <th>ID</th>
        <th>Student</th>
        <th>Dorm</th>
        <th>Start</th>
        <th>End</th>
        <th>Status</th>
        <th>Notes</th>
        <th>Actions</th>
      </tr>
    </thead>
    <tbody>
      <?php foreach ($bookings as $b): ?>
        <tr>
          <td><?= htmlspecialchars($b['booking_id']) ?></td>
          <td><?= htmlspecialchars($b['student_name']) ?></td>
          <td><?= htmlspecialchars($b['dorm_name']) ?></td>
          <td><?= htmlspecialchars($b['start_date']) ?></td>
          <td><?= htmlspecialchars($b['end_date']) ?></td>
          <td><span class="status <?= $b['status'] ?>"><?= ucfirst($b['status']) ?></span></td>
          <td><?= htmlspecialchars($b['notes'] ?? '') ?></td>
          <td>
            <button class="btn-primary" onclick="openEditModal(
              '<?= $b['booking_id'] ?>',
              '<?= $b['start_date'] ?>',
              '<?= $b['end_date'] ?>',
              '<?= $b['status'] ?>',
              '<?= htmlspecialchars($b['notes'] ?? '', ENT_QUOTES) ?>'
            )">Edit</button>

            <form method="post" style="display:inline" onsubmit="return confirm('Delete this booking?')">
              <input type="hidden" name="booking_id" value="<?= $b['booking_id'] ?>">
              <button class="btn-danger" name="delete_booking">Delete</button>
            </form>
          </td>
        </tr>
      <?php endforeach; ?>
    </tbody>
  </table>
</div>

<div id="editModal" class="modal" style="display:none;">
  <div class="modal-content">
    <h2>Edit Booking</h2>
    <form method="post">
      <input type="hidden" name="booking_id" id="edit_booking_id">
      <label>Start Date
        <input type="date" name="start_date" id="edit_start_date" required>
      </label>
      <label>End Date
        <input type="date" name="end_date" id="edit_end_date" required>
      </label>
      <label>Status
        <select name="status" id="edit_status" required>
          <option value="pending">Pending</option>
          <option value="approved">Approved</option>
          <option value="cancelled">Cancelled</option>
          <option value="disapproved">Disapproved</option>
        </select>
      </label>
      <label>Notes
        <textarea name="notes" id="edit_notes" rows="3" placeholder="Enter remarks..."></textarea>
      </label>
      <button type="submit" name="edit_booking" class="btn-primary">Save Changes</button>
      <button type="button" class="btn-secondary" onclick="closeEditModal()">Cancel</button>
    </form>
  </div>
</div>

<script>
function openEditModal(id, start, end, status, notes) {
  document.getElementById('edit_booking_id').value = id;
  document.getElementById('edit_start_date').value = start;
  document.getElementById('edit_end_date').value = end;
  document.getElementById('edit_status').value = status;
  document.getElementById('edit_notes').value = notes;
  document.getElementById('editModal').style.display = 'flex';
}
function closeEditModal() {
  document.getElementById('editModal').style.display = 'none';
}
</script>

<?php require_once __DIR__ . '/../../partials/footer.php'; ?>
