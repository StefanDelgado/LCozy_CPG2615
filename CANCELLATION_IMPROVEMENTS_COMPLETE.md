# Cancellation Booking Improvements - Complete ✅

## Overview
Fixed three critical issues with the cancelled bookings management system for dorm owners.

## Problems Fixed

### 1. ❌ **Acknowledge Button Still Visible After Confirmation**
**Issue:** After owner acknowledges a cancellation, the button remained visible instead of showing the "Acknowledged" status badge.

**Root Cause:** The onAcknowledge callback was always provided for cancelled bookings, even if already acknowledged.

**Solution:** Updated the condition to only show the acknowledge button if the booking is NOT yet acknowledged:
```dart
onAcknowledge: status == 'cancelled' && booking['cancellation_acknowledged'] != 1 
    ? () => _acknowledgeCancellation(booking) 
    : null,
```

### 2. ❌ **No Cancellation Reason Displayed**
**Issue:** When students cancelled bookings with a reason, owners couldn't see why it was cancelled.

**Root Cause:** Cancellation reason was stored in the `notes` field but not extracted or displayed separately.

**Solutions:**
- **Backend (API):** Extract cancellation reason from notes using regex pattern matching
- **Frontend (UI):** Display extracted reason in a visually distinct card

### 3. ❌ **No Communication Method**
**Issue:** Owners had no easy way to message students about cancelled bookings.

**Root Cause:** No messaging integration in the cancelled bookings view.

**Solution:** Added "Message Student" button that opens the chat conversation screen.

---

## Changes Made

### 1. Backend API Updates
**File:** `Main/modules/mobile-api/owner/owner_bookings_api.php`

#### Added Fields to Query (Lines 203-224)
```php
SELECT 
    b.booking_id as id,
    u.email as student_email,
    u.name as student_name,
    b.created_at as requested_at,
    COALESCE(b.status, 'pending') as status,
    d.dorm_id,              // NEW: For messaging
    d.name as dorm,
    r.room_type,
    r.price as base_price,
    r.capacity,
    b.booking_type,
    b.start_date,
    b.end_date,
    b.notes as message,
    b.cancellation_acknowledged,
    b.cancellation_acknowledged_at,
    b.cancellation_acknowledged_by,
    b.student_id            // NEW: For messaging
FROM bookings b
```

#### Added Cancellation Reason Extraction (Lines 264-271)
```php
// Extract cancellation reason from notes (if cancelled)
$cancellation_reason = '';
if (strtolower($b['status']) === 'cancelled' && !empty($b['message'])) {
    // Look for "Reason: " in the notes
    if (preg_match('/Reason:\s*(.+?)(?:\n|$)/s', $b['message'], $matches)) {
        $cancellation_reason = trim($matches[1]);
    }
}
```

#### Added Fields to Response (Lines 273-296)
```php
return [
    'id' => $b['id'],
    'booking_id' => $b['id'],
    'student_id' => $b['student_id'],        // NEW
    'student_email' => $b['student_email'],
    'student_name' => $b['student_name'],
    'requested_at' => timeAgo($b['requested_at']),
    'status' => ucfirst(strtolower($b['status'])),
    'dorm_id' => $b['dorm_id'],              // NEW
    'dorm' => $b['dorm'],
    'dorm_name' => $b['dorm'],
    'room_type' => $b['room_type'],
    'booking_type' => ucfirst($booking_type),
    'duration' => $duration,
    'start_date' => $b['start_date'],
    'end_date' => $b['end_date'] ?? null,
    'base_price' => $base_price,
    'capacity' => $capacity,
    'price' => '₱' . number_format($calculated_price, 2),
    'message' => $b['message'] ?? 'No additional message',
    'cancellation_reason' => $cancellation_reason,  // NEW
    'cancellation_acknowledged' => $b['cancellation_acknowledged'] ?? 0,
    'cancellation_acknowledged_at' => $b['cancellation_acknowledged_at'] ?? null,
    'cancellation_acknowledged_by' => $b['cancellation_acknowledged_by'] ?? null
];
```

---

### 2. Mobile UI Updates
**File:** `mobile/lib/widgets/owner/bookings/booking_card.dart`

#### Added onMessage Callback (Lines 4-17)
```dart
class BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onAcknowledge;
  final VoidCallback? onMessage;        // NEW
  final bool isProcessing;

  const BookingCard({
    super.key,
    required this.booking,
    this.onApprove,
    this.onReject,
    this.onAcknowledge,
    this.onMessage,                     // NEW
    this.isProcessing = false,
  });
```

#### Added Cancellation Reason Display (Lines 260-296)
```dart
// Cancellation Reason (for cancelled bookings)
if (isCancelled && booking['cancellation_reason'] != null && 
    booking['cancellation_reason'].toString().isNotEmpty)
  Padding(
    padding: const EdgeInsets.only(top: 16),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFF87171)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Cancellation Reason:',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF991B1B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            booking['cancellation_reason'].toString(),
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF7F1D1D),
              height: 1.4,
            ),
          ),
        ],
      ),
    ),
  ),
```

#### Updated Cancelled Section with Message Button (Lines 419-525)
```dart
// Acknowledge Button or Status (for cancelled bookings)
if (isCancelled)
  Padding(
    padding: const EdgeInsets.only(top: 16),
    child: Column(
      children: [
        // Acknowledged status or Acknowledge button
        isAcknowledged
            ? Container(
                // ... Acknowledged badge display
              )
            : onAcknowledge != null
                ? Container(
                    // ... Acknowledge button
                  )
                : const SizedBox.shrink(),
        
        // Message button for cancelled bookings
        if (onMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9333EA), Color(0xFFA855F7)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9333EA).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: isProcessing ? null : onMessage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.message, size: 20),
                label: const Text(
                  'Message Student',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
      ],
    ),
  ),
```

---

### 3. Owner Booking Screen Updates
**File:** `mobile/lib/screens/owner/owner_booking_screen.dart`

#### Added Chat Screen Import (Line 8)
```dart
import '../shared/chat_conversation_screen.dart';
```

#### Fixed Acknowledge Button Condition (Lines 695-698)
```dart
return BookingCard(
  booking: booking,
  onApprove: status == 'pending' ? () => _approveBooking(booking) : null,
  onReject: status == 'pending' ? () => _rejectBooking(booking) : null,
  onAcknowledge: status == 'cancelled' && booking['cancellation_acknowledged'] != 1 
      ? () => _acknowledgeCancellation(booking) 
      : null,
  onMessage: status == 'cancelled' ? () => _messageStudent(booking) : null,
  isProcessing: _isProcessing,
);
```

#### Added Message Student Method (Lines 533-585)
```dart
/// Opens chat with the student who cancelled
Future<void> _messageStudent(Map<String, dynamic> booking) async {
  try {
    final studentEmail = booking['student_email']?.toString();
    final studentName = booking['student_name']?.toString() ?? 'Student';
    final studentId = booking['student_id'];
    final dormId = booking['dorm_id'];
    final dormName = booking['dorm_name']?.toString() ?? booking['dorm']?.toString() ?? 'Dorm';

    if (studentEmail == null || studentEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student email not available'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (studentId == null || dormId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open chat. Missing information.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    print('📨 [OwnerBooking] Opening chat with student: $studentName ($studentEmail) about $dormName');
    
    // Navigate to chat conversation screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatConversationScreen(
          currentUserEmail: widget.ownerEmail,
          currentUserRole: 'owner',
          otherUserId: int.parse(studentId.toString()),
          otherUserName: studentName,
          otherUserEmail: studentEmail,
          dormId: int.parse(dormId.toString()),
          dormName: dormName,
        ),
      ),
    );
  } catch (e) {
    print('❌ [OwnerBooking] Error opening chat: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening chat: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

---

## Visual Changes

### Before
- ✅ Acknowledged cancellations still showed "Acknowledge Cancellation" button
- ❌ No indication of why booking was cancelled
- ❌ No way to contact student about cancellation

### After
- ✅ Acknowledged cancellations show green "Cancellation Acknowledged" badge
- ✅ Acknowledge button only appears for unacknowledged cancellations
- ✅ Cancellation reason displayed in red-themed info card with reason icon
- ✅ Purple "Message Student" button for easy communication
- ✅ Button opens chat conversation about the specific dorm

---

## User Flow

### Cancelled Booking Card Display

#### Unacknowledged Cancellation
```
┌─────────────────────────────────────────┐
│  👤 Student Name                   🔴   │
│     📅 2h ago                   Cancelled│
├─────────────────────────────────────────┤
│  🏠 Dorm: Happy House                   │
│  🚪 Room: Standard Room                 │
│  👥 Type: Shared                        │
│  ⏰ Duration: 3 months                  │
│  💵 ₱1,500.00                           │
├─────────────────────────────────────────┤
│  ℹ️ Cancellation Reason:                │
│  Found a cheaper option closer to       │
│  school. Sorry for the inconvenience.   │
├─────────────────────────────────────────┤
│  [🔵 Acknowledge Cancellation]          │
│  [💜 Message Student]                   │
└─────────────────────────────────────────┘
```

#### After Acknowledgement
```
┌─────────────────────────────────────────┐
│  👤 Student Name                   🔴   │
│     📅 2h ago                   Cancelled│
├─────────────────────────────────────────┤
│  🏠 Dorm: Happy House                   │
│  🚪 Room: Standard Room                 │
│  👥 Type: Shared                        │
│  ⏰ Duration: 3 months                  │
│  💵 ₱1,500.00                           │
├─────────────────────────────────────────┤
│  ℹ️ Cancellation Reason:                │
│  Found a cheaper option closer to       │
│  school. Sorry for the inconvenience.   │
├─────────────────────────────────────────┤
│  [✅ Cancellation Acknowledged]         │
│  [💜 Message Student]                   │
└─────────────────────────────────────────┘
```

### Message Button Flow
1. Owner clicks **"Message Student"** button
2. System validates student info and dorm data
3. Opens `ChatConversationScreen` with:
   - Current user: Owner (with email)
   - Other user: Student (with ID, name, email)
   - Context: Specific dorm (with ID and name)
4. Owner can immediately discuss cancellation details

---

## Technical Details

### Cancellation Reason Extraction
**Pattern:** `/Reason:\s*(.+?)(?:\n|$)/s`

**Example Notes Field:**
```
Cancelled by student on 2024-12-03 14:30:00. Reason: Found accommodation closer to school.
```

**Extracted Reason:**
```
Found accommodation closer to school.
```

### Button Visibility Logic
```dart
// Acknowledge button: Only if cancelled AND not yet acknowledged
onAcknowledge: status == 'cancelled' && booking['cancellation_acknowledged'] != 1 
    ? () => _acknowledgeCancellation(booking) 
    : null

// Message button: Always available for cancelled bookings
onMessage: status == 'cancelled' 
    ? () => _messageStudent(booking) 
    : null
```

### State Management
- Button disappears after acknowledgement due to null callback
- Widget rebuilds after `_fetchBookings()` call
- New data from API includes `cancellation_acknowledged = 1`
- Condition evaluates to null, hiding acknowledge button
- Acknowledged badge displays instead

---

## Testing Checklist

### ✅ Acknowledge Button Behavior
- [x] Button shows for unacknowledged cancelled bookings
- [x] Button disappears after successful acknowledgement
- [x] Green badge appears after acknowledgement
- [x] Button doesn't reappear after screen refresh
- [x] Processing indicator shows during acknowledgement

### ✅ Cancellation Reason Display
- [x] Reason displays when present
- [x] Section hidden when no reason provided
- [x] Reason extracted correctly from notes field
- [x] Visual styling matches design (red theme)
- [x] Text wraps properly for long reasons

### ✅ Message Button
- [x] Button shows for all cancelled bookings
- [x] Button works before acknowledgement
- [x] Button works after acknowledgement
- [x] Opens chat conversation correctly
- [x] Passes correct student and dorm info
- [x] Shows error if student info missing

### ✅ Data Flow
- [x] API returns cancellation_reason field
- [x] API returns student_id field
- [x] API returns dorm_id field
- [x] Mobile receives all necessary fields
- [x] Widget displays all information correctly

---

## Benefits

### For Dorm Owners
✅ **Clear Status Tracking:** Know which cancellations have been reviewed
✅ **Understand Why:** See exact reason for each cancellation
✅ **Easy Communication:** One-tap access to message the student
✅ **Better Record Keeping:** Acknowledged status prevents duplicate processing
✅ **Improved Response:** Can address student concerns quickly

### For System
✅ **Reduced Confusion:** Owners know exactly what action is needed
✅ **Better UX:** Visual indicators guide user actions
✅ **Audit Trail:** Acknowledgement timestamp and user ID tracked
✅ **Communication Path:** Direct channel for resolving issues

---

## Future Enhancements

### Suggested Improvements
1. **Auto-acknowledge after 7 days:** Automatically mark old cancellations as acknowledged
2. **Cancellation statistics:** Show trends (reason categories, timing patterns)
3. **Quick responses:** Pre-written message templates for common scenarios
4. **Notification settings:** Alert owners only for specific cancellation reasons
5. **Reason categorization:** Dropdown for students (price, location, changed plans, etc.)

---

## Summary

All three critical issues with cancelled bookings have been resolved:

1. ✅ **Acknowledge button now disappears** after confirmation
2. ✅ **Cancellation reasons are displayed** prominently
3. ✅ **Message button provides** easy communication channel

The system now provides owners with complete visibility and tools to manage cancelled bookings effectively! 🎉
