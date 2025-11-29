<?php
require_once __DIR__ . '/../auth/auth.php';
require_role('superadmin'); // Only superadmin can access

$user = current_user();
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Super Admin Dashboard — CozyDorms</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <style>
        body {
            margin: 0;
            font-family: 'Segoe UI', Tahoma, sans-serif;
            background: #f5f7fb;
            display: flex;
            height: 100vh;
        }

        /* Sidebar */
        .sidebar {
            width: 250px;
            background: #4c3bcf;
            color: white;
            padding: 20px;
            box-sizing: border-box;
        }
        .sidebar h2 {
            margin-top: 0;
            font-size: 1.4rem;
        }
        .sidebar a {
            display: block;
            color: white;
            text-decoration: none;
            padding: 10px 0;
            margin: 5px 0;
            border-radius: 6px;
        }
        .sidebar a:hover {
            background: rgba(255,255,255,0.15);
        }

        /* Main content */
        .main {
            flex: 1;
            padding: 30px;
        }
        .card {
            background: white;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
        .logout-btn {
            background: #e63946;
            padding: 10px;
            color: white;
            text-align: center;
            display: block;
            border-radius: 6px;
            margin-top: 20px;
            text-decoration: none;
        }
        .logout-btn:hover {
            background: #c6283c;
        }
    </style>
</head>
<body>

    <!-- Sidebar -->
    <div class="sidebar">
        <h2>Super Admin</h2>
        <p>Welcome, <strong><?= htmlspecialchars($user['name']) ?></strong></p>

        <a href="/modules/admin/superadmin_management.php">Main Management</a>
        <a href="/modules/admin/admin_management.php">Admin Management</a>
        <a href="/modules/owner/owner_management.php">Owner Management</a>
        <a href="/modules/student/student_management.php">Student Management</a>

        <a class="logout-btn" href="/auth/logout.php">Logout</a>
    </div>

    <!-- Main Content -->
    <div class="main">
        <h1>Super Admin Dashboard</h1>

        <div class="card">
            <h2>System Overview</h2>
            <p>This area can include system data, metrics, or overview stats.</p>
        </div>

        <div class="card">
            <h2>Admin Controls</h2>
            <p>You have exclusive rights to approve, verify, and manage admin accounts.</p>
        </div>

        <div class="card">
            <h2>Platform Management</h2>
            <p>Configure global system settings, user permissions, and more.</p>
        </div>
    </div>

</body>
</html>