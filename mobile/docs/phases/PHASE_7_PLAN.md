# Phase 7 Plan: State Management + Maps Implementation

## Overview
**Phase**: 7  
**Status**: PLANNING  
**Priority**: HIGH  
**Objective**: Implement state management (Provider/Riverpod) and integrate Google Maps for dorm location features

## Current State Analysis

### Existing Architecture
- ✅ 15 screens refactored with clean UI
- ✅ 8 services with complete API abstraction
- ✅ 45+ reusable widgets
- ❌ State scattered across StatefulWidgets
- ❌ No centralized state management
- ❌ No map integration for dorm locations

### Pain Points Identified
1. **State Duplication**: Multiple screens fetch same data independently
2. **Unnecessary Rebuilds**: setState rebuilds entire widget tree
3. **Complex State Passing**: Deep widget trees pass data through constructors
4. **No State Persistence**: State lost on navigation
5. **Missing Maps**: No visual dorm location features

## Phase 7 Objectives

### Part A: State Management (Provider)
Implement Provider for centralized state management across the app.

**Benefits:**
- Centralized state across screens
- Reduced unnecessary rebuilds
- Better performance
- Easier testing
- Cleaner code

### Part B: Maps Integration (Google Maps)
Add Google Maps for dorm location features.

**Features:**
- View dorm locations on map
- Interactive map browsing
- Distance calculations
- Location-based dorm search
- Directions to dorms

## Part A: State Management Implementation

### 1. Dependencies to Add

```yaml
dependencies:
  # State Management
  provider: ^6.1.1
  
  # Optional: For complex state
  # flutter_riverpod: ^2.4.9
  # state_notifier: ^1.0.0
```

### 2. State Providers to Create

#### Priority 1: Authentication State (HIGH)
**File**: `lib/providers/auth_provider.dart`

**State:**
- `isAuthenticated: bool`
- `userEmail: String?`
- `userRole: UserRole?` (student/owner/admin)
- `isLoading: bool`

**Methods:**
- `login(email, password, role)`
- `register(userData)`
- `logout()`
- `checkAuthStatus()`

**Screens to Update:**
- `login_screen.dart`
- `register_screen.dart`
- `main.dart` (navigation)

---

#### Priority 1: Dorm State (HIGH)
**File**: `lib/providers/dorm_provider.dart`

**State:**
- `List<Dorm> allDorms`
- `List<Dorm> ownerDorms`
- `Dorm? selectedDorm`
- `bool isLoading`
- `String? error`

**Methods:**
- `fetchAllDorms()`
- `fetchOwnerDorms(ownerEmail)`
- `selectDorm(dormId)`
- `addDorm(dormData)`
- `updateDorm(dormId, data)`
- `deleteDorm(dormId)`
- `clearError()`

**Screens to Update:**
- `browse_dorms_screen.dart`
- `owner_dorms_screen.dart`
- `view_details_screen.dart`

---

#### Priority 1: Booking State (HIGH)
**File**: `lib/providers/booking_provider.dart`

**State:**
- `List<Booking> studentBookings`
- `List<Booking> ownerBookings`
- `BookingStats? stats`
- `bool isLoading`

**Methods:**
- `fetchStudentBookings(studentEmail)`
- `fetchOwnerBookings(ownerEmail)`
- `createBooking(bookingData)`
- `updateBookingStatus(bookingId, action)`
- `refreshBookings()`

**Screens to Update:**
- `student_home_screen.dart`
- `booking_form_screen.dart`
- `owner_booking_screen.dart`

---

#### Priority 2: Payment State (MEDIUM)
**File**: `lib/providers/payment_provider.dart`

**State:**
- `List<Payment> studentPayments`
- `List<Payment> ownerPayments`
- `PaymentStats? stats`
- `bool isLoading`

**Methods:**
- `fetchStudentPayments(studentEmail)`
- `fetchOwnerPayments(ownerEmail)`
- `uploadPaymentProof(paymentData)`
- `refreshPayments()`

**Screens to Update:**
- `student_payments_screen.dart`
- `owner_payments_screen.dart`

---

#### Priority 2: Room State (MEDIUM)
**File**: `lib/providers/room_provider.dart`

**State:**
- `List<Room> rooms`
- `Dorm? selectedDorm`
- `bool isLoading`

**Methods:**
- `fetchRoomsByDorm(dormId)`
- `addRoom(roomData)`
- `updateRoom(roomId, data)`
- `deleteRoom(roomId)`

**Screens to Update:**
- `room_management_screen.dart`
- `view_details_screen.dart` (rooms tab)

---

#### Priority 3: Chat State (LOW)
**File**: `lib/providers/chat_provider.dart`

**State:**
- `List<Conversation> conversations`
- `List<Message> currentMessages`
- `bool isLoading`
- `int unreadCount`

**Methods:**
- `fetchConversations(userEmail)`
- `fetchMessages(conversationId)`
- `sendMessage(message)`
- `markAsRead(conversationId)`

**Screens to Update:**
- `chat_list_screen.dart`
- `chat_conversation_screen.dart`

---

### 3. Provider Architecture Pattern

```dart
// Base Provider Structure
import 'package:flutter/foundation.dart';
import '../services/[feature]_service.dart';

class [Feature]Provider with ChangeNotifier {
  final [Feature]Service _service = [Feature]Service();
  
  // State
  List<Model> _items = [];
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<Model> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Methods
  Future<void> fetchData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final result = await _service.getData();
      if (result['success']) {
        _items = result['data'];
      } else {
        _error = result['error'];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

### 4. Screen Integration Pattern

```dart
// Using Provider in Screen
import 'package:provider/provider.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Option 1: Watch for changes
    final provider = context.watch<MyProvider>();
    
    // Option 2: Read once (no rebuilds)
    // final provider = context.read<MyProvider>();
    
    // Option 3: Select specific data
    // final isLoading = context.select((MyProvider p) => p.isLoading);
    
    if (provider.isLoading) {
      return LoadingWidget();
    }
    
    if (provider.error != null) {
      return ErrorWidget(error: provider.error);
    }
    
    return ListView.builder(
      itemCount: provider.items.length,
      itemBuilder: (context, index) {
        return ItemWidget(item: provider.items[index]);
      },
    );
  }
}
```

### 5. Main.dart Setup

```dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DormProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => RoomProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MyApp(),
    ),
  );
}
```

---

## Part B: Maps Implementation

### 1. Dependencies to Add

```yaml
dependencies:
  # Google Maps
  google_maps_flutter: ^2.5.0
  
  # Location Services
  geolocator: ^10.1.0
  geocoding: ^2.1.1
  
  # Permissions
  permission_handler: ^11.0.1
  
  # Optional: Map utilities
  flutter_polyline_points: ^2.0.0
  url_launcher: ^6.2.1  # For directions
```

### 2. Platform Configuration

#### Android Setup
**File**: `android/app/src/main/AndroidManifest.xml`

```xml
<manifest>
  <application>
    <!-- Add before </application> -->
    <meta-data
      android:name="com.google.android.geo.API_KEY"
      android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
  </application>
  
  <!-- Add before </manifest> -->
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
  <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
  <uses-permission android:name="android.permission.INTERNET"/>
</manifest>
```

**File**: `android/app/build.gradle`

```gradle
android {
    defaultConfig {
        minSdkVersion 21  // Required for Google Maps
    }
}
```

#### iOS Setup
**File**: `ios/Runner/AppDelegate.swift`

```swift
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

**File**: `ios/Runner/Info.plist`

```xml
<dict>
  <key>NSLocationWhenInUseUsageDescription</key>
  <string>This app needs access to location for showing dorms near you.</string>
  <key>NSLocationAlwaysUsageDescription</key>
  <string>This app needs access to location for showing dorms near you.</string>
</dict>
```

### 3. Map Features to Implement

#### Feature 1: Browse Dorms on Map (HIGH PRIORITY)
**New Screen**: `lib/screens/student/browse_dorms_map_screen.dart`

**Features:**
- Display all dorms as markers on map
- Custom marker icons (orange house icon)
- Info window with dorm name and price
- Tap marker to view dorm details
- Current location button
- Search within map bounds

**Integration Points:**
- Add "Map View" button to `browse_dorms_screen.dart`
- Use `DormProvider` for dorm data
- Navigate to `view_details_screen.dart` on marker tap

---

#### Feature 2: Dorm Location in Details (HIGH PRIORITY)
**Update Screen**: `lib/screens/student/view_details_screen.dart`

**Features:**
- Add "Location" tab to existing tabs
- Static map showing dorm location
- Distance from user's current location
- "Get Directions" button
- Nearby amenities (future)

**Widget to Create:**
- `lib/widgets/student/view_details/location_tab.dart`

---

#### Feature 3: Owner Dorm Location Picker (MEDIUM PRIORITY)
**Update Screen**: `lib/screens/owner/owner_dorms_screen.dart`

**Features:**
- Map picker when adding/editing dorm
- Drag marker to set location
- Search for address
- Reverse geocoding (get address from coordinates)
- Display selected coordinates

**Widget to Create:**
- `lib/widgets/common/location_picker_widget.dart`

---

#### Feature 4: Radius-Based Search (MEDIUM PRIORITY)
**Update Screen**: `lib/screens/student/browse_dorms_screen.dart`

**Features:**
- "Near Me" filter option
- Slider to select radius (1km - 10km)
- Filter dorms within radius
- Show distance for each dorm
- Sort by distance

---

### 4. Map Widgets to Create

#### MapWidget (Reusable)
**File**: `lib/widgets/common/map_widget.dart`

```dart
class MapWidget extends StatefulWidget {
  final LatLng initialPosition;
  final Set<Marker> markers;
  final bool showCurrentLocation;
  final Function(LatLng)? onMapTap;
  final Function(Marker)? onMarkerTap;
  
  const MapWidget({
    required this.initialPosition,
    this.markers = const {},
    this.showCurrentLocation = true,
    this.onMapTap,
    this.onMarkerTap,
  });
}
```

#### LocationPickerWidget
**File**: `lib/widgets/common/location_picker_widget.dart`

```dart
class LocationPickerWidget extends StatefulWidget {
  final LatLng? initialLocation;
  final Function(LatLng, String) onLocationSelected;
  
  const LocationPickerWidget({
    this.initialLocation,
    required this.onLocationSelected,
  });
}
```

#### DormMarkerInfoWindow
**File**: `lib/widgets/student/map/dorm_marker_info_window.dart`

```dart
class DormMarkerInfoWindow extends StatelessWidget {
  final Dorm dorm;
  final VoidCallback onTap;
  
  const DormMarkerInfoWindow({
    required this.dorm,
    required this.onTap,
  });
}
```

### 5. Location Service
**File**: `lib/services/location_service.dart`

```dart
class LocationService {
  // Get current location
  Future<Position> getCurrentLocation();
  
  // Check location permissions
  Future<bool> checkPermissions();
  
  // Request location permissions
  Future<bool> requestPermissions();
  
  // Calculate distance between two points
  double calculateDistance(LatLng point1, LatLng point2);
  
  // Get address from coordinates (reverse geocoding)
  Future<String> getAddressFromCoordinates(LatLng position);
  
  // Get coordinates from address (geocoding)
  Future<LatLng?> getCoordinatesFromAddress(String address);
}
```

### 6. Map Helper Utilities
**File**: `lib/utils/map_helpers.dart`

```dart
class MapHelpers {
  // Create custom marker icon
  static Future<BitmapDescriptor> createCustomMarker();
  
  // Format distance (e.g., "1.5 km" or "500 m")
  static String formatDistance(double distanceInMeters);
  
  // Calculate map bounds for multiple markers
  static LatLngBounds calculateBounds(List<LatLng> positions);
  
  // Open Google Maps for directions
  static Future<void> openGoogleMapsDirections(LatLng destination);
}
```

### 7. Database Schema Updates

Update backend API to support location data:

```sql
-- Add to dorms table (if not exists)
ALTER TABLE dorms ADD COLUMN latitude DECIMAL(10, 8);
ALTER TABLE dorms ADD COLUMN longitude DECIMAL(11, 8);
ALTER TABLE dorms ADD COLUMN address TEXT;
ALTER TABLE dorms ADD COLUMN formatted_address TEXT;
```

### 8. API Updates Required

#### Update DormService
Add location parameters to `addDorm()` and `updateDorm()`:

```dart
// In dorm_service.dart
Future<Map<String, dynamic>> addDorm(Map<String, dynamic> dormData) async {
  // dormData should now include:
  // - 'latitude': double
  // - 'longitude': double
  // - 'address': string
}
```

#### Update Backend Endpoints
- `dorm_api.php` - Accept latitude/longitude in POST/PUT requests
- Add validation for coordinate ranges (lat: -90 to 90, lng: -180 to 180)

---

## Implementation Order

### Stage 1: Setup & Configuration (Day 1)
1. ✅ Add dependencies to `pubspec.yaml`
2. ✅ Configure Android manifest
3. ✅ Configure iOS setup
4. ✅ Get Google Maps API key
5. ✅ Create location_service.dart
6. ✅ Create map_helpers.dart

### Stage 2: State Management - Priority 1 (Day 2-3)
1. ✅ Create AuthProvider
2. ✅ Create DormProvider
3. ✅ Create BookingProvider
4. ✅ Update main.dart with MultiProvider
5. ✅ Update login_screen.dart
6. ✅ Update register_screen.dart
7. ✅ Update browse_dorms_screen.dart
8. ✅ Update owner_dorms_screen.dart
9. ✅ Update student_home_screen.dart

### Stage 3: Maps - Browse Dorms Map (Day 4)
1. ✅ Create map_widget.dart
2. ✅ Create browse_dorms_map_screen.dart
3. ✅ Create dorm_marker_info_window.dart
4. ✅ Add "Map View" button to browse_dorms_screen.dart
5. ✅ Test map functionality

### Stage 4: Maps - Dorm Details Location (Day 5)
1. ✅ Create location_tab.dart
2. ✅ Update view_details_screen.dart
3. ✅ Add "Get Directions" functionality
4. ✅ Add distance calculation

### Stage 5: Maps - Owner Location Picker (Day 6)
1. ✅ Create location_picker_widget.dart
2. ✅ Update owner_dorms_screen.dart (add dorm form)
3. ✅ Update backend API to accept coordinates
4. ✅ Test location selection

### Stage 6: State Management - Priority 2 (Day 7)
1. ✅ Create PaymentProvider
2. ✅ Create RoomProvider
3. ✅ Update payment screens
4. ✅ Update room_management_screen.dart

### Stage 7: Maps - Radius Search (Day 8)
1. ✅ Add "Near Me" filter to browse_dorms_screen.dart
2. ✅ Implement radius slider
3. ✅ Add distance display to dorm cards
4. ✅ Test filtering

### Stage 8: State Management - Priority 3 (Day 9)
1. ✅ Create ChatProvider (optional)
2. ✅ Update chat screens (optional)

### Stage 9: Testing & Polish (Day 10)
1. ✅ Comprehensive testing on Android
2. ✅ Comprehensive testing on iOS
3. ✅ Performance optimization
4. ✅ Handle edge cases (no location permission, no internet)
5. ✅ Create PHASE_7_COMPLETE.md

---

## File Structure After Phase 7

```
lib/
├── providers/                    # NEW: State management
│   ├── auth_provider.dart
│   ├── dorm_provider.dart
│   ├── booking_provider.dart
│   ├── payment_provider.dart
│   ├── room_provider.dart
│   └── chat_provider.dart
│
├── services/
│   ├── location_service.dart     # NEW: Location utilities
│   ├── auth_service.dart
│   ├── chat_service.dart
│   ├── dorm_service.dart
│   ├── room_service.dart
│   ├── booking_service.dart
│   ├── payment_service.dart
│   ├── tenant_service.dart
│   └── dashboard_service.dart
│
├── screens/
│   ├── student/
│   │   ├── browse_dorms_map_screen.dart  # NEW: Map view
│   │   └── ... (existing screens)
│   └── ... (existing screens)
│
├── widgets/
│   ├── common/
│   │   ├── map_widget.dart               # NEW: Reusable map
│   │   └── location_picker_widget.dart   # NEW: Location picker
│   ├── student/
│   │   ├── map/
│   │   │   └── dorm_marker_info_window.dart  # NEW
│   │   └── view_details/
│   │       └── location_tab.dart         # NEW: Location tab
│   └── ... (existing widgets)
│
└── utils/
    ├── map_helpers.dart          # NEW: Map utilities
    └── ... (existing utils)
```

---

## Expected Benefits

### State Management Benefits
1. **Performance**: 50-70% reduction in unnecessary rebuilds
2. **Code Quality**: 30-40% less boilerplate code
3. **Maintainability**: Single source of truth for state
4. **Scalability**: Easy to add new features
5. **Testing**: Isolated state logic for unit tests

### Maps Benefits
1. **User Experience**: Visual dorm browsing
2. **Location Discovery**: Find dorms near user
3. **Navigation**: Easy directions to dorms
4. **Owner Convenience**: Easy location selection
5. **Competitive Feature**: Matches major rental platforms

---

## Risk Assessment

### State Management Risks
- **Migration Complexity**: MEDIUM - Gradual migration possible
- **Learning Curve**: LOW - Provider is simple to learn
- **Breaking Changes**: LOW - Isolated changes per screen

### Maps Risks
- **API Costs**: MEDIUM - Google Maps pricing (monitor usage)
- **Platform Issues**: MEDIUM - Different setup for Android/iOS
- **Performance**: LOW - Maps can be heavy on older devices
- **Data Requirements**: HIGH - Need location data in database

### Mitigation Strategies
1. Implement in stages (state first, maps second)
2. Use Google Maps free tier (28,000 loads/month)
3. Cache map tiles where possible
4. Fallback to list view if map fails
5. Add location data migration script

---

## Success Criteria

### State Management
- ✅ All screens using providers
- ✅ Zero direct service calls from screens
- ✅ Performance improvement measurable
- ✅ Zero compilation errors
- ✅ All tests passing

### Maps
- ✅ Browse dorms on map functional
- ✅ Location picker working for owners
- ✅ Distance calculations accurate
- ✅ Directions integration working
- ✅ Handles permission denials gracefully

---

## Testing Checklist

### State Management
- [ ] AuthProvider login/logout flow
- [ ] DormProvider CRUD operations
- [ ] BookingProvider create/update
- [ ] PaymentProvider data fetching
- [ ] Provider state persistence
- [ ] Multiple provider interactions

### Maps
- [ ] Map loads correctly on Android
- [ ] Map loads correctly on iOS
- [ ] Markers display correctly
- [ ] Info windows show data
- [ ] Location permissions work
- [ ] Current location button works
- [ ] Directions open Google Maps
- [ ] Distance calculations correct
- [ ] Radius search filters properly
- [ ] Location picker saves coordinates

---

## Documentation to Create
1. **PHASE_7_COMPLETE.md** - Completion documentation
2. **MAPS_SETUP_GUIDE.md** - Google Maps configuration guide
3. **PROVIDER_PATTERNS.md** - State management patterns guide
4. Update **PROJECT_STRUCTURE.md** - Add providers and maps
5. Update **README.md** - Phase 7 completion

---

**Phase 7 Estimated Completion**: 10 days  
**Complexity**: HIGH  
**Priority**: HIGH  
**Dependencies**: Phase 6 complete ✅

---

*Phase 7 planning complete. Ready to begin implementation.*
