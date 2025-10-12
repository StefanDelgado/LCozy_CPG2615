<?php
require_once __DIR__ . '/../auth.php';
require_role('owner');
require_once __DIR__ . '/../config.php';

// ---- DEBUG / SAFETY: enable during local debug only ----
if (isset($pdo) && $pdo instanceof PDO) {
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
}
// Turn on detailed errors in development only:
define('APP_DEBUG', true); // set to false on production
if (defined('APP_DEBUG') && APP_DEBUG) {
    ini_set('display_errors', '1');
    ini_set('display_startup_errors', '1');
    error_reporting(E_ALL);
}
// --------------------------------------------------------

$page_title = "Bookings";
include __DIR__ . '/../partials/header.php';

$owner_id = $_SESSION['user']['user_id'];

// ─── Handle Booking Approval/Rejection ───
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['approve_booking']) || isset($_POST['reject_booking'])) {
        $booking_id = (int)($_POST['booking_id'] ?? 0);

        // Determine new status from explicit button values (protect against empty values)
        $new_status = null;
        if (isset($_POST['approve_booking']) && $_POST['approve_booking'] !== '') {
            $new_status = 'approved';
        } elseif (isset($_POST['reject_booking']) && $_POST['reject_booking'] !== '') {
            $new_status = 'rejected';
        }

        // Basic validation
        if (!$booking_id || !$new_status) {
            $_SESSION['flash'] = ['type' => 'error', 'msg' => 'Invalid request.'];
            header('Location: owner_bookings.php');
            exit;
        }

        try {
            $pdo->beginTransaction();

            // Validate that the booking belongs to this owner
            $stmt = $pdo->prepare("
                SELECT b.*, r.price, r.room_id, r.dorm_id, u.user_id AS student_id, b.start_date
                FROM bookings b
                JOIN rooms r ON b.room_id = r.room_id
                JOIN dormitories d ON r.dorm_id = d.dorm_id
                JOIN users u ON b.student_id = u.user_id
                WHERE b.booking_id = ? AND d.owner_id = ?
            ");
            $stmt->execute([$booking_id, $owner_id]);
            $booking = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$booking) {
                $pdo->rollBack();
                $_SESSION['flash'] = ['type' => 'error', 'msg' => 'Booking not found or not authorized.'];
                header('Location: owner_bookings.php');
                exit;
            }

            // Update booking status (avoid updated_at to prevent column errors)
            $update = $pdo->prepare("UPDATE bookings SET status = ? WHERE booking_id = ?");
            $update->execute([$new_status, $booking_id]);

            // Log affected rows for debugging
            $affected = $update->rowCount();
            error_log("owner_bookings: booking_id={$booking_id} set status={$new_status} affected_rows={$affected}");

            // If approved, create a pending payment record (only if not already present)
            if ($new_status === 'approved') {
                $amount = $booking['price'] ?? 0;
                $student_id = $booking['student_id'];
                $due_date = $booking['start_date'] ?? date('Y-m-d', strtotime('+7 days')); // fallback

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

            $pdo->commit();
        } catch (Exception $e) {
            if (isset($pdo) && $pdo instanceof PDO && $pdo->inTransaction()) {
                $pdo->rollBack();
            }
            $msg = 'owner_bookings error: ' . $e->getMessage() . ' -- booking_id:' . ($booking_id ?? 'n/a') . ' owner_id:' . ($owner_id ?? 'n/a');
            error_log($msg . "\n" . $e->getTraceAsString());
            $_SESSION['flash'] = ['type' => 'error', 'msg' => defined('APP_DEBUG') && APP_DEBUG ? 'Internal error: ' . $e->getMessage() : 'An internal error occurred.'];
        }

        // Redirect (PRG)
        header('Location: owner_bookings.php');
        exit;
    }
}

// ─── Fetch All Bookings for Owner ───
$sql = "
    SELECT 
        b.booking_id,
        b.status,
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

// retrieve flash for display
$flash = $_SESSION['flash'] ?? null;
unset($_SESSION['flash']);
?>

<div class="page-header">
  <p>Approve or reject student bookings for your dorms. Approving automatically creates a payment reminder.</p>
</div>

<?php if ($flash): ?>
<div class="alert <?= $flash['type'] ?>">
  <?= htmlspecialchars($flash['msg']) ?>
</div>
<?php endif; ?>

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
        <?php foreach ($bookings as $b): ?>
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
          <td><span class="badge <?= strtolower($b['status']) ?>"><?= ucfirst($b['status']) ?></span></td>
          <td>
            <?php if ($b['status'] === 'pending'): ?>
              <form method="post" style="display:inline-block;">
                <input type="hidden" name="booking_id" value="<?= $b['booking_id'] ?>">
                <button type="submit" name="approve_booking" value="1" class="btn success">Approve</button>
              </form>
              <form method="post" style="display:inline-block;">
                <input type="hidden" name="booking_id" value="<?= $b['booking_id'] ?>">
                <button type="submit" name="reject_booking" value="1" class="btn danger">Reject</button>
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
.alert {
  padding: 10px; border-radius: 6px; margin-bottom: 15px;
  font-weight: 500;
}
.alert.success { background: #d4edda; color: #155724; }
.alert.error { background: #f8d7da; color: #721c24; }

.badge {
  padding: 4px 8px; border-radius: 6px; font-size: 0.9em; color: #fff;
}
.badge.pending { background: #ffc107; color: #000; }
.badge.approved { background: #28a745; }
.badge.rejected { background: #dc3545; }
.badge.cancelled { background: #6c757d; }
.badge.completed { background: #17a2b8; }

.btn { padding: 4px 8px; border:none; border-radius:5px; cursor:pointer; font-size:0.85em; }
.btn.success { background:#28a745; color:#fff; }
.btn.danger { background:#dc3545; color:#fff; }
.btn-secondary {
  background:#007bff; color:#fff; padding:4px 8px; border-radius:5px; text-decoration:none;
}
.btn-secondary:hover { background:#0056b3; }
</style>

<?php require_once __DIR__ . '/../partials/footer.php'; ?>