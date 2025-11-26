-- Add owner ID and business permit columns to dormitories table
-- Run this migration to add document upload fields

ALTER TABLE `dormitories` 
ADD COLUMN `owner_id_document` VARCHAR(255) DEFAULT NULL COMMENT 'Owner ID document file path' AFTER `deposit_required`,
ADD COLUMN `business_permit` VARCHAR(255) DEFAULT NULL COMMENT 'Business permit document file path' AFTER `owner_id_document`;

-- Optional: Update existing dorms to have NULL values (already default)
-- This is just for documentation purposes
