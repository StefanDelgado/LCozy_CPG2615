<?php
require_once __DIR__ . '/config.php';
require_once __DIR__ . '/auth.php';

$error = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
  $email = trim($_POST['email'] ?? '');
  $password = $_POST['password'] ?? '';

  $stmt = $pdo->prepare("SELECT user_id, name, email, password, role FROM users WHERE email = ?");
  $stmt->execute([$email]);
  $user = $stmt->fetch();

  if ($user && password_verify($password, $user['password'])) {
    $_SESSION['user'] = [
      'user_id' => $user['user_id'],
      'name'    => $user['name'],
      'email'   => $user['email'],
      'role'    => $user['role'],
    ];

    redirect_to_dashboard($user['role']);
  } else {
    $error = 'Invalid email or password';
  }
}
?>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>CozyDorms — Login</title>
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
    .auth-card .alert {
      background: #f8d7da;
      color: #721c24;
      padding: 0.7rem;
      border-radius: 6px;
      margin-bottom: 1rem;
      font-size: 0.9rem;
    }
    form {
      display: flex;
      flex-direction: column;
      gap: 1rem;
    }
    form label {
      font-weight: 500;
      text-align: left;
      color: #333;
      font-size: 0.9rem;
    }
    form input {
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
    p {
      margin-top: 1rem;
      font-size: 0.9rem;
    }
    p a {
      color: #6a5acd;
      text-decoration: none;
      font-weight: 500;
    }
    p a:hover {
      text-decoration: underline;
    }
  </style>
</head>
<body>
  <div class="auth-card">
    <h1>Welcome Back</h1>
    <?php if ($error): ?><div class="alert"><?=$error?></div><?php endif; ?>
    <form method="post" autocomplete="off">
      <label>Email
        <input type="email" name="email" required>
      </label>
      <label>Password
        <input type="password" name="password" required>
      </label>
      <button type="submit">Sign In</button>
    </form>
    <p>Don't have an account? <a href="register.php">Sign Up</a></p>
  </div>
</body>
</html>