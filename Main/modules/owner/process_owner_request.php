<?php
// Main/modules/owner/process_owner_request.php

require_once __DIR__ . '/../../auth/auth.php';
require_role(['admin', 'superadmin']); // Only admin & superadmin can act on requests

require_once __DIR__ . '/../../config.php';

$action = $_GET['action'] ?? null;
$request_id = $_GET['request_id'] ?? null;
$user_id = $_GET['user_id'] ?? null;

if (!$action || !$request_id || !$user_id) {
    die("Invalid request.");
}

try {

    // Get request details from user_verifications
    $stmt = $pdo->prepare("
        SELECT r.*, u.role 
        FROM user_verifications r
        JOIN users u ON u.user_id = r.user_id
        WHERE r.request_id = ?
    ");
    $stmt->execute([$request_id]);
    $req = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$req) {
        die("Request not found.");
    }

    if ($req['status'] !== 'pending') {
        die("This request has already been processed.");
    }

    // --- ACTION: APPROVE ---
    if ($action === 'approve') {

        $pdo->beginTransaction();

        // Update user role to owner
        $updateUser = $pdo->prepare("
            UPDATE users SET role = 'owner', verified = 1
            WHERE user_id = ?
        ");
        $updateUser->execute([$user_id]);

        // Mark request as approved
        $approve = $pdo->prepare("
            UPDATE user_verifications
            SET status = 'approved', processed_at = NOW()
            WHERE request_id = ?
        ");
        $approve->execute([$request_id]);

        $pdo->commit();

        header("Location: owner_requests.php?success=Owner verified successfully.");
        exit;
    }

    // --- ACTION: DISAPPROVE ---
    elseif ($action === 'disapprove') {

        $disapprove = $pdo->prepare("
            UPDATE user_verifications
            SET status = 'disapproved', processed_at = NOW()
            WHERE request_id = ?
        ");
        $disapprove->execute([$request_id]);

        header("Location: owner_requests.php?success=Owner verification disapproved.");
        exit;
    }

    else {
        die("Invalid action.");
    }

} catch (Exception $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    die("Error processing request: " . $e->getMessage());
}
