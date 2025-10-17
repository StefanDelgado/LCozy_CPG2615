# Phase 6: Service Layer Expansion 🚀

## 📋 Overview

**Goal:** Extract all remaining HTTP API calls from screens into dedicated service classes, establishing a complete service layer architecture across the entire mobile app.

**Status:** 🔄 IN PROGRESS

**Current State:**
- ✅ 2 services created (AuthService, ChatService)
- ⚠️ 88+ direct HTTP calls still in screen files
- ⚠️ API logic mixed with UI logic

**Target State:**
- ✅ Complete service layer for all features
- ✅ All HTTP calls centralized
- ✅ Clean separation of concerns
- ✅ Easy to test and mock

---

## 🎯 Phase 6 Objectives

### Primary Goals
1. **Create Service Classes** - Build dedicated services for each feature area
2. **Extract API Calls** - Move all HTTP logic from screens to services
3. **Standardize Responses** - Use consistent response format across all services
4. **Update Screens** - Refactor screens to use services instead of direct HTTP calls
5. **Maintain Zero Errors** - Keep compilation errors at zero throughout

### Secondary Goals
- Establish error handling patterns
- Add response validation
- Prepare for caching layer
- Document service patterns

---

## 📊 API Call Analysis

### Current HTTP Calls by Feature

| Feature | Screens | GET Calls | POST Calls | Total | Priority |
|---------|---------|-----------|------------|-------|----------|
| **Dorms** | 3 | 3 | 3 | 6 | HIGH |
| **Rooms** | 1 | 1 | 3 | 4 | HIGH |
| **Bookings** | 2 | 2 | 2 | 4 | HIGH |
| **Payments** | 2 | 2 | 1 | 3 | MEDIUM |
| **Tenants** | 1 | 1 | 0 | 1 | MEDIUM |
| **Dashboard** | 2 | 2 | 0 | 2 | LOW |
| **TOTAL** | **11** | **11** | **9** | **20** | |

### Service Creation Priority

1. **🔥 Priority 1: Core Features (HIGH)**
   - DormService - Dorm CRUD operations
   - RoomService - Room management
   - BookingService - Booking operations

2. **⚡ Priority 2: Secondary Features (MEDIUM)**
   - PaymentService - Payment management
   - TenantService - Tenant operations

3. **✨ Priority 3: Supporting Features (LOW)**
   - DashboardService - Dashboard data aggregation

---

## 📁 Services to Create

### 1. DormService
**File:** `lib/services/dorm_service.dart`
**Screens Affected:** 3
- `owner_dorms_screen.dart`
- `browse_dorms_screen.dart`
- `view_details_screen.dart`

**Methods:**
```dart
class DormService {
  // GET operations
  Future<Map<String, dynamic>> getOwnerDorms(String ownerEmail)
  Future<Map<String, dynamic>> getAllDorms()
  Future<Map<String, dynamic>> getDormDetails(String dormId)
  
  // POST operations
  Future<Map<String, dynamic>> addDorm(Map<String, dynamic> dormData)
  Future<Map<String, dynamic>> updateDorm(String dormId, Map<String, dynamic> dormData)
  Future<Map<String, dynamic>> deleteDorm(String dormId)
}
```

**API Endpoints:**
- GET: `/modules/mobile-api/owner_dorms_api.php`
- GET: `/mobile-api/student_dashboard_api.php`
- GET: `/mobile-api/get_dorm_details.php`
- POST: `/modules/mobile-api/add_dorm_api.php`
- POST: `/modules/mobile-api/delete_dorm_api.php`

---

### 2. RoomService
**File:** `lib/services/room_service.dart`
**Screens Affected:** 1
- `room_management_screen.dart`

**Methods:**
```dart
class RoomService {
  // GET operations
  Future<Map<String, dynamic>> getRoomsByDorm(String dormId)
  Future<Map<String, dynamic>> getRoomDetails(String roomId)
  
  // POST operations
  Future<Map<String, dynamic>> addRoom(Map<String, dynamic> roomData)
  Future<Map<String, dynamic>> updateRoom(String roomId, Map<String, dynamic> roomData)
  Future<Map<String, dynamic>> deleteRoom(String roomId)
}
```

**API Endpoints:**
- GET: `/modules/mobile-api/fetch_rooms.php`
- POST: `/modules/mobile-api/add_room_api.php`
- POST: `/modules/mobile-api/edit_room_api.php`
- POST: `/modules/mobile-api/delete_room_api.php`

---

### 3. BookingService
**File:** `lib/services/booking_service.dart`
**Screens Affected:** 3
- `student_home_screen.dart`
- `booking_form_screen.dart`
- `owner_booking_screen.dart`

**Methods:**
```dart
class BookingService {
  // GET operations
  Future<Map<String, dynamic>> getStudentBookings(String studentEmail)
  Future<Map<String, dynamic>> getOwnerBookings(String ownerEmail, String status)
  Future<Map<String, dynamic>> getBookingDetails(String bookingId)
  
  // POST operations
  Future<Map<String, dynamic>> createBooking(Map<String, dynamic> bookingData)
  Future<Map<String, dynamic>> updateBookingStatus(String bookingId, String status, String action)
  Future<Map<String, dynamic>> cancelBooking(String bookingId)
}
```

**API Endpoints:**
- GET: `/mobile-api/student_dashboard_api.php` (bookings section)
- GET: `/modules/mobile-api/owner_bookings_api.php`
- POST: `/mobile-api/create_booking_api.php`
- POST: `/modules/mobile-api/owner_bookings_api.php` (with action)

---

### 4. PaymentService
**File:** `lib/services/payment_service.dart`
**Screens Affected:** 2
- `student_payments_screen.dart`
- `owner_payments_screen.dart`

**Methods:**
```dart
class PaymentService {
  // GET operations
  Future<Map<String, dynamic>> getStudentPayments(String studentEmail)
  Future<Map<String, dynamic>> getOwnerPayments(String ownerEmail, String status)
  Future<Map<String, dynamic>> getPaymentDetails(String paymentId)
  
  // POST operations
  Future<Map<String, dynamic>> uploadPaymentProof(String paymentId, File proofFile)
  Future<Map<String, dynamic>> verifyPayment(String paymentId, String status)
}
```

**API Endpoints:**
- GET: `/mobile-api/student_payments_api.php`
- GET: `/modules/mobile-api/owner_payments_api.php`
- POST: `/mobile-api/upload_payment_proof.php`

---

### 5. TenantService
**File:** `lib/services/tenant_service.dart`
**Screens Affected:** 1
- `owner_tenants_screen.dart`

**Methods:**
```dart
class TenantService {
  // GET operations
  Future<Map<String, dynamic>> getOwnerTenants(String ownerEmail, String status)
  Future<Map<String, dynamic>> getTenantDetails(String tenantId)
  
  // POST operations (future)
  Future<Map<String, dynamic>> addTenant(Map<String, dynamic> tenantData)
  Future<Map<String, dynamic>> removeTenant(String tenantId)
}
```

**API Endpoints:**
- GET: `/modules/mobile-api/owner_tenants_api.php`

---

### 6. DashboardService
**File:** `lib/services/dashboard_service.dart`
**Screens Affected:** 2
- `student_home_screen.dart`
- `owner_dashboard_screen.dart`

**Methods:**
```dart
class DashboardService {
  // GET operations
  Future<Map<String, dynamic>> getStudentDashboard(String studentEmail)
  Future<Map<String, dynamic>> getOwnerDashboard(String ownerEmail)
  Future<Map<String, dynamic>> getDashboardStats(String userEmail, String userType)
}
```

**API Endpoints:**
- GET: `/mobile-api/student_dashboard_api.php`
- GET: `/modules/mobile-api/owner_dashboard_api.php`

---

## 🏗️ Service Architecture Pattern

### Standard Service Structure

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_constants.dart';

class [Feature]Service {
  // Base configuration
  static const String _baseUrl = ApiConstants.baseUrl;
  
  // HTTP client configuration
  static final http.Client _client = http.Client();
  
  // Certificate bypass for development
  static HttpClient _getHttpClient() {
    final client = HttpClient()
      ..badCertificateCallback = (cert, host, port) => true;
    return client;
  }
  
  // GET method template
  Future<Map<String, dynamic>> get[Resource]([params]) async {
    try {
      final uri = Uri.parse('$_baseUrl/endpoint?param=$param');
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Success'
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to load data',
          'message': 'Status: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Exception occurred',
        'message': e.toString()
      };
    }
  }
  
  // POST method template
  Future<Map<String, dynamic>> create[Resource](Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('$_baseUrl/endpoint');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'data': responseData,
          'message': 'Created successfully'
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to create',
          'message': 'Status: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Exception occurred',
        'message': e.toString()
      };
    }
  }
}
```

### Response Format Standard

All services return consistent response format:

```dart
// Success response
{
  'success': true,
  'data': <dynamic>,  // The actual data
  'message': 'Success message'
}

// Error response
{
  'success': false,
  'error': 'Error type',
  'message': 'Error description'
}
```

---

## 📝 Implementation Plan

### Step-by-Step Process

#### **Priority 1: DormService (HIGH)**

1. **Create DormService**
   - [ ] Create `lib/services/dorm_service.dart`
   - [ ] Implement `getOwnerDorms()`
   - [ ] Implement `getAllDorms()`
   - [ ] Implement `getDormDetails()`
   - [ ] Implement `addDorm()`
   - [ ] Implement `deleteDorm()`

2. **Update Screens**
   - [ ] Update `owner_dorms_screen.dart` to use DormService
   - [ ] Update `browse_dorms_screen.dart` to use DormService
   - [ ] Update `view_details_screen.dart` to use DormService
   - [ ] Test all dorm operations

3. **Verify**
   - [ ] Run `flutter analyze`
   - [ ] Test GET operations
   - [ ] Test POST operations

---

#### **Priority 2: RoomService (HIGH)**

1. **Create RoomService**
   - [ ] Create `lib/services/room_service.dart`
   - [ ] Implement `getRoomsByDorm()`
   - [ ] Implement `addRoom()`
   - [ ] Implement `updateRoom()`
   - [ ] Implement `deleteRoom()`

2. **Update Screens**
   - [ ] Update `room_management_screen.dart` to use RoomService
   - [ ] Test all room operations

3. **Verify**
   - [ ] Run `flutter analyze`
   - [ ] Test all CRUD operations

---

#### **Priority 3: BookingService (HIGH)**

1. **Create BookingService**
   - [ ] Create `lib/services/booking_service.dart`
   - [ ] Implement `getStudentBookings()`
   - [ ] Implement `getOwnerBookings()`
   - [ ] Implement `createBooking()`
   - [ ] Implement `updateBookingStatus()`

2. **Update Screens**
   - [ ] Update `student_home_screen.dart` to use BookingService
   - [ ] Update `booking_form_screen.dart` to use BookingService
   - [ ] Update `owner_booking_screen.dart` to use BookingService
   - [ ] Test all booking operations

3. **Verify**
   - [ ] Run `flutter analyze`
   - [ ] Test booking creation
   - [ ] Test booking status updates

---

#### **Priority 4: PaymentService (MEDIUM)**

1. **Create PaymentService**
   - [ ] Create `lib/services/payment_service.dart`
   - [ ] Implement `getStudentPayments()`
   - [ ] Implement `getOwnerPayments()`
   - [ ] Implement `uploadPaymentProof()`

2. **Update Screens**
   - [ ] Update `student_payments_screen.dart` to use PaymentService
   - [ ] Update `owner_payments_screen.dart` to use PaymentService
   - [ ] Test payment operations

3. **Verify**
   - [ ] Run `flutter analyze`
   - [ ] Test payment retrieval
   - [ ] Test payment proof upload

---

#### **Priority 5: TenantService (MEDIUM)**

1. **Create TenantService**
   - [ ] Create `lib/services/tenant_service.dart`
   - [ ] Implement `getOwnerTenants()`

2. **Update Screens**
   - [ ] Update `owner_tenants_screen.dart` to use TenantService
   - [ ] Test tenant retrieval

3. **Verify**
   - [ ] Run `flutter analyze`
   - [ ] Test tenant operations

---

#### **Priority 6: DashboardService (LOW)**

1. **Create DashboardService**
   - [ ] Create `lib/services/dashboard_service.dart`
   - [ ] Implement `getStudentDashboard()`
   - [ ] Implement `getOwnerDashboard()`

2. **Update Screens**
   - [ ] Update `student_home_screen.dart` dashboard section
   - [ ] Update `owner_dashboard_screen.dart`
   - [ ] Test dashboard data loading

3. **Verify**
   - [ ] Run `flutter analyze`
   - [ ] Test dashboard functionality

---

## 📈 Success Metrics

### Code Quality
- [ ] Zero compilation errors
- [ ] Zero lint warnings
- [ ] All services follow consistent pattern

### Architecture
- [ ] All HTTP calls extracted to services
- [ ] Screens use dependency injection pattern
- [ ] Response format is consistent

### Functionality
- [ ] All features work as before
- [ ] Error handling is improved
- [ ] Loading states are maintained

---

## 📊 Phase 6 Statistics (Target)

| Metric | Before | After | Change |
|--------|--------|-------|--------|
| **Service Files** | 2 | 8 | +6 |
| **Direct HTTP Calls in Screens** | 88+ | 0 | -100% |
| **Total Service Methods** | 7 | 35+ | +28 |
| **Screens with Services** | 4 | 15 | +11 |
| **Code in Services** | ~300 lines | ~1,200 lines | +900 lines |

---

## 🎯 Expected Outcomes

### Architecture Benefits
✅ **Complete separation of concerns** - UI and API logic fully separated
✅ **Testable code** - Services can be easily unit tested
✅ **Mockable dependencies** - Easy to mock for widget tests
✅ **Consistent error handling** - Centralized error management
✅ **Reusable API calls** - Services can be used anywhere

### Development Benefits
✅ **Easier maintenance** - API changes only affect service files
✅ **Better debugging** - API issues isolated to service layer
✅ **Faster development** - Reuse existing service methods
✅ **Cleaner screens** - Screens focus only on UI logic
✅ **Prepared for caching** - Service layer ready for caching implementation

---

## 🚀 Next Steps After Phase 6

### Phase 7: State Management (Optional)
- Introduce Provider/Riverpod
- Centralize app state
- Implement reactive updates

### Phase 8: Caching Layer (Optional)
- Add local storage (Hive/SQLite)
- Implement offline support
- Cache API responses

### Phase 9: Testing (Optional)
- Unit tests for all services
- Widget tests for screens
- Integration tests for flows

---

## 📝 Notes

- Follow the existing pattern from AuthService and ChatService
- Keep response format consistent across all services
- Test each service immediately after creation
- Update screens one at a time to minimize errors
- Run `flutter analyze` after each major change
- Document any API quirks or special handling needed

**Phase 6 Status:** 🔄 **READY TO START**

---

*Created: October 16, 2025*
*Phase 6: Service Layer Expansion - Building a complete API service architecture*
