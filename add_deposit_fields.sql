-- Add deposit/downpayment fields to dormitories table
-- Date: October 18, 2025

ALTER TABLE `dormitories` 
ADD COLUMN `deposit_months` INT DEFAULT 1 COMMENT 'Number of months required as deposit (1-12)' AFTER `features`,
ADD COLUMN `deposit_required` TINYINT(1) DEFAULT 1 COMMENT 'Whether deposit is required (1=yes, 0=no)' AFTER `deposit_months`;

-- Update existing records to have default 1 month deposit
UPDATE `dormitories` SET `deposit_months` = 1, `deposit_required` = 1 WHERE `deposit_months` IS NULL;
