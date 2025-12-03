# Cancel Cancellation Request Feature - Complete Documentation

## Overview
This document describes the "Cancel Cancellation Request" feature that allows students to undo their cancellation request and revert their booking back to pending status before the dorm owner confirms the cancellation.

## Feature Purpose
- **Problem**: Students may request cancellation but change their mind before owner confirms
- **Solution**: Allow students to cancel their cancellation request while it's still pending owner confirmation
- **Result**: Booking status reverts from 'cancellation_requested' back to 'pending'

---

## Implementation Details

### 1. Database Schema
The feature uses the existing `cancellation_requested` status added in the two-step cancellation system:

```sql
ALTER TABLE `bookings` 
MODIFY COLUMN `status` ENUM(
    'pending', 'approved', 'rejected',
    'cancellation_requested',  -- Used for this feature
    'cancelled', 'completed', 'active'
) NOT NULL DEFAULT 'pending';
```

### 2. Backend API

#### **File**: `Main/modules/mobile-api/student/cancel_cancellation_request.php`

**Purpose**: Handles requests to cancel a cancellation request and revert booking to pending

**Request Format**:
```json
{
  "booking_id": 123,
  "student_email": "student@example.com"
}
```

**Validation**:
1. ✅ Validates required fields (booking_id, student_email)
2. ✅ Verifies booking exists
3. ✅ Confirms student owns the booking
4. ✅ Checks current status is 'cancellation_requested'
5. ✅ Uses transaction for data integrity

**Actions Performed**:
1. Changes status from 'cancellation_requested' → 'pending'
2. Adds historical note: "Cancellation request cancelled by student on [timestamp]"
3. Returns success with new status

**Response Format** (Success):
```json
{
  "success": true,
  "status": "pending",
  "message": "Cancellation request cancelled successfully. Your booking has been reverted to pending status."
}
```

**Response Format** (Error):
```json
{
  "success": false,
  "error": "Error message here"
}
```

**Error Cases**:
- Missing booking_id or student_email
- Booking not found
- Student doesn't own the booking
- Status is not 'cancellation_requested'
- Database update failed

---

### 3. Mobile Service Layer

#### **File**: `mobile/lib/services/booking_service.dart`

**Method**: `cancelCancellationRequest()`

```dart
Future<Map<String, dynamic>> cancelCancellationRequest({
  required int bookingId,
  required String studentEmail,
}) async {
  try {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/modules/mobile-api/student/cancel_cancellation_request.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'booking_id': bookingId,
        'student_email': studentEmail,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Cancellation request cancelled successfully',
          'status': data['status'] ?? 'pending',
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to cancel cancellation request',
        };
      }
    } else {
      return {
        'success': false,
        'error': 'Server error: ${response.statusCode}',
      };
    }
  } catch (e) {
    return {
      'success': false,
      'error': 'Network error: ${e.toString()}',
    };
  }
}
```

**Features**:
- ✅ Debug logging for troubleshooting
- ✅ Proper error handling
- ✅ Returns structured response
- ✅ Network error handling

---

### 4. Mobile UI Layer

#### **File**: `mobile/lib/screens/student/booking_details_screen.dart`

#### **A. Cancel Cancellation UI (Lines 206-277)**

Shows orange info box when booking status is 'cancellation_requested':

```dart
if (isCancellationRequested) ...[
  const SizedBox(height: 16),
  Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.orange[50],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.orange[200]!, width: 2),
    ),
    child: Column(
      children: [
        // Status Display
        Row(
          children: [
            Icon(Icons.pending_actions, color: Colors.orange[700], size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cancellation Pending', ...),
                  Text('Waiting for owner confirmation', ...),
                ],
              ),
            ),
          ],
        ),
        
        // Cancel Cancellation Button
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 45,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _showCancelCancellationDialog,
            icon: const Icon(Icons.undo, size: 20),
            label: const Text('Cancel Cancellation Request'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue[700],
              side: BorderSide(color: Colors.blue[700]!, width: 2),
            ),
          ),
        ),
        
        // Helper Text
        const SizedBox(height: 8),
        Text('This will revert your booking back to pending status', ...),
      ],
    ),
  ),
]
```

**Visual Design**:
- 🟠 Orange theme to indicate "pending" state
- 📋 Clear status message
- 🔄 Undo icon for intuitive action
- 💡 Helper text explaining what will happen

#### **B. Confirmation Dialog (Lines 1021-1099)**

**Method**: `_showCancelCancellationDialog()`

Shows confirmation dialog with:
1. **Title**: "Cancel Cancellation Request?"
2. **Confirmation Question**: "Are you sure you want to cancel your cancellation request?"
3. **Info Box** (Blue themed):
   - "What happens:"
   - • Your booking will return to PENDING status
   - • The owner will no longer see a cancellation request
   - • You can proceed with this booking normally
4. **Actions**:
   - "No, Keep Request" (TextButton)
   - "Yes, Cancel Request" (ElevatedButton - Blue)

```dart
Future<void> _showCancelCancellationDialog() async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Cancel Cancellation Request?'),
      content: Column(...), // Info box with bullet points
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('No, Keep Request'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: const Text('Yes, Cancel Request'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    await _submitCancelCancellation();
  }
}
```

#### **C. Submit Handler (Lines 1125-1181)**

**Method**: `_submitCancelCancellation()`

Handles the actual submission:
1. Shows loading state
2. Extracts booking ID
3. Calls BookingService
4. Handles success/error
5. Returns to previous screen with refresh flag

```dart
Future<void> _submitCancelCancellation() async {
  setState(() => _isLoading = true);

  try {
    final bookingId = widget.booking['booking_id'] is int
        ? widget.booking['booking_id']
        : int.tryParse(widget.booking['booking_id']?.toString() ?? '0') ?? 0;

    final result = await _bookingService.cancelCancellationRequest(
      bookingId: bookingId,
      studentEmail: widget.userEmail,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Cancellation request cancelled successfully'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
      // Return to previous screen with refresh flag
      Navigator.pop(context, true);
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Failed to cancel cancellation request'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  } catch (e) {
    // Handle exceptions
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}
```

**Features**:
- ✅ Loading state management
- ✅ Null safety with mounted checks
- ✅ Success/error feedback
- ✅ Navigation with refresh flag
- ✅ Exception handling

---

## User Flow

### Complete Cancellation Request Flow

```
┌─────────────────────────────────────┐
│ Student has APPROVED booking        │
└───────────┬─────────────────────────┘
            │
            ▼
┌─────────────────────────────────────┐
│ Student clicks "Cancel Booking"     │
│ - Enters reason                     │
│ - Confirms in dialog                │
└───────────┬─────────────────────────┘
            │
            ▼
┌─────────────────────────────────────┐
│ Status: CANCELLATION_REQUESTED      │
│ - Orange "Cancellation Pending" box │
│ - Shows "Cancel Cancellation" btn   │
└───────────┬─────────────────────────┘
            │
            ├──────────── Option 1: Student Changes Mind ────────────┐
            │                                                         │
            │                                                         ▼
            │                                          ┌──────────────────────────┐
            │                                          │ Click "Cancel            │
            │                                          │ Cancellation Request"    │
            │                                          └────────┬─────────────────┘
            │                                                   │
            │                                                   ▼
            │                                          ┌──────────────────────────┐
            │                                          │ Confirm in dialog        │
            │                                          └────────┬─────────────────┘
            │                                                   │
            │                                                   ▼
            │                                          ┌──────────────────────────┐
            │                                          │ Status: PENDING          │
            │                                          │ - Booking active again   │
            │                                          │ - Can proceed normally   │
            │                                          └──────────────────────────┘
            │
            └──────────── Option 2: Owner Confirms ─────────────┐
                                                                 │
                                                                 ▼
                                                  ┌──────────────────────────┐
                                                  │ Owner clicks "Confirm    │
                                                  │ Cancellation"            │
                                                  └────────┬─────────────────┘
                                                           │
                                                           ▼
                                                  ┌──────────────────────────┐
                                                  │ Status: CANCELLED        │
                                                  │ - Payments rejected      │
                                                  │ - Reason visible         │
                                                  │ - Can't be reverted      │
                                                  └──────────────────────────┘
```

---

## Status Display Consistency

### Student Dashboard
**File**: `Main/modules/mobile-api/student/student_dashboard_api.php`

**Updated Query (Line 123)**:
```php
WHERE b.status IN ('pending', 'approved', 'active', 'cancellation_requested', 'cancelled', 'completed')
```

**Notification Text (Line 217)**:
```php
WHEN b.status = 'cancellation_requested' 
THEN 'Your cancellation request is pending owner confirmation'
```

**Urgency Level (Line 223)**:
```php
WHEN b.status = 'cancellation_requested' THEN 'warning'
```

### Owner Dashboard
**File**: `mobile/lib/widgets/owner/bookings/booking_card.dart`

**Cancelled Tab Filter**:
Shows both 'cancellation_requested' and 'cancelled' bookings together

**Button Display**:
- cancellation_requested → Blue "Confirm Cancellation" button
- cancelled + acknowledged → Green "Cancellation Confirmed" badge

**Cancellation Reason Display (Line 260)**:
```dart
// Only show reason after owner confirms (not during request)
if (isCancelled) ...[
  // Show cancellation reason
]
```

---

## Edge Cases & Validation

### ✅ Handled Cases

1. **Status Validation**:
   - Can only cancel cancellation if status is exactly 'cancellation_requested'
   - Cannot cancel if owner already confirmed (status = 'cancelled')

2. **Ownership Validation**:
   - Student must own the booking
   - Verified via email match in database

3. **Race Conditions**:
   - Transaction used for data integrity
   - Status checked before update

4. **UI State Management**:
   - Loading state prevents double submissions
   - Mounted checks prevent updates after widget disposal

5. **Network Errors**:
   - Try-catch blocks around all network calls
   - User-friendly error messages

### ❌ Not Handled (By Design)

1. **After Owner Confirmation**:
   - Once owner confirms cancellation (status = 'cancelled'), cannot be reverted
   - This is intentional - payments have been rejected

2. **Payment Refunds**:
   - No payments are affected during cancellation_requested
   - Payments only rejected when owner confirms

---

## Testing Checklist

### ✅ Functional Testing

- [ ] Student can request cancellation (status → cancellation_requested)
- [ ] Orange info box appears for cancellation_requested status
- [ ] "Cancel Cancellation Request" button is visible and clickable
- [ ] Dialog shows with proper messaging
- [ ] Confirming dialog reverts status to pending
- [ ] Success message appears after cancellation
- [ ] Screen refreshes showing updated status
- [ ] Cannot cancel after owner confirms

### ✅ UI/UX Testing

- [ ] Orange theme used consistently for pending cancellation
- [ ] Blue theme used for cancel cancellation action
- [ ] Icons are intuitive (pending_actions, undo)
- [ ] Text is clear and informative
- [ ] Loading states work correctly
- [ ] Error messages are helpful

### ✅ API Testing

- [ ] Endpoint rejects missing parameters
- [ ] Endpoint validates ownership
- [ ] Endpoint checks status correctly
- [ ] Transaction rollback works on error
- [ ] Historical note is added
- [ ] Response format is consistent

### ✅ Integration Testing

- [ ] Student dashboard shows correct status
- [ ] Owner dashboard shows correct status
- [ ] Cancellation reason hidden during request
- [ ] Cancellation reason shown after confirmation
- [ ] Message button works in all states

---

## Related Features

### Two-Step Cancellation System
**Documentation**: `TWO_STEP_CANCELLATION_COMPLETE.md`

The cancel cancellation request feature is built on top of the two-step cancellation system:

1. **Step 1**: Student requests cancellation
   - Status: 'cancellation_requested'
   - Can be cancelled by student (this feature)
   
2. **Step 2**: Owner confirms cancellation
   - Status: 'cancelled'
   - Cannot be reversed

### Other Related Files

1. **Cancel Booking API**: `Main/modules/mobile-api/student/cancel_booking.php`
   - Sets status to 'cancellation_requested'
   
2. **Acknowledge Cancellation API**: `Main/modules/mobile-api/owner/acknowledge_cancellation.php`
   - Confirms cancellation to 'cancelled'
   - Rejects payments

3. **Owner Bookings API**: `Main/modules/mobile-api/owner/owner_bookings_api.php`
   - Returns cancellation details for owner view

---

## Future Enhancements

### Potential Improvements

1. **Time Limits**:
   - Add expiration time for cancellation requests
   - Auto-confirm after X days

2. **Notifications**:
   - Push notification when owner confirms/denies
   - Email notification of status changes

3. **Analytics**:
   - Track cancellation request frequency
   - Monitor cancel-cancellation patterns

4. **Admin Override**:
   - Allow admin to force-revert cancelled bookings
   - For exceptional circumstances

---

## Summary

The Cancel Cancellation Request feature provides students with flexibility to change their mind before the dorm owner confirms the cancellation. It maintains data integrity through transactions, provides clear UI feedback, and integrates seamlessly with the existing two-step cancellation system.

**Key Benefits**:
- ✅ Improved user experience - mistakes can be corrected
- ✅ Reduced support requests - self-service solution
- ✅ Clear communication - owner knows when request is active
- ✅ Data integrity - proper transaction handling
- ✅ Consistent UI - status displays match across views

---

**Document Version**: 1.0  
**Last Updated**: 2024  
**Related Documentation**:
- TWO_STEP_CANCELLATION_COMPLETE.md
- CANCELLATION_IMPROVEMENTS_COMPLETE.md
