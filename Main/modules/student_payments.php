<?php
require_once __DIR__ . '/../partials/header.php';
require_role('student');
require_once __DIR__ . '/../config.php';

$page_title = "My Payments";
$user_id = $_SESSION['user']['user_id'];

// Fetch payments for the logged-in student
$stmt = $pdo->prepare("
  SELECT 
    p.payment_id, p.amount, p.status, p.payment_date, p.due_date, p.receipt_image, p.created_at,
    d.name AS dorm_name, r.room_type
  FROM payments p
  JOIN bookings b ON p.booking_id = b.booking_id
  JOIN dormitories d ON b.dorm_id = d.dorm_id
  JOIN rooms r ON b.room_id = r.room_id
  WHERE p.student_id = ?
  ORDER BY p.created_at DESC
");
$stmt->execute([$user_id]);
$payments = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

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
        <?php foreach ($payments as $p): 
          $statusClass = match($p['status']) {
            'paid' => 'status-paid',
            'pending' => 'status-pending',
            'expired' => 'status-overdue',
            default => ''
          };
          $now = new DateTime();
          $createdAt = new DateTime($p['created_at']);
          $diff = $now->diff($createdAt);
          $hoursPassed = ($diff->days * 24) + $diff->h;
          $hoursLeft = max(0, 48 - $hoursPassed);
        ?>
        <tr>
          <td><?= htmlspecialchars($p['dorm_name']) ?></td>
          <td><?= htmlspecialchars($p['room_type']) ?></td>
          <td>₱<?= number_format($p['amount'], 2) ?></td>
          <td><?= $p['due_date'] ? date('M d, Y', strtotime($p['due_date'])) : '-' ?></td>
          <td><?= $p['payment_date'] ? date('M d, Y', strtotime($p['payment_date'])) : '-' ?></td>
          <td class="<?= $statusClass ?>">
            <?= ucfirst($p['status']) ?>
            <?php if ($p['status'] === 'pending'): ?>
              <br><small class="countdown" data-hours="<?= $hoursLeft ?>">⏳ <?= $hoursLeft ?>h left</small>
            <?php endif; ?>
          </td>
          <td>
            <?php if ($p['status'] === 'pending'): ?>
              <?php if ($p['receipt_image']): ?>
                <a href="../uploads/<?= htmlspecialchars($p['receipt_image']) ?>" target="_blank" class="btn-secondary">View Receipt</a>
              <?php else: ?>
                <button class="btn upload-btn" onclick="openUploadModal(<?= $p['payment_id'] ?>)">Upload Receipt</button>
              <?php endif; ?>
            <?php elseif ($p['status'] === 'paid'): ?>
              ✅ Confirmed
            <?php elseif ($p['status'] === 'expired'): ?>
              ❌ Expired
            <?php endif; ?>
          </td>
        </tr>
        <?php endforeach; ?>
      </tbody>
    </table>
  <?php endif; ?>
</div>

<!-- Upload Receipt Modal -->
<div id="uploadModal" class="modal">
  <div class="modal-content">
    <h3>Upload Payment Receipt</h3>
    <form method="post" enctype="multipart/form-data" action="upload_receipt.php">
      <input type="hidden" name="payment_id" id="upload_payment_id">
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