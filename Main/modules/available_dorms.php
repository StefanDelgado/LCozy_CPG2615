<?php
require_once __DIR__ . '/../auth.php';
require_role('student');
require_once __DIR__ . '/../config.php';

$page_title = "Available Dorms";
include __DIR__ . '/../partials/header.php';

$flash = null;
$student_id = $_SESSION['user']['user_id'];

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['book_room_id'])) {
    $room_id = intval($_POST['book_room_id']);
    $share_choice = $_POST['booking_type'];
    $start_date = date('Y-m-d');
    $end_date = date('Y-m-d', strtotime('+6 months'));
    $expires_at = date('Y-m-d H:i:s', strtotime('+2 hours'));

    $check = $pdo->prepare("
        SELECT r.capacity, r.status,
               COUNT(b.booking_id) AS total_booked
        FROM rooms r
        LEFT JOIN bookings b ON b.room_id = r.room_id AND b.status IN ('pending','approved')
        WHERE r.room_id = ?
        GROUP BY r.room_id
    ");
    $check->execute([$room_id]);
    $room_info = $check->fetch(PDO::FETCH_ASSOC);

    if (!$room_info) {
        $flash = ['type' => 'error', 'msg' => 'Room not found.'];
    } elseif ($room_info['status'] === 'occupied') {
        $flash = ['type' => 'error', 'msg' => 'Room is already occupied.'];
    } elseif ($room_info['total_booked'] >= $room_info['capacity']) {
        $flash = ['type' => 'error', 'msg' => 'Room is already fully booked.'];
    } else {
        try {
            if ($share_choice === 'whole' && $room_info['total_booked'] > 0) {
                throw new Exception('Cannot book whole room — it already has other tenants.');
            }

            $stmt = $pdo->prepare("
                INSERT INTO bookings (room_id, student_id, booking_type, start_date, end_date, status, created_at, expires_at)
                VALUES (?, ?, ?, ?, ?, 'pending', NOW(), ?)
            ");
            $stmt->execute([$room_id, $student_id, $share_choice, $start_date, $end_date, $expires_at]);

            $flash = [
                'type' => 'success',
                'msg' => 'Booking request submitted! Please upload your payment receipt within 2 hours.'
            ];
        } catch (Exception $e) {
            $flash = ['type' => 'error', 'msg' => $e->getMessage()];
        }
    }
}

$search = trim($_GET['search'] ?? '');
$params = [];

$sql = "
    SELECT d.dorm_id, d.name AS dorm_name, d.address, d.description, d.cover_image,
           u.name AS owner_name,
           COALESCE(AVG(r.rating), 0) AS avg_rating,
           COUNT(r.review_id) AS total_reviews
    FROM dormitories d
    JOIN users u ON d.owner_id = u.user_id
    LEFT JOIN reviews r ON d.dorm_id = r.dorm_id AND r.status = 'approved'
    WHERE 1=1
";

if ($search) {
    $sql .= " AND (d.name LIKE ? OR d.address LIKE ?)";
    $params[] = "%$search%";
    $params[] = "%$search%";
}

$sql .= " GROUP BY d.dorm_id ORDER BY avg_rating DESC, d.name ASC";

$stmt = $pdo->prepare($sql);
$stmt->execute($params);
$dorms = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

<?php if ($flash): ?>
<div id="flashModal" class="flash-modal <?= $flash['type'] ?>" onclick="closeFlash()">
  <div class="flash-content" onclick="event.stopPropagation();">
    <p><?= htmlspecialchars($flash['msg']) ?></p>
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
  <p>Browse and book dorm rooms — choose whole or shared booking.</p>
</div>

<div class="grid-2">
<?php foreach ($dorms as $dorm): ?>
  <div class="card">

    <?php if (!empty($dorm['cover_image']) && file_exists(__DIR__ . '/../uploads/' . $dorm['cover_image'])): ?>
      <img src="../uploads/<?= htmlspecialchars($dorm['cover_image']) ?>" 
           alt="<?= htmlspecialchars($dorm['dorm_name']) ?>" 
           class="dorm-image">
    <?php else: ?>
      <div class="no-image">
        <span>No Image Available</span>
      </div>
    <?php endif; ?>

    <h2><?= htmlspecialchars($dorm['dorm_name']) ?></h2>
    <p><strong>Address:</strong> <?= htmlspecialchars($dorm['address']) ?></p>
    <p><strong>Owner:</strong> <?= htmlspecialchars($dorm['owner_name']) ?></p>
    <p><?= nl2br(htmlspecialchars($dorm['description'])) ?></p>

    <div class="rating">
      <?php if ($dorm['total_reviews'] > 0): ?>
        <?php
          $stars = str_repeat("⭐", round($dorm['avg_rating']));
          if ($dorm['avg_rating'] < 5) $stars .= str_repeat("☆", 5 - round($dorm['avg_rating']));
        ?>
        <?= $stars ?> (<?= number_format($dorm['avg_rating'], 1) ?>/5)
        <small><?= $dorm['total_reviews'] ?> reviews</small>
      <?php else: ?>
        <em>No reviews yet</em>
      <?php endif; ?>
    </div>

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
        $room_sql = "
          SELECT r.*, 
            (SELECT COUNT(*) FROM bookings b 
             WHERE b.room_id = r.room_id AND b.status IN ('pending','approved')) AS booked_count
          FROM rooms r
          WHERE r.dorm_id = ?
        ";
        $rooms = $pdo->prepare($room_sql);
        $rooms->execute([$dorm['dorm_id']]);
        $rooms = $rooms->fetchAll(PDO::FETCH_ASSOC);
        ?>

        <?php if ($rooms): ?>
          <?php foreach ($rooms as $room): 
            $available_slots = $room['capacity'] - $room['booked_count'];
          ?>
          <tr>
            <td><?= htmlspecialchars($room['room_type']) ?></td>
            <td><?= htmlspecialchars($room['capacity']) ?></td>
            <td><?= number_format($room['price'], 2) ?></td>
            <td>
              <?php if ($available_slots > 0): ?>
                <span class="badge success">Available (<?= $available_slots ?> left)</span>
              <?php else: ?>
                <span class="badge error">Full</span>
              <?php endif; ?>
            </td>
            <td>
              <?php if ($available_slots > 0): ?>
                <form method="POST" style="display:inline;">
                  <input type="hidden" name="book_room_id" value="<?= $room['room_id'] ?>">
                  <label>
                    <select name="booking_type" required>
                      <option value="">Select Type</option>
                      <option value="whole">Whole Room</option>
                      <option value="shared">Shared</option>
                    </select>
                  </label>
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

<style>
.rating { margin: 8px 0; font-weight: bold; color: #ff9800; }
.badge { padding: 4px 8px; border-radius: 6px; font-size: 0.9em; color: #fff; }
.badge.success { background: #08ee3e; }
.badge.error { background: #dc3545; }
select { padding: 4px; border-radius: 5px; }

.dorm-image {
  width: 100%;
  height: 200px;
  object-fit: cover;
  border-radius: 10px;
  margin-bottom: 10px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  transition: transform 0.3s ease;
}
.dorm-image:hover { transform: scale(1.03); }
.no-image {
  width: 100%;
  height: 200px;
  background: #f1f1f1;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #888;
  font-size: 0.9em;
  border-radius: 10px;
  margin-bottom: 10px;
}
</style>

<?php include __DIR__ . '/../partials/footer.php'; ?>