# 📬 Postman API Testing Guide

**Date**: October 19, 2025  
**Purpose**: Test cozydorms.life mobile APIs using Postman  
**Target**: Owner Bookings API (fixing 404 error)

---

## 🚀 Quick Setup

### 1. Install Postman
- Download: https://www.postman.com/downloads/
- Or use web version: https://web.postman.com/

### 2. Create New Collection
1. Open Postman
2. Click "New" → "Collection"
3. Name it: **"CozyDorms Mobile API"**

---

## 🧪 Test #1: Owner Bookings - GET Request

### Request Details

**Method:** `GET`

**URL:**
```
http://cozydorms.life/modules/mobile-api/owner/owner_bookings_api.php
```

**Query Parameters:**
| Key | Value | Description |
|-----|-------|-------------|
| `owner_email` | `your@email.com` | Replace with your actual owner email |

**Headers:**
| Key | Value |
|-----|-------|
| `Accept` | `application/json` |

### How to Set Up in Postman

1. **Create New Request**
   - Click "New" → "HTTP Request"
   - Name it: "Get Owner Bookings"
   - Save to "CozyDorms Mobile API" collection

2. **Set Method and URL**
   - Method: `GET`
   - URL: `http://cozydorms.life/modules/mobile-api/owner/owner_bookings_api.php`

3. **Add Query Parameters**
   - Click "Params" tab
   - Add key: `owner_email`
   - Add value: `your@email.com` (your actual email)

4. **Add Headers**
   - Click "Headers" tab
   - Add: `Accept: application/json`

5. **Send Request**
   - Click "Send" button
   - Check response

### Expected Response (Success - 200 OK)

```json
{
  "ok": true,
  "success": true,
  "bookings": [
    {
      "id": 1,
      "booking_id": 1,
      "student_email": "student@example.com",
      "student_name": "John Doe",
      "requested_at": "2h ago",
      "status": "Pending",
      "dorm": "Sample Dorm",
      "dorm_name": "Sample Dorm",
      "room_type": "Standard",
      "booking_type": "Whole",
      "duration": "3 months",
      "start_date": "2025-11-01",
      "end_date": "2026-02-01",
      "base_price": 5000,
      "capacity": 2,
      "price": "₱5,000.00",
      "message": "I would like to book this room"
    }
  ]
}
```

### Possible Error Responses

**404 Not Found:**
```
Status: 404 Not Found
Body: <!DOCTYPE html>...File not found...
```
**Cause:** API file doesn't exist on server  
**Solution:** Upload `owner_bookings_api.php` to server

**400 Bad Request:**
```json
{
  "ok": false,
  "success": false,
  "error": "Owner email required"
}
```
**Cause:** Missing `owner_email` parameter  
**Solution:** Add the query parameter

**404 Not Found (JSON):**
```json
{
  "ok": false,
  "success": false,
  "error": "Owner not found"
}
```
**Cause:** Email not in database or not an owner  
**Solution:** Use correct owner email or create owner account

**500 Internal Server Error:**
```json
{
  "ok": false,
  "success": false,
  "error": "Server error: SQLSTATE[...]"
}
```
**Cause:** Database connection issue or SQL error  
**Solution:** Check `config.php` and database

---

## 🧪 Test #2: Approve Booking - POST Request

### Request Details

**Method:** `POST`

**URL:**
```
http://cozydorms.life/modules/mobile-api/owner/owner_bookings_api.php
```

**Body Type:** `x-www-form-urlencoded`

**Body Parameters:**
| Key | Value | Description |
|-----|-------|-------------|
| `action` | `approve` | Action to perform |
| `booking_id` | `1` | ID of booking to approve |
| `owner_email` | `your@email.com` | Your owner email |

### How to Set Up in Postman

1. **Create New Request**
   - Click "New" → "HTTP Request"
   - Name it: "Approve Booking"
   - Save to "CozyDorms Mobile API" collection

2. **Set Method and URL**
   - Method: `POST`
   - URL: `http://cozydorms.life/modules/mobile-api/owner/owner_bookings_api.php`

3. **Set Body**
   - Click "Body" tab
   - Select "x-www-form-urlencoded"
   - Add parameters:
     ```
     action: approve
     booking_id: 1
     owner_email: your@email.com
     ```

4. **Send Request**
   - Click "Send"
   - Check response

### Expected Response (Success - 200 OK)

```json
{
  "ok": true,
  "success": true,
  "message": "Booking approved successfully"
}
```

### Possible Error Responses

**400 Bad Request:**
```json
{
  "ok": false,
  "success": false,
  "error": "Owner email required"
}
```

**403 Forbidden:**
```json
{
  "ok": false,
  "success": false,
  "error": "Booking not found or access denied"
}
```

---

## 🧪 Test #3: Reject Booking - POST Request

### Request Details

**Method:** `POST`

**URL:**
```
http://cozydorms.life/modules/mobile-api/owner/owner_bookings_api.php
```

**Body Type:** `x-www-form-urlencoded`

**Body Parameters:**
| Key | Value | Description |
|-----|-------|-------------|
| `action` | `reject` | Action to perform |
| `booking_id` | `1` | ID of booking to reject |
| `owner_email` | `your@email.com` | Your owner email |

### Expected Response (Success - 200 OK)

```json
{
  "ok": true,
  "success": true,
  "message": "Booking rejected successfully"
}
```

---

## 🧪 Test #4: Login API

### Request Details

**Method:** `POST`

**URL:**
```
http://cozydorms.life/modules/mobile-api/auth/login-api.php
```

**Body Type:** `raw` → `JSON`

**Body:**
```json
{
  "email": "your@email.com",
  "password": "your_password"
}
```

**Headers:**
| Key | Value |
|-----|-------|
| `Content-Type` | `application/json` |
| `Accept` | `application/json` |

### Expected Response (Success - 200 OK)

```json
{
  "success": true,
  "ok": true,
  "user_id": 1,
  "name": "John Doe",
  "email": "your@email.com",
  "role": "owner"
}
```

---

## 🧪 Test #5: Owner Dashboard

### Request Details

**Method:** `GET`

**URL:**
```
http://cozydorms.life/modules/mobile-api/owner/owner_dashboard_api.php?owner_email=your@email.com
```

### Expected Response (Success - 200 OK)

```json
{
  "ok": true,
  "stats": {
    "total_dorms": 5,
    "total_rooms": 20,
    "occupied_rooms": 15,
    "available_rooms": 5,
    "pending_bookings": 3,
    "total_tenants": 15,
    "monthly_revenue": 75000
  }
}
```

---

## 🧪 Test #6: Owner Payments

### Request Details

**Method:** `GET`

**URL:**
```
http://cozydorms.life/modules/mobile-api/owner/owner_payments_api.php?owner_email=your@email.com
```

### Expected Response (Success - 200 OK)

```json
{
  "ok": true,
  "payments": [
    {
      "payment_id": 1,
      "tenant_name": "Jane Smith",
      "amount": "5000.00",
      "due_date": "2025-11-01",
      "status": "pending",
      "receipt_image": null
    }
  ]
}
```

---

## 📊 Postman Collection JSON

### Import This Collection

Save this as `cozydorms-api.postman_collection.json`:

```json
{
  "info": {
    "name": "CozyDorms Mobile API",
    "description": "Testing collection for CozyDorms mobile APIs",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Owner Bookings",
      "item": [
        {
          "name": "Get Owner Bookings",
          "request": {
            "method": "GET",
            "header": [
              {
                "key": "Accept",
                "value": "application/json"
              }
            ],
            "url": {
              "raw": "http://cozydorms.life/modules/mobile-api/owner/owner_bookings_api.php?owner_email={{owner_email}}",
              "protocol": "http",
              "host": ["cozydorms", "life"],
              "path": ["modules", "mobile-api", "owner", "owner_bookings_api.php"],
              "query": [
                {
                  "key": "owner_email",
                  "value": "{{owner_email}}"
                }
              ]
            }
          }
        },
        {
          "name": "Approve Booking",
          "request": {
            "method": "POST",
            "header": [],
            "body": {
              "mode": "urlencoded",
              "urlencoded": [
                {
                  "key": "action",
                  "value": "approve"
                },
                {
                  "key": "booking_id",
                  "value": "1"
                },
                {
                  "key": "owner_email",
                  "value": "{{owner_email}}"
                }
              ]
            },
            "url": {
              "raw": "http://cozydorms.life/modules/mobile-api/owner/owner_bookings_api.php",
              "protocol": "http",
              "host": ["cozydorms", "life"],
              "path": ["modules", "mobile-api", "owner", "owner_bookings_api.php"]
            }
          }
        },
        {
          "name": "Reject Booking",
          "request": {
            "method": "POST",
            "header": [],
            "body": {
              "mode": "urlencoded",
              "urlencoded": [
                {
                  "key": "action",
                  "value": "reject"
                },
                {
                  "key": "booking_id",
                  "value": "1"
                },
                {
                  "key": "owner_email",
                  "value": "{{owner_email}}"
                }
              ]
            },
            "url": {
              "raw": "http://cozydorms.life/modules/mobile-api/owner/owner_bookings_api.php",
              "protocol": "http",
              "host": ["cozydorms", "life"],
              "path": ["modules", "mobile-api", "owner", "owner_bookings_api.php"]
            }
          }
        }
      ]
    },
    {
      "name": "Auth",
      "item": [
        {
          "name": "Login",
          "request": {
            "method": "POST",
            "header": [
              {
                "key": "Content-Type",
                "value": "application/json"
              },
              {
                "key": "Accept",
                "value": "application/json"
              }
            ],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"email\": \"{{owner_email}}\",\n  \"password\": \"{{owner_password}}\"\n}"
            },
            "url": {
              "raw": "http://cozydorms.life/modules/mobile-api/auth/login-api.php",
              "protocol": "http",
              "host": ["cozydorms", "life"],
              "path": ["modules", "mobile-api", "auth", "login-api.php"]
            }
          }
        }
      ]
    },
    {
      "name": "Owner Dashboard",
      "request": {
        "method": "GET",
        "header": [
          {
            "key": "Accept",
            "value": "application/json"
          }
        ],
        "url": {
          "raw": "http://cozydorms.life/modules/mobile-api/owner/owner_dashboard_api.php?owner_email={{owner_email}}",
          "protocol": "http",
          "host": ["cozydorms", "life"],
          "path": ["modules", "mobile-api", "owner", "owner_dashboard_api.php"],
          "query": [
            {
              "key": "owner_email",
              "value": "{{owner_email}}"
            }
          ]
        }
      }
    },
    {
      "name": "Owner Payments",
      "request": {
        "method": "GET",
        "header": [
          {
            "key": "Accept",
            "value": "application/json"
          }
        ],
        "url": {
          "raw": "http://cozydorms.life/modules/mobile-api/owner/owner_payments_api.php?owner_email={{owner_email}}",
          "protocol": "http",
          "host": ["cozydorms", "life"],
          "path": ["modules", "mobile-api", "owner", "owner_payments_api.php"],
          "query": [
            {
              "key": "owner_email",
              "value": "{{owner_email}}"
            }
          ]
        }
      }
    }
  ],
  "variable": [
    {
      "key": "owner_email",
      "value": "your@email.com"
    },
    {
      "key": "owner_password",
      "value": "your_password"
    }
  ]
}
```

### How to Import

1. Open Postman
2. Click "Import" button
3. Select "File"
4. Choose `cozydorms-api.postman_collection.json`
5. Update variables:
   - Click collection name
   - Go to "Variables" tab
   - Set `owner_email` to your email
   - Set `owner_password` to your password

---

## 🔍 Reading Postman Responses

### Status Code Meanings

| Code | Meaning | What It Means |
|------|---------|---------------|
| **200** | OK | ✅ Request successful |
| **400** | Bad Request | ❌ Missing or invalid parameters |
| **401** | Unauthorized | ❌ Invalid credentials |
| **403** | Forbidden | ❌ No permission to access |
| **404** | Not Found | ❌ File doesn't exist on server |
| **500** | Server Error | ❌ PHP/Database error |

### Response Time

- **< 200ms**: Excellent
- **200-500ms**: Good
- **500-1000ms**: Acceptable
- **> 1000ms**: Slow (check query optimization)

### Response Size

- **< 5KB**: Small response (good)
- **5-50KB**: Medium (normal)
- **> 50KB**: Large (consider pagination)

---

## 🐛 Troubleshooting Common Issues

### Issue 1: 404 Not Found

**Postman shows:**
```
Status: 404 Not Found
```

**Diagnosis:**
- File doesn't exist on server
- Wrong URL path
- Wrong domain

**Test:**
1. Copy URL from Postman
2. Paste in browser
3. If browser also shows 404 → File missing on server

**Solution:**
- Upload `owner_bookings_api.php` to:
  ```
  /modules/mobile-api/owner/owner_bookings_api.php
  ```

### Issue 2: CORS Error

**Postman works, but mobile app fails**

**Cause:**
- Browser/mobile enforces CORS
- Postman doesn't enforce CORS

**Solution:**
- Verify `cors.php` is included
- Check headers include:
  ```
  Access-Control-Allow-Origin: *
  ```

### Issue 3: Empty Response

**Postman shows:**
```
Status: 200 OK
Body: (empty)
```

**Causes:**
- PHP error before output
- `exit()` called too early
- Output buffering issue

**Solution:**
- Check server error logs
- Add error display temporarily:
  ```php
  error_reporting(E_ALL);
  ini_set('display_errors', 1);
  ```

### Issue 4: HTML Instead of JSON

**Postman shows HTML error page**

**Causes:**
- PHP syntax error
- Server configuration error
- .htaccess redirect

**Solution:**
- Check PHP syntax: `php -l file.php`
- Disable .htaccess temporarily
- Check server error logs

---

## ✅ Success Checklist

Mark these off as you test:

### Basic Tests
- [ ] GET Owner Bookings returns 200 status
- [ ] Response is valid JSON
- [ ] Response has `"ok": true` field
- [ ] Response has `"success": true` field
- [ ] Response has `"bookings"` array

### Data Validation
- [ ] Bookings array contains items (or is empty if no bookings)
- [ ] Each booking has required fields (id, student_name, status, etc.)
- [ ] Status values are correct (Pending, Approved, etc.)
- [ ] Dates are formatted correctly
- [ ] Prices are formatted as currency

### Error Handling
- [ ] Missing `owner_email` returns 400 error
- [ ] Invalid `owner_email` returns 404 error
- [ ] Error responses have `"error"` field
- [ ] Error responses have `"ok": false`

### POST Operations
- [ ] Can approve booking (returns success message)
- [ ] Can reject booking (returns success message)
- [ ] Invalid booking_id returns error
- [ ] Wrong owner_email can't modify booking

---

## 📱 Compare with Mobile App

After testing in Postman:

1. **If Postman works but mobile app doesn't:**
   - Problem is in Flutter code or app configuration
   - Check `ApiConstants.baseUrl`
   - Check request headers in Flutter
   - Clear app cache

2. **If Postman also fails:**
   - Problem is on the server
   - File missing or wrong location
   - Database connection issue
   - PHP error in code

---

## 🎯 Quick Test Workflow

**5-Minute Test:**

1. Open Postman
2. Create new GET request
3. URL: `http://cozydorms.life/modules/mobile-api/owner/owner_bookings_api.php`
4. Add parameter: `owner_email=your@email.com`
5. Click "Send"
6. Check status code:
   - **200** = Working! ✅
   - **404** = File not on server ❌
   - **500** = Server error ❌

That's it! You'll know immediately what's wrong.

---

**Start with the Owner Bookings GET request. If that works, the issue is somewhere else!** 🚀
