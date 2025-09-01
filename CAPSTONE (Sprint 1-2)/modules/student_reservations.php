<?php
require_once __DIR__ . '/../auth.php';
require_role('student');
require_once __DIR__ . '/../config.php';

$page_title = "My Reservations";
include __DIR__ . '/../partials/header.php';

$student_id = $_SESSION['user']['user_id'];
$flash = null;

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['cancel_booking_id'])) {
    $booking_id = intval($_POST['cancel_booking_id']);

    $pdo->beginTransaction();
    try {
        $stmt = $pdo->prepare("SELECT room_id FROM bookings WHERE booking_id = ? AND student_id = ?");
        $stmt->execute([$booking_id, $student_id]);
        $room_id = $stmt->fetchColumn();

        if ($room_id) {
            $stmt = $pdo->prepare("UPDATE bookings SET status = 'cancelled' WHERE booking_id = ? AND student_id = ?");
            $stmt->execute([$booking_id, $student_id]);

            $stmt = $pdo->prepare("UPDATE rooms SET status = 'vacant' WHERE room_id = ?");
            $stmt->execute([$room_id]);
        }

        $pdo->commit();
        $flash = ['type'=>'success','msg'=>'Reservation cancelled successfully. Room is now available.'];
    } catch (Exception $e) {
        $pdo->rollBack();
        $flash = ['type'=>'error','msg'=>'Error: Could not cancel reservation.'];
    }
}

$sql = "
    SELECT b.booking_id, b.start_date, b.end_date, b.status AS booking_status,
           r.room_type, r.price, r.status AS room_status,
           d.name AS dorm_name,
           u.name AS owner_name
    FROM bookings b
    JOIN rooms r ON b.room_id = r.room_id
    JOIN dormitories d ON r.dorm_id = d.dorm_id
    JOIN users u ON d.owner_id = u.user_id
    WHERE b.student_id = ?
    ORDER BY b.created_at DESC
";
$stmt = $pdo->prepare($sql);
$stmt->execute([$student_id]);
$reservations = $stmt->fetchAll(PDO::FETCH_ASSOC);
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
  <p>Track your active and past dorm room reservations</p>
</div>

<?php if ($reservations): ?>
  <table class="data-table">
    <thead>
      <tr>
        <th>Dorm</th>
        <th>Room</th>
        <th>Owner</th>
        <th>Price</th>
        <th>Booking Status</th>
        <th>Room Status</th>
        <th>Check-in</th>
        <th>Check-out</th>
        <th>Action</th>
      </tr>
    </thead>
    <tbody>
      <?php foreach ($reservations as $res): ?>
      <tr>
        <td><?= htmlspecialchars($res['dorm_name']) ?></td>
        <td><?= htmlspecialchars($res['room_type']) ?></td>
        <td><?= htmlspecialchars($res['owner_name']) ?></td>
        <td>₱<?= number_format($res['price'], 2) ?></td>
        <td>
          <?php if ($res['booking_status'] === 'pending'): ?>
            <span class="badge warning">Pending</span>
          <?php elseif ($res['booking_status'] === 'approved'): ?>
            <span class="badge success">Approved</span>
          <?php elseif ($res['booking_status'] === 'rejected'): ?>
            <span class="badge error">Rejected</span>
          <?php elseif ($res['booking_status'] === 'cancelled'): ?>
            <span class="badge">Cancelled</span>
          <?php else: ?>
            <span class="badge"><?= htmlspecialchars($res['booking_status']) ?></span>
          <?php endif; ?>
        </td>
        <td>
          <?php if ($res['room_status'] === 'vacant'): ?>
            <span class="badge success">Vacant</span>
          <?php else: ?>
            <span class="badge error">Occupied</span>
          <?php endif; ?>
        </td>
        <td><?= htmlspecialchars($res['start_date']) ?></td>
        <td><?= htmlspecialchars($res['end_date']) ?></td>
        <td>
          <?php if (in_array($res['booking_status'], ['pending','approved'])): ?>
            <form method="POST" onsubmit="return confirm('Cancel this reservation?');">
              <input type="hidden" name="cancel_booking_id" value="<?= $res['booking_id'] ?>">
              <button type="submit" class="btn-danger">Cancel</button>
            </form>
          <?php else: ?>
            <em>N/A</em>
          <?php endif; ?>
        </td>
      </tr>
      <?php endforeach; ?>
    </tbody>
  </table>
<?php else: ?>
  <p><em>You don’t have any reservations yet.</em></p>
<?php endif; ?>

<?php include __DIR__ . '/../partials/footer.php'; ?>