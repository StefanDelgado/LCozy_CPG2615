-- ============================================
-- LCozy System - Data Cleanup and Fixes
-- Run this script to fix issues shown in screenshots
-- ============================================

-- 1. REMOVE DUPLICATE STUDENT ACCOUNTS
-- ============================================
-- Keep only one 'stefan' account and remove duplicates
-- WARNING: This will delete duplicate user accounts!

-- First, check which duplicates exist:
SELECT user_id, name, email, role, created_at 
FROM users 
WHERE name LIKE '%stefan%' 
ORDER BY created_at ASC;

-- OPTION 1: Delete specific duplicate users by user_id (RECOMMENDED)
-- Replace XXX with the actual user_id numbers you want to delete
-- DELETE FROM users WHERE user_id IN (XXX, XXX);

-- OPTION 2: Keep only the oldest account, delete newer ones
-- Uncomment below if you want to automatically remove newer duplicates:
/*
DELETE FROM users 
WHERE user_id NOT IN (
    SELECT * FROM (
        SELECT MIN(user_id) 
        FROM users 
        WHERE email LIKE 'delgado%@%'
    ) AS keep_user
) 
AND email LIKE 'delgado%@%';
*/

-- 2. FIX DORMITORY VERIFICATION STATUS
-- ============================================
-- Update "St. Claire Student Inn" to proper pending status
-- Current: verified = 0 (showing as "Pending / Rejected")
-- Fix: Should show clear status

-- Check current status:
SELECT dorm_id, name, verified, owner_id
FROM dormitories
WHERE name LIKE '%St. Claire%';

-- If dorm should be APPROVED:
-- UPDATE dormitories SET verified = 1 WHERE name LIKE '%St. Claire%';

-- If dorm should be PENDING (awaiting approval):
-- Already 0, but now will show as "Pending Approval" instead of "Pending / Rejected"

-- If dorm should be REJECTED:
-- UPDATE dormitories SET verified = -1 WHERE name LIKE '%St. Claire%';

-- 3. VERIFY IMAGE PATHS IN DATABASE
-- ============================================
-- Check if cover_image paths are stored correctly
SELECT dorm_id, name, cover_image 
FROM dormitories 
WHERE cover_image IS NOT NULL;

-- Image paths should be stored as one of:
-- 'filename.jpg' (just filename) OR
-- 'uploads/filename.jpg' OR
-- '/uploads/filename.jpg'

-- If images are stored incorrectly, update them:
-- UPDATE dormitories SET cover_image = 'St_Claire_Inn.jpg' WHERE dorm_id = XXX;

-- 4. CHECK ROOM STATUS
-- ============================================
-- Ensure room status is lowercase 'vacant' not 'Vacant'
SELECT room_id, room_number, room_type, status 
FROM rooms 
WHERE dorm_id IN (
    SELECT dorm_id FROM dormitories WHERE name LIKE '%St. Claire%'
);

-- Fix room status if needed (should be lowercase):
UPDATE rooms SET status = LOWER(status);

-- 5. VERIFICATION STATUS LEGEND
-- ============================================
-- For reference:
-- users.verified:
--   1 = Verified/Approved
--   0 = Pending verification
--  -1 = Rejected

-- dormitories.verified:
--   1 = Approved (visible to students)
--   0 = Pending approval
--  -1 = Rejected (not visible)

-- 6. CLEAN UP TEST DATA (OPTIONAL)
-- ============================================
-- Remove all test accounts if needed:
/*
DELETE FROM users 
WHERE email LIKE '%test%' 
   OR email LIKE '%example%' 
   OR name LIKE '%test%';
*/

-- 7. VERIFY FIXES
-- ============================================
-- After running fixes, verify with these queries:

-- Check users:
SELECT user_id, name, email, role, verified 
FROM users 
ORDER BY created_at DESC 
LIMIT 10;

-- Check dorms:
SELECT d.dorm_id, d.name, d.verified, u.name AS owner_name
FROM dormitories d
JOIN users u ON d.owner_id = u.user_id
ORDER BY d.created_at DESC;

-- Check rooms:
SELECT r.room_id, r.room_number, r.room_type, r.status, d.name AS dorm_name
FROM rooms r
JOIN dormitories d ON r.dorm_id = d.dorm_id
ORDER BY d.created_at DESC, r.room_number;

-- ============================================
-- SUMMARY OF FIXES APPLIED TO CODE:
-- ============================================
-- 1. Updated dorm_listings.php to show three distinct statuses:
--    - Approved (green badge) when verified = 1
--    - Rejected (red badge) when verified = -1  
--    - Pending Approval (yellow badge) when verified = 0
--
-- 2. Changed reject action to set verified = -1 (not 0)
--
-- 3. Fixed image path handling to work with multiple path formats
--
-- 4. Added image error handling (shows placeholder if image not found)
--
-- 5. Only show relevant action buttons (hide Approve if already approved, etc.)
-- ============================================
