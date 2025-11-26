<?php
// owner_mark_complete.php
require_once __DIR__ . '/../../auth/auth.php';
require_role('owner');
require_once __DIR__ . '/../../config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST' || !isset($_POST['request_id'])) {
    header('Location: owner_checkout_requests.php');
    exit;
}

$owner_id = $_SESSION['user']['user_id'] ?? 0;
$request_id = (int)$_POST['request_id'];

// Verify ownership AND that request exists
$check = $pdo->prepare("
    SELECT *
    FROM checkout_requests
    WHERE id = ? AND owner_id = ?
    LIMIT 1
");
$check->execute([$request_id, $owner_id]);
$req = $check->fetch(PDO::FETCH_ASSOC);

if (!$req) {
    $_SESSION['flash'] = ['type'=>'error','msg'=>'Request not found or unauthorized access.'];
    header('Location: owner_checkout_requests.php');
    exit;
}

// Must be APPROVED before completion
if ($req['status'] !== 'approved') {
    $_SESSION['flash'] = ['type'=>'error','msg'=>'Only approved requests can be marked completed.'];
    header('Location: owner_checkout_requests.php');
    exit;
}

try {
    $pdo->beginTransaction();

    // Mark checkout request as completed
    $pdo->prepare("
        UPDATE checkout_requests
        SET status = 'completed',
            processed_by = ?,
            processed_at = NOW(),
            updated_at = NOW()
        WHERE id = ?
    ")->execute([$owner_id, $request_id]);

    // Update booking
    $pdo->prepare("
        UPDATE bookings
        SET status = 'checkout_completed',
            end_date = COALESCE(end_date, NOW())
        WHERE booking_id = ?
    ")->execute([$req['booking_id']]);

    // Update tenants table (if exists)
    // This avoids errors if your database does NOT have `tenants` table
    try {
        $updateTenant = $pdo->prepare("
            UPDATE tenants
            SET status = 'completed', checkout_date = NOW()
            WHERE booking_id = ?
        ");
        @ $updateTenant->execute([$req['booking_id']]);
    } catch (Exception $ignored) {
        // No tenants table? Ignore silently.
    }

    // Optional final logic: outstanding payments, balance settlement...

    // Notify tenant
    $pdo->prepare("
        INSERT INTO messages (sender_id, receiver_id, dorm_id, body, created_at)
        VALUES (?, ?, ?, ?, NOW())
    ")->execute([
        $owner_id,
        $req['tenant_id'],
        null,
        "Your checkout for booking #{$req['booking_id']} has been marked as COMPLETED by the owner."
    ]);

    $pdo->commit();
    $_SESSION['flash'] = ['type'=>'success','msg'=>'Checkout completed. Tenant moved to past tenants.'];

} catch (Exception $e) {
    if ($pdo->inTransaction()) $pdo->rollBack();
    error_log('checkout complete error: '.$e->getMessage());
    $_SESSION['flash'] = ['type'=>'error','msg'=>'An error occurred while completing checkout.'];
}

header('Location: owner_checkout_requests.php');
exit;
