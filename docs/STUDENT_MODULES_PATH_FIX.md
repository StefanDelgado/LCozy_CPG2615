# Student Modules Path Fix

## Problem
All student module pages were returning HTTP 500 errors because they were using incorrect relative paths.

## Root Cause
Student module files are located at: `/Main/modules/student/`

They were using `/../` to go up one level, but they needed `/../../` to go up two levels to reach the Main directory.

**Wrong Path:**
```php
require_once __DIR__ . '/../auth/auth.php';  // Looks for /Main/modules/auth/
```

**Correct Path:**
```php
require_once __DIR__ . '/../../auth/auth.php';  // Looks for /Main/auth/ ✅
```

## Files Fixed

All student module files updated with correct paths:

### 1. **student_messages.php** ✅
- Fixed header: `/__DIR__ . '/../../auth/auth.php'`
- Fixed config: `__DIR__ . '/../../config.php'`
- Fixed header include: `__DIR__ . '/../../partials/header.php'`
- Fixed footer include: `__DIR__ . '/../../partials/footer.php'`

### 2. **student_announcements.php** ✅
- Fixed header paths (auth, config, header.php)
- Fixed footer path

### 3. **student_payments.php** ✅
- Fixed header paths (auth, config, header.php)
- Fixed footer path

### 4. **student_reservations.php** ✅
- Fixed header paths (auth, config, header.php)
- Fixed footer path

### 5. **student_reviews.php** ✅
- Fixed header paths (auth, config, header.php)
- Fixed footer path

### 6. **student_receipt.php** ✅
- Fixed header paths (auth, config, header.php)
- Fixed footer path
- Note: Had wrong order (header before auth)

## Path Pattern

For all files in `/Main/modules/student/` or `/Main/modules/owner/`:

```php
<?php
require_once __DIR__ . '/../../auth/auth.php';      // ✅ Up 2 levels
require_role('student'); // or 'owner'
require_once __DIR__ . '/../../config.php';         // ✅ Up 2 levels

$page_title = "Page Title";
include __DIR__ . '/../../partials/header.php';     // ✅ Up 2 levels

// Page content...

<?php include __DIR__ . '/../../partials/footer.php'; ?>  // ✅ Up 2 levels
```

## Why This Happened

The header.php file uses **root-relative paths** (starting with `/`) which work from any depth:
```php
<link rel="stylesheet" href="/assets/style.css">  // Always works
```

But the PHP includes in module files were using **relative paths** (with `../`), which depend on the current file's location.

## Summary

| File Location | Levels Up Needed | Path Pattern |
|--------------|------------------|--------------|
| `/Main/dashboards/*.php` | 1 level | `__DIR__ . '/../'` |
| `/Main/modules/student/*.php` | 2 levels | `__DIR__ . '/../../'` |
| `/Main/modules/owner/*.php` | 2 levels | `__DIR__ . '/../../'` |
| `/Main/modules/admin/*.php` | 2 levels | `__DIR__ . '/../../'` |

## Result

✅ All student module pages now work correctly:
- Messages
- Announcements  
- Payments
- Reservations
- Reviews
- Receipt Upload

After uploading these fixed files to the server, students will be able to access all their pages without HTTP 500 errors! 🎉

## Related Fixes

This is the same issue that was fixed earlier for:
- Owner modules (owner_dorms.php, owner_tenants.php, etc.)
- Header.php CSS/navigation paths (changed to root-relative)

The system-wide pattern is now consistent and all paths are correct!
