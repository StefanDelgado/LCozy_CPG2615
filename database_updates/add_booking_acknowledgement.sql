-- Add cancellation acknowledgement tracking to bookings table
-- Run this migration to track when owners acknowledge cancelled bookings

ALTER TABLE `bookings` 
ADD COLUMN `cancellation_acknowledged` TINYINT(1) DEFAULT 0 COMMENT '0=not acknowledged, 1=owner acknowledged cancellation' AFTER `check_out_date`,
ADD COLUMN `cancellation_acknowledged_at` DATETIME DEFAULT NULL COMMENT 'When owner acknowledged the cancellation' AFTER `cancellation_acknowledged`,
ADD COLUMN `cancellation_acknowledged_by` INT(11) DEFAULT NULL COMMENT 'Owner user_id who acknowledged' AFTER `cancellation_acknowledged_at`;

-- Add foreign key for acknowledged_by (optional, for referential integrity)
ALTER TABLE `bookings`
ADD CONSTRAINT `fk_booking_acknowledged_by` 
FOREIGN KEY (`cancellation_acknowledged_by`) 
REFERENCES `users`(`user_id`) 
ON DELETE SET NULL;

-- Update existing cancelled bookings to be unacknowledged
UPDATE `bookings` 
SET `cancellation_acknowledged` = 0 
WHERE `status` = 'cancelled' 
AND `cancellation_acknowledged` IS NULL;
