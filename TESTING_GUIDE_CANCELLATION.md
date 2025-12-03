# Testing Guide - Cancellation System Enhancements

## Quick Test Scenarios

### Scenario 1: Two-Step Cancellation (Happy Path)
**Goal**: Verify complete cancellation flow

**Steps**:
1. **Student App**:
   - Open booking with 'approved' status
   - Click "Cancel Booking" button
   - Enter reason: "Changed plans"
   - Confirm in dialog
   
2. **Expected Result**:
   - ✅ Status changes to 'cancellation_requested'
   - ✅ Orange "Cancellation Pending" box appears
   - ✅ "Cancel Cancellation Request" button visible
   - ✅ Cancellation reason NOT visible yet

3. **Owner App**:
   - Go to "Cancelled" tab
   - Find the booking
   
4. **Expected Result**:
   - ✅ Booking appears with orange "Cancellation Requested" badge
   - ✅ Blue "Confirm Cancellation" button visible
   - ✅ Cancellation reason NOT visible yet
   - ✅ Message button available

5. **Owner App**:
   - Click "Confirm Cancellation"
   - Confirm in dialog
   
6. **Expected Result**:
   - ✅ Status changes to 'cancelled'
   - ✅ Green "Cancellation Confirmed" badge appears
   - ✅ Cancellation reason NOW visible
   - ✅ Payments rejected in database

7. **Student App**:
   - Refresh booking details
   
8. **Expected Result**:
   - ✅ Status shows 'cancelled' (red badge)
   - ✅ "Cancel Cancellation Request" button gone
   - ✅ Message button available

---

### Scenario 2: Cancel Cancellation Request
**Goal**: Verify student can undo cancellation request

**Steps**:
1. **Student App**:
   - Cancel a booking (follows Scenario 1 steps 1-2)
   - Status: 'cancellation_requested'
   - Click "Cancel Cancellation Request" button
   
2. **Expected Result**:
   - ✅ Dialog appears: "Cancel Cancellation Request?"
   - ✅ Shows info box explaining what happens
   - ✅ Two buttons: "No, Keep Request" / "Yes, Cancel Request"

3. **Student App**:
   - Click "Yes, Cancel Request"
   
4. **Expected Result**:
   - ✅ Success message appears (green)
   - ✅ Returns to previous screen
   - ✅ Status reverted to 'pending'
   - ✅ Orange box disappeared

5. **Owner App**:
   - Check Cancelled tab
   
6. **Expected Result**:
   - ✅ Booking no longer appears in Cancelled tab
   - ✅ Booking appears in appropriate tab based on status

7. **Database Check**:
   ```sql
   SELECT booking_id, status, notes 
   FROM bookings 
   WHERE booking_id = [test_booking_id];
   ```
   
8. **Expected Result**:
   - ✅ status = 'pending'
   - ✅ notes contains: "Cancellation request cancelled by student on [timestamp]"

---

### Scenario 3: Cannot Cancel After Owner Confirms
**Goal**: Verify cancellation cannot be undone after confirmation

**Steps**:
1. **Complete Scenario 1** (owner confirms cancellation)
2. **Student App**:
   - Open cancelled booking details
   
3. **Expected Result**:
   - ✅ Status shows 'cancelled' (red)
   - ✅ "Cancel Cancellation Request" button NOT visible
   - ✅ No option to revert

4. **API Test** (Optional):
   ```bash
   curl -X POST http://your-domain/modules/mobile-api/student/cancel_cancellation_request.php \
   -H "Content-Type: application/json" \
   -d '{
     "booking_id": [test_booking_id],
     "student_email": "student@test.com"
   }'
   ```
   
5. **Expected Result**:
   ```json
   {
     "success": false,
     "error": "Can only cancel cancellation requests that are pending (status: cancellation_requested)"
   }
   ```

---

### Scenario 4: Cancellation Reason Visibility
**Goal**: Verify reason hidden during request, shown after confirmation

**Steps**:
1. **Student cancels booking** with reason: "Test reason - should be hidden"
2. **Owner App** (before confirming):
   - Open booking in Cancelled tab
   
3. **Expected Result**:
   - ✅ Cancellation reason section NOT visible
   - ✅ Only sees status: "Cancellation Requested"

4. **Owner confirms cancellation**
5. **Owner App** (after confirming):
   - Open same booking
   
6. **Expected Result**:
   - ✅ Yellow info box appears
   - ✅ Shows "Cancellation Reason: Test reason - should be hidden"

---

### Scenario 5: Status Display Consistency
**Goal**: Verify student and owner see same status

**Steps**:
1. **Student cancels booking**
2. **Student App**:
   - Check dashboard
   - Check booking details
   
3. **Expected Result**:
   - ✅ Dashboard: Shows 'cancellation_requested' or "Cancellation Requested"
   - ✅ Details: Orange "Cancellation Pending" box
   - ✅ Notification: "Your cancellation request is pending owner confirmation"

4. **Owner App**:
   - Check Cancelled tab
   - Open booking
   
5. **Expected Result**:
   - ✅ Shows 'cancellation_requested' or "Cancellation Requested"
   - ✅ Orange badge
   - ✅ Same terminology as student view

---

### Scenario 6: Message Functionality
**Goal**: Verify messaging works for cancelled bookings

**Steps**:
1. **Student cancels booking** (status: cancellation_requested)
2. **Student App**:
   - In booking details, look for message button
   
3. **Expected Result**:
   - ✅ Message button visible and enabled

4. **Student App**:
   - Click message button
   
5. **Expected Result**:
   - ✅ Opens messaging interface
   - ✅ Can send messages

6. **Owner confirms cancellation** (status: cancelled)
7. **Both Apps**:
   - Check message button availability
   
8. **Expected Result**:
   - ✅ Message button still visible
   - ✅ Can continue conversation

---

### Scenario 7: Acknowledge Button States
**Goal**: Verify button changes to badge after acknowledgement

**Steps**:
1. **Student cancels booking**
2. **Owner App**:
   - Go to Cancelled tab
   - Find booking
   
3. **Expected Result**:
   - ✅ Blue "Confirm Cancellation" button visible
   - ✅ Button is clickable

4. **Owner App**:
   - Click "Confirm Cancellation"
   - Confirm in dialog
   
5. **Expected Result**:
   - ✅ Button disappears
   - ✅ Green "Cancellation Confirmed" badge appears
   - ✅ Badge shows checkmark icon

6. **Owner App**:
   - Refresh or reopen booking
   
7. **Expected Result**:
   - ✅ Badge still present (not button)
   - ✅ Cannot re-acknowledge

---

## Database Validation Queries

### Check Status Values
```sql
-- Verify ENUM includes new status
SHOW COLUMNS FROM bookings WHERE Field = 'status';

-- Expected output should include:
-- 'pending','approved','rejected','cancellation_requested','cancelled','completed','active'
```

### Find Cancellation Requests
```sql
-- All pending cancellation requests
SELECT 
    b.booking_id,
    b.status,
    s.name as student_name,
    d.name as dorm_name,
    b.cancellation_reason,
    b.created_at,
    b.updated_at
FROM bookings b
JOIN students s ON b.student_id = s.student_id
JOIN rooms r ON b.room_id = r.room_id
JOIN dorms d ON r.dorm_id = d.dorm_id
WHERE b.status = 'cancellation_requested'
ORDER BY b.updated_at DESC;
```

### Check Acknowledged Cancellations
```sql
-- All acknowledged cancellations
SELECT 
    booking_id,
    status,
    cancellation_reason,
    cancellation_acknowledged,
    cancellation_acknowledged_at,
    cancellation_acknowledged_by
FROM bookings
WHERE status = 'cancelled' 
  AND cancellation_acknowledged = true
ORDER BY cancellation_acknowledged_at DESC;
```

### Verify Payment Rejection
```sql
-- Check payments were rejected when owner confirmed
SELECT 
    p.payment_id,
    p.booking_id,
    p.status as payment_status,
    p.amount,
    b.status as booking_status,
    b.cancellation_acknowledged_at
FROM payments p
JOIN bookings b ON p.booking_id = b.booking_id
WHERE b.status = 'cancelled'
  AND b.cancellation_acknowledged = true
ORDER BY b.cancellation_acknowledged_at DESC;

-- Expected: payment_status should be 'rejected'
```

### Track Status Changes
```sql
-- Check notes for status change history
SELECT 
    booking_id,
    status,
    notes,
    updated_at
FROM bookings
WHERE notes LIKE '%cancellation%'
ORDER BY updated_at DESC
LIMIT 20;
```

---

## API Testing with Postman

### Test 1: Cancel Booking (Request Cancellation)
```http
POST {{base_url}}/modules/mobile-api/student/cancel_booking.php
Content-Type: application/json

{
  "booking_id": 123,
  "student_email": "student@test.com",
  "cancellation_reason": "Test cancellation reason"
}

Expected Response:
{
  "success": true,
  "message": "Cancellation request submitted successfully. Waiting for owner confirmation."
}
```

### Test 2: Cancel Cancellation Request
```http
POST {{base_url}}/modules/mobile-api/student/cancel_cancellation_request.php
Content-Type: application/json

{
  "booking_id": 123,
  "student_email": "student@test.com"
}

Expected Response (Success):
{
  "success": true,
  "status": "pending",
  "message": "Cancellation request cancelled successfully. Your booking has been reverted to pending status."
}

Expected Response (Error - Wrong Status):
{
  "success": false,
  "error": "Can only cancel cancellation requests that are pending (status: cancellation_requested)"
}
```

### Test 3: Acknowledge Cancellation
```http
POST {{base_url}}/modules/mobile-api/owner/acknowledge_cancellation.php
Content-Type: application/json

{
  "booking_id": 123,
  "owner_email": "owner@test.com"
}

Expected Response:
{
  "success": true,
  "message": "Cancellation acknowledged successfully"
}
```

### Test 4: Get Owner Bookings
```http
GET {{base_url}}/modules/mobile-api/owner/owner_bookings_api.php?owner_email=owner@test.com

Expected Response (Partial):
{
  "ok": true,
  "bookings": [
    {
      "booking_id": 123,
      "status": "cancellation_requested",
      "cancellation_reason": "Test reason",
      "cancellation_acknowledged": false,
      "cancellation_acknowledged_at": null,
      "cancellation_acknowledged_by": null,
      ...
    }
  ]
}
```

### Test 5: Get Student Dashboard
```http
GET {{base_url}}/modules/mobile-api/student/student_dashboard_api.php?student_email=student@test.com

Expected Response (Partial):
{
  "ok": true,
  "bookings": [
    {
      "booking_id": 123,
      "status": "cancellation_requested",
      "notification_text": "Your cancellation request is pending owner confirmation",
      "notification_urgency": "warning",
      ...
    }
  ]
}
```

---

## Error Cases to Test

### Test: Invalid Booking ID
```json
Request:
{
  "booking_id": 99999,
  "student_email": "student@test.com"
}

Expected:
{
  "success": false,
  "error": "Booking not found or you don't have permission"
}
```

### Test: Wrong Owner
```json
Request:
{
  "booking_id": 123,
  "student_email": "wrong@test.com"
}

Expected:
{
  "success": false,
  "error": "Booking not found or you don't have permission"
}
```

### Test: Missing Required Fields
```json
Request:
{
  "booking_id": 123
  // Missing student_email
}

Expected:
{
  "success": false,
  "error": "Missing required fields"
}
```

---

## Mobile UI Checklist

### Student View
- [ ] Cancel booking button visible for approved bookings
- [ ] Cancel dialog has reason input field
- [ ] Cancel dialog shows confirmation message
- [ ] Orange "Cancellation Pending" box appears after cancellation
- [ ] "Cancel Cancellation Request" button visible
- [ ] Cancel cancellation dialog shows info box
- [ ] Success message appears after cancel cancellation
- [ ] Status badge shows correct color (orange/red)
- [ ] Message button available for cancelled bookings

### Owner View
- [ ] Cancelled tab shows both requests and confirmed
- [ ] Orange badge for cancellation_requested
- [ ] Red badge for cancelled
- [ ] Blue "Confirm Cancellation" button for requests
- [ ] Green "Confirmed" badge for acknowledged
- [ ] Cancellation reason hidden during request
- [ ] Cancellation reason visible after confirmation
- [ ] Message button available for all states
- [ ] Confirmation dialog explains impact

---

## Performance Tests

### Load Test Scenarios
1. **Multiple Concurrent Cancellations**:
   - 10 students cancel simultaneously
   - Verify all status updates correctly
   - Check for race conditions

2. **Rapid Status Changes**:
   - Cancel booking
   - Immediately cancel cancellation
   - Verify status updates correctly

3. **Large Dataset**:
   - Test with 1000+ bookings
   - Filter performance in Cancelled tab
   - Dashboard load times

---

## Edge Cases

### Edge Case 1: Cancel While Owner Confirming
**Steps**:
1. Student requests cancellation
2. Owner starts confirmation process (opens dialog)
3. Student cancels cancellation request
4. Owner completes confirmation

**Expected**: One should fail with appropriate error message

### Edge Case 2: Multiple Rapid Clicks
**Steps**:
1. Student clicks "Cancel Cancellation Request" multiple times rapidly

**Expected**: Button disabled during loading, only one request sent

### Edge Case 3: Network Failure
**Steps**:
1. Disconnect internet
2. Try to cancel cancellation request

**Expected**: Network error message shown, no status change

### Edge Case 4: App Killed During Operation
**Steps**:
1. Start cancel cancellation operation
2. Kill app before completion

**Expected**: Operation completes or rolls back, no partial state

---

## Rollback Procedure

If issues are found in production:

### 1. Disable New Features
```php
// In cancel_cancellation_request.php, add at top:
header('HTTP/1.1 503 Service Unavailable');
exit(json_encode(['success' => false, 'error' => 'Feature temporarily disabled']));
```

### 2. Revert Database Changes
```sql
-- Only if absolutely necessary
ALTER TABLE `bookings` 
MODIFY COLUMN `status` ENUM(
    'pending', 'approved', 'rejected',
    'cancelled', 'completed', 'active'
) NOT NULL DEFAULT 'pending';

-- Update existing cancellation_requested to cancelled
UPDATE bookings 
SET status = 'cancelled' 
WHERE status = 'cancellation_requested';
```

### 3. Revert Mobile App
```bash
# Revert to previous version
# Rebuild and redeploy
flutter build apk --release
```

---

## Success Criteria

### All Tests Pass When:
- ✅ Two-step cancellation works end-to-end
- ✅ Cancel cancellation reverts to pending
- ✅ Reasons hidden/shown at correct times
- ✅ Status displays consistent across views
- ✅ Acknowledge button becomes badge
- ✅ Message functionality works throughout
- ✅ No data inconsistencies
- ✅ No race conditions
- ✅ Error handling works properly
- ✅ UI feedback is clear and immediate

---

**Document Version**: 1.0  
**Last Updated**: 2024  
**Test Coverage**: Backend + Mobile + Database + Edge Cases
