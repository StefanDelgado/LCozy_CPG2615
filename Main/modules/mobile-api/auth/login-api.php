<?php
require_once __DIR__ . '/../../../config.php';
require_once __DIR__ . '/../shared/cors.php';

// Ensure this endpoint returns JSON
header('Content-Type: application/json; charset=utf-8');

// Get JSON POST data
$json = file_get_contents('php://input');
$data = json_decode($json, true);

// Validate input
if (!isset($data['email']) || !isset($data['password'])) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'ok' => false,
        'error' => 'Email and password required'
    ]);
    exit;
}

$email = trim($data['email']);
$password = $data['password'];

try {
    // Query user
    $stmt = $pdo->prepare("
        SELECT user_id, name, email, password, role, verified 
        FROM users 
        WHERE email = ?
    ");
    $stmt->execute([$email]);
    $user = $stmt->fetch();

    if ($user && password_verify($password, $user['password'])) {
        // Check verification status: 1 = verified, 0 = pending, -1 = rejected
        if ((int)$user['verified'] !== 1) {
            if ((int)$user['verified'] === -1) {
                http_response_code(403);
                echo json_encode([
                    'success' => false,
                    'ok' => false,
                    'error' => 'Your account was rejected. Contact support.'
                ]);
            } else {
                http_response_code(403);
                echo json_encode([
                    'success' => false,
                    'ok' => false,
                    'error' => 'Your account is pending. Please activate your account or wait for admin approval.'
                ]);
            }
        } else {
            // Success - return user data without password
            unset($user['password']);
            http_response_code(200);
            echo json_encode([
                'success' => true,
                'ok' => true,
                'user_id' => $user['user_id'],
                'name' => $user['name'], 
                'email' => $user['email'],
                'role' => $user['role']
            ]);
        }
    } else {
        // Invalid credentials
        http_response_code(401);
        echo json_encode([
            'success' => false,
            'ok' => false,
            'error' => 'Invalid email or password'
        ]);
    }
} catch (Exception $e) {
    // Log error server-side
    error_log('Login API error: ' . $e->getMessage());
    
    // Return generic error to client
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'ok' => false,
        'error' => 'Server error occurred'
    ]);
}
