<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

require_once __DIR__ . '/../auth.php';  // Add auth.php first
require_once __DIR__ . '/../config.php';
require_role('student');

$page_title = "My Payments";
include __DIR__ . '/../partials/header.php'; // Move header include after config and auth

$user_id = $_SESSION['user']['user_id'];

// Ensure uploads directory exists
$uploadsDir = __DIR__ . '/../uploads/receipts';
if (!is_dir($uploadsDir)) {
    mkdir($uploadsDir, 0777, true);
}

// Fetch payments for the logged-in student
$stmt = $pdo->prepare("
  SELECT 
    p.payment_id, p.amount, p.status, p.payment_date, p.due_date, 
    p.receipt_image, p.created_at,
    d.name AS dorm_name, r.room_type
  FROM payments p
  JOIN bookings b ON p.booking_id = b.booking_id
  JOIN rooms r ON b.room_id = r.room_id
  JOIN dormitories d ON r.dorm_id = d.dorm_id
  WHERE p.student_id = ?
  ORDER BY p.created_at DESC
");

if (!$stmt->execute([$user_id])) {
    $error = $stmt->errorInfo();
    error_log('Payment query error: ' . print_r($error, true));
    echo "Error fetching payments. Please try again.";
    exit;
}

$payments = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

<style>
.data-table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 1rem;
}
.data-table th, .data-table td {
    padding: 8px;
    border: 1px solid #ddd;
    text-align: left;
}
.status-paid { color: #28a745; }
.status-pending { color: #ffc107; }
.status-overdue { color: #dc3545; }
.modal {
    display: none;
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0,0,0,0.5);
    align-items: center;
    justify-content: center;
}
.modal-content {
    background: white;
    padding: 20px;
    border-radius: 8px;
    max-width: 500px;
    width: 90%;
}
.btn {
    padding: 5px 10px;
    border-radius: 4px;
    border: none;
    cursor: pointer;
    background: #4A3AFF;
    color: white;
}
.btn-secondary {
    background: #6c757d;
    color: white;
    text-decoration: none;
    padding: 5px 10px;
    border-radius: 4px;
    display: inline-block;
}
</style>

<div class="page-header">
  <h1>My Payments</h1>
  <p>Manage and track your dorm payments — upload receipts, check status, and see due reminders.</p>
</div>

<div class="card">
  <?php if (!$payments): ?>
    <p>No payments found.</p>
  <?php else: ?>
    <table class="data-table">
      <thead>
        <tr>
          <th>Dorm</th>
          <th>Room Type</th>
          <th>Amount</th>
          <th>Due Date</th>
          <th>Payment Date</th>
          <th>Status</th>
          <th>Action</th>
        </tr>
      </thead>
      <tbody>
        <?php foreach ($payments as $p): ?>
          <tr>
            <td><?php echo htmlspecialchars($p['dorm_name']); ?></td>
            <td><?php echo htmlspecialchars($p['room_type']); ?></td>
            <td><?php echo htmlspecialchars(number_format($p['amount'], 2)); ?></td>
            <td><?php echo htmlspecialchars(date('Y-m-d', strtotime($p['due_date']))); ?></td>
            <td><?php echo $p['payment_date'] ? htmlspecialchars(date('Y-m-d', strtotime($p['payment_date']))) : 'N/A'; ?></td>
            <td class="<?php echo 'status-' . htmlspecialchars($p['status']); ?>">
              <?php echo ucfirst(htmlspecialchars($p['status'])); ?>
              <?php if ($p['status'] == 'pending' && strtotime($p['due_date']) > time()): ?>
                <span class="countdown" data-hours="<?php echo floor((strtotime($p['due_date']) - time()) / 3600); ?>">⏳</span>
              <?php endif; ?>
            </td>
            <td>
              <?php if ($p['status'] == 'pending'): ?>
                <button class="btn" onclick="openUploadModal(<?php echo $p['payment_id']; ?>)">Upload Receipt</button>
              <?php else: ?>
                <a href="<?php echo htmlspecialchars($p['receipt_image']); ?>" target="_blank" class="btn-secondary">View Receipt</a>
              <?php endif; ?>
            </td>
          </tr>
        <?php endforeach; ?>
      </tbody>
    </table>
  <?php endif; ?>
</div>

<div class="modal" id="uploadModal">
  <div class="modal-content">
    <h2>Upload Receipt</h2>
    <form action="upload_receipt.php" method="POST" enctype="multipart/form-data">
      <input type="hidden" name="payment_id" id="upload_payment_id" value="">
      <label for="receipt">Choose File (JPG/PNG/PDF)</label>
      <input type="file" name="receipt" id="receipt" accept=".jpg,.jpeg,.png,.pdf" required>
      <div class="actions">
        <button type="submit" class="btn">Upload</button>
        <button type="button" class="btn-secondary" onclick="closeUploadModal()">Cancel</button>
      </div>
    </form>
  </div>
</div>

<script>
// Countdown update
function updateCountdowns() {
  document.querySelectorAll('.countdown').forEach(el => {
    let hours = parseInt(el.dataset.hours);
    if (hours > 0) {
      hours--;
      el.dataset.hours = hours;
      el.textContent = `⏳ ${hours}h left`;
    } else {
      el.textContent = '❌ Expired';
      el.closest('tr').querySelector('td.status-pending').classList.replace('status-pending','status-overdue');
    }
  });
}
setInterval(updateCountdowns, 3600000); // update every hour

// Upload modal controls
function openUploadModal(id) {
  document.getElementById('upload_payment_id').value = id;
  document.getElementById('uploadModal').style.display = 'flex';
}
function closeUploadModal() {
  document.getElementById('uploadModal').style.display = 'none';
}
</script>

<?php require_once __DIR__ . '/../partials/footer.php'; ?>