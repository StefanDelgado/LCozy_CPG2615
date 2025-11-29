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

try {
    // Fetch admin details
    $stmt = $conn->prepare("SELECT * FROM users WHERE user_id = ? AND role = 'admin'");
    $stmt->execute([$adminId]);
    $admin = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$admin) {
        header("Location: superadmin_management.php?msg=Admin+not+found");
        exit;
    }
    
    $conn->beginTransaction();
    
    // Remove all privileges
    $deletePrivStmt = $conn->prepare("DELETE FROM admin_privileges WHERE admin_user_id = ?");
    $deletePrivStmt->execute([$adminId]);
    
    // Change role back to student or owner (keep their original role if possible)
    // For simplicity, we'll change to 'student'
    $updateRoleStmt = $conn->prepare("UPDATE users SET role = 'student' WHERE user_id = ?");
    $updateRoleStmt->execute([$adminId]);
    
    // Log the action
    $logStmt = $conn->prepare("
        INSERT INTO admin_audit_log (admin_user_id, action_type, target_user_id, action_details, ip_address)
        VALUES (?, 'revoke_admin', ?, ?, ?)
    ");
    $logStmt->execute([
        $superAdminId,
        $adminId,
        "Revoked admin privileges for {$admin['name']} ({$admin['email']}). Role changed to student.",
        $_SERVER['REMOTE_ADDR']
    ]);
    
    $conn->commit();
    header("Location: superadmin_management.php?msg=Admin+privileges+revoked+successfully");
    
} catch (Exception $e) {
    $conn->rollBack();
    header("Location: superadmin_management.php?msg=Error:+{$e->getMessage()}");
    exit;
}
?>
