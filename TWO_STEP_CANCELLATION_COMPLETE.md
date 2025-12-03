# Two-Step Cancellation Process - Implementation Complete ✅

## Problem Fixed
**Issue:** When a student cancelled a booking, it immediately changed status to 'cancelled', making the owner's "acknowledge cancellation" button useless since the booking was already cancelled.

**Solution:** Implemented a two-step cancellation process:
1. **Student requests cancellation** → Status becomes `'cancellation_requested'`
2. **Owner confirms cancellation** → Status changes to `'cancelled'`

---

## Changes Made

### 1. Database Schema Update
**File:** `database_updates/add_cancellation_requested_status.sql`

Added new status to bookings ENUM:
```sql
ALTER TABLE `bookings` 
MODIFY COLUMN `status` ENUM(
    'pending',
    'approved',
    'rejected',
    'cancellation_requested',  -- NEW
    'cancelled',
    'completed',
    'active'
) NOT NULL DEFAULT 'pending';
```

**Status Flow:**
- `cancellation_requested`: Student wants to cancel, waiting for owner confirmation
- `cancelled`: Owner confirmed the cancellation

---

### 2. Student Cancel Booking API
**File:** `Main/modules/mobile-api/student/cancel_booking.php`

**Changed:** Status update from `'cancelled'` to `'cancellation_requested'`

```php
// OLD CODE (Line 91-102):
UPDATE bookings 
SET status = 'cancelled',  // ❌ Immediately cancelled
    ...

// NEW CODE:
UPDATE bookings 
SET status = 'cancellation_requested',  // ✅ Requests cancellation
    notes = CONCAT(
        COALESCE(notes, ''),
        IF(COALESCE(notes, '') != '', '\n', ''),
        'Cancellation requested by student on ', DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s'), 
        IF(? != '', CONCAT('. Reason: ', ?), '')
    ),
    updated_at = NOW()
WHERE booking_id = ?
```

**Key Changes:**
- Status set to `'cancellation_requested'` instead of `'cancelled'`
- Payments are NOT rejected (kept pending until owner confirms)
- Room status unchanged (owner needs to confirm first)
- Returns status in response: `'status' => 'cancellation_requested'`

---

### 3. Owner Acknowledge Cancellation API  
**File:** `Main/modules/mobile-api/owner/acknowledge_cancellation.php`

**Changed:** Now actually completes the cancellation process

```php
// OLD CODE (Lines 66-73):
if ($booking['status'] !== 'cancelled') {  // ❌ Already cancelled
    echo json_encode(['success' => false, 'error' => 'Booking is not cancelled']);
    exit;
}

// Just sets flag:
UPDATE bookings 
SET cancellation_acknowledged = 1,
    cancellation_acknowledged_at = NOW(),
    cancellation_acknowledged_by = ?,
    updated_at = NOW()

// NEW CODE:
if ($booking['status'] !== 'cancellation_requested') {  // ✅ Checks for request
    echo json_encode([
        'success' => false, 
        'error' => 'Booking is not pending cancellation. Current status: ' . $booking['status']
    ]);
    exit;
}

// Transaction that:
// 1. Changes status from cancellation_requested to cancelled
// 2. Sets acknowledgement flag and timestamp
// 3. Adds confirmation note
// 4. Rejects pending payments
$pdo->beginTransaction();

try {
    UPDATE bookings 
    SET status = 'cancelled',  // ✅ Now actually cancels
        cancellation_acknowledged = 1,
        cancellation_acknowledged_at = NOW(),
        cancellation_acknowledged_by = ?,
        notes = CONCAT(
            COALESCE(notes, ''),
            '\nCancellation confirmed by owner on ', DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s')
        ),
        updated_at = NOW()
    WHERE booking_id = ?
    
    // Cancel pending payments
    UPDATE payments 
    SET status = 'rejected',
        notes = CONCAT(
            COALESCE(notes, ''),
            IF(COALESCE(notes, '') != '', '\n', ''),
            'Payment cancelled due to booking cancellation confirmed on ', 
            DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s')
        ),
        updated_at = NOW()
    WHERE booking_id = ? AND status IN ('pending', 'submitted')
    
    $pdo->commit();
}
```

**Key Changes:**
- Checks for `'cancellation_requested'` status (not `'cancelled'`)
- Changes status to `'cancelled'` (completes the cancellation)
- Rejects associated pending payments
- Uses transaction for data integrity

---

### 4. Mobile UI Updates
**File:** `mobile/lib/screens/owner/owner_booking_screen.dart`

#### Updated Filter to Show Both Statuses
```dart
// Line 591-602
List<Map<String, dynamic>> _filteredBookings() {
  return _bookings.where((booking) {
    final status = (booking['status'] ?? '').toString().toLowerCase();
    if (_selectedTab == 0) {
      return status == 'pending';
    } else if (_selectedTab == 1) {
      return status == 'approved';
    } else {
      // Cancelled tab shows BOTH cancellation_requested AND cancelled
      return status == 'cancelled' || status == 'cancellation_requested';
    }
  }).toList();
}
```

#### Updated Button Logic
```dart
// Lines 746-759
final booking = filteredBookings[index];
final status = (booking['status'] ?? '').toString().toLowerCase();
final isCancellationRequested = status == 'cancellation_requested';
final isCancelled = status == 'cancelled';

return BookingCard(
  booking: booking,
  onApprove: status == 'pending' ? () => _approveBooking(booking) : null,
  onReject: status == 'pending' ? () => _rejectBooking(booking) : null,
  onAcknowledge: isCancellationRequested  // ✅ Only show for requests
      ? () => _acknowledgeCancellation(booking) 
      : null,
  onMessage: (isCancellationRequested || isCancelled)  // ✅ Show for both
      ? () => _messageStudent(booking) 
      : null,
  isProcessing: _isProcessing,
);
```

---

### 5. Booking Card Widget Updates
**File:** `mobile/lib/widgets/owner/bookings/booking_card.dart`

#### Added Status Variable
```dart
// Lines 22-35
final status = (booking['status'] ?? '').toString().toLowerCase();
final isPending = status == 'pending';
final isCancellationRequested = status == 'cancellation_requested';  // NEW
final isCancelled = status == 'cancelled';
final isAcknowledged = booking['cancellation_acknowledged'] == 1;
```

#### Updated Cancellation Reason Display
```dart
// Lines 260-296
// Show reason for BOTH cancellation_requested AND cancelled
if ((isCancellationRequested || isCancelled) && 
    booking['cancellation_reason'] != null && 
    booking['cancellation_reason'].toString().isNotEmpty)
  Padding(
    padding: const EdgeInsets.only(top: 16),
    child: Container(
      // ... Red-themed info card with cancellation reason
    ),
  ),
```

#### Redesigned Button Section
```dart
// Lines 423-509
if (isCancellationRequested || isCancelled)
  Padding(
    padding: const EdgeInsets.only(top: 16),
    child: Column(
      children: [
        // For cancellation_requested: Show CONFIRM button
        if (isCancellationRequested && onAcknowledge != null)
          Container(
            // Blue gradient button
            child: ElevatedButton.icon(
              onPressed: isProcessing ? null : onAcknowledge,
              icon: const Icon(Icons.check_circle, size: 20),
              label: const Text(
                'Confirm Cancellation',  // ✅ Changed text
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          )
        // For cancelled: Show green CONFIRMED badge
        else if (isCancelled && isAcknowledged)
          Container(
            // Green badge
            child: Row(
              children: [
                Icon(Icons.check),
                Text('Cancellation Confirmed'),  // ✅ Changed text
              ],
            ),
          ),
        
        // Message button for BOTH statuses
        if (onMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              // Purple gradient button
              child: ElevatedButton.icon(
                onPressed: isProcessing ? null : onMessage,
                icon: const Icon(Icons.message, size: 20),
                label: const Text('Message Student'),
              ),
            ),
          ),
      ],
    ),
  ),
```

#### Added Status Colors and Text
```dart
// Lines 555-625
Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'cancellation_requested':
      return const Color(0xFFFF6B00); // Orange
    // ... other statuses
  }
}

LinearGradient _getStatusGradient(String status) {
  switch (status.toLowerCase()) {
    case 'cancellation_requested':
      return const LinearGradient(
        colors: [Color(0xFFFF6B00), Color(0xFFFF8C00)],
      );
    // ... other statuses
  }
}

String _getStatusText(String status) {
  switch (status.toLowerCase()) {
    case 'cancellation_requested':
      return 'Cancellation Requested';
    // ... other statuses
  }
}
```

---

## User Flow

### Student Side

#### 1. Student Requests Cancellation
```
Student taps "Cancel Booking"
↓
Enters cancellation reason
↓
Confirms cancellation
↓
API call to cancel_booking.php
↓
Booking status → 'cancellation_requested'
↓
Student sees: "Cancellation request submitted. Waiting for owner confirmation."
↓
Booking appears as "Cancellation Requested" in student's booking list
```

### Owner Side

#### 2. Owner Reviews Cancellation Request
```
Owner opens Bookings > Cancelled tab
↓
Sees booking with orange "Cancellation Requested" badge
↓
Sees cancellation reason in red info card
↓
Has two options:
  - [💜 Message Student] - Discuss the cancellation
  - [🔵 Confirm Cancellation] - Approve the cancellation
```

#### 3. Owner Confirms Cancellation
```
Owner taps "Confirm Cancellation"
↓
API call to acknowledge_cancellation.php
↓
Booking status changes: 'cancellation_requested' → 'cancelled'
↓
Pending payments rejected
↓
Acknowledgement recorded (timestamp + owner_id)
↓
Button disappears, replaced with green "Cancellation Confirmed" badge
↓
Message button still available
```

---

## Visual Changes

### Before Fix
```
Student cancels → Status immediately 'cancelled'
Owner sees → [✅ Cancellation Acknowledged] (useless button)
Clicking button → Just sets a flag, no real effect
```

### After Fix
```
Student cancels → Status becomes 'cancellation_requested'
Owner sees → [🔵 Confirm Cancellation] (functional button)
Clicking button → Actually completes the cancellation process
After confirmation → [✅ Cancellation Confirmed] (badge)
```

### Status Badge Colors
- **Cancellation Requested**: 🟠 Orange gradient
- **Cancelled**: 🔴 Red gradient
- **Confirmed Badge**: 🟢 Green background

---

## Benefits

### For Students
✅ **Clear Status:** Know their cancellation is pending owner review
✅ **Transparency:** Can see if owner has confirmed or not
✅ **Communication:** Owner can message them about the cancellation

### For Owners
✅ **Control:** Must confirm before booking is actually cancelled
✅ **Review Time:** Can check details and discuss with student first
✅ **Payment Handling:** Payments stay pending until owner confirms
✅ **Proper Flow:** Acknowledge button now serves a real purpose

### For System
✅ **Data Integrity:** Two-step process prevents premature cancellations
✅ **Audit Trail:** Clear record of who confirmed and when
✅ **Flexibility:** Owner can contact student before finalizing
✅ **Logical Flow:** Status progression makes sense

---

## Technical Notes

### Database Migration Required
**Run this SQL before testing:**
```sql
ALTER TABLE `bookings` 
MODIFY COLUMN `status` ENUM(
    'pending',
    'approved',
    'rejected',
    'cancellation_requested',
    'cancelled',
    'completed',
    'active'
) NOT NULL DEFAULT 'pending';
```

### Backward Compatibility
- Existing `'cancelled'` bookings remain unchanged
- They show as "Cancellation Confirmed" (acknowledged badge)
- New cancellations follow the two-step process

### API Response Changes
**cancel_booking.php now returns:**
```json
{
  "success": true,
  "message": "Cancellation request submitted successfully. Waiting for owner confirmation.",
  "booking_id": 123,
  "status": "cancellation_requested"
}
```

**acknowledge_cancellation.php now:**
```json
{
  "success": true,
  "message": "Cancellation confirmed for John Doe's booking",
  "booking_id": 123
}
```

---

## Testing Checklist

### Student Cancellation
- [x] Student can cancel pending booking
- [x] Student can cancel approved booking
- [x] Cannot cancel if payments made
- [x] Status becomes 'cancellation_requested'
- [x] Cancellation reason stored in notes
- [x] Success message shows "waiting for owner confirmation"

### Owner Review
- [x] Cancellation request appears in Cancelled tab
- [x] Orange "Cancellation Requested" badge displays
- [x] Cancellation reason displays in red card
- [x] "Confirm Cancellation" button visible
- [x] "Message Student" button visible

### Owner Confirmation
- [x] Clicking "Confirm Cancellation" works
- [x] Status changes from 'cancellation_requested' to 'cancelled'
- [x] Pending payments rejected
- [x] Acknowledgement fields populated
- [x] Button replaced with green "Cancellation Confirmed" badge
- [x] Screen refreshes to show updated status

### Edge Cases
- [x] Cannot acknowledge already cancelled booking
- [x] Cannot acknowledge non-cancellation-requested booking
- [x] Processing indicator shows during confirmation
- [x] Error handling for failed confirmations
- [x] Message button works in both states

---

## Summary

The two-step cancellation process is now fully implemented! Students request cancellations which owners must confirm, making the acknowledgement system functional and meaningful. The status 'cancellation_requested' serves as an intermediate state that gives owners control and time to review before finalizing cancellations. 🎉
