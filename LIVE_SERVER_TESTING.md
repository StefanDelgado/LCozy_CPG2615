# 🧪 Live Server Testing Guide

**Date**: October 19, 2025  
**Purpose**: Test and diagnose the booking API on cozydorms.life live server  
**Issue**: Mobile app showing 404 error for owner bookings

---

## 📋 Testing Steps

### Step 1: Upload Test Files

Upload these 2 diagnostic files to your live server:

**File 1: General API Diagnostics**
```
Local:  Main/test-api-status.php
Remote: /test-api-status.php (root of your website)
```

**File 2: Booking API Specific Test**
```
Local:  Main/test-booking-api.php
Remote: /test-booking-api.php (root of your website)
```

### Step 2: Run General Diagnostics

**Open in browser:**
```
http://cozydorms.life/test-api-status.php
```

**What it checks:**
- ✅ PHP version and server info
- ✅ If owner_bookings_api.php file exists
- ✅ If config.php exists and works
- ✅ If cors.php exists
- ✅ Lists all mobile-api folders
- ✅ Tests database connection
- ✅ Attempts to call the booking API

**Expected output:**
```json
{
  "overall_status": "ALL_SYSTEMS_GO",
  "checks": {
    "owner_bookings_file": {
      "exists": true,
      "size": 11070
    },
    "config_file": {
      "exists": true
    },
    "cors_file": {
      "exists": true
    },
    "database": {
      "status": "connected"
    }
  }
}
```

### Step 3: Test Booking API Directly

**Replace YOUR_EMAIL with your actual owner email:**
```
http://cozydorms.life/test-booking-api.php?owner_email=YOUR_EMAIL
```

**What it does:**
- Checks if the API file exists
- Checks if it's readable
- Actually calls the API
- Shows the exact response
- Validates JSON format

**Expected output if working:**
```
=== OWNER BOOKINGS API TEST ===

Testing with owner email: your@email.com

Step 1: Checking if API file exists...
✅ File exists
File size: 11070 bytes

Step 2: Checking if file is readable...
✅ File is readable

Step 3: Testing API call...

API Response:
=====================================
{
  "ok": true,
  "success": true,
  "bookings": [ ... ]
}
=====================================

✅ Valid JSON response
```

---

## 🔍 Diagnosing Different Scenarios

### Scenario 1: File Not Found (404)

**Output:**
```
❌ ERROR: File does not exist!
Path: /home/xxx/public_html/modules/mobile-api/owner/owner_bookings_api.php
```

**Solution:**
- Upload `owner_bookings_api.php` to the server
- Check the path is correct: `/modules/mobile-api/owner/`
- Verify filename is exact (case-sensitive)

### Scenario 2: File Exists But Old Version

**Output:**
```
✅ File exists
File size: 8524 bytes  ← OLD SIZE (should be 11070)
```

**Solution:**
- The file on server is outdated
- Upload the NEW version (11,070 bytes)
- Check last modified date

### Scenario 3: Permission Error

**Output:**
```
✅ File exists
❌ ERROR: File is not readable!
```

**Solution:**
```bash
chmod 644 owner_bookings_api.php
```

### Scenario 4: Config.php Missing

**Output:**
```json
{
  "checks": {
    "config_file": {
      "exists": false
    }
  }
}
```

**Solution:**
- Upload `config.php` to root directory
- Verify database credentials

### Scenario 5: Database Connection Error

**Output:**
```json
{
  "checks": {
    "database": {
      "status": "error",
      "message": "SQLSTATE[HY000] [1045] Access denied"
    }
  }
}
```

**Solution:**
- Check database credentials in `config.php`
- Verify database server is running
- Check user has correct permissions

---

## 📱 Testing from Mobile App

After running the tests above and confirming everything works:

### Test 1: Check Network Request

1. Open mobile app
2. Go to Bookings screen
3. Open browser DevTools (if testing on emulator)
4. Check Network tab for request to:
   ```
   http://cozydorms.life/modules/mobile-api/owner/owner_bookings_api.php?owner_email=XXX
   ```

5. Look at:
   - Status code (should be 200, not 404)
   - Response body (should be JSON)
   - Response headers

### Test 2: Check Flutter Console

Look for these debug messages:
```
📋 [BookingService] Response status: 200  ← Should be 200
📋 [BookingService] Response body: {"ok":true,...}
```

If still 404:
```
📋 [BookingService] Response status: 404  ← Problem!
📋 [BookingService] ❌ Server error: 404
```

---

## 🛠️ Common Issues & Fixes

### Issue 1: API Works in Browser, Fails in App

**Problem:** File exists on server, test-booking-api.php works, but mobile app still gets 404

**Possible causes:**
1. **Caching issue** - App is caching old failed request
   - Solution: Clear app data, reinstall app

2. **URL mismatch** - App is calling wrong URL
   - Check `ApiConstants.baseUrl` in Flutter
   - Should be: `http://cozydorms.life`

3. **CORS issue** - Server blocking mobile requests
   - Check cors.php is properly included
   - Verify headers: `Access-Control-Allow-Origin: *`

### Issue 2: Works for Some Owners, Not Others

**Problem:** API returns 404 for certain owner emails

**Cause:** Owner not found in database

**Solution:**
```sql
-- Check if owner exists
SELECT * FROM users WHERE email = 'your@email.com' AND role = 'owner';
```

### Issue 3: Intermittent 404 Errors

**Problem:** Sometimes works, sometimes 404

**Possible causes:**
1. **Server load** - Server timing out
2. **File permission changes** - Host resetting permissions
3. **Cache** - CDN or server cache

**Solution:**
- Add query parameter to bypass cache: `?v=2`
- Check server error logs
- Contact hosting support

---

## 📊 Checklist

Before declaring the issue "fixed", verify:

- [ ] `test-api-status.php` shows `"overall_status": "ALL_SYSTEMS_GO"`
- [ ] `test-booking-api.php` returns valid JSON with bookings
- [ ] Browser can access: `http://cozydorms.life/modules/mobile-api/owner/owner_bookings_api.php?owner_email=YOUR_EMAIL`
- [ ] Returns status code 200 (not 404)
- [ ] Response has `"ok": true` and `"success": true`
- [ ] Mobile app loads bookings without error
- [ ] Can approve/reject bookings
- [ ] No 404 errors in Flutter console

---

## 🎯 Quick Test Commands

### Test 1: Check File Exists (via SSH)
```bash
ssh user@cozydorms.life
ls -lh /home/xxx/public_html/modules/mobile-api/owner/owner_bookings_api.php
# Should show: 11070 bytes, -rw-r--r-- permissions
```

### Test 2: Test API via curl
```bash
curl -v "http://cozydorms.life/modules/mobile-api/owner/owner_bookings_api.php?owner_email=test@test.com"
# Look for: HTTP/1.1 200 OK (not 404)
```

### Test 3: Check Response Headers
```bash
curl -I "http://cozydorms.life/modules/mobile-api/owner/owner_bookings_api.php?owner_email=test@test.com"
# Should show:
# HTTP/1.1 200 OK
# Content-Type: application/json
# Access-Control-Allow-Origin: *
```

---

## 📝 What to Do Next

### If ALL tests pass ✅

**The server is working!** The issue is in the mobile app:

1. **Clear app data** on device
2. **Uninstall and reinstall** the app
3. **Check Flutter code** - ensure correct URL
4. **Test on different device**

### If tests FAIL ❌

**Focus on what failed:**

1. **File not found** → Upload the file
2. **Wrong size** → Upload correct version  
3. **Database error** → Fix config.php
4. **Permission error** → Fix file permissions
5. **CORS error** → Check cors.php

---

## 🚀 Success Indicators

You'll know it's working when:

✅ **test-api-status.php** shows all green checkmarks  
✅ **test-booking-api.php** returns JSON with bookings  
✅ **Browser** can load the API URL directly  
✅ **Mobile app** shows bookings list  
✅ **No 404 errors** in Flutter console  
✅ **Can approve/reject** bookings successfully  

---

**Upload the test files and run them to see what's actually happening on your live server!** 🔍
