<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

require_once '../../auth/auth.php';
require_role(['superadmin']); // ONLY SUPER ADMIN CAN ACCESS THIS PAGE

require_once '../../config.php';

$pageTitle = "Super Admin - Admin Management";
$activePage = "superadmin";

// Get message if any
$msg = $_GET['msg'] ?? null;

// Fetch all admin requests
$adminRequestsStmt = $pdo->prepare("
    SELECT 
        ar.*,
        u.name AS requester_name,
        u.email AS requester_email,
        u.role AS user_role,
        ru.name AS reviewer_name
    FROM admin_approval_requests ar
    INNER JOIN users u ON ar.requester_user_id = u.user_id
    LEFT JOIN users ru ON ar.reviewed_by = ru.user_id
    ORDER BY 
        FIELD(ar.status, 'pending', 'approved', 'rejected'),
        ar.created_at DESC
");
$adminRequestsStmt->execute();
$adminRequests = $adminRequestsStmt->fetchAll(PDO::FETCH_ASSOC);

// Fetch all admins
$adminsStmt = $pdo->prepare("
    SELECT 
        u.*,
        COUNT(DISTINCT ap.privilege_id) AS privilege_count,
        GROUP_CONCAT(DISTINCT ap.privilege_name) AS privileges
    FROM users u
    LEFT JOIN admin_privileges ap ON u.user_id = ap.admin_user_id
    WHERE u.role IN ('admin', 'superadmin')
    GROUP BY u.user_id
    ORDER BY FIELD(u.role, 'superadmin', 'admin'), u.created_at
");
$adminsStmt->execute();
$admins = $adminsStmt->fetchAll(PDO::FETCH_ASSOC);

// Get recent super admin actions
$auditStmt = $pdo->prepare("
    SELECT 
        al.*,
        au.name AS admin_name,
        tu.name AS target_name,
        tu.email AS target_email
    FROM admin_audit_log al
    INNER JOIN users au ON al.admin_user_id = au.user_id
    LEFT JOIN users tu ON al.target_user_id = tu.user_id
    ORDER BY al.created_at DESC
    LIMIT 20
");
$auditStmt->execute();
$auditLogs = $auditStmt->fetchAll(PDO::FETCH_ASSOC);

// Available privileges
$availablePrivileges = [
    'manage_users' => 'Create, edit, and delete users',
    'approve_owners' => 'Verify and approve owner accounts',
    'manage_reviews' => 'Moderate and manage reviews',
    'manage_payments' => 'View and manage payment disputes',
    'manage_dorms' => 'Approve or reject dorm listings',
    'view_reports' => 'Access system reports and analytics',
    'manage_bookings' => 'Manage booking disputes and cancellations'
];
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
        }
        
        .top-nav a:hover {
            background: rgba(255,255,255,0.3);
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        
        .stat-card h3 {
            margin: 0 0 10px 0;
            font-size: 14px;
            opacity: 0.9;
        }
        
        .stat-card .number {
            font-size: 32px;
            font-weight: bold;
            margin: 0;
        }
        
        .status-badge {
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }
        
        .status-pending {
            background-color: #fef3c7;
            color: #92400e;
        }
        
        .status-approved {
            background-color: #d1fae5;
            color: #065f46;
        }
        
        .status-rejected {
            background-color: #fee2e2;
            color: #991b1b;
        }
        
        .role-badge {
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }
        
        .role-superadmin {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        
        .role-admin {
            background-color: #dbeafe;
            color: #1e40af;
        }
        
        .privilege-tag {
            display: inline-block;
            background-color: #e0e7ff;
            color: #3730a3;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 11px;
            margin: 2px;
        }
        
        .action-buttons {
            display: flex;
            gap: 8px;
        }
        
        .btn {
            padding: 8px 16px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 14px;
            text-decoration: none;
            display: inline-block;
            transition: all 0.3s;
        }
        
        .btn-primary {
            background-color: #3b82f6;
            color: white;
        }
        
        .btn-primary:hover {
            background-color: #2563eb;
        }
        
        .btn-success {
            background-color: #10b981;
            color: white;
        }
        
        .btn-success:hover {
            background-color: #059669;
        }
        
        .btn-danger {
            background-color: #ef4444;
            color: white;
        }
        
        .btn-danger:hover {
            background-color: #dc2626;
        }
        
        .alert {
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
        }
        
        .alert-success {
            background-color: #d1fae5;
            color: #065f46;
            border: 1px solid #10b981;
        }
        
        .alert-danger {
            background-color: #fee2e2;
            color: #991b1b;
            border: 1px solid #ef4444;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        }
        
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #e5e7eb;
        }
        
        th {
            background-color: #f9fafb;
            font-weight: 600;
            color: #374151;
        }
        
        .section {
            background: white;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 30px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        }
        
        .section h2 {
            margin-top: 0;
            color: #1f2937;
            display: flex;
            align-items: center;
            gap: 10px;
        }
    </style>
</head>
<body>
    <!-- Top Navigation -->
    <div class="top-nav">
        <h2><i class="fas fa-crown"></i> LCozy Super Admin</h2>
        <div>
            <a href="../../dashboards/superadmin_dashboard.php"><i class="fas fa-arrow-left"></i> Back to Dashboard</a>
            <a href="../../auth/logout.php"><i class="fas fa-sign-out-alt"></i> Logout</a>
        </div>
    </div>
    
    <div class="main-container" style="margin: 0; width: 100%; padding: 30px; max-width: 1400px; margin: 0 auto;">
        
        <main class="main-content" style="margin: 0; width: 100%;">
            <div class="page-header" style="margin-bottom: 30px;">
                <h1><i class="fas fa-crown"></i> Super Admin Management</h1>
                <p>Manage admin privileges and approval requests</p>
            </div>
            
            <?php if ($msg): ?>
                <div class="alert alert-<?php echo strpos($msg, 'success') !== false ? 'success' : 'danger'; ?>">
                    <?php echo htmlspecialchars(str_replace('+', ' ', $msg)); ?>
                </div>
            <?php endif; ?>
            
            <!-- Statistics -->
            <div class="stats-grid">
                <div class="stat-card">
                    <h3>Total Admins</h3>
                    <p class="number"><?php echo count(array_filter($admins, fn($a) => $a['role'] === 'admin')); ?></p>
                </div>
                <div class="stat-card">
                    <h3>Pending Requests</h3>
                    <p class="number"><?php echo count(array_filter($adminRequests, fn($r) => $r['status'] === 'pending')); ?></p>
                </div>
                <div class="stat-card">
                    <h3>Total Privileges Granted</h3>
                    <p class="number"><?php echo array_sum(array_column(array_filter($admins, fn($a) => $a['role'] === 'admin'), 'privilege_count')); ?></p>
                </div>
                <div class="stat-card">
                    <h3>Audit Log Entries</h3>
                    <p class="number"><?php echo count($auditLogs); ?></p>
                </div>
            </div>
            
            <!-- Admin Approval Requests -->
            <div class="section">
                <h2>
                    <i class="fas fa-user-check"></i>
                    Admin Approval Requests
                </h2>
                
                <?php if (empty($adminRequests)): ?>
                    <p style="color: #6b7280;">No admin requests at this time.</p>
                <?php else: ?>
                    <table>
                        <thead>
                            <tr>
                                <th>Requester</th>
                                <th>Email</th>
                                <th>Current Role</th>
                                <th>Reason</th>
                                <th>Status</th>
                                <th>Date</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($adminRequests as $request): ?>
                                <tr>
                                    <td><strong><?php echo htmlspecialchars($request['requester_name']); ?></strong></td>
                                    <td><?php echo htmlspecialchars($request['requester_email']); ?></td>
                                    <td><span class="role-badge"><?php echo ucfirst($request['user_role']); ?></span></td>
                                    <td><?php echo htmlspecialchars($request['reason'] ?? 'No reason provided'); ?></td>
                                    <td>
                                        <span class="status-badge status-<?php echo $request['status']; ?>">
                                            <?php echo ucfirst($request['status']); ?>
                                        </span>
                                    </td>
                                    <td><?php echo date('M d, Y', strtotime($request['created_at'])); ?></td>
                                    <td>
                                        <?php if ($request['status'] === 'pending'): ?>
                                            <div class="action-buttons">
                                                <a href="process_admin_request.php?id=<?php echo $request['request_id']; ?>&action=approve" 
                                                   class="btn btn-success btn-sm"
                                                   onclick="return confirm('Approve this admin request?')">
                                                    <i class="fas fa-check"></i> Approve
                                                </a>
                                                <a href="process_admin_request.php?id=<?php echo $request['request_id']; ?>&action=reject" 
                                                   class="btn btn-danger btn-sm"
                                                   onclick="return confirm('Reject this admin request?')">
                                                    <i class="fas fa-times"></i> Reject
                                                </a>
                                            </div>
                                        <?php else: ?>
                                            <small style="color: #6b7280;">
                                                Reviewed by <?php echo htmlspecialchars($request['reviewer_name']); ?>
                                            </small>
                                        <?php endif; ?>
                                    </td>
                                </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                <?php endif; ?>
            </div>
            
            <!-- Current Admins -->
            <div class="section">
                <h2>
                    <i class="fas fa-users-cog"></i>
                    Admin Users & Privileges
                </h2>
                
                <table>
                    <thead>
                        <tr>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Role</th>
                            <th>Privileges</th>
                            <th>Joined</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($admins as $admin): ?>
                            <tr>
                                <td><strong><?php echo htmlspecialchars($admin['name']); ?></strong></td>
                                <td><?php echo htmlspecialchars($admin['email']); ?></td>
                                <td>
                                    <span class="role-badge role-<?php echo $admin['role']; ?>">
                                        <?php echo $admin['role'] === 'superadmin' ? '<i class="fas fa-crown"></i> ' : ''; ?>
                                        <?php echo ucfirst($admin['role']); ?>
                                    </span>
                                </td>
                                <td>
                                    <?php if ($admin['role'] === 'superadmin'): ?>
                                        <span class="privilege-tag"><i class="fas fa-infinity"></i> All Privileges</span>
                                    <?php elseif ($admin['privileges']): ?>
                                        <?php foreach (explode(',', $admin['privileges']) as $priv): ?>
                                            <span class="privilege-tag"><?php echo str_replace('_', ' ', ucfirst($priv)); ?></span>
                                        <?php endforeach; ?>
                                    <?php else: ?>
                                        <span style="color: #9ca3af;">No privileges assigned</span>
                                    <?php endif; ?>
                                </td>
                                <td><?php echo date('M d, Y', strtotime($admin['created_at'])); ?></td>
                                <td>
                                    <?php if ($admin['role'] === 'admin'): ?>
                                        <div class="action-buttons">
                                            <a href="manage_admin_privileges.php?id=<?php echo $admin['user_id']; ?>" 
                                               class="btn btn-primary btn-sm">
                                                <i class="fas fa-key"></i> Manage
                                            </a>
                                            <a href="revoke_admin.php?id=<?php echo $admin['user_id']; ?>" 
                                               class="btn btn-danger btn-sm"
                                               onclick="return confirm('Revoke admin privileges for <?php echo htmlspecialchars($admin['name']); ?>?')">
                                                <i class="fas fa-user-times"></i> Revoke
                                            </a>
                                        </div>
                                    <?php else: ?>
                                        <span style="color: #9ca3af;">Protected</span>
                                    <?php endif; ?>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
            
            <!-- Recent Activity -->
            <div class="section">
                <h2>
                    <i class="fas fa-history"></i>
                    Recent Super Admin Activity
                </h2>
                
                <?php if (empty($auditLogs)): ?>
                    <p style="color: #6b7280;">No recent activity.</p>
                <?php else: ?>
                    <table>
                        <thead>
                            <tr>
                                <th>Date</th>
                                <th>Admin</th>
                                <th>Action</th>
                                <th>Target User</th>
                                <th>Details</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($auditLogs as $log): ?>
                                <tr>
                                    <td><?php echo date('M d, Y H:i', strtotime($log['created_at'])); ?></td>
                                    <td><?php echo htmlspecialchars($log['admin_name']); ?></td>
                                    <td>
                                        <strong><?php echo str_replace('_', ' ', ucwords($log['action_type'])); ?></strong>
                                    </td>
                                    <td>
                                        <?php if ($log['target_name']): ?>
                                            <?php echo htmlspecialchars($log['target_name']); ?>
                                            <br><small style="color: #6b7280;"><?php echo htmlspecialchars($log['target_email']); ?></small>
                                        <?php else: ?>
                                            <span style="color: #9ca3af;">N/A</span>
                                        <?php endif; ?>
                                    </td>
                                    <td><?php echo htmlspecialchars($log['action_details'] ?? ''); ?></td>
                                </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                <?php endif; ?>
            </div>
            
        </main>
    </div>
    
    <script>
        // Auto-hide success messages after 5 seconds
        setTimeout(() => {
            const alerts = document.querySelectorAll('.alert-success');
            alerts.forEach(alert => {
                alert.style.transition = 'opacity 0.5s';
                alert.style.opacity = '0';
                setTimeout(() => alert.remove(), 500);
            });
        }, 5000);
    </script>
</body>
</html>
