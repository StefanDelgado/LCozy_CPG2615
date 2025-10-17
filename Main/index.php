<?php
session_start();

// If user is logged in, redirect to their dashboard
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

// If not logged in, show the landing page
header('Location: /public/index.php');
exit;