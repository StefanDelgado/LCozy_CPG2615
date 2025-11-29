<?php
require_once '../../auth/auth.php';
require_role(['superadmin']); // ONLY SUPER ADMIN

require_once '../../config.php';

$adminId = $_GET['id'] ?? null;

if (!$adminId) {
    header("Location: superadmin_management.php?msg=Invalid+admin+ID");
    exit;
}

$currentUser = current_user();
$superAdminId = $currentUser['user_id'];

// Fetch admin details
$stmt = $pdo->prepare("
    SELECT u.*, 
           GROUP_CONCAT(ap.privilege_name) AS privileges
    FROM users u
    LEFT JOIN admin_privileges ap ON u.user_id = ap.admin_user_id
    WHERE u.user_id = ? AND u.role = 'admin'
    GROUP BY u.user_id
");
$stmt->execute([$adminId]);
$admin = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$admin) {
    header("Location: superadmin_management.php?msg=Admin+not+found");
    exit;
}

// Handle privilege update
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $selectedPrivileges = $_POST['privileges'] ?? [];
    
    try {
        $pdo->beginTransaction();
        
        // Remove all existing privileges
        $deleteStmt = $pdo->prepare("DELETE FROM admin_privileges WHERE admin_user_id = ?");
        $deleteStmt->execute([$adminId]);
        
        // Insert selected privileges
        if (!empty($selectedPrivileges)) {
            $insertStmt = $pdo->prepare("
                INSERT INTO admin_privileges (admin_user_id, privilege_name, granted_by) 
                VALUES (?, ?, ?)
            ");
            
            foreach ($selectedPrivileges as $privilege) {
                $insertStmt->execute([$adminId, $privilege, $superAdminId]);
            }
        }
        
        // Log the action
        $logStmt = $pdo->prepare("
            INSERT INTO admin_audit_log (admin_user_id, action_type, target_user_id, action_details, ip_address)
            VALUES (?, 'update_privileges', ?, ?, ?)
        ");
        $logStmt->execute([
            $superAdminId,
            $adminId,
            "Updated privileges for {$admin['name']}: " . implode(', ', $selectedPrivileges),
            $_SERVER['REMOTE_ADDR']
        ]);
        
        $pdo->commit();
        header("Location: superadmin_management.php?msg=Privileges+updated+successfully");
        exit;
        
    } catch (Exception $e) {
        $pdo->rollBack();
        header("Location: manage_admin_privileges.php?id=$adminId&msg=Error:+{$e->getMessage()}");
        exit;
    }
}

$currentPrivileges = $admin['privileges'] ? explode(',', $admin['privileges']) : [];

// Available privileges
$availablePrivileges = [
    'manage_users' => [
        'name' => 'Manage Users',
        'description' => 'Create, edit, and delete user accounts (students and owners)',
        'icon' => 'fa-users'
    ],
    'approve_owners' => [
        'name' => 'Approve Owners',
        'description' => 'Verify and approve owner account applications',
        'icon' => 'fa-user-check'
    ],
    'manage_reviews' => [
        'name' => 'Manage Reviews',
        'description' => 'Moderate, edit, and delete inappropriate reviews',
        'icon' => 'fa-star'
    ],
    'manage_payments' => [
        'name' => 'Manage Payments',
        'description' => 'View payment history and manage payment disputes',
        'icon' => 'fa-dollar-sign'
    ],
    'manage_dorms' => [
        'name' => 'Manage Dorms',
        'description' => 'Approve or reject dorm listings and edit dorm information',
        'icon' => 'fa-building'
    ],
    'view_reports' => [
        'name' => 'View Reports',
        'description' => 'Access system reports, analytics, and statistics',
        'icon' => 'fa-chart-bar'
    ],
    'manage_bookings' => [
        'name' => 'Manage Bookings',
        'description' => 'Handle booking disputes, cancellations, and refunds',
        'icon' => 'fa-calendar-check'
    ]
];

$pageTitle = "Manage Admin Privileges";
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo $pageTitle; ?></title>
    <link rel="stylesheet" href="../../assets/css/admin.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .privilege-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }
        
        .privilege-card {
            background: white;
            border: 2px solid #e5e7eb;
            border-radius: 10px;
            padding: 20px;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .privilege-card:hover {
            border-color: #3b82f6;
            box-shadow: 0 4px 6px rgba(59, 130, 246, 0.1);
        }
        
        .privilege-card.selected {
            border-color: #3b82f6;
            background: linear-gradient(135deg, #eff6ff 0%, #dbeafe 100%);
        }
        
        .privilege-card .icon {
            width: 50px;
            height: 50px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 24px;
            margin-bottom: 15px;
        }
        
        .privilege-card.selected .icon {
            background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
        }
        
        .privilege-card h3 {
            margin: 0 0 8px 0;
            color: #1f2937;
            font-size: 16px;
        }
        
        .privilege-card p {
            margin: 0;
            color: #6b7280;
            font-size: 14px;
            line-height: 1.5;
        }
        
        .privilege-card input[type="checkbox"] {
            display: none;
        }
        
        .privilege-card .check-indicator {
            position: absolute;
            top: 15px;
            right: 15px;
            width: 24px;
            height: 24px;
            border: 2px solid #d1d5db;
            border-radius: 6px;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s;
        }
        
        .privilege-card.selected .check-indicator {
            background: #3b82f6;
            border-color: #3b82f6;
        }
        
        .privilege-card.selected .check-indicator::after {
            content: '\f00c';
            font-family: 'Font Awesome 6 Free';
            font-weight: 900;
            color: white;
            font-size: 12px;
        }
        
        .admin-info {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 25px;
            border-radius: 10px;
            margin-bottom: 30px;
        }
        
        .admin-info h2 {
            margin: 0 0 10px 0;
            font-size: 24px;
        }
        
        .admin-info p {
            margin: 5px 0;
            opacity: 0.9;
        }
        
        .btn-container {
            display: flex;
            gap: 15px;
            margin-top: 30px;
        }
        
        .btn {
            padding: 12px 30px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 600;
            text-decoration: none;
            display: inline-block;
            transition: all 0.3s;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
            color: white;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(59, 130, 246, 0.4);
        }
        
        .btn-secondary {
            background: #e5e7eb;
            color: #374151;
        }
        
        .btn-secondary:hover {
            background: #d1d5db;
        }
        
        body {
            margin: 0;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background-color: #f3f4f6;
        }
        
        .top-nav {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 15px 30px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .top-nav h2 {
            margin: 0;
            font-size: 20px;
        }
        
        .top-nav a {
            color: white;
            text-decoration: none;
            padding: 8px 16px;
            border-radius: 6px;
            background: rgba(255,255,255,0.2);
            transition: all 0.3s;
            margin-left: 10px;
        }
        
        .top-nav a:hover {
            background: rgba(255,255,255,0.3);
        }
    </style>
</head>
<body>
    <!-- Top Navigation -->
    <div class="top-nav">
        <h2><i class="fas fa-key"></i> LCozy Admin Privileges</h2>
        <div>
            <a href="superadmin_management.php"><i class="fas fa-arrow-left"></i> Back to Super Admin</a>
            <a href="../../dashboards/admin_dashboard.php"><i class="fas fa-home"></i> Dashboard</a>
        </div>
    </div>
    
    <div class="main-container" style="margin: 0; width: 100%; padding: 30px; max-width: 1200px; margin: 0 auto;">
        
        <main class="main-content" style="margin: 0; width: 100%;">
            <div class="page-header" style="margin-bottom: 30px;">
                <h1><i class="fas fa-key"></i> Manage Admin Privileges</h1>
                <p>Configure privileges for admin users</p>
            </div>
            
            <div class="admin-info">
                <h2><i class="fas fa-user-shield"></i> <?php echo htmlspecialchars($admin['name']); ?></h2>
                <p><i class="fas fa-envelope"></i> <?php echo htmlspecialchars($admin['email']); ?></p>
                <p><i class="fas fa-calendar"></i> Admin since: <?php echo date('F d, Y', strtotime($admin['created_at'])); ?></p>
            </div>
            
            <form method="POST">
                <h3 style="margin-bottom: 10px; color: #1f2937;">
                    <i class="fas fa-list-check"></i> Select Privileges
                </h3>
                <p style="color: #6b7280; margin-bottom: 20px;">
                    Click on the cards to grant or revoke specific privileges for this admin.
                </p>
                
                <div class="privilege-grid">
                    <?php foreach ($availablePrivileges as $key => $privilege): ?>
                        <div class="privilege-card <?php echo in_array($key, $currentPrivileges) ? 'selected' : ''; ?>" 
                             onclick="togglePrivilege(this, '<?php echo $key; ?>')">
                            <div class="check-indicator"></div>
                            <div class="icon">
                                <i class="fas <?php echo $privilege['icon']; ?>"></i>
                            </div>
                            <h3><?php echo $privilege['name']; ?></h3>
                            <p><?php echo $privilege['description']; ?></p>
                            <input type="checkbox" 
                                   name="privileges[]" 
                                   value="<?php echo $key; ?>" 
                                   <?php echo in_array($key, $currentPrivileges) ? 'checked' : ''; ?>>
                        </div>
                    <?php endforeach; ?>
                </div>
                
                <div class="btn-container">
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save"></i> Save Privileges
                    </button>
                    <a href="superadmin_management.php" class="btn btn-secondary">
                        <i class="fas fa-times"></i> Cancel
                    </a>
                </div>
            </form>
            
        </main>
    </div>
    
    <script>
        function togglePrivilege(card, privilegeKey) {
            const checkbox = card.querySelector('input[type="checkbox"]');
            checkbox.checked = !checkbox.checked;
            card.classList.toggle('selected');
        }
    </script>
</body>
</html>
