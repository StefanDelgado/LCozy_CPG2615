<?php
require_once __DIR__ . '/config.php';

function current_user() {
    return $_SESSION['user'] ?? null;
}

function login_required() {
    if (!isset($_SESSION['user'])) {
        header('Location: /CAPSTONE/login.php');
        exit;
    }
}

function require_role($role) {
    login_required();
    $user = current_user();

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
        case 'admin':
            header('Location: /CAPSTONE/dashboard.php');
            break;
        case 'owner':
            header('Location: /CAPSTONE/owner_dashboard.php');
            break;
        case 'student':
            header('Location: /CAPSTONE/student_dashboard.php');
            break;
        default:
            header('Location: /CAPSTONE/login.php');
    }
    exit;
}