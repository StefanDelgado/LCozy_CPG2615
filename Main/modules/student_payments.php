<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

require_once __DIR__ . '/../auth/auth.php';
require_once __DIR__ . '/../config.php';
require_role('student');

$page_title = "My Payments";
include __DIR__ . '/../partials/header.php';

$user_id = $_SESSION['user']['user_id'];

// Ensure uploads directory exists
$uploadsDir = __DIR__ . '/../uploads/receipts';
if (!is_dir($uploadsDir)) {
    mkdir($uploadsDir, 0777, true);
}

// Fetch payments with booking and room details
$stmt = $pdo->prepare("
    SELECT 
        p.payment_id, p.amount, p.status, p.payment_date, p.due_date, 
        p.receipt_image, p.created_at,
        d.name AS dorm_name, r.room_type,
        b.booking_id, b.start_date, b.end_date
    FROM payments p
    JOIN bookings b ON p.booking_id = b.booking_id
    JOIN rooms r ON b.room_id = r.room_id
    JOIN dormitories d ON r.dorm_id = d.dorm_id
    WHERE p.student_id = ?
    ORDER BY p.created_at DESC
");

$stmt->execute([$user_id]);
$payments = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Calculate payment statistics
$total_due = 0;
$paid_amount = 0;
$pending_count = 0;

foreach ($payments as $p) {
    if ($p['status'] === 'pending') {
        $total_due += $p['amount'];
        $pending_count++;
    } elseif ($p['status'] === 'paid') {
        $paid_amount += $p['amount'];
    }
}
?>

<style>
.stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 1rem;
    margin-bottom: 1.5rem;
}
.stat-card {
    background: white;
    padding: 1rem;
    border-radius: 10px;
    text-align: center;
    box-shadow: 0 2px 6px rgba(0,0,0,0.05);
}
.stat-card h3 { 
    margin: 0;
    color: #4A3AFF;
    font-size: 1.5rem;
}
.stat-card p {
    margin: 0.3rem 0 0;
    color: #666;
}
.data-table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 1rem;
    background: white;
    border-radius: 12px;
    overflow: hidden;
    box-shadow: 0 1px 6px rgba(0,0,0,0.05);
}
.data-table th {
    background: #f8f9fa;
    padding: 12px;
    text-align: left;
    font-weight: 600;
}
.data-table td {
    padding: 12px;
    border-top: 1px solid #eee;
}
.status-paid { color: #28a745; }
.status-pending { color: #ffc107; }
.status-overdue { color: #dc3545; }
.btn {
    padding: 6px 12px;
    border-radius: 6px;
    border: none;
    cursor: pointer;
    font-size: 0.9rem;
    transition: all 0.2s;
}
.btn-primary {
    background: #4A3AFF;
    color: white;
}
.btn-primary:hover {
    background: #372fdb;
}
.btn-secondary {
    background: #f8f9fa;
    color: #444;
    border: 1px solid #ddd;
}
.modal {
    display: none;
    position: fixed;
    inset: 0;
    background: rgba(0,0,0,0.5);
    align-items: center;
    justify-content: center;
}
.modal-content {
    background: white;
    padding: 1.5rem;
    border-radius: 12px;
    max-width: 500px;
    width: 90%;
}
.modal-content h2 {
    margin: 0 0 1rem;
    font-size: 1.4rem;
}
.form-group {
    margin-bottom: 1rem;
}
.form-group label {
    display: block;
    margin-bottom: 0.5rem;
    font-weight: 500;
}
.actions {
    display: flex;
    gap: 0.5rem;
    justify-content: flex-end;
    margin-top: 1.5rem;
}
</style>

<div class="page-header">
    <h1>My Payments</h1>
    <p>Track your payments and upload receipts</p>
</div>

<div class="stats-grid">
    <div class="stat-card">
        <h3><?= $pending_count ?></h3>
        <p>Pending Payments</p>
    </div>
    <div class="stat-card">
        <h3>₱<?= number_format($total_due, 2) ?></h3>
        <p>Total Due</p>
    </div>
    <div class="stat-card">
        <h3>₱<?= number_format($paid_amount, 2) ?></h3>
        <p>Total Paid</p>
    </div>
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
                <!-- Fix: Update receipt path to point to uploads directory -->
                <a href="../uploads/receipts/<?php echo htmlspecialchars($p['receipt_image']); ?>" 
                   target="_blank" 
                   class="btn-secondary">
                  View Receipt
                </a>
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
function updateCountdowns() {
    document.querySelectorAll('.countdown').forEach(el => {
        let hours = parseInt(el.dataset.hours);
        if (hours > 0) {
            hours--;
            el.dataset.hours = hours;
            el.textContent = `⏳ ${hours}h left`;
        } else {
            el.textContent = '❌ Overdue';
            el.closest('tr').querySelector('.status-pending')?.classList.replace('status-pending','status-overdue');
        }
    });
}

function openUploadModal(id) {
    document.getElementById('upload_payment_id').value = id;
    document.getElementById('uploadModal').style.display = 'flex';
}

function closeUploadModal() {
    document.getElementById('uploadModal').style.display = 'none';
}

// Update countdowns every hour
setInterval(updateCountdowns, 3600000);
// Initial update
updateCountdowns();
</script>

<?php require_once __DIR__ . '/../partials/footer.php'; ?>
