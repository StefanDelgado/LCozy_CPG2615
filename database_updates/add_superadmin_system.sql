-- Add super admin functionality to LCozy system
-- This migration adds proper super admin role and privileges

-- Step 1: Update users table role enum to include 'superadmin'
ALTER TABLE `users` 
MODIFY COLUMN `role` ENUM('superadmin', 'admin', 'owner', 'student') NOT NULL DEFAULT 'student';

-- Step 2: Update the first admin to super admin (typically user_id = 1)
UPDATE `users` 
SET `role` = 'superadmin' 
WHERE `user_id` = 1 AND `role` = 'admin';

-- Step 3: Create admin_privileges table to track specific permissions
CREATE TABLE IF NOT EXISTS `admin_privileges` (
  `privilege_id` INT(11) NOT NULL AUTO_INCREMENT,
  `admin_user_id` INT(11) NOT NULL,
  `privilege_name` VARCHAR(100) NOT NULL COMMENT 'Permission name (e.g., manage_users, approve_owners, manage_reviews)',
  `granted_by` INT(11) DEFAULT NULL COMMENT 'Super admin who granted this privilege',
  `granted_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`privilege_id`),
  UNIQUE KEY `unique_admin_privilege` (`admin_user_id`, `privilege_name`),
  FOREIGN KEY (`admin_user_id`) REFERENCES `users`(`user_id`) ON DELETE CASCADE,
  FOREIGN KEY (`granted_by`) REFERENCES `users`(`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Step 4: Create admin_approval_requests table for new admin requests
CREATE TABLE IF NOT EXISTS `admin_approval_requests` (
  `request_id` INT(11) NOT NULL AUTO_INCREMENT,
  `requester_user_id` INT(11) NOT NULL COMMENT 'User requesting admin privileges',
  `requested_role` ENUM('admin') NOT NULL DEFAULT 'admin',
  `reason` TEXT DEFAULT NULL COMMENT 'Why they need admin access',
  `status` ENUM('pending', 'approved', 'rejected') NOT NULL DEFAULT 'pending',
  `reviewed_by` INT(11) DEFAULT NULL COMMENT 'Super admin who reviewed',
  `reviewed_at` DATETIME DEFAULT NULL,
  `review_notes` TEXT DEFAULT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`request_id`),
  FOREIGN KEY (`requester_user_id`) REFERENCES `users`(`user_id`) ON DELETE CASCADE,
  FOREIGN KEY (`reviewed_by`) REFERENCES `users`(`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Step 5: Create audit log for super admin actions
CREATE TABLE IF NOT EXISTS `admin_audit_log` (
  `log_id` INT(11) NOT NULL AUTO_INCREMENT,
  `admin_user_id` INT(11) NOT NULL COMMENT 'Admin who performed the action',
  `action_type` VARCHAR(100) NOT NULL COMMENT 'Type of action (e.g., grant_privilege, approve_admin, delete_user)',
  `target_user_id` INT(11) DEFAULT NULL COMMENT 'User affected by the action',
  `action_details` TEXT DEFAULT NULL COMMENT 'JSON or text details of the action',
  `ip_address` VARCHAR(45) DEFAULT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`),
  FOREIGN KEY (`admin_user_id`) REFERENCES `users`(`user_id`) ON DELETE CASCADE,
  FOREIGN KEY (`target_user_id`) REFERENCES `users`(`user_id`) ON DELETE SET NULL,
  INDEX `idx_admin_actions` (`admin_user_id`, `created_at`),
  INDEX `idx_action_type` (`action_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Step 6: Grant default full privileges to super admin
-- Available privileges for regular admins:
-- - manage_users: Create, edit, delete users
-- - approve_owners: Verify owner accounts
-- - manage_reviews: Moderate reviews
-- - manage_payments: View and manage payment disputes
-- - manage_dorms: Approve/reject dorm listings
-- - view_reports: Access system reports
-- - manage_bookings: Manage booking disputes

-- Super admins automatically have ALL privileges and don't need entries in admin_privileges

-- Step 7: Add helpful views for super admin dashboard
CREATE OR REPLACE VIEW `v_admin_summary` AS
SELECT 
    u.user_id,
    u.name,
    u.email,
    u.role,
    u.created_at,
    (SELECT COUNT(*) FROM admin_privileges WHERE admin_user_id = u.user_id) AS privilege_count,
    (SELECT GROUP_CONCAT(privilege_name) FROM admin_privileges WHERE admin_user_id = u.user_id) AS privileges
FROM users u
WHERE u.role IN ('admin', 'superadmin')
ORDER BY FIELD(u.role, 'superadmin', 'admin'), u.created_at;

-- Step 8: Insert default privilege records (optional - for documentation)
-- These will be referenced in the application but not enforced in DB
-- Superadmins bypass all privilege checks

-- Sample data for testing (uncomment if needed):
-- INSERT INTO admin_approval_requests (requester_user_id, requested_role, reason, status)
-- VALUES (2, 'admin', 'Need admin access to manage users', 'pending');

-- Verification queries:
-- SELECT * FROM users WHERE role = 'superadmin';
-- SELECT * FROM admin_privileges;
-- SELECT * FROM admin_approval_requests;
-- SELECT * FROM v_admin_summary;
