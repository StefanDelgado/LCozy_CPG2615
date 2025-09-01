<?php 
require_once __DIR__ . '/../partials/header.php'; 
require_role('admin');
require_once __DIR__ . '/../config.php';

$page_title = "Booking & Reservation";

$flash = null;

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['approve_id'])) {
        $booking_id = intval($_POST['approve_id']);

        $pdo->beginTransaction();
        try {
            $stmt = $pdo->prepare("UPDATE bookings SET status = 'approved' WHERE booking_id = ?");
            $stmt->execute([$booking_id]);

            $stmt = $pdo->prepare("SELECT room_id FROM bookings WHERE booking_id = ?");
            $stmt->execute([$booking_id]);
            $room_id = $stmt->fetchColumn();

            if ($room_id) {
                $stmt = $pdo->prepare("UPDATE rooms SET status = 'occupied' WHERE room_id = ?");
                $stmt->execute([$room_id]);
            }

            $pdo->commit();
            $flash = ['type'=>'success','msg'=>'Booking approved successfully!'];
        } catch (Exception $e) {
            $pdo->rollBack();
            $flash = ['type'=>'error','msg'=>'Error: Could not approve booking.'];
        }
    }

    if (isset($_POST['reject_id'])) {
        $booking_id = intval($_POST['reject_id']);

        $pdo->beginTransaction();
        try {
            $stmt = $pdo->prepare("UPDATE bookings SET status = 'rejected' WHERE booking_id = ?");
            $stmt->execute([$booking_id]);

            $stmt = $pdo->prepare("SELECT room_id FROM bookings WHERE booking_id = ?");
            $stmt->execute([$booking_id]);
            $room_id = $stmt->fetchColumn();

            if ($room_id) {
                $stmt = $pdo->prepare("UPDATE rooms SET status = 'vacant' WHERE room_id = ?");
                $stmt->execute([$room_id]);
            }

            $pdo->commit();
            $flash = ['type'=>'error','msg'=>'Booking rejected. Room returned to vacant.'];
        } catch (Exception $e) {
            $pdo->rollBack();
            $flash = ['type'=>'error','msg'=>'Error: Could not reject booking.'];
        }
    }
}

$sql = "
    SELECT b.booking_id, b.status, b.start_date, b.end_date,
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
  <p>Monitor reservation activities, booking trends, and review requests</p>
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
  <h2>Review Bookings</h2>
  <table class="data-table">
    <thead>
      <tr>
        <th>ID</th>
        <th>Student</th>
        <th>Dorm</th>
        <th>Start</th>
        <th>End</th>
        <th>Status</th>
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
          <td>
            <span class="status <?= $b['status'] ?>">
              <?= ucfirst($b['status']) ?>
            </span>
          </td>
          <td>
            <?php if ($b['status'] === 'pending'): ?>
              <form method="post" style="display:inline" onsubmit="return confirm('Approve this booking?')">
                <input type="hidden" name="approve_id" value="<?= $b['booking_id'] ?>">
                <button class="btn-primary">Approve</button>
              </form>
              <form method="post" style="display:inline" onsubmit="return confirm('Reject this booking?')">
                <input type="hidden" name="reject_id" value="<?= $b['booking_id'] ?>">
                <button class="btn-secondary">Reject</button>
              </form>
            <?php else: ?>
              <button class="btn-secondary" disabled>View</button>
            <?php endif; ?>
          </td>
        </tr>
      <?php endforeach; ?>
    </tbody>
  </table>
</div>

<?php require_once __DIR__ . '/../partials/footer.php'; ?>