<?php
// tenant_checkout.php
require_once __DIR__ . '/../../auth/auth.php';
require_role('student');
require_once __DIR__ . '/../../config.php';
$page_title = "Request Checkout";
include __DIR__ . '/../../partials/header.php';

$student_id = $_SESSION['user']['user_id'] ?? 0;
$flash = null;

// POST: Create checkout request
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['booking_id'])) {
    $booking_id = (int)$_POST['booking_id'];
    $reason = trim($_POST['reason'] ?? null);

    // Verify booking belongs to this student and is active
    $stmt = $pdo->prepare("
        SELECT b.booking_id, b.status, d.owner_id
        FROM bookings b
        JOIN rooms r ON b.room_id = r.room_id
        JOIN dormitories d ON r.dorm_id = d.dorm_id
        WHERE b.booking_id = ? AND b.student_id = ? 
        LIMIT 1
    ");
    $stmt->execute([$booking_id, $student_id]);
    $booking = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$booking) {
        $flash = ['type'=>'error','msg'=>'Booking not found.'];
    } elseif (!in_array($booking['status'], ['active','approved'])) {
        $flash = ['type'=>'error','msg'=>'Cannot request checkout for this booking status.'];
    } else {
        // Insert into checkout_requests
        $ins = $pdo->prepare("INSERT INTO checkout_requests (booking_id, tenant_id, owner_id, request_reason, status, created_at) VALUES (?, ?, ?, ?, 'requested', NOW())");
        $ins->execute([$booking_id, $student_id, $booking['owner_id'], $reason]);
        // Update booking status to checkout_requested (optional)
        $upd = $pdo->prepare("UPDATE bookings SET status = 'checkout_requested' WHERE booking_id = ?");
        $upd->execute([$booking_id]);

        // Optional: create a message/notification entry for owner
        $msg = $pdo->prepare("INSERT INTO messages (sender_id, receiver_id, dorm_id, body, created_at) VALUES (?, ?, ?, ?, NOW())");
        // dorm_id from booking -> fetch
        $dormStmt = $pdo->prepare("SELECT r.room_id, d.dorm_id FROM bookings b JOIN rooms r ON b.room_id = r.room_id JOIN dormitories d ON r.dorm_id = d.dorm_id WHERE b.booking_id = ? LIMIT 1");
        $dormStmt->execute([$booking_id]);
        $d = $dormStmt->fetch(PDO::FETCH_ASSOC);
        $dorm_id = $d['dorm_id'] ?? null;
        $message_body = "Tenant requested checkout (Booking #{$booking_id}). Reason: " . ($reason ?: 'No reason provided.');
        if ($dorm_id) {
            $msg->execute([$student_id, $booking['owner_id'], $dorm_id, $message_body]);
        } else {
            $msg->execute([$student_id, $booking['owner_id'], null, $message_body]);
        }

        $flash = ['type'=>'success','msg'=>'Checkout request submitted. The owner will review it.'];
    }
}

// Fetch active bookings for this tenant
$bookingsStmt = $pdo->prepare("
    SELECT b.booking_id, d.name AS dorm_name, r.room_type, b.start_date, b.end_date, b.status
    FROM bookings b
    JOIN rooms r ON b.room_id = r.room_id
    JOIN dormitories d ON r.dorm_id = d.dorm_id
    WHERE b.student_id = ? AND b.status IN ('active','approved')
    ORDER BY b.start_date DESC
");
$bookingsStmt->execute([$student_id]);
$bookings = $bookingsStmt->fetchAll(PDO::FETCH_ASSOC);
?>

<div class="page-header">
  <h1>Request Checkout</h1>
  <p>Submit a checkout request when you plan to move out.</p>
</div>

<?php if ($flash): ?>
  <div class="alert alert-<?= htmlspecialchars($flash['type']) ?>"><?= htmlspecialchars($flash['msg']) ?></div>
<?php endif; ?>

<?php if (empty($bookings)): ?>
  <p>No active bookings found.</p>
<?php else: ?>
  <?php foreach ($bookings as $b): ?>
    <div class="card" style="padding:12px;margin-bottom:12px;">
      <strong><?= htmlspecialchars($b['dorm_name']) ?> — <?= htmlspecialchars($b['room_type']) ?></strong>
      <div>From: <?= htmlspecialchars($b['start_date']) ?> — <?= htmlspecialchars($b['end_date'] ?? 'Ongoing') ?></div>
      <div>Status: <?= htmlspecialchars($b['status']) ?></div>

      <form method="post" style="margin-top:8px;">
        <input type="hidden" name="booking_id" value="<?= (int)$b['booking_id'] ?>">
        <label>Reason (optional)</label>
        <textarea name="reason" rows="2" style="width:100%"></textarea>
        <button type="submit" style="margin-top:8px;">Request Checkout</button>
      </form>
    </div>
  <?php endforeach; ?>
<?php endif; ?>

<?php include __DIR__ . '/../../partials/footer.php'; ?>