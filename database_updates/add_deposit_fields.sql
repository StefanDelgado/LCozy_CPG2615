-- PHASE 2: Add Deposit Fields to Dormitories Table
-- Date: October 19, 2025

-- Add deposit_required and deposit_months columns
ALTER TABLE `dormitories`
ADD COLUMN `deposit_required` TINYINT(1) DEFAULT 0 COMMENT 'Whether deposit is required' AFTER `features`,
ADD COLUMN `deposit_months` INT(2) DEFAULT 1 COMMENT 'Number of months deposit (1-12)' AFTER `deposit_required`;

-- Update existing dormitories to have default values
UPDATE `dormitories` SET `deposit_required` = 0, `deposit_months` = 1 WHERE `deposit_required` IS NULL;

-- Verify the changes
SELECT dorm_id, name, deposit_required, deposit_months FROM dormitories LIMIT 5;
