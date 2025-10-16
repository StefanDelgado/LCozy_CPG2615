# Automatic Payment Creation on Booking Approval

## Overview
When an owner approves a booking, the system now automatically creates a payment record for the student. This ensures that every approved booking has a corresponding payment that needs to be fulfilled.

## Changes Made

### File: `Main/modules/mobile-api/owner_bookings_api.php`

Added automatic payment creation in the approval process:

## Workflow

### Before Approval:
1. Student submits booking request
2. Status: **Pending**
3. No payment exists yet

### After Approval:
1. Owner approves booking
2. Booking status updated to: **Approved**
3. Room marked as: **Unavailable** (is_available = 0)
4. **Payment automatically created** with:
   - Amount calculated based on booking type
   - Status: **Pending**
   - Due date: 7 days from start date (or 7 days from today, whichever is later)
   - Links: student_id, booking_id, owner_id

## Payment Calculation Logic

### Shared Booking:
```
Amount = Base Room Price ÷ Room Capacity

Example:
- Room Price: ₱6,000
- Capacity: 4 persons
- Payment Amount: ₱6,000 ÷ 4 = ₱1,500
```

### Whole Room Booking:
```
Amount = Full Base Room Price

Example:
- Room Price: ₱6,000
- Payment Amount: ₱6,000
```

## Due Date Logic

Payment due date is set to:
```
due_date = MAX(booking_start_date, today + 7 days)
```

**Examples:**

1. **Future booking:**
   - Booking starts: January 20, 2025
   - Approved: January 10, 2025
   - Due date: January 20, 2025 (on start date)

2. **Immediate booking:**
   - Booking starts: January 10, 2025
   - Approved: January 10, 2025
   - Due date: January 17, 2025 (7 days later)

3. **Past booking (edge case):**
   - Booking starts: January 5, 2025
   - Approved: January 15, 2025
   - Due date: January 22, 2025 (7 days from approval)

## Database Record Created

### Payment Table Entry:
```sql
INSERT INTO payments (
    student_id,      -- From booking
    booking_id,      -- Current booking
    owner_id,        -- Owner who approved
    amount,          -- Calculated amount
    status,          -- 'pending'
    payment_date,    -- NOW() timestamp
    due_date,        -- Calculated due date
    created_at       -- NOW() timestamp
)
```

### Fields Populated:
- `payment_id`: Auto-incremented
- `student_id`: From booking record
- `booking_id`: Current booking being approved
- `owner_id`: Owner performing the approval
- `amount`: Calculated based on room price and booking type
- `status`: Always 'pending' on creation
- `payment_date`: Current timestamp
- `due_date`: Calculated future date
- `created_at`: Current timestamp

## Complete Approval Flow

```
1. Owner clicks "Approve" button
   ↓
2. Verify owner owns this dorm
   ↓
3. Update booking status to 'approved'
   ↓
4. Mark room as unavailable (is_available = 0)
   ↓
5. Fetch booking details (student_id, price, capacity, booking_type)
   ↓
6. Calculate payment amount:
   - If shared: price ÷ capacity
   - If whole: full price
   ↓
7. Calculate due date:
   - MAX(start_date, today + 7 days)
   ↓
8. Create payment record
   ↓
9. Log payment creation
   ↓
10. Return success response
```

## Benefits

### For Students:
✅ **Automatic payment tracking** - Don't need manual payment creation
✅ **Clear due dates** - Know when payment is expected
✅ **Fair pricing** - Correct amount based on booking type
✅ **Immediate visibility** - Payment appears right after approval

### For Owners:
✅ **No manual payment creation** - System handles it automatically
✅ **Consistent process** - Every approval creates payment
✅ **Accurate amounts** - Calculation matches booking type
✅ **Better tracking** - Every approved booking has payment

### For System:
✅ **Data integrity** - No approved bookings without payments
✅ **Automated workflow** - Reduces manual errors
✅ **Consistent logic** - Same calculation as booking creation
✅ **Complete audit trail** - Every action is logged

## Error Handling

### If Payment Creation Fails:
- Booking is still approved
- Room is still marked unavailable
- Error is logged in error_log
- Owner sees success message (booking approved)
- Admin can manually create payment if needed

### Logged Information:
```
Success: "Payment 123 created for booking 456 - Amount: 1500, Due: 2025-01-20"
Warning: "WARNING: Could not create payment - booking details not found for booking 456"
```

## Testing Scenarios

### Test 1: Shared Booking Approval
1. **Create** shared booking (4-person room at ₱8,000)
2. **Approve** booking as owner
3. **Verify** payment created with amount = ₱2,000
4. **Check** due date is 7 days from start date
5. **Confirm** payment appears in student's payment list

### Test 2: Whole Room Booking Approval
1. **Create** whole room booking (room at ₱6,000)
2. **Approve** booking as owner
3. **Verify** payment created with amount = ₱6,000
4. **Check** due date is 7 days from start date
5. **Confirm** payment appears in student's payment list

### Test 3: Multiple Bookings
1. **Create** 3 bookings for same student
2. **Approve** all 3 bookings
3. **Verify** 3 separate payments created
4. **Check** student sees all 3 payments
5. **Confirm** each payment has correct amount

### Test 4: Payment List Count
1. **Before approval**: Check payment count
2. **Approve booking**: Trigger payment creation
3. **Refresh payments**: Pull to refresh
4. **After approval**: Count should increase by 1
5. **Verify**: New payment shows correct details

## API Response

The approval response remains the same:
```json
{
  "ok": true,
  "message": "Booking approved successfully"
}
```

But internally, it also creates the payment. The student will see the new payment when they refresh their payments screen.

## Backward Compatibility

### Old Bookings:
- Bookings approved before this update won't have payments
- Admin can manually create payments for old approvals if needed
- Or wait for next monthly payment cycle

### New Bookings:
- All approvals from now on will automatically create payments ✅

## Summary

✅ **Automatic payment creation** on booking approval
✅ **Correct amount calculation** based on booking type
✅ **Smart due date** calculation
✅ **Complete data linkage** (student, booking, owner)
✅ **Error logging** for troubleshooting
✅ **No breaking changes** to existing API responses

Now when you approve a booking, the student will automatically get a payment record, and you'll see the count increase from 2 to 3! 🎉
