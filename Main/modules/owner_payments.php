<?php
require_once __DIR__ . '/../auth.php';
require_role('owner');
require_once __DIR__ . '/../config.php';

$page_title = "Payment Management";
include __DIR__ . '/../partials/header.php';

$owner_id = $_SESSION['user']['user_id'];
$flash = null;

if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    if (isset($_POST['add_reminder'])) {
        $booking_id = intval($_POST['booking_id']);
        $amount = floatval($_POST['amount']);
        $due_date = $_POST['due_date'];

        $stmt = $pdo->prepare("
            INSERT INTO payments (booking_id, student_id, amount, due_date, status, created_at)
            SELECT b.booking_id, b.student_id, ?, ?, 'pending', NOW()
            FROM bookings b
            JOIN rooms r ON b.room_id = r.room_id
            JOIN dormitories d ON r.dorm_id = d.dorm_id
            WHERE b.booking_id = ? AND d.owner_id = ?
        ");
        $stmt->execute([$amount, $due_date, $booking_id, $owner_id]);

        $flash = ['type'=>'success','msg'=>'Payment reminder added successfully.'];
    }

    if (isset($_POST['update_status'])) {
        $payment_id = intval($_POST['payment_id']);
        $status = $_POST['status'];

        $stmt = $pdo->prepare("
            UPDATE payments 
            SET status = ?, updated_at = NOW()
            WHERE payment_id = ? 
              AND booking_id IN (
                SELECT b.booking_id 
                FROM bookings b
                JOIN rooms r ON b.room_id = r.room_id
                JOIN dormitories d ON r.dorm_id = d.dorm_id
                WHERE d.owner_id = ?
              )
        ");
        $stmt->execute([$status, $payment_id, $owner_id]);
        $flash = ['type'=>'success','msg'=>'Payment status updated successfully.'];
    }

    if (isset($_POST['delete_payment'])) {
        $payment_id = intval($_POST['payment_id']);
        $stmt = $pdo->prepare("
            DELETE FROM payments 
            WHERE payment_id = ? 
              AND booking_id IN (
                SELECT b.booking_id 
                FROM bookings b
                JOIN rooms r ON b.room_id = r.room_id
                JOIN dormitories d ON r.dorm_id = d.dorm_id
                WHERE d.owner_id = ?
              )
        ");
        $stmt->execute([$payment_id, $owner_id]);
        $flash = ['type'=>'error','msg'=>'Payment deleted successfully.'];
    }
}

$sql = "
    SELECT 
        p.payment_id, p.amount, p.status, p.due_date, p.payment_date, p.receipt_image,
        u.name AS student_name, u.email,
        d.name AS dorm_name, r.room_type, b.booking_id
    FROM payments p
    JOIN bookings b ON p.booking_id = b.booking_id
    JOIN rooms r ON b.room_id = r.room_id
    JOIN dormitories d ON r.dorm_id = d.dorm_id
    JOIN users u ON b.student_id = u.user_id
    WHERE d.owner_id = ?
    ORDER BY p.due_date ASC
";
$stmt = $pdo->prepare($sql);
$stmt->execute([$owner_id]);
$payments = $stmt->fetchAll(PDO::FETCH_ASSOC);

$bookings = $pdo->prepare("
    SELECT b.booking_id, u.name AS student_name, d.name AS dorm_name
    FROM bookings b
    JOIN users u ON b.student_id = u.user_id
    JOIN rooms r ON b.room_id = r.room_id
    JOIN dormitories d ON r.dorm_id = d.dorm_id
    WHERE d.owner_id = ? AND b.status = 'approved'
");
$bookings->execute([$owner_id]);
$bookings = $bookings->fetchAll(PDO::FETCH_ASSOC);
?>

<div class="page-header">
  <p>Track, update, and remind tenants about their payments.</p>
</div>

<?php if ($flash): ?>
<div class="alert <?= $flash['type'] ?>"><?= htmlspecialchars($flash['msg']) ?></div>
<?php endif; ?>

<div class="card">
  <h2>Add Payment Reminder</h2>
  <form method="post">
    <label>Booking
      <select name="booking_id" required>
        <option value="">Select Booking</option>
        <?php foreach ($bookings as $b): ?>
          <option value="<?= $b['booking_id'] ?>">
            <?= htmlspecialchars($b['student_name']) ?> — <?= htmlspecialchars($b['dorm_name']) ?>
          </option>
        <?php endforeach; ?>
      </select>
    </label>
    <label>Amount (₱)
      <input type="number" step="0.01" name="amount" required>
    </label>
    <label>Due Date
      <input type="date" name="due_date" required>
    </label>
    <button type="submit" name="add_reminder" class="btn-primary">Add Reminder</button>
  </form>
</div>

<div class="card">
  <h2>Payments Overview</h2>
  <table class="data-table">
    <thead>
      <tr>
        <th>Student</th>
        <th>Dorm</th>
        <th>Room</th>
        <th>Amount</th>
        <th>Due Date</th>
        <th>Status</th>
        <th>Receipt</th>
        <th>Actions</th>
      </tr>
    </thead>
    <tbody>
      <?php foreach ($payments as $p): ?>
      <tr>
        <td><?= htmlspecialchars($p['student_name']) ?></td>
        <td><?= htmlspecialchars($p['dorm_name']) ?></td>
        <td><?= htmlspecialchars($p['room_type']) ?></td>
        <td>₱<?= number_format($p['amount'], 2) ?></td>
        <td><?= htmlspecialchars($p['due_date']) ?></td>
        <td>
          <form method="post" style="display:inline;">
            <input type="hidden" name="payment_id" value="<?= $p['payment_id'] ?>">
            <select name="status" onchange="this.form.submit()">
              <?php 
              $statuses = ['pending', 'submitted', 'paid', 'overdue'];
              foreach ($statuses as $s): 
              ?>
                <option value="<?= $s ?>" <?= $p['status'] === $s ? 'selected' : '' ?>>
                  <?= ucfirst($s) ?>
                </option>
              <?php endforeach; ?>
            </select>
            <input type="hidden" name="update_status" value="1">
          </form>
        </td>
        <td>
          <?php if ($p['receipt_image']): ?>
            <a href="../uploads/receipts/<?= htmlspecialchars($p['receipt_image']) ?>" target="_blank">View</a>
          <?php else: ?>
            <em>No receipt</em>
          <?php endif; ?>
        </td>
        <td>
          <form method="post" onsubmit="return confirm('Delete this payment record?')" style="display:inline;">
            <input type="hidden" name="payment_id" value="<?= $p['payment_id'] ?>">
            <button type="submit" name="delete_payment" class="btn-danger">Delete</button>
          </form>
        </td>
      </tr>
      <?php endforeach; ?>
    </tbody>
  </table>
</div>

<style>
.alert.success {background:#d4edda;color:#155724;padding:10px;border-radius:6px;}
.alert.error {background:#f8d7da;color:#721c24;padding:10px;border-radius:6px;}
.btn-danger {background:#dc3545;color:#fff;border:none;padding:5px 10px;border-radius:6px;cursor:pointer;}
select {padding:4px 6px;border-radius:5px;}
</style>

<?php require_once __DIR__ . '/../partials/footer.php'; ?>