# Troubleshooting HTTP Error - Browse Dorms

**Issue:** HTTP error when clicking "Browse" on real phone device  
**Date:** October 16, 2025  
**Affected Feature:** Browse Dorms API

---

## ✅ Fixes Applied

### 1. **Android Cleartext Traffic** (MAIN FIX)
**Problem:** Android blocks HTTP traffic by default for security  
**Solution:** Added `android:usesCleartextTraffic="true"` to AndroidManifest.xml

**File:** `android/app/src/main/AndroidManifest.xml`
```xml
<application
    android:label="cozydorm"
    android:icon="@mipmap/ic_launcher"
    android:usesCleartextTraffic="true">  <!-- ✅ ADDED -->
```

### 2. **Enhanced Error Handling**
**Problem:** Generic error messages make debugging difficult  
**Solution:** Added specific error messages for different failure types

**Changes:**
- ✅ Network errors now show: "Cannot connect to server. Please check your internet connection."
- ✅ Timeout errors now show: "Server is taking too long to respond."
- ✅ Data format errors now show: "Invalid response from server."
- ✅ HTTP errors now include status code and partial response body

### 3. **Request Timeout**
**Problem:** No timeout handling causes app to hang  
**Solution:** Added 15-second timeout to API requests

**File:** `lib/services/dorm_service.dart`
```dart
final response = await http.get(uri).timeout(
  const Duration(seconds: 15),
  onTimeout: () {
    throw Exception('Request timeout - Please check your internet connection');
  },
);
```

---

## 🔍 Common Error Causes & Solutions

### Error 1: "Cannot connect to server"
**Causes:**
1. Phone not connected to internet
2. Phone on different network than server
3. Firewall blocking connection
4. Server not running

**Solutions:**
- ✅ Connect phone to same WiFi as server
- ✅ Or use mobile data and ensure server has public IP
- ✅ Verify server is running: visit `http://cozydorms.life` in phone browser
- ✅ Check firewall settings on server

### Error 2: "Request timeout"
**Causes:**
1. Server is slow or overloaded
2. Database query taking too long
3. Network latency issues

**Solutions:**
- ✅ Optimize database queries
- ✅ Increase timeout if needed (currently 15 seconds)
- ✅ Check server logs for performance issues

### Error 3: "HTTP Error 404"
**Causes:**
1. API endpoint doesn't exist
2. Wrong URL in constants

**Solutions:**
- ✅ Verify endpoint: `http://cozydorms.life/modules/mobile-api/student_dashboard_api.php`
- ✅ Check server has the file at correct location
- ✅ Ensure `.htaccess` is not blocking access

### Error 4: "HTTP Error 500"
**Causes:**
1. Server-side PHP error
2. Database connection error
3. Missing database tables

**Solutions:**
- ✅ Check server error logs: `/xampp/htdocs/.../error_log`
- ✅ Verify database connection in `config.php`
- ✅ Ensure `cozydorm` database exists and has dorms table

### Error 5: "Data format error"
**Causes:**
1. API returning HTML instead of JSON
2. PHP error output mixed with JSON
3. Invalid JSON structure

**Solutions:**
- ✅ Check API returns valid JSON: `{"dorms": [...]}`
- ✅ Remove any `echo` or `print_r` statements before JSON output
- ✅ Ensure `Content-Type: application/json` header is set

---

## 🧪 Testing Steps

### Test 1: Check Server Accessibility
```bash
# From phone browser, visit:
http://cozydorms.life

# Should show the website
```

### Test 2: Test API Directly
```bash
# From phone browser, visit:
http://cozydorms.life/modules/mobile-api/student_dashboard_api.php

# Should return JSON with dorms data
```

### Test 3: Check Network Connection
```dart
// Add debug print in dorm_service.dart before API call:
print('Calling API: ${ApiConstants.studentDashboardEndpoint}');
print('Response Status: ${response.statusCode}');
print('Response Body: ${response.body}');
```

### Test 4: Verify AndroidManifest.xml
```bash
# Check that cleartext traffic is enabled
flutter build apk --debug
# Inspect build/app/outputs/apk/debug/AndroidManifest.xml
```

---

## 🚀 Deployment Checklist

### For Development (Current)
- [x] Enable cleartext traffic in AndroidManifest.xml
- [x] Use HTTP endpoint: `http://cozydorms.life`
- [x] Phone on same network as server (or server has public IP)
- [x] Test on real device

### For Production (Future)
- [ ] Get SSL certificate for server
- [ ] Change to HTTPS: `https://cozydorms.life`
- [ ] Remove `android:usesCleartextTraffic="true"` from manifest
- [ ] Update all API endpoints to HTTPS in `constants.dart`

---

## 📱 Device-Specific Issues

### Android 9+ (API 28+)
- **Issue:** Blocks cleartext traffic by default
- **Fix:** Already applied `usesCleartextTraffic="true"`

### Android Emulator vs Real Device
- **Emulator:** Use `10.0.2.2` to access localhost
- **Real Device:** Use actual server IP or domain name

### Network Configuration
```
Emulator -> Localhost (10.0.2.2)
Real Device on WiFi -> Local IP (e.g., 192.168.1.100) or domain
Real Device on Mobile Data -> Public IP or domain only
```

---

## 🔧 Debugging Tools

### 1. Flutter DevTools
```bash
flutter run
# Press 'v' to open DevTools
# Check network tab for failed requests
```

### 2. Android Logcat
```bash
adb logcat | grep -i "http\|network\|socket"
```

### 3. Server Logs
```bash
# Check Apache error log
tail -f /xampp/htdocs/.../error_log

# Check PHP errors
tail -f /xampp/logs/php_error_log
```

### 4. Network Inspection
```bash
# Check if server is reachable
ping cozydorms.life

# Check if port 80 is open
telnet cozydorms.life 80
```

---

## 📋 API Response Format

### Expected Response
```json
{
  "dorms": [
    {
      "dorm_id": "1",
      "title": "Sample Dorm",
      "location": "Manila",
      "desc": "Description",
      "image": "http://cozydorms.life/uploads/dorm1.jpg",
      "owner_email": "owner@example.com",
      "owner_name": "John Doe",
      "min_price": "₱5,000/month",
      "available_rooms": "3",
      "latitude": "14.5995",
      "longitude": "120.9842"
    }
  ]
}
```

### Alternative Response (Array)
```json
[
  {
    "dorm_id": "1",
    ...
  }
]
```

---

## ⚠️ Important Notes

### Latitude/Longitude (For Maps)
- **Required:** For "Near Me" filter and map features
- **Format:** String or number (both accepted)
- **Example:** `"14.5995"` or `14.5995`
- **Fallback:** If missing, map features won't work but browse will

### Image URLs
- **Must be absolute:** `http://cozydorms.life/uploads/image.jpg`
- **Not relative:** `/uploads/image.jpg` ❌
- **Fallback:** App shows placeholder icon if image fails to load

---

## 🎯 Quick Fix Checklist

If you get HTTP error on real phone:

1. ✅ **Rebuild the app** after AndroidManifest changes
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. ✅ **Check phone is on same network**
   - Phone WiFi → Same router as server

3. ✅ **Test server URL in phone browser**
   - Visit: `http://cozydorms.life`
   - Visit: `http://cozydorms.life/modules/mobile-api/student_dashboard_api.php`

4. ✅ **Check server is running**
   - Start XAMPP Apache and MySQL

5. ✅ **Verify database has data**
   ```sql
   SELECT * FROM dorms LIMIT 5;
   ```

6. ✅ **Check error message details**
   - App now shows specific error
   - Read the error carefully for hints

---

## 📞 Still Having Issues?

If error persists after applying fixes:

1. **Check exact error message** displayed in app
2. **Test API in browser** from phone
3. **Check server logs** for PHP errors
4. **Verify network connectivity** (ping server from phone)
5. **Try different network** (mobile data vs WiFi)

---

**Status:** ✅ Fixes Applied  
**Next Step:** Rebuild app and test on real device
