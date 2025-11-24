# Quick Test Guide - Mobile Image Fix

## What Was Fixed
Mobile app was trying to load dorm images from `http://cozydorms.life` (live server) even when testing locally. Now it automatically detects the environment and uses the correct URL.

## How to Test

### 1. Verify XAMPP is Running
```
✓ Apache - Running on port 80
✓ MySQL - Running on port 3306
```

### 2. Check Database Connection
Open browser: `http://localhost/WebDesign_BSITA-2/2nd%20sem/Joshan_System/LCozy_CPG2615/Main/`

Should see the LCozy homepage without errors.

### 3. Test Mobile API Directly

**Test Browse Dorms API:**
```
URL: http://localhost/WebDesign_BSITA-2/2nd%20sem/Joshan_System/LCozy_CPG2615/Main/modules/mobile-api/student/student_home_api.php

Expected Response:
{
  "ok": true,
  "dorms": [
    {
      "dorm_id": 1,
      "image": "http://localhost/WebDesign_BSITA-2/2nd%20sem/Joshan_System/LCozy_CPG2615/Main/uploads/dorms/dorm_1_cover.jpg",
      "location": "Near UST",
      "title": "St. Claire Student Inn",
      ...
    }
  ]
}
```

**✅ Correct:** Image URL starts with `http://localhost/...`
**❌ Wrong:** Image URL starts with `http://cozydorms.life/...`

### 4. Test Mobile App

**Method 1: Physical Device/Emulator**
1. Open LCozy mobile app
2. Login as student
3. Go to "Browse Dorms" screen
4. **Expected:** Dorm images load correctly
5. **Check:** No broken image icons (home icon fallback)

**Method 2: Flutter DevTools Console**
1. Run app in debug mode
2. Check console for image loading errors
3. Look for these debug prints:
   ```
   🌐 API Call: http://localhost/.../student_home_api.php
   📡 Response Status: 200
   ✅ Found dorms in Map: X dorms
   ```

### 5. Verify Each Image Type

| Feature | API Endpoint | Test Action |
|---------|--------------|-------------|
| Browse Dorms | `student_home_api.php` | Open browse screen, see dorm cards |
| Dorm Details | `dorm_details_api.php` | Tap a dorm, view image gallery |
| Student Dashboard | `student_dashboard_api.php` | View "My Bookings" cards |
| Payment Receipts | `student_payments_api.php` | View payment history |
| Upload Receipt | `upload_receipt_api.php` | Upload a receipt image |

### 6. Common Issues & Solutions

**Issue:** Still seeing `http://cozydorms.life` in API response
- **Fix:** Restart Apache (XAMPP Control Panel → Stop → Start)
- **Reason:** PHP file cache needs to refresh

**Issue:** Images still not loading
- **Check 1:** Verify images exist in `/Main/uploads/dorms/` folder
- **Check 2:** Check file permissions (should be readable)
- **Check 3:** Verify database `cover_image` field has correct filename

**Issue:** 404 error on image URL
- **Check:** URL path matches actual folder structure
- **Expected:** `/Main/uploads/dorms/filename.jpg`
- **Verify:** File actually exists at that location

**Issue:** Connection refused on mobile
- **Check:** Mobile device can reach localhost
- **Solution:** Use computer's IP address instead
- **Update:** `config.php` → Change localhost to `192.168.x.x`

### 7. Production Deployment Test

When deploying to live server:

1. Upload all modified files
2. Clear server cache (if using caching)
3. Test API directly:
   ```
   URL: http://cozydorms.life/modules/mobile-api/student/student_home_api.php
   
   Expected image URL: http://cozydorms.life/uploads/dorms/...
   ```
4. Test mobile app connected to production
5. Verify images load from production server

### 8. Verification Checklist

Copy this to verify all working:

```
LOCAL TESTING
[ ] XAMPP running (Apache + MySQL)
[ ] Browse dorms API returns localhost URLs
[ ] Mobile app browse dorms shows images
[ ] Dorm details shows all images
[ ] Student dashboard booking cards show images
[ ] Payment receipts display correctly
[ ] No console errors

PRODUCTION TESTING (when deployed)
[ ] API returns cozydorms.life URLs
[ ] Mobile app (production mode) shows images
[ ] All image types loading correctly
[ ] No 404 errors in browser console
```

---

## Debug Commands

**Check current SITE_URL:**
```php
// Add this temporarily to any API file:
echo json_encode(['SITE_URL' => SITE_URL]);
exit;
```

**Check database connection:**
```php
// Add this to config.php after PDO connection:
echo "Connected to: " . $pdo->query("SELECT DATABASE()")->fetchColumn();
echo " at " . $pdo->getAttribute(PDO::ATTR_CONNECTION_INFO);
```

**Test image exists:**
```
Open in browser:
http://localhost/WebDesign_BSITA-2/2nd%20sem/Joshan_System/LCozy_CPG2615/Main/uploads/dorms/[filename]

If 404: Image file missing
If loads: Image exists, API URL construction issue
```

---

## Expected Results Summary

### Local (XAMPP)
- API responses: `http://localhost/WebDesign_BSITA-2/...`
- Images load from: Local disk (`C:/xampp/htdocs/...`)
- Database: localhost (127.0.0.1)

### Production (GoDaddy)
- API responses: `http://cozydorms.life/...`
- Images load from: Live server
- Database: Remote (50.63.129.30)

Both environments now work without code changes!

---

**Last Updated:** 2025
**Status:** Ready for Testing
