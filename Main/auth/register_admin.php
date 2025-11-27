<?php
require_once __DIR__ . '/../config.php';

$error = '';
$success = '';

// Check if superadmin already exists
$stmt = $pdo->query("SELECT COUNT(*) FROM users WHERE role='superadmin'");
$superadmin_exists = $stmt->fetchColumn() > 0;

if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    $name    = trim($_POST['name'] ?? '');
    $email   = trim($_POST['email'] ?? '');
    $pass    = $_POST['password'] ?? '';
    $confirm = $_POST['confirm_password'] ?? '';
    $secret  = trim($_POST['secret'] ?? '');

    // Validate fields
    if (!$name || !$email || !$pass || (!$superadmin_exists && $confirm === '')) {
        $error = "All fields are required.";
    }
    elseif ($pass !== $confirm) {
        $error = "Passwords do not match.";
    }
    // Improved password rule — includes digits requirement
    elseif (!preg_match('/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*\W).{8,16}$/', $pass)) {
        $error = "Password must be 8–16 chars with uppercase, lowercase, number, and a special character.";
    }
    else {

        // Creating FIRST superadmin
        if (!$superadmin_exists) {

            // Prevent entering admin key for superadmin
            if (!empty($secret)) {
                $error = "Super Admin creation must NOT use an admin key.";
            } else {

                // Check if email already in use
                $stmt = $pdo->prepare("SELECT COUNT(*) FROM users WHERE email=?");
                $stmt->execute([$email]);

                if ($stmt->fetchColumn() > 0) {
                    $error = "Email already registered.";
                } else {

                    // Create superadmin (verified = 1)
                    $hash = password_hash($pass, PASSWORD_DEFAULT);
                    $stmt = $pdo->prepare("
                        INSERT INTO users (name, email, password, role, verified, created_at)
                        VALUES (?, ?, ?, 'superadmin', 1, NOW())
                    ");
                    $stmt->execute([$name, $email, $hash]);

                    $success = "Super Admin created successfully. You may now log in.";
                    $superadmin_exists = true;
                }
            }
        }

        // Creating NORMAL admin (superadmin already exists)
        else {

            if (!$secret || $secret !== ADMIN_SECRET_KEY) {
                $error = "Invalid admin registration key.";
            } else {

                $stmt = $pdo->prepare("SELECT COUNT(*) FROM users WHERE email=?");
                $stmt->execute([$email]);

                if ($stmt->fetchColumn() > 0) {
                    $error = "Email already registered.";
                } else {

                    $hash = password_hash($pass, PASSWORD_DEFAULT);

                    $stmt = $pdo->prepare("
                        INSERT INTO users (name,email,password,role,verified,created_at)
                        VALUES (?, ?, ?, 'admin', 1, NOW())
                    ");
                    $stmt->execute([$name, $email, $hash]);

                    $success = "Admin created successfully! You can now log in.";
                }
            }
        }
    }
}
?>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>CozyDorms — Admin Registration</title>
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <link rel="stylesheet" href="../assets/style.css">

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
      background: #fff; padding: 2rem; border-radius: 16px; width: 350px;
      box-shadow: 0 8px 20px rgba(0,0,0,0.1); text-align: center;
    }
    .auth-card h1 {
      margin-bottom: 1.5rem; font-size: 1.8rem; color: #2c2c2c;
    }
    .alert { padding: 0.7rem; border-radius: 6px; margin-bottom: 1rem; font-size: 0.9rem; }
    .alert.error { background: #f8d7da; color: #721c24; }
    .alert.success { background: #dcfce7; color: #166534; }
    form { display: flex; flex-direction: column; gap: 1rem; }
    form label { font-weight: 500; text-align: left; font-size: 0.9rem; }
    form input {
      width: 100%; padding: 0.7rem; border: 1px solid #ccc;
      border-radius: 8px; font-size: 0.95rem;
    }
    button {
      background: #6a5acd; color: #fff; border: none; padding: 0.8rem;
      border-radius: 10px; font-size: 1rem; cursor: pointer; transition: background 0.2s;
    }
    button:hover { background: #5848c2; }
    p { margin-top: 1rem; font-size: 0.9rem; }
    p a { color: #6a5acd; text-decoration: none; font-weight: 500; }
    p a:hover { text-decoration: underline; }
  </style>
</head>

<body>
  <div class="auth-card">
    <h1>
      <?= !$superadmin_exists ? "Create Super Admin" : "Register Admin" ?>
    </h1>

    <?php if ($error): ?><div class="alert error"><?=$error?></div><?php endif; ?>
    <?php if ($success): ?><div class="alert success"><?=$success?></div><?php endif; ?>

    <form method="post" autocomplete="off">

      <label>Full Name
        <input type="text" name="name" required>
      </label>

      <label>Email
        <input type="email" name="email" required>
      </label>

      <label>Password
        <input type="password" name="password" required minlength="8" maxlength="16">
      </label>

      <label>Confirm Password
        <input type="password" name="confirm_password" required minlength="8" maxlength="16">
      </label>

      <?php if ($superadmin_exists): ?>
      <!-- Only show admin key when superadmin already exists -->
      <label>Admin Registration Key
        <input type="text" name="secret" placeholder="Enter secret key" required>
      </label>
      <?php endif; ?>

      <button type="submit">
        <?= !$superadmin_exists ? "Create Super Admin" : "Register Admin" ?>
      </button>
    </form>

    <p>Already have an account? <a href="login.php">Login</a></p>
  </div>
</body>
</html>