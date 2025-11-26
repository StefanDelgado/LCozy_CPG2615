# Mobile Checkout Implementation

This directory contains the Flutter implementation for the checkout functionality in the CozyDorms mobile app.

## 📁 File Structure

```
lib/
├── services/
│   └── checkout_service.dart          # API service layer
├── screens/
│   ├── student/
│   │   └── student_checkout_screen.dart    # Student: Request checkout
│   └── owner/
│       ├── owner_checkout_requests_screen.dart  # Owner: Manage requests
│       └── owner_past_tenants_screen.dart       # Owner: View history
```

## 🎯 Features

### Student Features
- ✅ View all active/approved bookings
- ✅ Request checkout with optional reason
- ✅ See checkout request status (pending/approved)
- ✅ Pull-to-refresh for real-time updates
- ✅ Status badges for bookings

### Owner Features
- ✅ View checkout requests in 4 tabs (Pending, Approved, Completed, Disapproved)
- ✅ Approve/disapprove pending requests
- ✅ Mark approved requests as complete
- ✅ View past tenants with payment history
- ✅ Search past tenants by name, dorm, or room
- ✅ Statistics summary
- ✅ Badge counts on tabs

## 📱 Screens

### 1. StudentCheckoutScreen
**Path:** `lib/screens/student/student_checkout_screen.dart`

**Usage:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => StudentCheckoutScreen(
      studentId: currentUserId,
    ),
  ),
);
```

**Features:**
- Lists all active and approved bookings
- Shows booking details (dorm, room, dates, price)
- Displays checkout status badges
- Request checkout dialog with optional reason field
- Real-time status updates
- Pull-to-refresh

**UI Elements:**
- Booking cards with status badges
- "Request Checkout" button (only for eligible bookings)
- Loading states
- Error handling with retry
- Empty state

---

### 2. OwnerCheckoutRequestsScreen
**Path:** `lib/screens/owner/owner_checkout_requests_screen.dart`

**Usage:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => OwnerCheckoutRequestsScreen(
      ownerId: currentUserId,
    ),
  ),
);
```

**Features:**
- 4 tabs with badge counts: Pending, Approved, Completed, Disapproved
- Approve/Disapprove buttons for pending requests
- Mark Complete button for approved requests
- Shows tenant name, dorm, room, dates
- Displays checkout reason if provided
- Confirmation dialogs for all actions
- Automatic notifications to tenants

**UI Elements:**
- TabBar with 4 tabs
- Request cards grouped by status
- Action buttons (Approve/Disapprove/Complete)
- Status badges
- Loading and error states

---

### 3. OwnerPastTenantsScreen
**Path:** `lib/screens/owner/owner_past_tenants_screen.dart`

**Usage:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => OwnerPastTenantsScreen(
      ownerId: currentUserId,
    ),
  ),
);
```

**Features:**
- Search by tenant name, dorm, or room
- View check-in/checkout dates
- See stay duration in days
- Payment status (complete/pending)
- Total paid and outstanding balance
- Statistics summary (total tenants, filtered results)
- Historical records

**UI Elements:**
- Search bar with clear button
- Summary statistics card
- Tenant cards with avatar
- Payment status badges
- Duration calculator
- Financial information display

---

## 🔌 Service Layer

### CheckoutService
**Path:** `lib/services/checkout_service.dart`

**Methods:**

#### 1. requestCheckout
```dart
static Future<Map<String, dynamic>> requestCheckout({
  required int studentId,
  required int bookingId,
  String? reason,
})
```
Submit a checkout request for a booking.

#### 2. getStudentBookings
```dart
static Future<Map<String, dynamic>> getStudentBookings({
  required int studentId,
})
```
Get all active/approved bookings for checkout.

#### 3. getOwnerRequests
```dart
static Future<Map<String, dynamic>> getOwnerRequests({
  required int ownerId,
})
```
Get all checkout requests for owner's properties.

#### 4. approveCheckout
```dart
static Future<Map<String, dynamic>> approveCheckout({
  required int requestId,
  required int ownerId,
})
```
Approve a pending checkout request.

#### 5. disapproveCheckout
```dart
static Future<Map<String, dynamic>> disapproveCheckout({
  required int requestId,
  required int ownerId,
})
```
Disapprove/reject a pending checkout request.

#### 6. completeCheckout
```dart
static Future<Map<String, dynamic>> completeCheckout({
  required int requestId,
  required int ownerId,
})
```
Mark an approved checkout as completed.

#### 7. getPastTenants
```dart
static Future<Map<String, dynamic>> getPastTenants({
  required int ownerId,
})
```
Get historical data of completed checkouts.

---

## 🎨 UI/UX Features

### Status Badges
- **Active/Approved** - Green badge
- **Pending** - Orange badge
- **Checkout Approved** - Blue badge
- **Completed** - Green badge
- **Disapproved** - Red badge

### Loading States
- Circular progress indicator during API calls
- Skeleton loading for better UX
- Pull-to-refresh on all list screens

### Error Handling
- User-friendly error messages
- Retry buttons
- Network error detection
- Validation error display

### Confirmation Dialogs
- Approve action - Green button
- Disapprove action - Red button
- Complete action - Blue button
- All actions require confirmation

### Empty States
- "No active bookings" for students
- "No requests" for owners per tab
- "No past tenants yet" for history
- "No results found" for search

---

## 🔗 Integration Guide

### 1. Add to Student Dashboard
```dart
// In student_dashboard.dart
ListTile(
  leading: const Icon(Icons.logout),
  title: const Text('Request Checkout'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentCheckoutScreen(
          studentId: currentUserId,
        ),
      ),
    );
  },
),
```

### 2. Add to Owner Dashboard
```dart
// In owner_dashboard.dart
Card(
  child: ListTile(
    leading: const Icon(Icons.exit_to_app),
    title: const Text('Checkout Requests'),
    trailing: Badge(
      label: Text('$pendingCount'),
      child: const Icon(Icons.arrow_forward),
    ),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OwnerCheckoutRequestsScreen(
            ownerId: currentUserId,
          ),
        ),
      );
    },
  ),
),

Card(
  child: ListTile(
    leading: const Icon(Icons.history),
    title: const Text('Past Tenants'),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OwnerPastTenantsScreen(
            ownerId: currentUserId,
          ),
        ),
      );
    },
  ),
),
```

---

## 📦 Dependencies

Add these to `pubspec.yaml`:
```yaml
dependencies:
  http: ^1.1.0
  intl: ^0.18.0  # For date formatting
```

---

## 🔐 Security Notes

- All API calls use POST for mutations (approve/disapprove/complete)
- User IDs are validated server-side
- Authorization checks prevent unauthorized actions
- HTTPS should be enabled in production

---

## 🧪 Testing Checklist

### Student Flow:
- [ ] View active bookings
- [ ] Submit checkout request
- [ ] See request status update
- [ ] Handle errors gracefully
- [ ] Pull-to-refresh works

### Owner Flow:
- [ ] View pending requests
- [ ] Approve request
- [ ] Disapprove request
- [ ] Complete approved request
- [ ] Switch between tabs
- [ ] View past tenants
- [ ] Search past tenants

### Edge Cases:
- [ ] No bookings available
- [ ] Already requested checkout
- [ ] Invalid booking status
- [ ] Network errors
- [ ] Empty search results

---

## 🎯 Workflow Diagram

```
STUDENT                          OWNER
   │                               │
   ├─ View Bookings                │
   ├─ Request Checkout ────────────┼─► Receive Notification
   │                               │
   │                               ├─ View Request (Pending Tab)
   │                               ├─ Approve ───────────────┐
   │                               │                          │
   ├─◄ Notification (Approved) ────┤                          │
   │                               │                          │
   │                               ├─ Mark Complete          │
   │                               │                          │
   ├─◄ Notification (Completed) ───┤                          │
   │                               │                          │
   │                               └─ Tenant → Past Tenants  │
```

---

## 📝 Change Log

**v1.0.0** - 2025-11-26
- Initial implementation
- All 3 screens created
- Service layer with 7 API methods
- Full checkout workflow support
- Search and filter functionality
- Badge counts and statistics

---

## 🚀 Future Enhancements

- [ ] Push notifications for checkout updates
- [ ] Export past tenants to CSV/PDF
- [ ] Payment reminders for outstanding balances
- [ ] Rating system for past tenants
- [ ] Advanced filtering (date range, payment status)
- [ ] Offline mode with local caching
- [ ] Real-time updates via WebSocket

---

## 💡 Tips

1. **Testing:** Use Postman to test API endpoints before mobile integration
2. **Debugging:** Enable API logging in ApiConfig for troubleshooting
3. **Performance:** Consider pagination for large past tenant lists
4. **UX:** Show loading indicators during all API calls
5. **Notifications:** Integrate with FCM for real-time alerts
