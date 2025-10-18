# HTTP 500 Error Fix - October 17, 2025

## 🔴 Problem
Accessing `http://cozydorms.life/auth/login.php` resulted in:
```
HTTP ERROR 500
This page isn't working
cozydorms.life is currently unable to handle this request.
```

## 🔍 Root Causes Found

### 1. **Wrong config.php Path in auth.php**
**File:** `Main/auth/auth.php` (Line 5)

**Before (WRONG):**
```php
require_once __DIR__ . '/config.php';  // ❌ Looking in auth/ folder
```

**After (FIXED):**
```php
require_once __DIR__ . '/../config.php';  // ✅ Go up one level to find config.php
```

**Why it failed:** `config.php` is in the root (`Main/`) directory, not in `Main/auth/` directory. The path needs to go up one level (`../`) to find it.

---

### 2. **Old Redirect URLs in auth.php**
**File:** `Main/auth/auth.php` (Lines 12-13, 38-47)

**Before (WRONG):**
```php
function login_required() {
    if (!isset($_SESSION['user'])) {
        header('Location: /login.php');  // ❌ Old root location
        exit;
    }
}

function redirect_to_dashboard($role) {
    switch ($role) {
        case 'admin':
            header('Location: /dashboard.php');        // ❌ Old location
            break;
        case 'owner':
            header('Location: /owner_dashboard.php');  // ❌ Old location
            break;
        case 'student':
            header('Location: /student_dashboard.php'); // ❌ Old location
            break;
        default:
            header('Location: /login.php');            // ❌ Old location
    }
}
```

**After (FIXED):**
```php
function login_required() {
    if (!isset($_SESSION['user'])) {
        header('Location: /auth/login.php');  // ✅ New organized location
        exit;
    }
}

function redirect_to_dashboard($role) {
    switch ($role) {
        case 'admin':
            header('Location: /dashboards/admin_dashboard.php');   // ✅ New location
            break;
        case 'owner':
            header('Location: /dashboards/owner_dashboard.php');   // ✅ New location
            break;
        case 'student':
            header('Location: /dashboards/student_dashboard.php'); // ✅ New location
            break;
        default:
            header('Location: /auth/login.php');                   // ✅ New location
    }
}
```

**Why it failed:** After reorganization, these files moved from root to subdirectories, but the redirect URLs weren't updated.

---

## ✅ Solution Applied

### Files Modified:
1. **`Main/auth/auth.php`**
   - Fixed config.php require path
   - Updated login redirect URL
   - Updated dashboard redirect URLs

### Changes Summary:
- ✅ Config path: `/config.php` → `/../config.php`
- ✅ Login URL: `/login.php` → `/auth/login.php`
- ✅ Admin dashboard: `/dashboard.php` → `/dashboards/admin_dashboard.php`
- ✅ Owner dashboard: `/owner_dashboard.php` → `/dashboards/owner_dashboard.php`
- ✅ Student dashboard: `/student_dashboard.php` → `/dashboards/student_dashboard.php`

---

## 🧪 Testing Steps

### 1. **Test the Diagnostic Page**
Access: `http://cozydorms.life/auth/diagnostic.php`

This will show you:
- ✅ PHP version
- ✅ File paths
- ✅ Config.php loading status
- ✅ Database connection test
- ✅ Auth.php loading status
- ✅ Directory structure
- ✅ Required files existence
- ✅ PHP extensions
- ✅ Session functionality

**⚠️ DELETE THIS FILE AFTER TESTING!** (It exposes server info)

### 2. **Test Login Page**
1. Visit: `http://cozydorms.life/auth/login.php`
2. Should load without HTTP 500 error
3. Try logging in with test credentials
4. Should redirect to appropriate dashboard

### 3. **Test Dashboards**
- Admin: `http://cozydorms.life/dashboards/admin_dashboard.php`
- Owner: `http://cozydorms.life/dashboards/owner_dashboard.php`
- Student: `http://cozydorms.life/dashboards/student_dashboard.php`

### 4. **Test Logout**
- Click logout from any dashboard
- Should redirect to: `http://cozydorms.life/auth/login.php`

---

## 📝 Deployment Notes

### For cPanel Git Deployment:

**Before pushing, verify locally:**
```powershell
# Test locally first
php -l Main/auth/auth.php
# Should output: "No syntax errors detected"

# Start XAMPP and test
# Visit: http://localhost/auth/login.php
```

**Then push to production:**
```bash
git add Main/auth/auth.php
git add Main/auth/diagnostic.php
git commit -m "Fix HTTP 500 error: Update auth.php paths for new structure"
git push origin main
```

**After deployment:**
1. Test diagnostic page
2. Test login functionality
3. **Delete diagnostic.php from server!**

---

## 🔧 Common Issues & Solutions

### Issue: Still getting HTTP 500 after fix

**Check these:**

1. **PHP syntax errors:**
   ```bash
   php -l /home/yyju4g9j6ey3/public_html/auth/auth.php
   ```

2. **File permissions:**
   ```bash
   chmod 644 /home/yyju4g9j6ey3/public_html/auth/*.php
   chmod 644 /home/yyju4g9j6ey3/public_html/config.php
   ```

3. **Check error logs:**
   - cPanel → Metrics → Errors
   - Or check: `/home/yyju4g9j6ey3/public_html/error_log`

4. **Database connection:**
   - Verify `config.php` has correct production credentials
   - Test with: `http://cozydorms.life/admin/test-pdo.php`

### Issue: "config.php not found" error

**Solution:**
```bash
# Via SSH, verify file exists
ls -la /home/yyju4g9j6ey3/public_html/config.php

# Should show: -rw-r--r-- config.php
```

### Issue: "Call to undefined function" error

**This means auth.php failed to load**

**Check:**
1. Syntax errors in auth.php
2. Config.php loading before auth.php
3. File permissions (should be 644)

---

## 🎯 Prevention for Future

### When moving/organizing files, always update:

1. **`require_once` paths** - Check all includes
2. **`header('Location:')` redirects** - Update URLs
3. **Form `action` attributes** - Update submission URLs
4. **HTML `href` links** - Update navigation
5. **`.htaccess` rules** - Update rewrite rules

### Use relative paths pattern:
```php
// From auth/ files:
require_once __DIR__ . '/../config.php';           // Go up to root
header('Location: ../dashboards/student_dashboard.php'); // Relative redirect

// From dashboards/ files:
require_once __DIR__ . '/../auth/auth.php';        // Up then into auth/
include __DIR__ . '/../partials/header.php';       // Up then into partials/

// From modules/ files:
require_once __DIR__ . '/../auth/auth.php';        // Up then into auth/
require_once __DIR__ . '/../config.php';           // Up to root
```

---

## 📊 Status

- ✅ **Fixed:** auth.php config path
- ✅ **Fixed:** login redirect URL
- ✅ **Fixed:** dashboard redirect URLs
- ✅ **Created:** Diagnostic tool
- ⏳ **Pending:** Test on production
- ⏳ **Pending:** Delete diagnostic.php after testing

---

**Fixed by:** GitHub Copilot  
**Date:** October 17, 2025  
**Affected Files:** `Main/auth/auth.php`  
**Status:** Ready for deployment and testing
