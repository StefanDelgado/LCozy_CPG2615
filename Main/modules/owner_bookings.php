<?php
require_once __DIR__ . '/../auth.php';
require_role('owner');
require_once __DIR__ . '/../config.php';

// ---- DEBUG MODE ----
if (isset($pdo) && $pdo instanceof PDO) {
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
}
define('APP_DEBUG', true);
if (APP_DEBUG) {
    ini_set('display_errors', '1');
    ini_set('display_startup_errors', '1');
    error_reporting(E_ALL);
}

$page_title = "Bookings";
include __DIR__ . '/../partials/header.php';

$owner_id = $_SESSION['user']['user_id'] ?? 0;

// ─── Handle Approve/Reject ───
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['booking_id'])) {
    $booking_id = (int)$_POST['booking_id'];
    $new_status = isset($_POST['approve_booking']) ? 'approved' : 'rejected';

    try {
        $pdo->beginTransaction();

        // Validate owner access
        $stmt = $pdo->prepare("
            SELECT b.*, r.price, u.user_id AS student_id, b.start_date
            FROM bookings b
            JOIN rooms r ON b.room_id = r.room_id
            JOIN dormitories d ON r.dorm_id = d.dorm_id
            JOIN users u ON b.student_id = u.user_id
            WHERE b.booking_id = ? AND d.owner_id = ?
        ");
        $stmt->execute([$booking_id, $owner_id]);
        $booking = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($booking) {
            // Update booking status
            $update = $pdo->prepare("UPDATE bookings SET status = LOWER(?), updated_at = NOW() WHERE booking_id = ?");
            $update->execute([$new_status, $booking_id]);

            // If approved, insert pending payment if not existing
            if ($new_status === 'approved') {
                $amount = $booking['price'] ?? 0;
                $student_id = $booking['student_id'];
                $due_date = $booking['start_date'] ?? date('Y-m-d', strtotime('+7 days'));

                $check = $pdo->prepare("SELECT COUNT(*) FROM payments WHERE booking_id = ?");
                $check->execute([$booking_id]);
                if ($check->fetchColumn() == 0) {
                    $insert = $pdo->prepare("
                        INSERT INTO payments (booking_id, student_id, amount, status, due_date, created_at)
                        VALUES (?, ?, ?, 'pending', ?, NOW())
                    ");
                    $insert->execute([$booking_id, $student_id, $amount, $due_date]);
                }

                $_SESSION['flash'] = ['type' => 'success', 'msg' => 'Booking approved and payment reminder created.'];
            } else {
                $_SESSION['flash'] = ['type' => 'success', 'msg' => 'Booking rejected successfully.'];
            }
        } else {
            $_SESSION['flash'] = ['type' => 'error', 'msg' => 'Booking not found or unauthorized.'];
        }

        $pdo->commit();
    } catch (Exception $e) {
        if ($pdo->inTransaction()) $pdo->rollBack();
        error_log('owner_bookings error: ' . $e->getMessage());
        $_SESSION['flash'] = [
            'type' => 'error',
            'msg' => APP_DEBUG ? 'Internal error: ' . $e->getMessage() : 'An error occurred.'
        ];
    }

    header('Location: owner_bookings.php');
    exit;
}

// ─── Fetch All Bookings for Owner ───
$sql = "
    SELECT 
        b.booking_id,
        LOWER(b.status) AS status,
        b.start_date,
        b.end_date,
        u.user_id AS student_id,
        u.name AS student_name,
        u.email,
        u.phone,
        r.room_type,
        r.price,
        r.capacity,
        d.name AS dorm_name
    FROM bookings b
    JOIN users u ON b.student_id = u.user_id
    JOIN rooms r ON b.room_id = r.room_id
    JOIN dormitories d ON r.dorm_id = d.dorm_id
    WHERE d.owner_id = ?
    ORDER BY FIELD(b.status, 'pending','approved','rejected','cancelled','completed'), b.start_date DESC
";
$stmt = $pdo->prepare($sql);
$stmt->execute([$owner_id]);
$bookings = $stmt->fetchAll(PDO::FETCH_ASSOC);

$flash = $_SESSION['flash'] ?? null;
unset($_SESSION['flash']);
?>

<div class="page-header">
  <h2>Manage Bookings</h2>
  <p>Approve or reject student bookings for your dorms. Approving automatically creates a payment reminder.</p>
</div>

<?php if ($flash): ?>
<div class="alert <?= htmlspecialchars($flash['type']) ?>">
  <?= htmlspecialchars($flash['msg']) ?>
</div>
<?php endif; ?>

<div style="margin-bottom:10px;">
  <strong>Status Legend:</strong>
  <span class="badge pending">Pending</span>
  <span class="badge approved">Approved</span>
  <span class="badge rejected">Rejected</span>
  <span class="badge cancelled">Cancelled</span>
  <span class="badge completed">Completed</span>
</div>

<div class="card">
  <table class="data-table">
    <thead>
      <tr>
        <th>Student</th>
        <th>Email</th>
        <th>Phone</th>
        <th>Dorm</th>
        <th>Room Type</th>
        <th>Price</th>
        <th>Capacity</th>
        <th>Booking Period</th>
        <th>Status</th>
        <th>Actions</th>
      </tr>
    </thead>
    <tbody>
      <?php if (empty($bookings)): ?>
        <tr><td colspan="10" style="text-align:center;">No bookings found.</td></tr>
      <?php else: ?>
        <?php foreach ($bookings as $b): 
          $status = strtolower(trim($b['status'] ?? 'pending')); // fallback to pending
          if ($status === '' || $status === null) $status = 'pending';
        ?>
        <tr>
          <td><?= htmlspecialchars($b['student_name']) ?></td>
          <td><?= htmlspecialchars($b['email']) ?></td>
          <td><?= htmlspecialchars($b['phone'] ?? 'N/A') ?></td>
          <td><?= htmlspecialchars($b['dorm_name']) ?></td>
          <td><?= htmlspecialchars($b['room_type']) ?></td>
          <td>₱<?= number_format($b['price'], 2) ?></td>
          <td><?= htmlspecialchars($b['capacity']) ?></td>
          <td>
            <?= htmlspecialchars($b['start_date'] ?? '—') ?> 
            <?php if ($b['end_date']): ?> → <?= htmlspecialchars($b['end_date']) ?><?php endif; ?>
          </td>
          <td><span class="badge <?= $status ?>"><?= ucfirst($status) ?></span></td>
          <td>
            <?php if ($status === 'pending'): ?>
              <form method="post" style="display:inline-block;">
                <input type="hidden" name="booking_id" value="<?= $b['booking_id'] ?>">
                <button type="submit" name="approve_booking" class="btn success">Approve</button>
              </form>
              <form method="post" style="display:inline-block;">
                <input type="hidden" name="booking_id" value="<?= $b['booking_id'] ?>">
                <button type="submit" name="reject_booking" class="btn danger">Reject</button>
              </form>
            <?php else: ?>
              <a href="owner_messages.php?recipient_id=<?= $b['student_id'] ?>" class="btn-secondary">Contact</a>
            <?php endif; ?>
          </td>
        </tr>
        <?php endforeach; ?>
      <?php endif; ?>
    </tbody>
  </table>
</div>

<style>
.alert { padding:10px; border-radius:6px; margin-bottom:15px; font-weight:500; }
.alert.success { background:#d4edda; color:#155724; }
.alert.error { background:#f8d7da; color:#721c24; }

.badge { padding:4px 8px; border-radius:6px; font-size:0.9em; color:#fff; }
.badge.pending { background:#ffc107; color:#000; }
.badge.approved { background:#28a745; }
.badge.rejected { background:#dc3545; }
.badge.cancelled { background:#6c757d; }
.badge.completed { background:#17a2b8; }

.btn { padding:4px 8px; border:none; border-radius:5px; cursor:pointer; font-size:0.85em; }
.btn.success { background:#28a745; color:#fff; }
.btn.danger { background:#dc3545; color:#fff; }
.btn-secondary { background:#007bff; color:#fff; padding:4px 8px; border-radius:5px; text-decoration:none; }
.btn-secondary:hover { background:#0056b3; }

.data-table { width:100%; border-collapse:collapse; }
.data-table th, .data-table td { border:1px solid #ddd; padding:8px; }
.data-table th { background-color:#f8f9fa; font-weight:bold; }
</style>

<?php require_once __DIR__ . '/../partials/footer.php'; ?>
