<?php
session_start();
require_once __DIR__ . '/../config.php';

// Ensure user is logged in
if (!isset($_SESSION['user'])) {
    header("Location: login.php");
    exit;
}

$user_id = $_SESSION['user']['user_id'];
$error = '';
$success = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    $old_pass = $_POST['old_password'] ?? '';
    $new_pass = $_POST['new_password'] ?? '';
    $confirm_pass = $_POST['confirm_password'] ?? '';

    // Fetch user from DB
    $stmt = $pdo->prepare("SELECT password FROM users WHERE user_id = ?");
    $stmt->execute([$user_id]);
    $user = $stmt->fetch();

    if (!$user) {
        $error = "User not found.";
    }
    else if (!password_verify($old_pass, $user['password'])) {
        $error = "Old password is incorrect.";
    }
    else if ($new_pass !== $confirm_pass) {
        $error = "New passwords do not match.";
    }
    else if (!preg_match('/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()\-_=+\[\]{};:,.<>\/?]).{8,16}$/', $new_pass)) {
        // 8–16 chars, uppercase, lowercase, number, special char
        $error = "Password must be 8–16 characters and include uppercase, lowercase, number, and special character.";
    }
    else {
        // Update password
        $hash = password_hash($new_pass, PASSWORD_DEFAULT);
        $stmt = $pdo->prepare("UPDATE users SET password = ? WHERE user_id = ?");
        $stmt->execute([$hash, $user_id]);

        $success = "Password updated successfully!";
    }
}
?>
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Change Password — CozyDorms</title>
<meta name="viewport" content="width=device-width, initial-scale=1">

<style>
    body {
        margin: 0;
        font-family: 'Segoe UI', Tahoma;
        background: #f3f3ff;
        height: 100vh;
        display: flex;
        justify-content: center;
        align-items: center;
    }
    .card {
        background: white;
        width: 400px;
        padding: 2rem;
        border-radius: 14px;
        box-shadow: 0 8px 20px rgba(0,0,0,0.1);
    }
    h2 {
        margin-top: 0;
        text-align: center;
        color: #333;
    }
    .alert {
        padding: 0.7rem;
        border-radius: 6px;
        margin-bottom: 1rem;
        font-size: 0.9rem;
        text-align: center;
    }
    .alert.error { background: #fde2e2; color: #b30000; }
    .alert.success { background: #dcfce7; color: #166534; }
    form {
        display: flex;
        flex-direction: column;
        gap: 1rem;
    }
    input {
        width: 100%;
        padding: 0.8rem;
        border: 1px solid #bbb;
        border-radius: 8px;
    }
    button {
        background: #6a5acd;
        color: #fff;
        border: none;
        padding: 0.8rem;
        border-radius: 10px;
        font-size: 1rem;
        cursor: pointer;
    }
    button:hover {
        background: #5848c2;
    }
    .back {
        margin-top: 1rem;
        text-align: center;
        font-size: 0.9rem;
    }
    .back a { color: #6a5acd; text-decoration: none; }
</style>

</head>
<body>

<div class="card">
    <h2>Change Password</h2>

    <?php if ($error): ?>
        <div class="alert error"><?= $error ?></div>
    <?php endif; ?>

    <?php if ($success): ?>
        <div class="alert success"><?= $success ?></div>
    <?php endif; ?>

    <form method="post">
        <label>Old Password
            <input type="password" name="old_password" required>
        </label>

        <label>New Password
            <input type="password" name="new_password" minlength="8" maxlength="16" required>
        </label>

        <label>Confirm New Password
            <input type="password" name="confirm_password" minlength="8" maxlength="16" required>
        </label>

        <button type="submit">Update Password</button>
    </form>

    <div class="back">
        <a href="../dashboard.php">Back to Dashboard</a>
    </div>
</div>

</body>
</html>
