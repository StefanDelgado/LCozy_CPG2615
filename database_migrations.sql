-- ============================================================
-- CozyDorm Database Migration Script
-- Version: 2.0
-- Date: October 18, 2025
-- Purpose: Add tenant management, payment types, and location features
-- ============================================================

-- Use the database
USE cozydorms;

-- ============================================================
-- SECTION 1: BOOKINGS TABLE UPDATES
-- Add 'completed' status for bookings
-- ============================================================

-- Update bookings table to add 'completed' and 'active' status
ALTER TABLE `bookings` 
MODIFY COLUMN `status` ENUM('pending','approved','rejected','cancelled','completed','active') 
NOT NULL DEFAULT 'pending';

-- Add check-in and check-out tracking columns
ALTER TABLE `bookings`
ADD COLUMN `check_in_date` DATETIME DEFAULT NULL COMMENT 'Actual check-in date/time',
ADD COLUMN `check_out_date` DATETIME DEFAULT NULL COMMENT 'Actual check-out date/time',
ADD COLUMN `booking_reference` VARCHAR(50) DEFAULT NULL COMMENT 'Unique booking reference code',
ADD INDEX idx_booking_reference (booking_reference),
ADD INDEX idx_check_in (check_in_date),
ADD INDEX idx_check_out (check_out_date);

-- Add comment to status field
ALTER TABLE `bookings`
MODIFY COLUMN `status` ENUM('pending','approved','rejected','cancelled','completed','active') 
NOT NULL DEFAULT 'pending' 
COMMENT 'pending=awaiting approval, approved=owner approved, active=currently occupying, completed=tenancy ended, rejected=owner declined, cancelled=student cancelled';

-- ============================================================
-- SECTION 2: PAYMENTS TABLE UPDATES
-- Add payment types and 'paid' status support
-- ============================================================

-- Add payment_type column to distinguish different payment types
ALTER TABLE `payments`
ADD COLUMN `payment_type` ENUM('downpayment','monthly','utility','deposit','other') 
DEFAULT 'monthly' 
COMMENT 'Type of payment: downpayment (initial), monthly (rent), utility (bills), deposit (security), other' 
AFTER `booking_id`;

-- Update payment status to include 'verified' and 'processing'
ALTER TABLE `payments`
MODIFY COLUMN `status` ENUM('pending','submitted','processing','paid','verified','expired','rejected') 
DEFAULT 'pending'
COMMENT 'pending=awaiting payment, submitted=receipt uploaded, processing=owner reviewing, paid=owner confirmed, verified=system verified, expired=past due, rejected=invalid receipt';

-- Add verification tracking
ALTER TABLE `payments`
ADD COLUMN `verified_by` INT DEFAULT NULL COMMENT 'User ID who verified the payment',
ADD COLUMN `verified_at` DATETIME DEFAULT NULL COMMENT 'When payment was verified',
ADD COLUMN `rejection_reason` TEXT DEFAULT NULL COMMENT 'Reason for rejection',
ADD COLUMN `payment_method` ENUM('cash','bank_transfer','gcash','paymaya','other') DEFAULT 'bank_transfer' COMMENT 'Method used for payment',
ADD COLUMN `reference_number` VARCHAR(100) DEFAULT NULL COMMENT 'Transaction/Reference number',
ADD INDEX idx_payment_type (payment_type),
ADD INDEX idx_payment_method (payment_method),
ADD INDEX idx_verified_by (verified_by);

-- Add foreign key for verified_by
ALTER TABLE `payments`
ADD CONSTRAINT fk_payment_verified_by 
FOREIGN KEY (verified_by) REFERENCES users(user_id) 
ON DELETE SET NULL;

-- ============================================================
-- SECTION 3: TENANTS TABLE
-- New table for tracking current and past tenants
-- ============================================================

CREATE TABLE IF NOT EXISTS `tenants` (
  `tenant_id` INT AUTO_INCREMENT PRIMARY KEY,
  `booking_id` INT NOT NULL,
  `student_id` INT NOT NULL,
  `dorm_id` INT NOT NULL,
  `room_id` INT NOT NULL,
  `status` ENUM('active','completed','terminated') DEFAULT 'active' 
    COMMENT 'active=currently occupying, completed=tenancy ended normally, terminated=early termination',
  `check_in_date` DATETIME NOT NULL COMMENT 'Actual check-in date/time',
  `check_out_date` DATETIME DEFAULT NULL COMMENT 'Actual check-out date/time',
  `expected_checkout` DATE DEFAULT NULL COMMENT 'Expected end date from booking',
  `total_paid` DECIMAL(10,2) DEFAULT 0.00 COMMENT 'Total amount paid during tenancy',
  `outstanding_balance` DECIMAL(10,2) DEFAULT 0.00 COMMENT 'Remaining balance if any',
  `notes` TEXT DEFAULT NULL COMMENT 'Additional notes about the tenancy',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  -- Foreign Keys
  FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE,
  FOREIGN KEY (student_id) REFERENCES users(user_id) ON DELETE CASCADE,
  FOREIGN KEY (dorm_id) REFERENCES dormitories(dorm_id) ON DELETE CASCADE,
  FOREIGN KEY (room_id) REFERENCES rooms(room_id) ON DELETE CASCADE,
  
  -- Indexes for performance
  INDEX idx_student (student_id),
  INDEX idx_dorm (dorm_id),
  INDEX idx_room (room_id),
  INDEX idx_status (status),
  INDEX idx_check_in (check_in_date),
  INDEX idx_check_out (check_out_date),
  INDEX idx_active_tenants (status, check_out_date),
  
  -- Unique constraint: one active tenancy per booking
  UNIQUE KEY unique_active_booking (booking_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci 
COMMENT='Tracks current and past tenants for dormitories';

-- ============================================================
-- SECTION 4: LOCATION FEATURES
-- Add latitude/longitude if not exists
-- ============================================================

-- Check if columns exist before adding (idempotent)
-- Add latitude and longitude to dormitories
ALTER TABLE `dormitories`
ADD COLUMN IF NOT EXISTS `latitude` DECIMAL(10,8) DEFAULT NULL COMMENT 'Latitude coordinate for map display',
ADD COLUMN IF NOT EXISTS `longitude` DECIMAL(11,8) DEFAULT NULL COMMENT 'Longitude coordinate for map display';

-- Add indexes for location-based queries
ALTER TABLE `dormitories`
ADD INDEX IF NOT EXISTS idx_location (latitude, longitude);

-- ============================================================
-- SECTION 5: DORM IMAGES TABLE
-- Support multiple images per dorm
-- ============================================================

CREATE TABLE IF NOT EXISTS `dorm_images` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `dorm_id` INT NOT NULL,
  `image_path` VARCHAR(255) NOT NULL COMMENT 'Path to image file',
  `is_cover` BOOLEAN DEFAULT 0 COMMENT 'Is this the cover/featured image',
  `display_order` INT DEFAULT 0 COMMENT 'Order for displaying images',
  `caption` VARCHAR(255) DEFAULT NULL COMMENT 'Optional image caption',
  `uploaded_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  -- Foreign Key
  FOREIGN KEY (dorm_id) REFERENCES dormitories(dorm_id) ON DELETE CASCADE,
  
  -- Indexes
  INDEX idx_dorm (dorm_id),
  INDEX idx_cover (is_cover),
  INDEX idx_order (display_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
COMMENT='Multiple images for each dormitory';

-- ============================================================
-- SECTION 6: USER PREFERENCES TABLE
-- Settings and preferences for users
-- ============================================================

CREATE TABLE IF NOT EXISTS `user_preferences` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `notification_email` BOOLEAN DEFAULT 1 COMMENT 'Receive email notifications',
  `notification_sms` BOOLEAN DEFAULT 0 COMMENT 'Receive SMS notifications',
  `notification_push` BOOLEAN DEFAULT 1 COMMENT 'Receive push notifications',
  `notification_payment_reminder` BOOLEAN DEFAULT 1 COMMENT 'Payment reminders',
  `notification_booking_updates` BOOLEAN DEFAULT 1 COMMENT 'Booking status updates',
  `notification_messages` BOOLEAN DEFAULT 1 COMMENT 'New message alerts',
  `privacy_profile_visible` BOOLEAN DEFAULT 1 COMMENT 'Profile visible to others',
  `privacy_show_phone` BOOLEAN DEFAULT 1 COMMENT 'Show phone number',
  `language` VARCHAR(10) DEFAULT 'en' COMMENT 'Preferred language',
  `timezone` VARCHAR(50) DEFAULT 'Asia/Manila' COMMENT 'User timezone',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  -- Foreign Key
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  
  -- Unique constraint
  UNIQUE KEY idx_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
COMMENT='User preferences and settings';

-- ============================================================
-- SECTION 7: PAYMENT SCHEDULES TABLE
-- Track scheduled/recurring payments
-- ============================================================

CREATE TABLE IF NOT EXISTS `payment_schedules` (
  `schedule_id` INT AUTO_INCREMENT PRIMARY KEY,
  `tenant_id` INT NOT NULL,
  `booking_id` INT NOT NULL,
  `payment_type` ENUM('monthly','utility','other') DEFAULT 'monthly',
  `amount` DECIMAL(10,2) NOT NULL,
  `due_date` DATE NOT NULL,
  `status` ENUM('pending','paid','overdue','waived') DEFAULT 'pending',
  `payment_id` INT DEFAULT NULL COMMENT 'Link to actual payment when paid',
  `notes` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  -- Foreign Keys
  FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id) ON DELETE CASCADE,
  FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE,
  FOREIGN KEY (payment_id) REFERENCES payments(payment_id) ON DELETE SET NULL,
  
  -- Indexes
  INDEX idx_tenant (tenant_id),
  INDEX idx_booking (booking_id),
  INDEX idx_due_date (due_date),
  INDEX idx_status (status),
  INDEX idx_overdue (status, due_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
COMMENT='Scheduled payments for tenants';

-- ============================================================
-- SECTION 8: DATA MIGRATION
-- Migrate existing data to new structure
-- ============================================================

-- Migrate existing dorm cover_image to dorm_images table
INSERT INTO `dorm_images` (dorm_id, image_path, is_cover, display_order)
SELECT dorm_id, cover_image, 1, 0
FROM dormitories
WHERE cover_image IS NOT NULL 
  AND cover_image != ''
  AND NOT EXISTS (
    SELECT 1 FROM dorm_images di 
    WHERE di.dorm_id = dormitories.dorm_id 
    AND di.is_cover = 1
  );

-- Generate booking reference codes for existing bookings
UPDATE bookings 
SET booking_reference = CONCAT('BK', LPAD(booking_id, 8, '0'))
WHERE booking_reference IS NULL;

-- Create tenant records for approved bookings
INSERT INTO tenants (booking_id, student_id, dorm_id, room_id, status, check_in_date, expected_checkout, notes)
SELECT 
  b.booking_id,
  b.student_id,
  r.dorm_id,
  b.room_id,
  CASE 
    WHEN b.status = 'approved' AND b.start_date <= CURDATE() AND b.end_date >= CURDATE() THEN 'active'
    WHEN b.status = 'approved' AND b.end_date < CURDATE() THEN 'completed'
    ELSE 'active'
  END as status,
  COALESCE(b.check_in_date, CONCAT(b.start_date, ' 12:00:00')),
  b.end_date,
  b.notes
FROM bookings b
JOIN rooms r ON b.room_id = r.room_id
WHERE b.status IN ('approved', 'active')
  AND NOT EXISTS (
    SELECT 1 FROM tenants t WHERE t.booking_id = b.booking_id
  );

-- Update booking status to 'active' for current tenants
UPDATE bookings b
JOIN tenants t ON b.booking_id = t.booking_id
SET b.status = 'active'
WHERE t.status = 'active' 
  AND b.status = 'approved'
  AND b.start_date <= CURDATE();

-- Calculate total_paid for each tenant from payments
UPDATE tenants t
SET total_paid = (
  SELECT COALESCE(SUM(p.amount), 0)
  FROM payments p
  WHERE p.booking_id = t.booking_id
    AND p.status IN ('paid', 'verified')
);

-- ============================================================
-- SECTION 9: TRIGGERS
-- Automatic updates for data integrity
-- ============================================================

-- Trigger: Update tenant status when booking ends
DELIMITER $$

DROP TRIGGER IF EXISTS update_tenant_on_booking_complete$$
CREATE TRIGGER update_tenant_on_booking_complete
AFTER UPDATE ON bookings
FOR EACH ROW
BEGIN
  IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
    UPDATE tenants 
    SET status = 'completed',
        check_out_date = NOW()
    WHERE booking_id = NEW.booking_id
      AND status = 'active';
  END IF;
END$$

-- Trigger: Update tenant total_paid when payment is made
DROP TRIGGER IF EXISTS update_tenant_paid_on_payment$$
CREATE TRIGGER update_tenant_paid_on_payment
AFTER UPDATE ON payments
FOR EACH ROW
BEGIN
  IF NEW.status IN ('paid', 'verified') AND OLD.status != NEW.status THEN
    UPDATE tenants t
    SET total_paid = (
      SELECT COALESCE(SUM(p.amount), 0)
      FROM payments p
      WHERE p.booking_id = t.booking_id
        AND p.status IN ('paid', 'verified')
    )
    WHERE t.booking_id = NEW.booking_id;
  END IF;
END$$

-- Trigger: Create tenant record when booking is approved
DROP TRIGGER IF EXISTS create_tenant_on_booking_approved$$
CREATE TRIGGER create_tenant_on_booking_approved
AFTER UPDATE ON bookings
FOR EACH ROW
BEGIN
  IF NEW.status = 'approved' AND OLD.status = 'pending' THEN
    INSERT INTO tenants (booking_id, student_id, dorm_id, room_id, status, check_in_date, expected_checkout, notes)
    SELECT 
      NEW.booking_id,
      NEW.student_id,
      r.dorm_id,
      NEW.room_id,
      'active',
      COALESCE(NEW.start_date, CURDATE()),
      NEW.end_date,
      NEW.notes
    FROM rooms r
    WHERE r.room_id = NEW.room_id
      AND NOT EXISTS (
        SELECT 1 FROM tenants t WHERE t.booking_id = NEW.booking_id
      );
  END IF;
END$$

DELIMITER ;

-- ============================================================
-- SECTION 10: VIEWS
-- Convenient views for common queries
-- ============================================================

-- View: Current active tenants with full details
CREATE OR REPLACE VIEW view_active_tenants AS
SELECT 
  t.tenant_id,
  t.booking_id,
  t.student_id,
  u.name as student_name,
  u.email as student_email,
  u.phone as student_phone,
  t.dorm_id,
  d.name as dorm_name,
  d.address as dorm_address,
  t.room_id,
  r.room_type,
  r.capacity,
  r.price as room_price,
  t.check_in_date,
  t.expected_checkout,
  DATEDIFF(t.expected_checkout, CURDATE()) as days_remaining,
  t.total_paid,
  t.outstanding_balance,
  b.booking_type,
  t.created_at as tenancy_start
FROM tenants t
JOIN users u ON t.student_id = u.user_id
JOIN dormitories d ON t.dorm_id = d.dorm_id
JOIN rooms r ON t.room_id = r.room_id
JOIN bookings b ON t.booking_id = b.booking_id
WHERE t.status = 'active';

-- View: Owner dashboard statistics
CREATE OR REPLACE VIEW view_owner_stats AS
SELECT 
  d.owner_id,
  COUNT(DISTINCT d.dorm_id) as total_dorms,
  COUNT(DISTINCT r.room_id) as total_rooms,
  COUNT(DISTINCT CASE WHEN t.status = 'active' THEN t.tenant_id END) as active_tenants,
  COUNT(DISTINCT CASE WHEN b.status = 'pending' THEN b.booking_id END) as pending_bookings,
  COALESCE(SUM(CASE WHEN p.status IN ('paid','verified') AND p.payment_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) THEN p.amount END), 0) as monthly_revenue,
  COALESCE(SUM(CASE WHEN p.status IN ('pending','submitted') THEN p.amount END), 0) as pending_payments
FROM dormitories d
LEFT JOIN rooms r ON d.dorm_id = r.dorm_id
LEFT JOIN bookings b ON r.room_id = b.room_id
LEFT JOIN tenants t ON b.booking_id = t.booking_id
LEFT JOIN payments p ON b.booking_id = p.booking_id
GROUP BY d.owner_id;

-- View: Payment summary by tenant
CREATE OR REPLACE VIEW view_tenant_payments AS
SELECT 
  t.tenant_id,
  t.student_id,
  u.name as student_name,
  t.dorm_id,
  d.name as dorm_name,
  t.room_id,
  r.room_type,
  COUNT(p.payment_id) as total_payments,
  COALESCE(SUM(CASE WHEN p.status IN ('paid','verified') THEN p.amount END), 0) as total_paid,
  COALESCE(SUM(CASE WHEN p.status IN ('pending','submitted') THEN p.amount END), 0) as pending_amount,
  MAX(p.payment_date) as last_payment_date,
  t.outstanding_balance
FROM tenants t
JOIN users u ON t.student_id = u.user_id
JOIN dormitories d ON t.dorm_id = d.dorm_id
JOIN rooms r ON t.room_id = r.room_id
LEFT JOIN payments p ON t.booking_id = p.booking_id
WHERE t.status = 'active'
GROUP BY t.tenant_id, t.student_id, u.name, t.dorm_id, d.name, t.room_id, r.room_type, t.outstanding_balance;

-- ============================================================
-- SECTION 11: INDEXES FOR PERFORMANCE
-- Additional indexes for common queries
-- ============================================================

-- Bookings indexes
ALTER TABLE bookings
ADD INDEX IF NOT EXISTS idx_status_dates (status, start_date, end_date),
ADD INDEX IF NOT EXISTS idx_student_status (student_id, status),
ADD INDEX IF NOT EXISTS idx_room_status (room_id, status);

-- Payments indexes
ALTER TABLE payments
ADD INDEX IF NOT EXISTS idx_booking_status (booking_id, status),
ADD INDEX IF NOT EXISTS idx_student_status (student_id, status),
ADD INDEX IF NOT EXISTS idx_due_date (due_date),
ADD INDEX IF NOT EXISTS idx_payment_date (payment_date);

-- Messages indexes
ALTER TABLE messages
ADD INDEX IF NOT EXISTS idx_conversation (sender_id, receiver_id),
ADD INDEX IF NOT EXISTS idx_unread (receiver_id, read_at);

-- ============================================================
-- SECTION 12: SAMPLE DATA FOR TESTING (Optional - Comment out for production)
-- ============================================================

-- Insert default preferences for existing users
INSERT INTO user_preferences (user_id)
SELECT user_id FROM users 
WHERE NOT EXISTS (
  SELECT 1 FROM user_preferences up WHERE up.user_id = users.user_id
);

-- ============================================================
-- SECTION 13: CLEANUP AND OPTIMIZATION
-- ============================================================

-- Optimize tables
OPTIMIZE TABLE bookings;
OPTIMIZE TABLE payments;
OPTIMIZE TABLE tenants;
OPTIMIZE TABLE dormitories;

-- Analyze tables for query optimization
ANALYZE TABLE bookings;
ANALYZE TABLE payments;
ANALYZE TABLE tenants;
ANALYZE TABLE dormitories;

-- ============================================================
-- MIGRATION COMPLETE
-- ============================================================

-- Display summary
SELECT 'Migration completed successfully!' as Status;
SELECT COUNT(*) as TotalTenants FROM tenants;
SELECT COUNT(*) as TotalDormImages FROM dorm_images;
SELECT COUNT(*) as TotalUserPreferences FROM user_preferences;
SELECT COUNT(*) as BookingsWithReference FROM bookings WHERE booking_reference IS NOT NULL;

-- ============================================================
-- ROLLBACK SCRIPT (Run only if needed to undo changes)
-- ============================================================

/*
-- To rollback this migration, run these commands:

DROP VIEW IF EXISTS view_tenant_payments;
DROP VIEW IF EXISTS view_owner_stats;
DROP VIEW IF EXISTS view_active_tenants;

DROP TRIGGER IF EXISTS create_tenant_on_booking_approved;
DROP TRIGGER IF EXISTS update_tenant_paid_on_payment;
DROP TRIGGER IF EXISTS update_tenant_on_booking_complete;

DROP TABLE IF EXISTS payment_schedules;
DROP TABLE IF EXISTS user_preferences;
DROP TABLE IF EXISTS dorm_images;
DROP TABLE IF EXISTS tenants;

ALTER TABLE payments 
DROP COLUMN IF EXISTS payment_type,
DROP COLUMN IF EXISTS verified_by,
DROP COLUMN IF EXISTS verified_at,
DROP COLUMN IF EXISTS rejection_reason,
DROP COLUMN IF EXISTS payment_method,
DROP COLUMN IF EXISTS reference_number;

ALTER TABLE bookings
DROP COLUMN IF EXISTS check_in_date,
DROP COLUMN IF EXISTS check_out_date,
DROP COLUMN IF EXISTS booking_reference;

-- Revert status enums to original
ALTER TABLE bookings 
MODIFY COLUMN status ENUM('pending','approved','rejected','cancelled') NOT NULL DEFAULT 'pending';

ALTER TABLE payments
MODIFY COLUMN status ENUM('pending','paid','expired','rejected','submitted') DEFAULT 'pending';
*/
