<?php
require_once '../../auth/auth.php';
require_role(['superadmin']); // ONLY SUPER ADMIN

require_once '../../config.php';

$requestId = $_GET['id'] ?? null;
$action = $_GET['action'] ?? null;

if (!$requestId || !in_array($action, ['approve', 'reject'])) {
    header("Location: superadmin_management.php?msg=Invalid+request");
    exit;
}

$currentUser = current_user();
$superAdminId = $currentUser['user_id'];

try {
    // Fetch the request
    $stmt = $pdo->prepare("
        SELECT ar.*, u.name, u.email, u.role 
        FROM admin_approval_requests ar
        INNER JOIN users u ON ar.requester_user_id = u.user_id
        WHERE ar.request_id = ? AND ar.status = 'pending'
    ");
    $stmt->execute([$requestId]);
    $request = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$request) {
        header("Location: superadmin_management.php?msg=Request+not+found+or+already+processed");
        exit;
    }
    
    $pdo->beginTransaction();
    
    if ($action === 'approve') {
        // Update user role to admin
        $updateUserStmt = $pdo->prepare("UPDATE users SET role = 'admin' WHERE user_id = ?");
        $updateUserStmt->execute([$request['requester_user_id']]);
        
        // Grant default privileges to new admin
        $defaultPrivileges = ['manage_users', 'approve_owners', 'view_reports'];
        $privilegeStmt = $pdo->prepare("
            INSERT INTO admin_privileges (admin_user_id, privilege_name, granted_by) 
            VALUES (?, ?, ?)
        ");
        
        foreach ($defaultPrivileges as $privilege) {
            $privilegeStmt->execute([
                $request['requester_user_id'],
                $privilege,
                $superAdminId
            ]);
        }
        
        // Update request status
        $updateRequestStmt = $pdo->prepare("
            UPDATE admin_approval_requests 
            SET status = 'approved', reviewed_by = ?, reviewed_at = NOW(), review_notes = 'Approved by super admin'
            WHERE request_id = ?
        ");
        $updateRequestStmt->execute([$superAdminId, $requestId]);
        
        // Log the action
        $logStmt = $pdo->prepare("
            INSERT INTO admin_audit_log (admin_user_id, action_type, target_user_id, action_details, ip_address)
            VALUES (?, 'approve_admin', ?, ?, ?)
        ");
        $logStmt->execute([
            $superAdminId,
            $request['requester_user_id'],
            "Approved admin request for {$request['name']} ({$request['email']}). Granted default privileges: " . implode(', ', $defaultPrivileges),
            $_SERVER['REMOTE_ADDR']
        ]);
        
        $pdo->commit();
        header("Location: superadmin_management.php?msg=Admin+request+approved+successfully");
        
    } else { // reject
        // Update request status
        $updateRequestStmt = $pdo->prepare("
            UPDATE admin_approval_requests 
            SET status = 'rejected', reviewed_by = ?, reviewed_at = NOW(), review_notes = 'Rejected by super admin'
            WHERE request_id = ?
        ");
        $updateRequestStmt->execute([$superAdminId, $requestId]);
        
        // Log the action
        $logStmt = $pdo->prepare("
            INSERT INTO admin_audit_log (admin_user_id, action_type, target_user_id, action_details, ip_address)
            VALUES (?, 'reject_admin_request', ?, ?, ?)
        ");
        $logStmt->execute([
            $superAdminId,
            $request['requester_user_id'],
            "Rejected admin request for {$request['name']} ({$request['email']})",
            $_SERVER['REMOTE_ADDR']
        ]);
        
        $pdo->commit();
        header("Location: superadmin_management.php?msg=Admin+request+rejected");
    }
    
} catch (Exception $e) {
    $pdo->rollBack();
    header("Location: superadmin_management.php?msg=Error:+{$e->getMessage()}");
    exit;
}
?>
