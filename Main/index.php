<?php
session_start();

if (isset($_SESSION['user'])) {
    $role = $_SESSION['user']['role'] ?? '';

    switch ($role) {
        case 'admin':
            header('Location: /dashboards/admin_dashboard.php');
            exit;
        case 'owner':
            header('Location: /dashboards/owner_dashboard.php');
            exit;
        case 'student':
            header('Location: /dashboards/student_dashboard.php');
            exit;
    }
}

header('Location: /auth/login.php');
exit;