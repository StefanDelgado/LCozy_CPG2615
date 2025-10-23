<?php
require_once __DIR__ . '/../../../config.php';
require_once __DIR__ . '/../shared/cors.php';

header('Content-Type: application/json');

try {
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);

    // Validate required fields
    if (!isset($data['email']) || !isset($data['password']) || !isset($data['name']) || !isset($data['role'])) {
        echo json_encode(['error' => 'Missing required fields']);
        exit;
    }

    $name = trim($data['name']);
    $email = trim($data['email']);
    $password = $data['password'];
    $role = strtolower($data['role']);

    // Validate role
    if (!in_array($role, ['student', 'owner'])) {
        echo json_encode(['error' => 'Invalid role']);
        exit;
    }

    // Check if email exists
    $stmt = $pdo->prepare("SELECT COUNT(*) FROM users WHERE email = ?");
    $stmt->execute([$email]);
    if ($stmt->fetchColumn() > 0) {
        http_response_code(409); // Conflict
        echo json_encode(['success' => false, 'error' => 'Email already registered']);
        exit;
    }

    // Email domain logic
    $trusted_domains = ['gmail.com','yahoo.com','outlook.com','hotmail.com','icloud.com','protonmail.com','zoho.com','aol.com','ymail.com'];
    $fake_domains = ['example.com','email.com','test.com','mailinator.com','fake.com'];
    $email_domain = strtolower(substr(strrchr($email, '@'), 1));

    // Email cleanliness checks
    $is_clean = true;
    if (preg_match('/[._%+-]{2,}/', $email)) $is_clean = false;
    if (preg_match('/\.\./', $email)) $is_clean = false;
    if (preg_match('/^[._%+-]|[._%+-]$/', $email)) $is_clean = false;

    if (in_array($email_domain, $fake_domains)) {
        $verified_status = -1; // auto reject
        $message = 'Your email was rejected. Please use a valid email provider.';
    } elseif (in_array($email_domain, $trusted_domains) && $is_clean) {
        $verified_status = 1; // auto accept
        $message = 'Your email was automatically verified. Please check your email for activation.';
    } else {
        $verified_status = 0; // pending
        $message = 'Your email requires admin approval or further verification.';
    }

    // Insert new user
    $hash = password_hash($password, PASSWORD_DEFAULT);
    $stmt = $pdo->prepare("
        INSERT INTO users (name, email, password, role, created_at, verified) 
        VALUES (?, ?, ?, ?, NOW(), ?)
    ");
    $stmt->execute([$name, $email, $hash, $role, $verified_status]);

    echo json_encode([
        'success' => true,
        'verified' => $verified_status,
        'message' => $message
    ]);

} catch (Exception $e) {
    error_log('Registration API error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['error' => 'Server error']);
}