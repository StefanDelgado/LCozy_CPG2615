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
        echo json_encode(['error' => 'Email already registered']);
        exit;
    }

    // Insert new user
    $hash = password_hash($password, PASSWORD_DEFAULT);
    $stmt = $pdo->prepare("
        INSERT INTO users (name, email, password, role, created_at) 
        VALUES (?, ?, ?, ?, NOW())
    ");
    
    $stmt->execute([$name, $email, $hash, $role]);

    echo json_encode([
        'ok' => true,
        'message' => 'Registration successful'
    ]);

} catch (Exception $e) {
    error_log('Registration API error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['error' => 'Server error']);
}