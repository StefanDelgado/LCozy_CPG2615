<?php
session_start();

if (isset($_SESSION['user'])) {
    $role = $_SESSION['user']['role'] ?? '';

    switch ($role) {
        case 'admin':
            header('Location: /dashboard.php');
            exit;
        case 'owner':
            header('Location: /owner_dashboard.php');
            exit;
        case 'student':
            header('Location: /student_dashboard.php');
            exit;
    }
}

header('Location: login.php');
exit;