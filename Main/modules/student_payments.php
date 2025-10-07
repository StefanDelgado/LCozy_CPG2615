<?php
require_once __DIR__ . '/../partials/header.php';
require_role('student');
require_once __DIR__ . '/../config.php';

$page_title = "My Payments";
$flash = null;
$user_id = $_SESSION['user']['user_id'];

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_FILES['receipt_image'])) {
    $payment_id = intval($_POST['payment_id']);
    $file = $_FILES['receipt_image'];

    if ($file['error'] === UPLOAD_ERR_OK) {
        $allowed_types = ['image/jpeg', 'image/png', 'application/pdf'];
        $max_size = 5 * 1024 * 1024;

        if (in_array($file['type'], $allowed_types) && $file['size'] <= $max_size) {
            $ext = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
            $filename = 'receipt_' . $payment_id . '_' . time() . '.' . $ext;
            $upload_dir = __DIR__ . '/../uploads/receipts/';

            if (!file_exists($upload_dir)) mkdir($upload_dir, 0777, true);

            $upload_path = $upload_dir . $filename;
            if (move_uploaded_file($file['tmp_name'], $upload_path)) {
                $stmt = $pdo->prepare("
                    SELECT b.booking_id, b.expires_at, b.status 
                    FROM payments p
                    JOIN bookings b ON p.booking_id = b.booking_id
                    WHERE p.payment_id = ? AND b.student_id = ?
                ");
                $stmt->execute([$payment_id, $user_id]);
                $booking = $stmt->fetch(PDO::FETCH_ASSOC);

                if ($booking) {
                    $now = new DateTime();
                    $expires = new DateTime($booking['expires_at']);

                    if ($now < $expires) {
                        $pdo->beginTransaction();
                        $pdo->prepare("UPDATE payments SET receipt_image = ?, status='paid', payment_date=NOW(), updated_at=NOW() WHERE payment_id=?")
                            ->execute([$filename, $payment_id]);
                        $pdo->prepare("UPDATE bookings SET status='approved' WHERE booking_id=?")->execute([$booking['booking_id']]);
                        $pdo->commit();

                        $flash = ['type' => 'success', 'msg' => 'Receipt uploaded successfully. Booking approved!'];
                    } else {
                        $pdo->beginTransaction();
                        $pdo->prepare("UPDATE payments SET status='cancelled', updated_at=NOW() WHERE payment_id=?")->execute([$payment_id]);
                        $pdo->prepare("UPDATE bookings SET status='cancelled' WHERE booking_id=?")->execute([$booking['booking_id']]);
                        $pdo->commit();

                        $flash = ['type' => 'error', 'msg' => 'Payment window expired. Booking automatically cancelled.'];
                    }
                } else {
                    $flash = ['type' => 'error', 'msg' => 'Booking not found.'];
                }
            } else {
                $flash = ['type' => 'error', 'msg' => 'Failed to save uploaded file.'];
            }
        } else {
            $flash = ['type' => 'error', 'msg' => 'Invalid file. Only JPG, PNG, or PDF up to 5MB allowed.'];
        }
    } else {
        $flash = ['type' => 'error', 'msg' => 'Error uploading file. Please try again.'];
    }
}

$sql = "
    SELECT 
        p.payment_id, p.amount, p.status, p.payment_date, p.due_date, p.receipt_image,
        d.name AS dorm_name, r.room_type, b.expires_at, b.status AS booking_status
    FROM payments p
    JOIN bookings b ON p.booking_id = b.booking_id
    JOIN rooms r ON b.room_id = r.room_id
    JOIN dormitories d ON r.dorm_id = d.dorm_id
    WHERE b.student_id = ?
    ORDER BY p.due_date ASC
";
$stmt = $pdo->prepare($sql);
$stmt->execute([$user_id]);
$payments = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

<div class="page-header">
  <h1>My Payments</h1>
  <p>View your payment records and upload receipts for verification.</p>
</div>

<?php if (!empty($flash)): ?>
<div class="alert <?= $flash['type'] ?>"><?= htmlspecialchars($flash['msg']) ?></div>
<?php endif; ?>

<table class="data-table">
  <thead>
    <tr>
      <th>Dorm</th>
      <th>Room Type</th>
      <th>Amount</th>
      <th>Due Date</th>
      <th>Booking Window</th>
      <th>Status</th>
      <th>Receipt</th>
      <th>Action</th>
    </tr>
  </thead>
  <tbody>
    <?php foreach ($payments as $p): 
      $expired = $p['expires_at'] && strtotime($p['expires_at']) < time();
    ?>
      <tr>
        <td><?= htmlspecialchars($p['dorm_name']) ?></td>
        <td><?= htmlspecialchars($p['room_type']) ?></td>
        <td>₱<?= number_format($p['amount'], 2) ?></td>
        <td><?= htmlspecialchars($p['due_date'] ?? '—') ?></td>
        <td>
          <?= $p['expires_at'] 
              ? ($expired 
                ? '<span class="badge error">Expired</span>' 
                : '<span class="badge info">'.date('M d, Y H:i', strtotime($p['expires_at'])).'</span>') 
              : '<em>—</em>' ?>
        </td>
        <td>
          <span class="badge <?= htmlspecialchars($p['status']) ?>">
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
          <?php if (in_array($p['status'], ['pending', 'overdue']) && !$expired): ?>
            <form method="post" enctype="multipart/form-data" style="display:inline;">
              <input type="hidden" name="payment_id" value="<?= $p['payment_id'] ?>">
              <input type="file" name="receipt_image" accept=".jpg,.jpeg,.png,.pdf" required>
              <button class="btn-primary">Upload</button>
            </form>
          <?php else: ?>
            <em>—</em>
          <?php endif; ?>
        </td>
      </tr>
    <?php endforeach; ?>
  </tbody>
</table>

<style>
.alert.success {background:#d4edda;color:#155724;padding:10px;border-radius:6px;}
.alert.error {background:#f8d7da;color:#721c24;padding:10px;border-radius:6px;}
.badge {padding:4px 10px;border-radius:6px;font-size:0.9em;}
.badge.success {background:#4CAF50;color:white;}
.badge.warning {background:#ff9800;color:white;}
.badge.error {background:#f44336;color:white;}
.badge.info {background:#2196F3;color:white;}
</style>

<?php require_once __DIR__ . '/../partials/footer.php'; ?>