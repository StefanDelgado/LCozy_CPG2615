<?php
require_once __DIR__ . '/../partials/header.php';
require_role('student');
require_once __DIR__ . '/../config.php';

$page_title = "Submit Payment Receipt";
$student_id = $_SESSION['user']['user_id'];
$flash = null;

// --- Handle receipt upload ---
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['payment_id'])) {
    $payment_id = intval($_POST['payment_id']);

    if (!empty($_FILES['receipt']['name'])) {
        $fileName = time() . '_' . basename($_FILES['receipt']['name']);
        $targetDir = __DIR__ . '/../uploads/receipts/';
        if (!is_dir($targetDir)) mkdir($targetDir, 0777, true);
        $targetPath = $targetDir . $fileName;

        $allowed = ['image/jpeg', 'image/png', 'application/pdf'];
        if (in_array($_FILES['receipt']['type'], $allowed)) {
            move_uploaded_file($_FILES['receipt']['tmp_name'], $targetPath);

            $stmt = $pdo->prepare("
                UPDATE payments 
                SET receipt_image = ?, status = 'submitted', updated_at = NOW()
                WHERE payment_id = ? AND student_id = ?
            ");
            $stmt->execute([$fileName, $payment_id, $student_id]);

            $flash = ['type'=>'success','msg'=>'Receipt uploaded successfully. Awaiting owner confirmation.'];
        } else {
            $flash = ['type'=>'error','msg'=>'Invalid file type. Please upload JPG, PNG, or PDF.'];
        }
    } else {
        $flash = ['type'=>'error','msg'=>'Please select a file to upload.'];
    }
}

// --- Fetch student’s payment records ---
$stmt = $pdo->prepare("
    SELECT p.*, d.name AS dorm_name, r.room_type
    FROM payments p
    JOIN bookings b ON p.booking_id = b.booking_id
    JOIN rooms r ON b.room_id = r.room_id
    JOIN dormitories d ON r.dorm_id = d.dorm_id
    WHERE p.student_id = ?
    ORDER BY p.due_date DESC
");
$stmt->execute([$student_id]);
$payments = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

<div class="page-header">
  <h1>Submit Payment Receipt</h1>
  <p>Upload payment proof for your pending or submitted payments.</p>
</div>

<?php if ($flash): ?>
  <div class="alert <?= $flash['type'] ?>"><?= htmlspecialchars($flash['msg']) ?></div>
<?php endif; ?>

<div class="card">
  <table class="data-table">
    <thead>
      <tr>
        <th>Dorm</th>
        <th>Room Type</th>
        <th>Amount</th>
        <th>Due Date</th>
        <th>Status</th>
        <th>Receipt</th>
      </tr>
    </thead>
    <tbody>
      <?php if (empty($payments)): ?>
        <tr><td colspan="6"><em>No payments found.</em></td></tr>
      <?php else: ?>
        <?php foreach ($payments as $p): ?>
          <tr>
            <td><?= htmlspecialchars($p['dorm_name']) ?></td>
            <td><?= htmlspecialchars($p['room_type']) ?></td>
            <td>₱<?= number_format($p['amount'], 2) ?></td>
            <td><?= htmlspecialchars($p['due_date']) ?></td>
            <td>
              <span class="badge <?= htmlspecialchars($p['status']) ?>">
                <?= ucfirst($p['status']) ?>
              </span>
            </td>
            <td>
              <?php if (in_array($p['status'], ['pending', 'submitted'])): ?>
                <form method="post" enctype="multipart/form-data" class="receipt-form">
                  <input type="hidden" name="payment_id" value="<?= $p['payment_id'] ?>">
                  <input type="file" name="receipt" accept=".jpg,.jpeg,.png,.pdf" required>
                  <button type="submit" class="btn">Upload</button>
                </form>
              <?php elseif ($p['receipt_image']): ?>
                <a href="../uploads/receipts/<?= htmlspecialchars($p['receipt_image']) ?>" target="_blank">View Receipt</a>
              <?php else: ?>
                <em>—</em>
              <?php endif; ?>
            </td>
          </tr>
        <?php endforeach; ?>
      <?php endif; ?>
    </tbody>
  </table>
</div>

<?php require_once __DIR__ . '/../partials/footer.php'; ?>