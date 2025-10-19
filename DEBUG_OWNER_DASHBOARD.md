# 🔍 Owner Dashboard Not Displaying Data - Debug Guide

**Date**: October 19, 2025  
**Issue**: Owner dashboard showing zeros or no data  
**Status**: 🔧 **DEBUGGING IN PROGRESS**

---

## 🐛 Problem Description

Owner dashboard is not displaying statistics (rooms, tenants, revenue) even though the data exists in the database.

---

## ✅ Fixes Applied

### Fix #1: API Response Format
**File**: `Main/modules/mobile-api/owner/owner_dashboard_api.php`

Changed from:
```php
'ok' => true
```

To:
```php
'success' => true,
'data' => [...]
```

### Fix #2: Dashboard Service
**File**: `mobile/lib/services/dashboard_service.dart`

Updated to match new API response structure:
- Changed check from `data['ok']` to `responseData['success']`
- Updated data extraction to `responseData['data']`
- Added proper mapping for all data fields

### Fix #3: Added Debug Logging
**File**: `mobile/lib/screens/owner/owner_dashboard_screen.dart`

Added console logging to track:
- 🔄 API request initiation
- 📊 API response
- ✅ Success state
- ❌ Error state
- 📈 Stats data

---

## 🧪 Testing Steps

### Step 1: Check API Directly

**Test the API endpoint in browser or Postman:**

```
URL: http://cozydorms.life/modules/mobile-api/owner/owner_dashboard_api.php?owner_email=YOUR_EMAIL
```

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "stats": {
      "rooms": 12,
      "tenants": 8,
      "monthly_revenue": 45000.00,
      "recent_activities": []
    },
    "recent_bookings": [],
    "recent_payments": [],
    "recent_messages": []
  }
}
```

**Common Issues:**
- ❌ `{"error": "Owner not found"}` → Email not registered as owner
- ❌ `{"error": "Owner email required"}` → Missing email parameter
- ❌ Empty response → PHP error, check error logs
- ❌ Stats are 0 → No rooms/tenants in database for this owner

---

### Step 2: Check Database

**Verify owner exists:**
```sql
SELECT user_id, name, email, role 
FROM users 
WHERE email = 'your_email@example.com' AND role = 'owner';
```

**Count owner's rooms:**
```sql
SELECT COUNT(*) as total_rooms
FROM rooms r
JOIN dormitories d ON r.dorm_id = d.dorm_id
WHERE d.owner_id = (
    SELECT user_id FROM users WHERE email = 'your_email@example.com'
);
```

**Count owner's tenants:**
```sql
SELECT COUNT(DISTINCT b.student_id) as total_tenants
FROM bookings b
JOIN rooms r ON b.room_id = r.room_id
JOIN dormitories d ON r.dorm_id = d.dorm_id
WHERE d.owner_id = (
    SELECT user_id FROM users WHERE email = 'your_email@example.com'
) AND b.status = 'approved';
```

**Check revenue:**
```sql
SELECT SUM(p.amount) as monthly_revenue
FROM payments p
JOIN bookings b ON p.booking_id = b.booking_id
JOIN rooms r ON b.room_id = r.room_id
JOIN dormitories d ON r.dorm_id = d.dorm_id
WHERE d.owner_id = (
    SELECT user_id FROM users WHERE email = 'your_email@example.com'
) 
AND p.status = 'paid'
AND p.payment_date >= DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY);
```

---

### Step 3: Check Mobile App Logs

**Run the app in debug mode:**

```bash
cd mobile
flutter run
```

**Watch for console output:**

```
🔄 Fetching dashboard data for: owner@example.com
📊 Dashboard API Response: {success: true, data: {...}}
✅ Success! Dashboard data: {stats: {...}, recent_bookings: [...]}
📈 Stats loaded: {rooms: 12, tenants: 8, monthly_revenue: 45000.0}
```

**Common Error Logs:**

1. **Network Error:**
```
💥 Exception caught: Failed host lookup: 'cozydorms.life'
```
**Solution**: Check internet connection or API URL

2. **API Error:**
```
❌ Error: Owner not found
```
**Solution**: Verify owner email in database

3. **Parse Error:**
```
💥 Exception caught: FormatException: Unexpected character
```
**Solution**: API returning invalid JSON, check PHP errors

---

## 🔧 Troubleshooting Checklist

### Backend Issues:

- [ ] **API file uploaded to server?**
  - Upload: `Main/modules/mobile-api/owner/owner_dashboard_api.php`
  
- [ ] **Database connection working?**
  - Check: `Main/config.php` has correct credentials
  
- [ ] **Owner exists in database?**
  - Query: `SELECT * FROM users WHERE email = '...' AND role = 'owner'`
  
- [ ] **Rooms/dormitories exist for owner?**
  - Query: `SELECT * FROM dormitories WHERE owner_id = ...`
  
- [ ] **PHP errors?**
  - Check: Server error logs or enable `error_reporting(E_ALL)`

### Frontend Issues:

- [ ] **API URL correct?**
  - Check: `mobile/lib/utils/constants.dart` → `ApiConstants.baseUrl`
  
- [ ] **Internet permission enabled?**
  - Android: `android/app/src/main/AndroidManifest.xml`
  - iOS: `ios/Runner/Info.plist`
  
- [ ] **App rebuilt after changes?**
  - Run: `flutter clean && flutter pub get && flutter run`
  
- [ ] **Console shows debug logs?**
  - Look for: 🔄 📊 ✅ ❌ 📈 emojis in console

---

## 🎯 Quick Fix Checklist

### If stats show 0:

1. **Verify API returns data:**
   - Test in browser: `http://cozydorms.life/modules/mobile-api/owner/owner_dashboard_api.php?owner_email=YOUR_EMAIL`

2. **Check if owner has dormitories:**
   ```sql
   SELECT * FROM dormitories WHERE owner_id = YOUR_OWNER_ID;
   ```

3. **Check if dormitories have rooms:**
   ```sql
   SELECT r.* FROM rooms r
   JOIN dormitories d ON r.dorm_id = d.dorm_id
   WHERE d.owner_id = YOUR_OWNER_ID;
   ```

4. **Rebuild mobile app:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

---

## 📝 Files Modified for This Fix

1. ✅ `Main/modules/mobile-api/owner/owner_dashboard_api.php`
   - Changed response structure
   
2. ✅ `mobile/lib/services/dashboard_service.dart`
   - Updated to parse new API response
   
3. ✅ `mobile/lib/screens/owner/owner_dashboard_screen.dart`
   - Added debug logging

---

## 🔍 Debug Commands

### Check API Response:
```bash
# PowerShell
Invoke-WebRequest -Uri "http://cozydorms.life/modules/mobile-api/owner/owner_dashboard_api.php?owner_email=test@example.com" | Select-Object -Expand Content
```

### Check Flutter Logs:
```bash
cd mobile
flutter run --verbose
```

### Check Server Logs:
```bash
# On server
tail -f /var/log/apache2/error.log
# Or
tail -f /xampp/apache/logs/error.log
```

---

## 📊 Expected Data Flow

```
1. Mobile App (owner_dashboard_screen.dart)
   ↓ Calls getOwnerDashboard(email)
   
2. Dashboard Service (dashboard_service.dart)
   ↓ HTTP GET request
   
3. API (owner_dashboard_api.php)
   ↓ Queries database
   
4. Database
   ↓ Returns data
   
5. API formats response
   ↓ Returns JSON
   
6. Service parses JSON
   ↓ Returns data map
   
7. Dashboard Screen
   ↓ Updates UI with stats
   
8. User sees dashboard ✅
```

---

## 🆘 If Still Not Working

**Provide this information:**

1. **Console logs** from Flutter app (copy the 🔄 📊 ✅ ❌ 📈 lines)

2. **API response** from browser test

3. **Database query results**:
   ```sql
   -- Owner info
   SELECT user_id, name, email, role FROM users WHERE email = 'your_email';
   
   -- Dorms count
   SELECT COUNT(*) FROM dormitories WHERE owner_id = YOUR_ID;
   
   -- Rooms count
   SELECT COUNT(*) FROM rooms r
   JOIN dormitories d ON r.dorm_id = d.dorm_id
   WHERE d.owner_id = YOUR_ID;
   ```

4. **Any error messages** from server logs

---

## ✅ Success Indicators

When working correctly, you should see:

- **Console**: 
  ```
  ✅ Success! Dashboard data: {stats: {rooms: X, tenants: Y, ...}}
  📈 Stats loaded: {rooms: X, tenants: Y, monthly_revenue: Z}
  ```

- **Dashboard UI**: 
  - Total Rooms: Shows actual count (not 0)
  - Total Tenants: Shows actual count (not 0)
  - Revenue: Shows actual amount (not ₱0.0K)

- **API Browser Test**: 
  ```json
  {"success":true,"data":{"stats":{...}}}
  ```

---

**Next Steps**: Run the app and check console logs to see where the data flow breaks! 🔍
