<?php
require_once __DIR__ . '/../auth/auth.php';
require_role('owner');
require_once __DIR__ . '/../config.php';

$page_title = "Payment Management";
include __DIR__ . '/../partials/header.php';

$owner_id = $_SESSION['user']['user_id'];
$flash = null;

// --- Add Payment Reminder ---
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['add_reminder'])) {
    $booking_id = intval($_POST['booking_id']);
    $amount = floatval($_POST['amount']);
    $due_date = $_POST['due_date'];

    $stmt = $pdo->prepare("
        INSERT INTO payments (booking_id, student_id, owner_id, amount, due_date, status, created_at)
        SELECT b.booking_id, b.student_id, ?, ?, ?, 'pending', NOW()
        FROM bookings b
        JOIN rooms r ON b.room_id = r.room_id
        JOIN dormitories d ON r.dorm_id = d.dorm_id
        WHERE b.booking_id = ? AND d.owner_id = ?
    ");
    $stmt->execute([$owner_id, $amount, $due_date, $booking_id, $owner_id]);
    $flash = ['type' => 'success', 'msg' => 'Payment reminder added successfully.'];
}

// --- Manual Status Updates (Confirm/Reject) ---
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['update_status'])) {
    $payment_id = intval($_POST['payment_id']);
    $status = $_POST['status'];

    // Authorize via booking->room->dorm (owner relationship) so we don't rely on payments.owner_id
    $stmt = $pdo->prepare("
        UPDATE payments p
        JOIN bookings b ON p.booking_id = b.booking_id
        JOIN rooms r ON b.room_id = r.room_id
        JOIN dormitories d ON r.dorm_id = d.dorm_id
        SET p.status = ?, p.updated_at = NOW()
        WHERE p.payment_id = ? AND d.owner_id = ?
    ");
    $stmt->execute([$status, $payment_id, $owner_id]);
    $flash = ['type' => 'success', 'msg' => 'Payment status updated successfully.'];
}
 
// --- Delete a Payment ---
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['delete_payment'])) {
    $payment_id = intval($_POST['payment_id']);
    // Ensure owner owns the related dorm via booking -> room -> dorm
    $stmt = $pdo->prepare("
        DELETE p FROM payments p
        JOIN bookings b ON p.booking_id = b.booking_id
        JOIN rooms r ON b.room_id = r.room_id
        JOIN dormitories d ON r.dorm_id = d.dorm_id
        WHERE p.payment_id = ? AND d.owner_id = ?
    ");
    $stmt->execute([$payment_id, $owner_id]);
    $flash = ['type' => 'error', 'msg' => 'Payment record deleted successfully.'];
}

// --- Fetch Bookings for Dropdown ---
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
  <h1>Payment Management</h1>
  <p>Track payments, confirm receipts, and manage student billing efficiently.</p>
</div>

<?php if ($flash): ?>
  <div class="alert <?= $flash['type'] ?>"><?= htmlspecialchars($flash['msg']) ?></div>
<?php endif; ?>

<!-- Add Payment Reminder -->
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
    <button type="submit" name="add_reminder" class="btn">Add Reminder</button>
  </form>
</div>

<!-- Payments Overview -->
<div class="card">
  <h2>Payments Overview</h2>
  <table class="data-table" id="paymentsTable">
    <thead>
      <tr>
        <th>Student</th>
        <th>Dorm</th>
        <th>Room</th>
        <th>Amount</th>
        <th>Due Date</th>
        <th>Status</th>
        <th>Receipt</th>
        <th>Action</th>
      </tr>
    </thead>
    <tbody id="paymentsBody">
      <!-- Loaded by fetch -->
    </tbody>
  </table>
</div>

<script>
async function fetchPayments() {
  try {
    const res = await fetch('fetch_payments.php');
    const data = await res.json();
    const tbody = document.getElementById('paymentsBody');
    tbody.innerHTML = '';

    data.forEach(p => {
      const createdAt = new Date(p.created_at);
      const now = new Date();
      const hoursElapsed = Math.floor((now - createdAt) / (1000 * 60 * 60));
      const hoursLeft = 48 - hoursElapsed;
      const expired = hoursElapsed >= 48 && p.status === 'pending';

      const tr = document.createElement('tr');
      tr.innerHTML = `
        <td>${p.student_name}</td>
        <td>${p.dorm_name}</td>
        <td>${p.room_type}</td>
        <td>₱${parseFloat(p.amount).toFixed(2)}</td>
        <td>${p.due_date}</td>
        <td>
          <span class="badge ${expired ? 'overdue' : p.status}">
            ${expired ? 'Expired' : p.status.charAt(0).toUpperCase() + p.status.slice(1)}
          </span>
          ${p.status === 'pending' && !expired ? `<br><small>⏳ ${hoursLeft}h left</small>` : ''}
        </td>
        <td>
          ${p.receipt_image 
            ? `<a href="../uploads/receipts/${p.receipt_image}" target="_blank">View</a>` 
            : '<em>No receipt</em>'}
        </td>
        <td>
          <form method="post" style="display:inline;">
            <input type="hidden" name="payment_id" value="${p.payment_id}">
            <select name="status" onchange="this.form.submit()">
              ${['pending', 'submitted', 'paid', 'expired'].map(s =>
                `<option value="${s}" ${p.status === s ? 'selected' : ''}>${s.charAt(0).toUpperCase() + s.slice(1)}</option>`
              ).join('')}
            </select>
            <input type="hidden" name="update_status" value="1">
          </form>
          <form method="post" style="display:inline;" onsubmit="return confirm('Delete this payment record?')">
            <input type="hidden" name="payment_id" value="${p.payment_id}">
            <button type="submit" name="delete_payment" class="btn-secondary">Delete</button>
          </form>
        </td>
      `;
      tbody.appendChild(tr);
    });
  } catch (err) {
    console.error('Error fetching payments:', err);
  }
}

document.addEventListener('DOMContentLoaded', fetchPayments);
setInterval(fetchPayments, 10000);
</script>

<?php require_once __DIR__ . '/../partials/footer.php'; ?>
