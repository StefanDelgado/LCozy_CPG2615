# 🧪 Tenant Management API - Postman Test Guide

**Date**: October 19, 2025  
**Issue**: Tenant management not showing anything on mobile  
**Test Method**: Postman API testing  

---

## 🎯 Quick Test

### Test URL

```
GET http://cozydorms.life/modules/mobile-api/owner/owner_tenants_api.php?owner_email=YOUR_EMAIL
```

Replace `YOUR_EMAIL` with your actual owner email address.

---

## 📋 Step-by-Step Testing

### Step 1: Open Postman

1. Launch Postman application
2. Create new request or use existing collection

### Step 2: Configure Request

**Method:** `GET`

**URL:**
```
http://cozydorms.life/modules/mobile-api/owner/owner_tenants_api.php
```

**Query Parameters:**

| Key | Value | Description |
|-----|-------|-------------|
| `owner_email` | `your@email.com` | Your owner account email |

**Headers:**

| Key | Value |
|-----|-------|
| `Accept` | `application/json` |

### Step 3: Send Request

Click the **"Send"** button and check the response.

---

## ✅ Expected Response (Success)

### Status Code: `200 OK`

```json
{
  "ok": true,
  "current_tenants": [
    {
      "tenant_id": 1,
      "tenant_name": "John Doe",
      "tenant_email": "john@example.com",
      "dorm_name": "Sample Dorm",
      "room_type": "Single",
      "move_in_date": "2025-01-15",
      "payment_status": "Paid",
      "monthly_rent": "5000.00",
      "contact": "+639123456789"
    }
  ],
  "past_tenants": [
    {
      "tenant_id": 2,
      "tenant_name": "Jane Smith",
      "tenant_email": "jane@example.com",
      "dorm_name": "Sample Dorm",
      "room_type": "Double",
      "move_in_date": "2024-08-01",
      "move_out_date": "2025-01-10",
      "total_paid": "30000.00"
    }
  ]
}
```

---

## ❌ Possible Error Responses

### Error 1: Missing Parameter (400 Bad Request)

```json
{
  "ok": false,
  "error": "Owner email required"
}
```

**Cause:** Forgot to add `owner_email` query parameter  
**Solution:** Add the parameter

---

### Error 2: Owner Not Found (404 Not Found)

```json
{
  "ok": false,
  "error": "Owner not found"
}
```

**Cause:** Email doesn't exist in database or not an owner account  
**Solution:** Use correct owner email or create owner account

---

### Error 3: No Tenants Found (200 OK but empty)

```json
{
  "ok": true,
  "current_tenants": [],
  "past_tenants": []
}
```

**Cause:** Owner has no tenants yet  
**This is VALID** - means API works but owner has no data

---

### Error 4: File Not Found (404 Not Found)

```
Status: 404 Not Found
Body: <!DOCTYPE html>...File not found...
```

**Cause:** API file doesn't exist on server  
**Solution:** Upload `owner_tenants_api.php` to:
```
/modules/mobile-api/owner/owner_tenants_api.php
```

---

### Error 5: Server Error (500 Internal Server Error)

```json
{
  "ok": false,
  "error": "Database error: SQLSTATE[...]"
}
```

**Cause:** Database connection issue or SQL error  
**Solution:** Check `config.php` and database connection

---

## 🔍 Interpreting Results

### Scenario 1: Returns Data ✅

**Response:**
```json
{
  "ok": true,
  "current_tenants": [ {...} ],
  "past_tenants": [ {...} ]
}
```

**Diagnosis:**
- ✅ API is working
- ✅ Server is working
- ✅ Database is connected
- ❌ **Problem is in the mobile app** (Flutter code)

**Next Steps:**
- Check Flutter tenant screen
- Check TenantService
- Check data parsing
- Check widget rendering

---

### Scenario 2: Empty Arrays ⚠️

**Response:**
```json
{
  "ok": true,
  "current_tenants": [],
  "past_tenants": []
}
```

**Diagnosis:**
- ✅ API is working
- ✅ Database query works
- ⚠️ Owner has no tenants

**Possible Reasons:**
1. Owner hasn't approved any bookings yet
2. No active bookings in database
3. Bookings exist but not linked to this owner
4. Booking status is not "Active"

**To Create Test Data:**
1. Have a student create a booking
2. Approve the booking as owner
3. Booking status should be "Active"
4. Active bookings appear as current tenants

---

### Scenario 3: 404 Error ❌

**Response:**
```
404 Not Found
```

**Diagnosis:**
- ❌ API file not on server
- ❌ Wrong URL path

**Solution:**
- Verify file exists at: `/modules/mobile-api/owner/owner_tenants_api.php`
- Check file permissions (should be 644)
- Upload file if missing

---

### Scenario 4: 500 Error ❌

**Response:**
```json
{
  "ok": false,
  "error": "Database error..."
}
```

**Diagnosis:**
- ❌ Database issue
- ❌ SQL query error
- ❌ Connection problem

**Solution:**
- Check database credentials in `config.php`
- Check database tables exist
- Check SQL query in API file

---

## 🔍 Let's Check the API File

Let me look at what the tenant API actually returns:

### Expected Query Logic

The API should:
1. Accept `owner_email` parameter
2. Query database for tenants belonging to owner's dorms
3. Separate current vs past tenants
4. Return JSON with both arrays

### Check Database

**Current Tenants Query:**
```sql
SELECT 
    u.user_id as tenant_id,
    u.name as tenant_name,
    u.email as tenant_email,
    d.name as dorm_name,
    r.room_type,
    b.start_date as move_in_date,
    p.status as payment_status,
    r.price as monthly_rent
FROM bookings b
JOIN users u ON b.student_email = u.email
JOIN rooms r ON b.room_id = r.room_id
JOIN dorms d ON r.dorm_id = d.dorm_id
WHERE d.owner_email = ?
  AND b.status = 'Active'
  AND b.end_date >= CURDATE()
```

**Past Tenants Query:**
```sql
SELECT 
    u.user_id as tenant_id,
    u.name as tenant_name,
    u.email as tenant_email,
    d.name as dorm_name,
    r.room_type,
    b.start_date as move_in_date,
    b.end_date as move_out_date
FROM bookings b
JOIN users u ON b.student_email = u.email
JOIN rooms r ON b.room_id = r.room_id
JOIN dorms d ON r.dorm_id = d.dorm_id
WHERE d.owner_email = ?
  AND (b.status = 'Completed' OR b.end_date < CURDATE())
```

---

## 🐛 Common Issues & Fixes

### Issue 1: API Returns Data but Mobile Shows Empty

**Diagnosis:** Data parsing issue in Flutter

**Check:**
1. TenantService parsing logic
2. Model classes match JSON structure
3. Widget expects correct data format

**Flutter Console Logs:**
```dart
print('API Response: $responseData');
print('Current tenants count: ${currentTenants.length}');
print('Past tenants count: ${pastTenants.length}');
```

---

### Issue 2: No Tenants in Database

**Diagnosis:** No bookings have been approved/activated

**Solution:**
1. Create a student booking
2. Approve it as owner
3. Status should be "Active"
4. Tenant should appear in current_tenants

---

### Issue 3: Wrong Response Format

**API might be returning:**
```json
{
  "success": true,  // Instead of "ok"
  "tenants": [...]  // Instead of "current_tenants"
}
```

**Check:**
- API response keys match what Flutter expects
- Modern API uses `"ok"` and `"current_tenants"`/`"past_tenants"`

---

## 🧪 Complete Test Sequence

### Test 1: Basic Connection
```bash
# Test if API file exists
curl -I http://cozydorms.life/modules/mobile-api/owner/owner_tenants_api.php
# Should return: 200 OK (or 400 if parameter missing)
```

### Test 2: With Owner Email
```bash
# In Postman
GET http://cozydorms.life/modules/mobile-api/owner/owner_tenants_api.php?owner_email=YOUR_EMAIL
```

### Test 3: Check Response Structure
- Verify `"ok"` field exists
- Verify `"current_tenants"` array exists
- Verify `"past_tenants"` array exists
- Check if arrays are empty or have data

### Test 4: If Empty Arrays
- Check bookings table in database
- Verify owner has dorms
- Verify dorms have rooms
- Verify rooms have bookings
- Verify bookings are "Active"

---

## 📝 Debugging Checklist

Run through this checklist after Postman test:

**API Level:**
- [ ] Postman returns 200 status
- [ ] Response has `"ok": true`
- [ ] Response has `current_tenants` array
- [ ] Response has `past_tenants` array
- [ ] Arrays contain data (or empty if no tenants)

**Data Level:**
- [ ] Owner has dorms in database
- [ ] Dorms have rooms
- [ ] Rooms have bookings
- [ ] At least one booking status is "Active"
- [ ] Booking dates are valid

**Mobile App Level:**
- [ ] TenantService calls correct URL
- [ ] Service parses response correctly
- [ ] Screen receives data from service
- [ ] Widget renders tenant cards
- [ ] Empty state shows if no data

---

## 🎯 Next Steps Based on Results

### If Postman Returns Data:
→ **Problem is in Flutter app**
- Check TenantService parsing
- Check OwnerTenantsScreen rendering
- Add debug prints to trace data flow

### If Postman Returns Empty Arrays:
→ **No tenant data in database**
- Create test bookings
- Approve bookings
- Verify booking status is "Active"

### If Postman Returns 404:
→ **API file issue**
- Upload API file to server
- Check file path is correct
- Verify file permissions

### If Postman Returns 500:
→ **Server/Database issue**
- Check database connection
- Check SQL queries
- Review server error logs

---

## 📞 Ready to Test!

**Run the test now and paste the response here.**

I'll help you interpret the results and identify the exact problem! 🚀
