<?php
require_once __DIR__ . '/../auth/auth.php';
require_role('superadmin');

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
        .sidebar h2 { margin-top: 0; font-size: 1.4rem; }
        .sidebar a {
            display: block;
            color: white;
            text-decoration: none;
            padding: 10px 0;
            margin: 5px 0;
            border-radius: 6px;
        }
        .sidebar a:hover { background: rgba(255,255,255,0.15); }
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

        /* Main content */
        .main {
            flex: 1;
            padding: 30px;
        }

        /* Tabs */
        .tabs {
            display: flex;
            border-bottom: 2px solid #ddd;
            margin-bottom: 20px;
            gap: 5px;
        }
        .tab {
            padding: 12px 20px;
            cursor: pointer;
            background: #e6e6ff;
            border-radius: 6px 6px 0 0;
            font-weight: bold;
            transition: 0.2s;
        }
        .tab:hover {
            background: #d3d3ff;
        }
        .tab.active {
            background: white;
            border-bottom: 2px solid white;
        }

        .tab-content {
            display: none;
        }
        .tab-content.active {
            display: block;
        }

        /* Cards */
        .card {
            background: white;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }

    </style>

    <script>
        function switchTab(tabName) {
            document.querySelectorAll(".tab").forEach(t => t.classList.remove("active"));
            document.querySelectorAll(".tab-content").forEach(c => c.classList.remove("active"));

            document.getElementById("tab-" + tabName).classList.add("active");
            document.getElementById("content-" + tabName).classList.add("active");
        }
    </script>
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

    <!-- Main -->
    <div class="main">
        <h1>Super Admin Dashboard</h1>

        <!-- Tabs -->
        <div class="tabs">
            <div class="tab active" id="tab-admin" onclick="switchTab('admin')">Admin Dashboard</div>
            <div class="tab" id="tab-owner" onclick="switchTab('owner')">Owner Dashboard</div>
            <div class="tab" id="tab-student" onclick="switchTab('student')">Student Dashboard</div>
        </div>

        <!-- Admin Dashboard -->
        <div class="tab-content active" id="content-admin">
            <div class="card">
                <h2>Admin Overview</h2>
                <p>Manage admin accounts, privileges, and access roles.</p>
            </div>

            <div class="card">
                <h2>Admin Controls</h2>
                <p>Approve, remove, or modify admin-level permissions.</p>
            </div>
        </div>

        <!-- Owner Dashboard -->
        <div class="tab-content" id="content-owner">
            <div class="card">
                <h2>Owner Verification</h2>
                <p>Review owner profiles & license submissions.</p>
            </div>

            <div class="card">
                <h2>Property Management</h2>
                <p>Monitor property listings and owner activity logs.</p>
            </div>
        </div>

        <!-- Student Dashboard -->
        <div class="tab-content" id="content-student">
            <div class="card">
                <h2>Student Verification</h2>
                <p>Review pending student ID uploads for verification.</p>
            </div>

            <div class="card">
                <h2>Student Activity Tracking</h2>
                <p>Monitor bookings, reports, and user engagement.</p>
            </div>
        </div>

    </div>

</body>
</html>
