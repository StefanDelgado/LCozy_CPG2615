# 🔴 SERVER ERROR - Quick Fix Guide

**Error**: `{"error": "Server error"}`  
**Status**: 🔧 **DEBUGGING**

---

## 🚨 What This Means

The API is catching an exception (error) in PHP. The error is being logged but not shown. We've now added detailed error output to help diagnose.

---

## ✅ Step 1: Try the API Again in Postman

**URL**:
```
http://localhost/WebDesign_BSITA-2/2nd%20sem/Joshan_System/LCozy_CPG2615/Main/modules/mobile-api/owner/owner_dashboard_api.php?owner_email=test@example.com
```

**You should now see MORE details**:
```json
{
  "error": "Server error",
  "details": "Actual error message here",
  "file": "path/to/file.php",
  "line": 123
}
```

**Copy the entire error response and share it!**

---

## ✅ Step 2: Use the Debug Script

I've created a debug script that tests everything step by step.

**Open in Browser**:
```
http://localhost/WebDesign_BSITA-2/2nd%20sem/Joshan_System/LCozy_CPG2615/Main/debug_dashboard.php
```

Or with a specific email:
```
http://localhost/WebDesign_BSITA-2/2nd%20sem/Joshan_System/LCozy_CPG2615/Main/debug_dashboard.php?email=your@email.com
```

**This will show**:
- ✅ If config.php loads
- ✅ If database connection works
- ✅ If owner email exists
- ✅ Results of each query
- ✅ Final JSON response

---

## 🔍 Common Causes & Solutions

### Issue 1: File Not Found
**Error**: `require_once(): Failed opening 'config.php'`

**Fix**:
Check file paths are correct:
```
Main/
  config.php ✅
  modules/
    mobile-api/
      shared/
        cors.php ✅
      owner/
        owner_dashboard_api.php ✅
```

---

### Issue 2: Database Connection Failed
**Error**: `PDO::__construct(): Connection refused`

**Fix**:
1. Check XAMPP MySQL is running
2. Open `Main/config.php`
3. Verify local database credentials:
   ```php
   $LOCAL_DB_HOST = '127.0.0.1';
   $LOCAL_DB_NAME = 'cozydorms';
   $LOCAL_DB_USER = 'root';
   $LOCAL_DB_PASS = '';
   ```

---

### Issue 3: Table or Column Not Found
**Error**: `Unknown column 'xyz' in 'field list'`

**Fix**:
1. Check if database tables exist:
   ```sql
   SHOW TABLES;
   ```

2. Check if columns exist:
   ```sql
   DESCRIBE dormitories;
   DESCRIBE rooms;
   DESCRIBE bookings;
   DESCRIBE payments;
   DESCRIBE messages;
   ```

---

### Issue 4: Owner Not Found
**Error Details**: `"Owner not found"`

**Fix**:
1. Check if user exists:
   ```sql
   SELECT user_id, name, email, role 
   FROM users 
   WHERE email = 'your@email.com';
   ```

2. Make sure role is 'owner':
   ```sql
   UPDATE users 
   SET role = 'owner' 
   WHERE email = 'your@email.com';
   ```

---

### Issue 5: Syntax Error
**Error**: `Parse error` or `syntax error`

**Fix**:
Check PHP syntax in:
- `owner_dashboard_api.php`
- `config.php`
- `cors.php`

---

## 🧪 Quick Tests in phpMyAdmin

### Test 1: Check Users Table
```sql
SELECT * FROM users WHERE role = 'owner' LIMIT 5;
```

### Test 2: Check Dormitories
```sql
SELECT * FROM dormitories LIMIT 5;
```

### Test 3: Check Rooms
```sql
SELECT * FROM rooms LIMIT 5;
```

### Test 4: Check Bookings
```sql
SELECT * FROM bookings LIMIT 5;
```

### Test 5: Manual Query
```sql
-- Replace 1 with your owner_id
SELECT COUNT(*) as rooms
FROM rooms r
JOIN dormitories d ON r.dorm_id = d.dorm_id
WHERE d.owner_id = 1;
```

---

## 📝 What to Share for Help

Please provide:

1. **Full Error from Postman** (with details):
   ```json
   {
     "error": "Server error",
     "details": "...",
     "file": "...",
     "line": ...
   }
   ```

2. **Debug Script Output**:
   - Screenshot or copy the output from `debug_dashboard.php`

3. **Database Check**:
   ```sql
   SELECT user_id, email, role FROM users WHERE role = 'owner';
   ```

---

## 🚀 Quick Action Items

- [ ] Try API in Postman again (should show detailed error)
- [ ] Open `debug_dashboard.php` in browser
- [ ] Check XAMPP MySQL is running
- [ ] Verify database exists (`cozydorms`)
- [ ] Check if owner email exists in users table
- [ ] Share detailed error message

---

## 📞 Quick Links

**Debug Script**:
```
http://localhost/WebDesign_BSITA-2/2nd%20sem/Joshan_System/LCozy_CPG2615/Main/debug_dashboard.php
```

**API Endpoint**:
```
http://localhost/WebDesign_BSITA-2/2nd%20sem/Joshan_System/LCozy_CPG2615/Main/modules/mobile-api/owner/owner_dashboard_api.php?owner_email=TEST_EMAIL
```

**phpMyAdmin**:
```
http://localhost/phpmyadmin
```

---

**Next**: Try the API again in Postman and share the detailed error! 🔍
