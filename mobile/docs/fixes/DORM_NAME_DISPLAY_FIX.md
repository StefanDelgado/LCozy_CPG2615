# Dorm Name Display Fix - After Booking Approval

## Problem
After approving a booking, the dorm name was not displayed in the booking card. The card showed "Unknown Dorm" instead of the actual dorm name.

## Root Cause
**Field Name Mismatch:**
- API returned: `'dorm'`
- Widget expected: `'dorm_name'`

The BookingCard widget was looking for `booking['dorm_name']` but the API was only providing `booking['dorm']`, causing it to fall back to the default value "Unknown Dorm".

## Solution

### Fixed File: `Main/modules/mobile-api/owner_bookings_api.php`

**Added `dorm_name` field to API response:**

```php
// Format data for mobile app
$formatted = array_map(function($b) {
    return [
        'id' => $b['id'],
        'booking_id' => $b['id'],
        'student_email' => $b['student_email'],
        'student_name' => $b['student_name'],
        'requested_at' => timeAgo($b['requested_at']),
        'status' => ucfirst(strtolower($b['status'])),
        'dorm' => $b['dorm'],           // ← Keep for backward compatibility
        'dorm_name' => $b['dorm'],      // ← NEW: Add for widget consistency
        'room_type' => $b['room_type'],
        'duration' => $b['duration'] ?? 'Not specified',
        'start_date' => $b['start_date'],
        'price' => '₱' . number_format($b['price'], 2),
        'message' => $b['message'] ?? 'No additional message'
    ];
}, $bookings);
```

## What Changed

### Before:
```php
'dorm' => $b['dorm'],  // Only this field
```

### After:
```php
'dorm' => $b['dorm'],           // Keep original
'dorm_name' => $b['dorm'],      // Add new field
```

## Why Both Fields?

1. **`'dorm'`** - Kept for backward compatibility with any code that might reference it
2. **`'dorm_name'`** - Added to match what the BookingCard widget expects

This ensures:
- ✅ No breaking changes to existing code
- ✅ BookingCard displays dorm name correctly
- ✅ Consistent field naming across the app

## BookingCard Widget Reference

The widget expects this field:
```dart
final dormName = booking['dorm_name']?.toString() ?? 'Unknown Dorm';
```

Now it will correctly display the dorm name instead of showing "Unknown Dorm".

## Testing

After this fix, when you:
1. ✅ Approve a booking
2. ✅ View the bookings list
3. ✅ See the booking card

The dorm name should now display correctly in all booking cards (pending, approved, and rejected).

## Impact

- **Pending bookings:** Now show dorm name ✅
- **Approved bookings:** Now show dorm name ✅
- **Rejected bookings:** Now show dorm name ✅
- **Backward compatibility:** Maintained ✅

The fix is live immediately - just refresh your booking list to see the change!
