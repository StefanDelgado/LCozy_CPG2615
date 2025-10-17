# Mobile API Documentation

## Overview
This directory contains all API endpoints for the CozyDorm mobile application. All APIs follow REST principles and return JSON responses.

## Directory Structure ✅ IMPLEMENTED
```
mobile-api/
├── 📄 Documentation
│   ├── README.md
│   ├── REFACTORING_PLAN.md
│   ├── REFACTORING_SUMMARY.md
│   └── QUICK_REFERENCE.md
│
├── 🔐 auth/
│   ├── login-api.php          # User login
│   └── register_api.php       # User registration
│
├── 👨‍🎓 student/
│   ├── student_dashboard_api.php  # Student dashboard & bookings
│   ├── student_home_api.php       # Browse available dorms
│   └── student_payments_api.php   # Student payment history
│
├── 👨‍💼 owner/
│   ├── owner_dashboard_api.php    # Owner statistics & overview
│   ├── owner_dorms_api.php        # Owner's dorm listings
│   ├── owner_bookings_api.php     # Owner's booking management
│   ├── owner_payments_api.php     # Owner's payment tracking
│   └── owner_tenants_api.php      # Owner's tenant management
│
├── 🏠 dorms/
│   ├── dorm_details_api.php       # Single dorm details
│   ├── add_dorm_api.php           # Create new dorm
│   ├── update_dorm_api.php        # Update dorm information
│   └── delete_dorm_api.php        # Delete dorm
│
├── 🛏️ rooms/
│   ├── fetch_rooms.php            # Get rooms for a dorm
│   ├── add_room_api.php           # Add room to dorm
│   ├── edit_room_api.php          # Update room details
│   └── delete_room_api.php        # Delete room
│
├── 📅 bookings/
│   └── create_booking_api.php     # Create booking request
│
├── 💰 payments/
│   ├── fetch_payment_api.php      # Get payment details
│   └── upload_receipt_api.php     # Upload payment receipt
│
├── 💬 messaging/
│   ├── conversation_api.php       # Get conversations list
│   ├── messages_api.php           # Get messages in conversation
│   └── send_message_api.php       # Send new message
│
├── 🛠️ shared/
│   ├── cors.php                   # CORS handling
│   ├── geocoding_helper.php       # Location services
│   └── geocode_existing_dorms.php # Batch geocoding
│
└── 🧪 tests/
    ├── test_booking.php           # Booking tests
    └── test_db.php                # Database connection test
```

## API Naming Convention
All API files follow this naming pattern:
- `{action}_{entity}_api.php` (e.g., `create_booking_api.php`)
- `{entity}_api.php` for general entity operations (e.g., `student_dashboard_api.php`)
- Helper files use descriptive names without `_api` suffix

## Response Format
All APIs return JSON in this standard format:

### Success Response
```json
{
  "ok": true,
  "message": "Success message",
  "data": { /* response data */ }
}
```

### Error Response
```json
{
  "ok": false,
  "error": "Error description"
}
```

## Base URL
**Production:** `http://cozydorms.life`
**Mobile API Path:** `/modules/mobile-api/`

Full endpoint example: `http://cozydorms.life/modules/mobile-api/auth/login-api.php`

**Note:** All endpoints are now organized in subdirectories by feature!

## Authentication
Most endpoints require authentication via:
- `student_email` or `owner_email` as query parameter or in request body
- No token-based auth currently implemented

## Common Parameters

### Student Endpoints
- `student_email`: Email of the logged-in student (required)

### Owner Endpoints
- `owner_email`: Email of the logged-in owner (required)

### Dorm/Room Operations
- `dorm_id`: Numeric ID of the dormitory
- `room_id`: Numeric ID of the room

## API Endpoints Reference

### Authentication
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/auth/login-api.php` | POST | User login |
| `/auth/register_api.php` | POST | User registration |

### Student APIs
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/student/student_dashboard_api.php` | GET | Get student bookings & dashboard |
| `/student/student_home_api.php` | GET | Browse all available dorms |
| `/student/student_payments_api.php` | GET | Get student payment history |

### Owner APIs
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/owner/owner_dashboard_api.php` | GET | Get owner statistics |
| `/owner/owner_dorms_api.php` | GET | Get owner's dorm listings |
| `/owner/owner_bookings_api.php` | GET/POST | Get/manage bookings |
| `/owner/owner_payments_api.php` | GET | Get payment tracking |
| `/owner/owner_tenants_api.php` | GET | Get tenant information |

### Dorm Management
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/dorms/dorm_details_api.php` | GET | Get detailed dorm information |
| `/dorms/add_dorm_api.php` | POST | Create new dormitory |
| `/dorms/update_dorm_api.php` | POST | Update dorm information |
| `/dorms/delete_dorm_api.php` | POST/DELETE | Remove dormitory |

### Room Management
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/rooms/fetch_rooms.php` | GET | Get rooms for a dorm |
| `/rooms/add_room_api.php` | POST | Add room to dorm |
| `/rooms/edit_room_api.php` | POST | Update room details |
| `/rooms/delete_room_api.php` | POST/DELETE | Remove room |

### Booking System
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/bookings/create_booking_api.php` | POST | Create booking request |
| `/owner/owner_bookings_api.php` | POST | Approve/reject booking |

### Payment System
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/payments/fetch_payment_api.php` | GET | Get payment details |
| `/payments/upload_receipt_api.php` | POST | Upload payment proof |

### Messaging System
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/messaging/conversation_api.php` | GET | Get user conversations |
| `/messaging/messages_api.php` | GET | Get conversation messages |
| `/messaging/send_message_api.php` | POST | Send message |

## Mobile Service Integration

The Flutter mobile app uses service classes that reference these APIs through `ApiConstants`:

```dart
// lib/utils/constants.dart
class ApiConstants {
  static const String baseUrl = 'http://cozydorms.life';
}
```

### Service Files
- `auth_service.dart` - Authentication
- `booking_service.dart` - Booking operations
- `chat_service.dart` - Messaging
- `dashboard_service.dart` - Dashboard data
- `dorm_service.dart` - Dorm management
- `payment_service.dart` - Payment operations
- `room_service.dart` - Room management
- `tenant_service.dart` - Tenant data

All services use `ApiConstants.baseUrl` + `/modules/mobile-api/` + `{category}/` + endpoint

**Example:** `${ApiConstants.baseUrl}/modules/mobile-api/auth/login-api.php`

## Recent Changes (October 2025)

### ✅ Phase 1: Initial Cleanup
1. ✅ Removed duplicate file `dorm_details.api.php` (kept `dorm_details_api.php`)
2. ✅ Standardized all mobile service files to use `ApiConstants.baseUrl`
3. ✅ Fixed hardcoded URLs in:
   - `booking_service.dart`
   - `payment_service.dart`

### ✅ Phase 2: Organized Directory Structure (COMPLETED!)
1. ✅ Created organized subdirectories:
   - `auth/` - Authentication APIs
   - `student/` - Student-specific APIs
   - `owner/` - Owner-specific APIs
   - `dorms/` - Dorm management APIs
   - `rooms/` - Room management APIs
   - `bookings/` - Booking APIs
   - `payments/` - Payment APIs
   - `messaging/` - Chat/messaging APIs
   - `shared/` - Shared utilities (CORS, geocoding)
   - `tests/` - Testing files

2. ✅ Moved all API files to appropriate directories
3. ✅ Updated all 8 mobile service files with new paths:
   - `auth_service.dart` ✅
   - `booking_service.dart` ✅
   - `chat_service.dart` ✅
   - `dashboard_service.dart` ✅
   - `dorm_service.dart` ✅
   - `payment_service.dart` ✅
   - `room_service.dart` ✅
   - `tenant_service.dart` ✅

4. ✅ All service files tested - NO ERRORS!

### Refactoring Notes
- All services now use organized paths with subdirectories
- API naming follows: `{category}/{action}_{entity}_api.php` pattern
- Legacy files in `mobile/lib/legacy/` still need updating (separate task)

## Testing
Test endpoints are available:
- `test_db.php` - Database connectivity
- `test_booking.php` - Booking system functionality

## Security Notes
⚠️ Current implementation notes:
- CORS is handled via `cors.php` include
- No JWT or token-based authentication currently
- Email-based identification for user operations
- Consider implementing proper authentication tokens for production

## Future Improvements
- [ ] Implement JWT authentication
- [ ] Add rate limiting
- [ ] Improve error handling standardization
- [ ] Add API versioning (e.g., `/v1/mobile-api/`)
- [ ] Complete migration of legacy screens to use service classes
- [ ] Add comprehensive API documentation with request/response examples
