<?php
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}
require_once __DIR__ . '/../config.php';

// Session timeout (seconds). Default: 30 minutes.
if (!defined('SESSION_TIMEOUT')) {
    define('SESSION_TIMEOUT', 1800);
}

// Enforce session timeout: if last activity exists and exceeded, destroy session and redirect to login
if (isset($_SESSION['last_activity']) && (time() - $_SESSION['last_activity']) > SESSION_TIMEOUT) {
    // Clean up session and redirect to login with timeout message
    session_unset();
    session_destroy();
    header('Location: /auth/login.php?msg=Session+timed+out');
    exit;
}

// Update last activity timestamp for active sessions
$_SESSION['last_activity'] = time();

function current_user() {
    return $_SESSION['user'] ?? null;
}

function login_required() {
    if (!isset($_SESSION['user'])) {
        header('Location: /auth/login.php');
        exit;
    }
}

function require_role($role) {
    login_required();
    $user = current_user();

    // SUPERADMIN OVERRIDE — can access EVERYTHING
    if ($user['role'] === 'superadmin') {
        return; // Always allow access
    }

    // Normal role checking
    if (is_array($role)) {
        if (!in_array($user['role'], $role)) {
            http_response_code(403);
            echo "Forbidden: This page is restricted.";
            exit;
        }
    } else {
        if ($user['role'] !== $role) {
            http_response_code(403);
            echo "Forbidden: This page is restricted.";
            exit;
        }
    }
}

function redirect_to_dashboard($role) {
    switch ($role) {
        case 'superadmin':
            header('Location: /dashboards/superadmin_dashboard.php');
            break;
        case 'admin':
            header('Location: /dashboards/admin_dashboard.php');
            break;
        case 'owner':
            header('Location: /dashboards/owner_dashboard.php');
            break;
        case 'student':
            header('Location: /dashboards/student_dashboard.php');
            break;
        default:
            header('Location: /auth/login.php');
    }
    exit;
}