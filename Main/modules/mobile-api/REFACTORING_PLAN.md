# Mobile API Refactoring Plan

## Current Status
✅ **Completed:**
1. Removed duplicate `dorm_details.api.php` file
2. Updated `booking_service.dart` to use `ApiConstants.baseUrl`
3. Updated `payment_service.dart` to use `ApiConstants.baseUrl` (2 occurrences)
4. Created comprehensive API documentation in `README.md`

## File Organization

### Current Structure (Flat)
All API files are in a single directory:
```
mobile-api/
├── add_dorm_api.php
├── add_room_api.php
├── conversation_api.php
├── cors.php
├── create_booking_api.php
├── delete_dorm_api.php
├── delete_room_api.php
├── dorm_details_api.php
├── edit_room_api.php
├── fetch_payment_api.php
├── fetch_rooms.php
├── geocode_existing_dorms.php
├── geocoding_helper.php
├── login-api.php
├── messages_api.php
├── owner_bookings_api.php
├── owner_dashboard_api.php
├── owner_dorms_api.php
├── owner_payments_api.php
├── owner_tenants_api.php
├── register_api.php
├── send_message_api.php
├── student_dashboard_api.php
├── student_home_api.php
├── student_payments_api.php
├── test_booking.php
├── test_db.php
├── update_dorm_api.php
└── upload_receipt_api.php
```

### Proposed Structure (Organized by Feature)
```
mobile-api/
├── README.md
├── index.php (API directory index/documentation)
│
├── auth/
│   ├── login-api.php
│   └── register_api.php
│
├── student/
│   ├── student_dashboard_api.php
│   ├── student_home_api.php
│   └── student_payments_api.php
│
├── owner/
│   ├── owner_dashboard_api.php
│   ├── owner_dorms_api.php
│   ├── owner_bookings_api.php
│   ├── owner_payments_api.php
│   └── owner_tenants_api.php
│
├── dorms/
│   ├── dorm_details_api.php
│   ├── add_dorm_api.php
│   ├── update_dorm_api.php
│   └── delete_dorm_api.php
│
├── rooms/
│   ├── fetch_rooms.php
│   ├── add_room_api.php
│   ├── edit_room_api.php
│   └── delete_room_api.php
│
├── bookings/
│   └── create_booking_api.php
│
├── payments/
│   ├── fetch_payment_api.php
│   └── upload_receipt_api.php
│
├── messaging/
│   ├── conversation_api.php
│   ├── messages_api.php
│   └── send_message_api.php
│
├── shared/
│   ├── cors.php
│   ├── geocoding_helper.php
│   └── geocode_existing_dorms.php
│
└── tests/
    ├── test_booking.php
    └── test_db.php
```

## Migration Steps (OPTIONAL - Not Recommended During Active Development)

⚠️ **Warning:** Organizing files into subdirectories will require updating all API endpoint URLs in mobile services.

### If You Want to Organize:

1. **Create subdirectories:**
   ```powershell
   cd Main/modules/mobile-api
   mkdir auth, student, owner, dorms, rooms, bookings, payments, messaging, shared, tests
   ```

2. **Move files to respective directories:**
   - Move `login-api.php`, `register_api.php` → `auth/`
   - Move `student_*.php` → `student/`
   - Move `owner_*.php` → `owner/`
   - Move dorm-related files → `dorms/`
   - Move room-related files → `rooms/`
   - Move booking files → `bookings/`
   - Move payment files → `payments/`
   - Move messaging files → `messaging/`
   - Move helper files → `shared/`
   - Move test files → `tests/`

3. **Update all mobile service files:**
   - `auth_service.dart`: Update login/register paths
   - `booking_service.dart`: Update booking paths
   - `chat_service.dart`: Update messaging paths
   - `dorm_service.dart`: Update dorm paths
   - `payment_service.dart`: Update payment paths
   - `room_service.dart`: Update room paths
   - `dashboard_service.dart`: Update dashboard paths
   - `tenant_service.dart`: Update tenant paths

4. **Update constants.dart:**
   ```dart
   class ApiConstants {
     static const String baseUrl = 'http://cozydorms.life';
     
     // Auth
     static const String loginEndpoint = '$baseUrl/modules/mobile-api/auth/login-api.php';
     static const String registerEndpoint = '$baseUrl/modules/mobile-api/auth/register_api.php';
     
     // Student
     static const String studentDashboardEndpoint = '$baseUrl/modules/mobile-api/student/student_dashboard_api.php';
     // ... etc
   }
   ```

5. **Update legacy screens** (if still in use)

## Recommended Approach

### Keep Current Flat Structure
**Pros:**
- No breaking changes
- All APIs work as-is
- Less refactoring needed
- Easier to locate files alphabetically

**Cons:**
- Less organized
- All 30+ files in one directory

### Use Naming Conventions Instead
Keep files flat but follow strict naming:
- `auth_*.php` - Authentication
- `student_*.php` - Student operations
- `owner_*.php` - Owner operations
- `dorm_*.php` - Dorm operations (add, update, delete, details)
- `room_*.php` - Room operations
- `booking_*.php` - Booking operations
- `payment_*.php` - Payment operations
- `message_*.php` - Messaging operations

## Mobile Service Files Status

### ✅ Refactored (Using ApiConstants)
- `auth_service.dart` - Uses `ApiConstants.baseUrl`
- `booking_service.dart` - ✅ Updated to use `ApiConstants.baseUrl`
- `chat_service.dart` - Uses `ApiConstants.baseUrl`
- `dashboard_service.dart` - Uses `ApiConstants.baseUrl`
- `dorm_service.dart` - Uses `ApiConstants.baseUrl`
- `payment_service.dart` - ✅ Updated to use `ApiConstants.baseUrl`
- `room_service.dart` - Uses `ApiConstants.baseUrl`
- `tenant_service.dart` - Uses `ApiConstants.baseUrl`

### ⚠️ Legacy Files (Still Using Hardcoded URLs)
Located in `mobile/lib/legacy/MobileScreen/`:
- `ownerpayments.dart`
- `ownertenants.dart`
- `Register.dart`
- `student_home.dart`
- `ownerdorms.dart`
- `student_payments.dart`
- `viewdetails.dart`
- `ownerdashboard.dart`
- `messages_screen.dart` (in `mobile/lib/screens/`)
- `owner_payments_screen.dart` (in `mobile/lib/screens/owner/`)

**Note:** These legacy files should eventually be migrated to use the service classes or refactored to use `ApiConstants`.

## Summary

### What Was Done Today:
1. ✅ Removed duplicate `dorm_details.api.php` file
2. ✅ Refactored `booking_service.dart` to use `ApiConstants`
3. ✅ Refactored `payment_service.dart` to use `ApiConstants` (2 fixes)
4. ✅ Created comprehensive API documentation
5. ✅ Created this refactoring plan

### Files Currently in mobile-api/: 30 files
All files are functioning and accessible at: `http://cozydorms.life/modules/mobile-api/{filename}`

### Recommendation:
**Keep the current flat structure** during active development. The files are well-named and follow a consistent pattern. Organizing into subdirectories can be done later when:
- Development is more stable
- You have time for comprehensive testing
- Mobile app can be updated and tested thoroughly

The current structure is functional and maintainable with proper documentation (now provided in README.md).
