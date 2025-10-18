<?php
require_once __DIR__ . '/../../auth/auth.php';
require_role('admin');
require_once __DIR__ . '/../../config.php';

$page_title = "All Payments Overview";
include __DIR__ . '/../../partials/header.php';

$flash = null;

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $payment_id = intval($_POST['payment_id']);
    $action = $_POST['action'] ?? null;

    if ($action === 'edit') {
        $amount = floatval($_POST['amount']);
        $due_date = $_POST['due_date'];
        $status = $_POST['status'];
        $stmt = $pdo->prepare("UPDATE payments SET amount=?, due_date=?, status=?, updated_at=NOW() WHERE payment_id=?");
        $stmt->execute([$amount, $due_date, $status, $payment_id]);
        $flash = ['type'=>'success','msg'=>'Payment details updated successfully.'];
    }

    elseif ($action === 'delete') {
        $stmt = $pdo->prepare("DELETE FROM payments WHERE payment_id=?");
        $stmt->execute([$payment_id]);
        $flash = ['type'=>'error','msg'=>'Payment record deleted successfully.'];
    }
}

$sql = "
    SELECT 
        p.payment_id, p.amount, p.status, p.due_date, p.payment_date, p.receipt_image,
        u.name AS student_name, u.email,
        d.name AS dorm_name,
        o.name AS owner_name,
        r.room_type
    FROM payments p
    JOIN bookings b ON p.booking_id = b.booking_id
    JOIN users u ON b.student_id = u.user_id
    JOIN rooms r ON b.room_id = r.room_id
    JOIN dormitories d ON r.dorm_id = d.dorm_id
    JOIN users o ON d.owner_id = o.user_id
    ORDER BY p.due_date ASC
";
$payments = $pdo->query($sql)->fetchAll(PDO::FETCH_ASSOC);
?>

<div class="page-header">
  <p>Monitor, edit, or delete payment records across all dormitories.</p>
</div>

<?php if ($flash): ?>
<div class="alert <?= $flash['type'] ?>"><?= htmlspecialchars($flash['msg']) ?></div>
<?php endif; ?>

<div class="stats-grid">
  <div class="stat-card"><h3><?= count($payments) ?></h3><p>Total Payments</p></div>
  <div class="stat-card"><h3><?= count(array_filter($payments, fn($p) => $p['status'] === 'paid')) ?></h3><p>Paid</p></div>
  <div class="stat-card"><h3><?= count(array_filter($payments, fn($p) => $p['status'] === 'pending')) ?></h3><p>Pending</p></div>
  <div class="stat-card"><h3><?= count(array_filter($payments, fn($p) => $p['status'] === 'overdue')) ?></h3><p>Overdue</p></div>
</div>

<div class="card">
  <h2>All Payments</h2>
  <table class="data-table">
    <thead>
      <tr>
        <th>Dorm</th>
        <th>Owner</th>
        <th>Student</th>
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
        <td><?= htmlspecialchars($p['dorm_name']) ?></td>
        <td><?= htmlspecialchars($p['owner_name']) ?></td>
        <td>
          <?= htmlspecialchars($p['student_name']) ?><br>
          <small><?= htmlspecialchars($p['email']) ?></small>
        </td>
        <td><?= htmlspecialchars($p['room_type']) ?></td>
        <td>₱<?= number_format($p['amount'], 2) ?></td>
        <td><?= htmlspecialchars($p['due_date']) ?></td>
        <td>
          <span class="badge <?= $p['status'] ?>">
            <?= ucfirst($p['status']) ?>
          </span>
        </td>
        <td>
          <?php if ($p['receipt_image']): ?>
            <a href="../uploads/receipts/<?= htmlspecialchars($p['receipt_image']) ?>" target="_blank">View</a>
          <?php else: ?>
            <em>No receipt</em>
          <?php endif; ?>
        </td>
        <td>
          <button class="btn-secondary" onclick="openEditModal(
            <?= $p['payment_id'] ?>,
            '<?= htmlspecialchars($p['amount'], ENT_QUOTES) ?>',
            '<?= htmlspecialchars($p['due_date'], ENT_QUOTES) ?>',
            '<?= htmlspecialchars($p['status'], ENT_QUOTES) ?>'
          )">Edit</button>

          <form method="post" style="display:inline;" onsubmit="return confirm('Delete this payment record?');">
            <input type="hidden" name="payment_id" value="<?= $p['payment_id'] ?>">
            <button class="btn-danger" name="action" value="delete">Delete</button>
          </form>
        </td>
      </tr>
      <?php endforeach; ?>
    </tbody>
  </table>
</div>

<div id="editModal" class="modal" style="display:none;">
  <div class="modal-content">
    <h2>Edit Payment</h2>
    <form method="post">
      <input type="hidden" name="payment_id" id="edit_payment_id">
      <label>Amount (₱)
        <input type="number" name="amount" id="edit_amount" step="0.01" required>
      </label>
      <label>Due Date
        <input type="date" name="due_date" id="edit_due_date" required>
      </label>
      <label>Status
        <select name="status" id="edit_status">
          <option value="pending">Pending</option>
          <option value="submitted">Submitted</option>
          <option value="paid">Paid</option>
          <option value="overdue">Overdue</option>
        </select>
      </label>
      <button type="submit" name="action" value="edit" class="btn-primary">Save Changes</button>
      <button type="button" class="btn-secondary" onclick="closeEditModal()">Cancel</button>
    </form>
  </div>
</div>

<style>
.modal {
  position: fixed; top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0,0,0,0.6);
  display: flex; align-items: center; justify-content: center;
  z-index: 9999;
}
.modal-content {
  background: white; padding: 20px; border-radius: 10px; width: 350px;
}
.btn-secondary, .btn-danger, .btn-primary {
  border: none; padding: 5px 10px; border-radius: 6px; cursor: pointer; color: white;
}
.btn-secondary { background: #6c757d; }
.btn-danger { background: #dc3545; }
.btn-primary { background: #007bff; }
.badge { padding: 4px 8px; border-radius: 6px; font-size: 0.85em; color: #fff; }
.badge.paid { background: #28a745; }
.badge.pending { background: #ffc107; color: #000; }
.badge.submitted { background: #007bff; }
.badge.overdue { background: #dc3545; }
.alert.success { background: #d4edda; color: #155724; padding: 10px; border-radius: 6px; }
.alert.error { background: #f8d7da; color: #721c24; padding: 10px; border-radius: 6px; }
</style>

<script>
function openEditModal(id, amount, due_date, status){
  document.getElementById('edit_payment_id').value = id;
  document.getElementById('edit_amount').value = amount;
  document.getElementById('edit_due_date').value = due_date;
  document.getElementById('edit_status').value = status;
  document.getElementById('editModal').style.display = 'flex';
}
function closeEditModal(){
  document.getElementById('editModal').style.display = 'none';
}
</script>

<?php require_once __DIR__ . '/../../partials/footer.php'; ?>
