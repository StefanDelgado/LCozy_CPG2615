<?php
session_start();
require_once __DIR__ . '/../config.php';

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

$error = '';
$success = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    $email = trim($_POST['email'] ?? '');
    $new_pass = $_POST['new_password'] ?? '';
    $confirm_pass = $_POST['confirm_password'] ?? '';

    if (!$email || !$new_pass || !$confirm_pass) {
        $error = "All fields are required.";

    } elseif ($new_pass !== $confirm_pass) {
        $error = "Passwords do not match.";

    } elseif (!preg_match('/^(?=.*[A-Z])(?=.*[a-z])(?=.*[!@#$%^&*()\-_=+\[\]{};:,.<>\/?]).{8,16}$/', $new_pass)) {
        $error = "Password must be 8–16 characters, include uppercase, lowercase, and a special character.";

    } else {
        // Check if email exists
        $stmt = $pdo->prepare("SELECT user_id FROM users WHERE email = ?");
        $stmt->execute([$email]);
        $user = $stmt->fetch();

        if (!$user) {
            $error = "Email not found.";
        } else {
            // Update password
            $hash = password_hash($new_pass, PASSWORD_DEFAULT);

            $update = $pdo->prepare("UPDATE users SET password = ? WHERE user_id = ?");
            $update->execute([$hash, $user['user_id']]);

            $success = "Password updated successfully! You can now log in.";
        }
    }
}
?>
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Forgot Password</title>
<meta name="viewport" content="width=device-width,initial-scale=1">

<style>
  body {
    margin: 0;
    font-family: 'Segoe UI', Tahoma, sans-serif;
    background: linear-gradient(135deg, #a18cd1 0%, #fbc2eb 100%);
    height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
  }
  .auth-card {
    background: #fff;
    padding: 2rem;
    border-radius: 16px;
    width: 350px;
    box-shadow: 0 8px 20px rgba(0,0,0,0.1);
    text-align: center;
  }
  .auth-card h1 {
    margin-bottom: 1.5rem;
    font-size: 1.8rem;
    color: #2c2c2c;
  }
  .alert {
    background: #f8d7da;
    color: #721c24;
    padding: 0.7rem;
    border-radius: 6px;
    margin-bottom: 1rem;
    font-size: 0.9rem;
  }
  .alert.success {
    background: #dcfce7;
    color: #166534;
  }
  form {
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }
  label {
    font-weight: 500;
    text-align: left;
    font-size: 0.9rem;
  }
  input {
    width: 100%;
    padding: 0.7rem;
    border: 1px solid #ccc;
    border-radius: 8px;
    font-size: 0.95rem;
  }
  button {
    background: #6a5acd;
    color: #fff;
    border: none;
    padding: 0.8rem;
    border-radius: 10px;
    font-size: 1rem;
    cursor: pointer;
    transition: background 0.2s;
  }
  button:hover {
    background: #5848c2;
  }
  p a {
    color: #6a5acd;
    text-decoration: none;
    font-weight: 500;
  }
</style>
</head>

<body>
  <div class="auth-card">
    <h1>Reset Password</h1>

    <?php if ($error): ?>
      <div class="alert"><?= $error ?></div>
    <?php endif; ?>

    <?php if ($success): ?>
      <div class="alert success"><?= $success ?></div>
    <?php endif; ?>

    <form method="post">
      <label>Email
        <input type="email" name="email" required>
      </label>

      <label>New Password
        <input type="password" name="new_password" required>
      </label>

      <label>Confirm New Password
        <input type="password" name="confirm_password" required>
      </label>

      <button type="submit">Update Password</button>
    </form>

    <p><a href="login.php">Back to Login</a></p>
  </div>
</body>
</html>