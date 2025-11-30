<?php
require_once __DIR__ . '/../../auth/auth.php';
require_role('superadmin'); 

$user = current_user();
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Student Management — CozyDorms</title>
    <link rel="stylesheet" href="/styles/global.css">
</head>
<body>

<h1>Student Management</h1>
<p>Welcome, <?= htmlspecialchars($user['name']) ?>.  
This page will manage student accounts, statuses, and reports.</p>

<p><strong>Note:</strong> This page is currently a placeholder.</p>

<a href="/dashboards/superadmin_dashboard.php">← Back to Dashboard</a>

</body>
</html>