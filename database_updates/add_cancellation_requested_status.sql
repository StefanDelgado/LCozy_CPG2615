-- Add 'cancellation_requested' status to bookings table
-- This allows a two-step cancellation process:
-- 1. Student requests cancellation -> status = 'cancellation_requested'
-- 2. Owner confirms cancellation -> status = 'cancelled'

ALTER TABLE `bookings` 
MODIFY COLUMN `status` ENUM(
    'pending',
    'approved',
    'rejected',
    'cancellation_requested',
    'cancelled',
    'completed',
    'active'
) NOT NULL DEFAULT 'pending' 
COMMENT 'pending=awaiting approval, approved=owner approved, active=currently occupying, completed=tenancy ended, rejected=owner declined, cancellation_requested=student wants to cancel, cancelled=cancellation confirmed';
