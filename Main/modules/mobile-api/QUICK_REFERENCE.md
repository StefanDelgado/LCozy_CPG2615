# Mobile API Quick Reference

**Base URL:** `http://cozydorms.life/modules/mobile-api/`

---

## 🔐 Authentication

### Login
- **File:** `login-api.php`
- **Method:** POST
- **Body:** `{email, password}`
- **Response:** `{ok, role, name, email}`

### Register
- **File:** `register_api.php`
- **Method:** POST
- **Body:** `{name, email, password, role}`
- **Response:** `{ok, message}`

---

## 👨‍🎓 Student APIs

### Dashboard
- **File:** `student_dashboard_api.php`
- **Method:** GET
- **Params:** `?student_email={email}`
- **Returns:** Bookings, stats

### Browse Dorms
- **File:** `student_home_api.php`
- **Method:** GET
- **Returns:** All available dorms

### Payments
- **File:** `student_payments_api.php`
- **Method:** GET
- **Params:** `?student_email={email}`
- **Returns:** Payment history, stats

---

## 👨‍💼 Owner APIs

### Dashboard
- **File:** `owner_dashboard_api.php`
- **Method:** GET
- **Params:** `?owner_email={email}`
- **Returns:** Stats, activities

### Dorms List
- **File:** `owner_dorms_api.php`
- **Method:** GET
- **Params:** `?owner_email={email}`
- **Returns:** Owner's dorms

### Bookings
- **File:** `owner_bookings_api.php`
- **Method:** GET/POST
- **GET Params:** `?owner_email={email}`
- **POST Body:** `{action: 'approve'|'reject', booking_id, owner_email}`

### Payments
- **File:** `owner_payments_api.php`
- **Method:** GET
- **Params:** `?owner_email={email}`
- **Returns:** Payment tracking

### Tenants
- **File:** `owner_tenants_api.php`
- **Method:** GET
- **Params:** `?owner_email={email}`
- **Returns:** Tenant list, stats

---

## 🏠 Dorm Management

### View Details
- **File:** `dorm_details_api.php`
- **Method:** GET
- **Params:** `?dorm_id={id}`
- **Returns:** Full dorm details, rooms, reviews

### Add Dorm
- **File:** `add_dorm_api.php`
- **Method:** POST
- **Body:** `{dorm_name, address, owner_email, description, amenities, cover_image}`

### Update Dorm
- **File:** `update_dorm_api.php`
- **Method:** POST
- **Body:** `{dorm_id, ...fields to update}`

### Delete Dorm
- **File:** `delete_dorm_api.php`
- **Method:** POST
- **Body:** `{dorm_id, owner_email}`

---

## 🛏️ Room Management

### Fetch Rooms
- **File:** `fetch_rooms.php`
- **Method:** GET
- **Params:** `?dorm_id={id}`
- **Returns:** Rooms for dorm

### Add Room
- **File:** `add_room_api.php`
- **Method:** POST
- **Body:** `{dorm_id, room_number, room_type, capacity, price, status}`

### Edit Room
- **File:** `edit_room_api.php`
- **Method:** POST
- **Body:** `{room_id, ...fields to update}`

### Delete Room
- **File:** `delete_room_api.php`
- **Method:** POST
- **Body:** `{room_id}`

---

## 📅 Booking System

### Create Booking
- **File:** `create_booking_api.php`
- **Method:** POST
- **Body:** `{student_email, dorm_id, room_id, booking_type, check_in_date, check_out_date}`

---

## 💰 Payment System

### Fetch Payment Details
- **File:** `fetch_payment_api.php`
- **Method:** GET
- **Params:** `?payment_id={id}`

### Upload Receipt
- **File:** `upload_receipt_api.php`
- **Method:** POST
- **Body:** `{booking_id, student_email, receipt_image (base64)}`

---

## 💬 Messaging System

### Get Conversations
- **File:** `conversation_api.php`
- **Method:** GET
- **Params:** `?user_email={email}&user_role={student|owner}`

### Get Messages
- **File:** `messages_api.php`
- **Method:** GET
- **Params:** `?user_email={email}&dorm_id={id}&other_user_id={id}`

### Send Message
- **File:** `send_message_api.php`
- **Method:** POST
- **Body:** `{sender_email, receiver_id, dorm_id, message}`

---

## 🛠️ Utilities

### CORS Handler
- **File:** `cors.php`
- **Usage:** `require_once 'cors.php';` in API files

### Geocoding Helper
- **File:** `geocoding_helper.php`
- **Function:** Convert addresses to coordinates

### Batch Geocode
- **File:** `geocode_existing_dorms.php`
- **Usage:** One-time script to geocode all dorms

---

## 🧪 Testing

### Test Database
- **File:** `test_db.php`
- **Purpose:** Check DB connection

### Test Booking
- **File:** `test_booking.php`
- **Purpose:** Test booking creation

---

## 📚 Documentation Files

- **README.md** - Complete API documentation
- **REFACTORING_PLAN.md** - Organization plan
- **REFACTORING_SUMMARY.md** - Changes summary
- **QUICK_REFERENCE.md** - This file

---

## 🎯 Response Format

All APIs return JSON:

```json
// Success
{
  "ok": true,
  "message": "Success",
  "data": { ... }
}

// Error
{
  "ok": false,
  "error": "Error description"
}
```

---

## 📱 Mobile Service Classes

**Location:** `mobile/lib/services/`

- `auth_service.dart` - Authentication
- `booking_service.dart` - Bookings
- `chat_service.dart` - Messaging
- `dashboard_service.dart` - Dashboard
- `dorm_service.dart` - Dorms
- `location_service.dart` - GPS/Location
- `payment_service.dart` - Payments
- `room_service.dart` - Rooms
- `tenant_service.dart` - Tenants

All services use: `${ApiConstants.baseUrl}/modules/mobile-api/{filename}`

---

## 🔗 Quick Links

**Config:** `mobile/lib/utils/constants.dart`

```dart
class ApiConstants {
  static const String baseUrl = 'http://cozydorms.life';
}
```

**Full Documentation:** [README.md](./README.md)  
**Refactoring Plan:** [REFACTORING_PLAN.md](./REFACTORING_PLAN.md)  
**Change Summary:** [REFACTORING_SUMMARY.md](./REFACTORING_SUMMARY.md)
