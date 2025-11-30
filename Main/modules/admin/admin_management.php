<?php
require_once __DIR__ . '/../../auth/auth.php';
require_role('superadmin'); 

$user = current_user();
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Admin Management — CozyDorms</title>
    <link rel="stylesheet" href="/styles/global.css">
</head>
<body>

<h1>Admin Management</h1>
<p>Welcome, <?= htmlspecialchars($user['name']) ?>.  
This module will allow you to view and manage all admin accounts.</p>

<p><strong>Note:</strong> This page is currently a placeholder.</p>

<a href="/dashboards/superadmin_dashboard.php">← Back to Dashboard</a>

</body>
</html>