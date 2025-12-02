-- Add contract document fields to bookings table
-- These fields store paths to signed contract copies from both owner and student

ALTER TABLE `bookings` 
ADD COLUMN `owner_contract_copy` VARCHAR(255) DEFAULT NULL COMMENT 'Path to owner signed contract document' AFTER `booking_reference`,
ADD COLUMN `student_contract_copy` VARCHAR(255) DEFAULT NULL COMMENT 'Path to student signed contract document' AFTER `owner_contract_copy`,
ADD COLUMN `owner_contract_uploaded_at` DATETIME DEFAULT NULL COMMENT 'When owner uploaded contract' AFTER `student_contract_copy`,
ADD COLUMN `student_contract_uploaded_at` DATETIME DEFAULT NULL COMMENT 'When student uploaded contract' AFTER `owner_contract_uploaded_at`;

-- Add index for quick lookup of bookings with contracts
ALTER TABLE `bookings`
ADD INDEX `idx_contract_status` (`booking_id`, `owner_contract_copy`, `student_contract_copy`);
