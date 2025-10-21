<?php
require_once __DIR__ . '/../config.php';

$token = $_GET['token'] ?? '';
if (!$token) {
    echo "Invalid activation link.";
    exit;
}

try {
    $stmt = $pdo->prepare("SELECT uv.user_id, uv.expires_at, u.verified FROM user_verifications uv JOIN users u ON uv.user_id = u.user_id WHERE uv.token = ? LIMIT 1");
    $stmt->execute([$token]);
    $row = $stmt->fetch();
    if (!$row) {
        echo "Activation token not found or already used.";
        exit;
    }

    if ($row['verified'] == 1) {
        echo "Account already activated. You may login.";
        exit;
    }

    if (strtotime($row['expires_at']) < time()) {
        echo "Activation link has expired. Please request a new activation link.";
        exit;
    }

    // activate
    $stmt = $pdo->prepare("UPDATE users SET verified = 1 WHERE user_id = ?");
    $stmt->execute([$row['user_id']]);

    // delete verification record
    $stmt = $pdo->prepare("DELETE FROM user_verifications WHERE token = ?");
    $stmt->execute([$token]);

    echo "Account activated successfully. <a href=\"login.php\">Login</a>";
} catch (Exception $e) {
    error_log('Activation error: ' . $e->getMessage());
    echo "An error occurred.";
}



