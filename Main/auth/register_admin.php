<?php
require_once __DIR__ . '/../config.php';

$error = '';
$success = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $name   = trim($_POST['name'] ?? '');
    $email  = trim($_POST['email'] ?? '');
    $pass   = $_POST['password'] ?? '';
    $secret = trim($_POST['secret'] ?? '');

    if (!$name || !$email || !$pass || !$secret) {
        $error = "All fields are required.";
    } elseif ($secret !== ADMIN_SECRET_KEY) {
        $error = "Invalid admin registration key.";
    } else {
        $stmt = $pdo->prepare("SELECT COUNT(*) FROM users WHERE email=?");
        $stmt->execute([$email]);
        if ($stmt->fetchColumn() > 0) {
            $error = "Email already registered.";
        } else {
            $hash = password_hash($pass, PASSWORD_DEFAULT);
            $stmt = $pdo->prepare("INSERT INTO users (name,email,password,role) VALUES (?,?,?,?)");
            $stmt->execute([$name,$email,$hash,'admin']);

            $success = "Admin account created successfully! You can now login.";
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
  <link rel="stylesheet" href="assets/style.css">
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
    .auth-card { background: #fff; padding: 2rem; border-radius: 16px; width: 350px;
      box-shadow: 0 8px 20px rgba(0,0,0,0.1); text-align: center; }
    .auth-card h1 { margin-bottom: 1.5rem; font-size: 1.8rem; color: #2c2c2c; }
    .alert { padding: 0.7rem; border-radius: 6px; margin-bottom: 1rem; font-size: 0.9rem; }
    .alert.error { background: #f8d7da; color: #721c24; }
    .alert.success { background: #dcfce7; color: #166534; }
    form { display: flex; flex-direction: column; gap: 1rem; }
    form label { font-weight: 500; text-align: left; font-size: 0.9rem; }
    form input { width: 100%; padding: 0.7rem; border: 1px solid #ccc;
      border-radius: 8px; font-size: 0.95rem; }
    button { background: #6a5acd; color: #fff; border: none; padding: 0.8rem;
      border-radius: 10px; font-size: 1rem; cursor: pointer; transition: background 0.2s; }
    button:hover { background: #5848c2; }
    p { margin-top: 1rem; font-size: 0.9rem; }
    p a { color: #6a5acd; text-decoration: none; font-weight: 500; }
    p a:hover { text-decoration: underline; }
  </style>
</head>
<body>
  <div class="auth-card">
    <h1>Register Admin</h1>
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
        <input type="password" name="password" required>
      </label>
      <label>Admin Registration Key
        <input type="text" name="secret" placeholder="Enter secret key" required>
      </label>
      <button type="submit">Register Admin</button>
    </form>
    <p>Already have an account? <a href="login.php">Login</a></p>
  </div>
</body>
</html>