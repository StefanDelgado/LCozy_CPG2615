<?php
// owner_checkout_requests.php
require_once __DIR__ . '/../../auth/auth.php';
require_role('owner');
require_once __DIR__ . '/../../config.php';
include __DIR__ . '/../../partials/header.php';

$owner_id = $_SESSION['user']['user_id'] ?? 0;
$flash = null;

// Handle Approve / Disapprove
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['request_id'], $_POST['action'])) {
    $request_id = (int)$_POST['request_id'];
    $action = $_POST['action']; // 'approve' or 'disapprove'

    // Verify request belongs to this owner
    $check = $pdo->prepare("SELECT * FROM checkout_requests WHERE id = ? AND owner_id = ? LIMIT 1");
    $check->execute([$request_id, $owner_id]);
    $req = $check->fetch(PDO::FETCH_ASSOC);

    if (!$req) {
        $flash = ['type'=>'error','msg'=>'Request not found.'];
    } else {

        // APPROVE
        if ($action === 'approve') {
            $pdo->beginTransaction();
            try {
                // Update checkout request
                $update = $pdo->prepare("
                    UPDATE checkout_requests 
                    SET status = 'approved', processed_by = ?, processed_at = NOW(), updated_at = NOW()
                    WHERE id = ?
                ");
                $update->execute([$owner_id, $request_id]);

                // Update booking
                $upb = $pdo->prepare("UPDATE bookings SET status = 'checkout_approved' WHERE booking_id = ?");
                $upb->execute([$req['booking_id']]);

                // Notify tenant
                $insmsg = $pdo->prepare("
                    INSERT INTO messages (sender_id, receiver_id, dorm_id, body, created_at)
                    VALUES (?, ?, ?, ?, NOW())
                ");
                $insmsg->execute([
                    $owner_id,
                    $req['tenant_id'],
                    null,
                    "Your checkout request (Booking #{$req['booking_id']}) has been approved."
                ]);

                $pdo->commit();
                $flash = ['type'=>'success','msg'=>'Checkout request approved.'];

            } catch (Exception $e) {
                if ($pdo->inTransaction()) $pdo->rollBack();
                error_log('checkout approve error: '.$e->getMessage());
                $flash = ['type'=>'error','msg'=>'An error occurred while approving.'];
            }
        }

        // DISAPPROVE
        elseif ($action === 'disapprove') {
            $upd = $pdo->prepare("
                UPDATE checkout_requests 
                SET status = 'disapproved', processed_by = ?, processed_at = NOW(), updated_at = NOW()
                WHERE id = ?
            ");
            $upd->execute([$owner_id, $request_id]);

            // Revert booking status
            $revert = $pdo->prepare("UPDATE bookings SET status = 'active' WHERE booking_id = ?");
            $revert->execute([$req['booking_id']]);

            // Notify tenant
            $insmsg = $pdo->prepare("
                INSERT INTO messages (sender_id, receiver_id, dorm_id, body, created_at)
                VALUES (?, ?, ?, ?, NOW())
            ");
            $insmsg->execute([
                $owner_id,
                $req['tenant_id'],
                null,
                "Your checkout request (Booking #{$req['booking_id']}) was disapproved by the owner."
            ]);

            $flash = ['type'=>'success','msg'=>'Checkout request disapproved.'];
        }
    }
}

// Fetch checkout requests
$requests = $pdo->prepare("
    SELECT cr.*, b.start_date, b.end_date, u.name AS tenant_name, d.name AS dorm_name
    FROM checkout_requests cr
    JOIN bookings b ON cr.booking_id = b.booking_id
    JOIN users u ON cr.tenant_id = u.user_id
    LEFT JOIN rooms r ON b.room_id = r.room_id
    LEFT JOIN dormitories d ON r.dorm_id = d.dorm_id
    WHERE cr.owner_id = ?
    ORDER BY cr.created_at DESC
");
$requests->execute([$owner_id]);
$requests = $requests->fetchAll(PDO::FETCH_ASSOC);
?>

<div class="page-header">
  <h1>Checkout Requests</h1>
  <p>Approve, disapprove, or mark completed checkout requests.</p>
</div>

<?php if ($flash): ?>
  <div class="alert alert-<?= htmlspecialchars($flash['type']) ?>">
    <?= htmlspecialchars($flash['msg']) ?>
  </div>
<?php endif; ?>

<?php if (empty($requests)): ?>
  <p>No checkout requests at the moment.</p>

<?php else: ?>
  <?php foreach ($requests as $r): ?>
    <div class="card" style="padding:12px; margin-bottom:12px;">
      
      <strong><?= htmlspecialchars($r['tenant_name']) ?> — <?= htmlspecialchars($r['dorm_name'] ?? 'Dorm') ?></strong>
      
      <div>
        Booking: <?= (int)$r['booking_id'] ?> |
        From: <?= htmlspecialchars($r['start_date']) ?> —
        <?= htmlspecialchars($r['end_date'] ?? 'Ongoing') ?>
      </div>

      <div>Requested at: <?= htmlspecialchars($r['created_at']) ?></div>
      <div>Status: <strong><?= htmlspecialchars($r['status']) ?></strong></div>

      <div style="margin-top:8px;">

        <?php if ($r['status'] === 'requested'): ?>

          <!-- APPROVE -->
          <form method="post" style="display:inline-block;margin-right:8px;">
            <input type="hidden" name="request_id" value="<?= (int)$r['id'] ?>">
            <button name="action" value="approve" class="btn btn-approve">Approve</button>
          </form>

          <!-- DISAPPROVE -->
          <form method="post" style="display:inline-block;">
            <input type="hidden" name="request_id" value="<?= (int)$r['id'] ?>">
            <button name="action" value="disapprove" class="btn btn-reject">Disapprove</button>
          </form>

        <?php elseif ($r['status'] === 'approved'): ?>

          <!-- MARK COMPLETE -->
          <form method="post" action="owner_mark_complete.php" style="display:inline-block;">
            <input type="hidden" name="request_id" value="<?= (int)$r['id'] ?>">
            <button type="submit" class="btn btn-complete">Mark Complete</button>
          </form>

        <?php else: ?>
          <small>
            Processed: <?= htmlspecialchars($r['status']) ?>
            (by <?= (int)$r['processed_by'] ?>)
          </small>
        <?php endif; ?>

      </div>
    </div>
  <?php endforeach; ?>
<?php endif; ?>

<?php include __DIR__ . '/../../partials/footer.php'; ?>