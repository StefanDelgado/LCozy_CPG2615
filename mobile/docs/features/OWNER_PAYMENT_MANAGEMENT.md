# Owner Payment Management Enhancement

## Overview
Enhanced the owner payment screen with complete payment management capabilities including view receipt, complete payment, and reject payment functions, plus functional filters.

## Features Implemented

### 1. **View Receipt** 📄
- Available for ALL payment statuses
- Opens a dialog showing:
  - Tenant information
  - Dorm and room details
  - Payment amount and due date
  - Status
  - Receipt image (if uploaded)
  - Quick action buttons (Complete/Reject for pending payments)

**How to use:**
1. Find any payment in the list
2. Click the **"View"** button
3. View receipt details and image
4. Take action directly from the dialog (if pending)

### 2. **Complete Payment** ✅
- Marks a payment as **"paid"**
- Updates payment_date to current timestamp
- Only available for **pending** payments
- Shows confirmation with success/error message
- Auto-refreshes payment list

**How to use:**
1. Find a pending payment
2. Click **"Complete"** button (green)
3. Payment status changes to "paid"
4. Payment appears in "Completed" filter

### 3. **Reject Payment** ❌
- Marks a payment as **"rejected"**
- Shows confirmation dialog before rejecting
- Only available for **pending** payments
- Updates timestamp
- Auto-refreshes payment list

**How to use:**
1. Find a pending payment
2. Click **"Reject"** button (red)
3. Confirm in the dialog
4. Payment status changes to "rejected"
5. Payment appears in "Failed" filter

### 4. **Functional Filters** 🔍
Enhanced filter system that groups related statuses:

**Filter Options:**
- **All**: Shows all payments
- **Completed**: Shows 'paid' or 'completed' status
- **Pending**: Shows 'pending' or 'submitted' status
- **Failed**: Shows 'failed' or 'rejected' status

**How filters work:**
```dart
Completed filter → status = 'paid' OR 'completed'
Pending filter → status = 'pending' OR 'submitted'
Failed filter → status = 'failed' OR 'rejected'
```

## UI Changes

### Payment Card Layout
```
┌─────────────────────────────────────┐
│ 👤 Tenant Name         ₱1,500.00    │
│ Blue Haven Dormitory - Single Room  │
│ Due Date: 2025-10-23                │
│ Method: GCash                       │
│ ┌─────────┐           ┌──────────┐  │
│ │ Pending │           │ View 📄  │  │
│ └─────────┘           └──────────┘  │
│ ┌─────────────┐  ┌──────────────┐  │
│ │ ❌ Reject   │  │ ✅ Complete  │  │
│ └─────────────┘  └──────────────┘  │
└─────────────────────────────────────┘
```

### Receipt Dialog
```
┌─────────────────────────────────────┐
│ Payment Receipt                  ✕  │
├─────────────────────────────────────┤
│ Tenant:     John Doe                │
│ Dorm:       Blue Haven Dormitory    │
│ Room:       Single Room             │
│ Amount:     ₱1,500.00               │
│ Due Date:   2025-10-23              │
│ Status:     pending                 │
│                                     │
│ Receipt Image:                      │
│ ┌─────────────────────────────────┐ │
│ │                                 │ │
│ │      [Receipt Image Here]       │ │
│ │                                 │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────┐  ┌──────────────┐  │
│ │ ❌ Reject   │  │ ✅ Complete  │  │
│ └─────────────┘  └──────────────┘  │
└─────────────────────────────────────┘
```

## Backend Changes

### File: `owner_payments_api.php`

Added POST request handling for payment actions:

```php
POST /owner_payments_api.php
Content-Type: application/json

{
  "action": "complete" | "reject",
  "payment_id": 123,
  "owner_email": "owner@example.com"
}
```

**Actions:**

1. **Complete Payment:**
```php
UPDATE payments 
SET status = 'paid', 
    payment_date = NOW(),
    updated_at = NOW()
WHERE payment_id = ?
```

2. **Reject Payment:**
```php
UPDATE payments 
SET status = 'rejected',
    updated_at = NOW()
WHERE payment_id = ?
```

**Security:**
- Verifies owner owns the payment through dorm ownership
- Returns 403 if payment not found or access denied
- Logs all payment actions

## Frontend Changes

### File: `payment_service.dart`

Added two new methods:

#### 1. `completePayment()`
```dart
Future<Map<String, dynamic>> completePayment(
  int paymentId, 
  String ownerEmail
) async
```
- Makes POST request to mark payment as paid
- Returns success/error result
- Includes debug logging

#### 2. `rejectPayment()`
```dart
Future<Map<String, dynamic>> rejectPayment(
  int paymentId, 
  String ownerEmail
) async
```
- Makes POST request to reject payment
- Returns success/error result
- Includes debug logging

### File: `owner_payments_screen.dart`

**State Management:**
```dart
final Set<int> _processingPayments = {};
```
- Tracks payments currently being processed
- Prevents double-clicks
- Shows loading states

**Enhanced Methods:**

1. **`_onMarkAsPaid()`**
   - Async implementation
   - Shows loading state
   - Displays success/error messages
   - Auto-refreshes list
   - Prevents duplicate requests

2. **`_onRejectPayment()`**
   - Shows confirmation dialog
   - Async implementation
   - Shows loading state
   - Displays success/error messages
   - Auto-refreshes list

3. **`_onViewReceipt()`**
   - Shows full-screen dialog
   - Displays payment details
   - Shows receipt image
   - Loads image from server
   - Error handling for missing images
   - Quick action buttons for pending payments

4. **`_getFilteredPayments()`**
   - Enhanced filter logic
   - Groups similar statuses
   - Case-insensitive matching
   - Search functionality

### File: `payment_card.dart`

**New Properties:**
```dart
final VoidCallback? onReject;
```

**Enhanced Action Section:**
```dart
Widget _buildStatusAndAction() {
  return Column(
    children: [
      // Status badge and View button
      Row(...)
      
      // Action buttons (only for pending)
      if (isPending) 
        Row(
          children: [
            Reject Button,
            Complete Button,
          ]
        )
    ]
  );
}
```

## Payment Status Flow

### Complete Status Flow:
```
pending → [Owner clicks Complete] → paid
         → payment_date updated
         → appears in "Completed" filter
```

### Reject Status Flow:
```
pending → [Owner clicks Reject] → rejected
         → appears in "Failed" filter
```

## Error Handling

### Network Errors:
```dart
try {
  final result = await _paymentService.completePayment(...);
  // Handle result
} catch (e) {
  ScaffoldMessenger.showSnackBar(
    SnackBar(content: Text('Error: $e'))
  );
}
```

### No Receipt Available:
```dart
if (receiptImage == null || receiptImage.isEmpty) {
  showSnackBar('No receipt available');
  return;
}
```

### Image Load Failure:
```dart
Image.network(
  url,
  errorBuilder: (context, error, stackTrace) {
    return ErrorWidget('Failed to load receipt');
  }
)
```

## Testing Scenarios

### Test 1: Complete Payment
1. **Login as owner**
2. **Go to Payments screen**
3. **Find pending payment**
4. **Click "Complete" button**
5. **Verify**: Status changes to "paid"
6. **Verify**: Payment appears in "Completed" filter
7. **Verify**: Payment_date is updated

### Test 2: Reject Payment
1. **Find pending payment**
2. **Click "Reject" button**
3. **Confirm in dialog**
4. **Verify**: Status changes to "rejected"
5. **Verify**: Payment appears in "Failed" filter

### Test 3: View Receipt
1. **Find any payment**
2. **Click "View" button**
3. **Verify**: Dialog opens with details
4. **Verify**: Receipt image loads (if available)
5. **If pending**: Complete/Reject buttons visible
6. **If completed/rejected**: No action buttons

### Test 4: Filters
1. **Click "All" filter**: See all payments
2. **Click "Pending" filter**: See only pending/submitted
3. **Click "Completed" filter**: See only paid/completed
4. **Click "Failed" filter**: See only failed/rejected

### Test 5: Search
1. **Type tenant name**: Filter by name
2. **Type dorm name**: Filter by dorm
3. **Combine with filter**: Both filters apply

### Test 6: No Receipt
1. **Find payment without receipt**
2. **Click "View"**
3. **Verify**: "No receipt available" message shows

## API Response Examples

### Success Response:
```json
{
  "ok": true,
  "message": "Payment marked as completed"
}
```

### Error Response:
```json
{
  "ok": false,
  "error": "Payment not found or access denied"
}
```

### Payment List Response:
```json
{
  "ok": true,
  "stats": {
    "monthly_revenue": 15000.00,
    "pending_amount": 4500.00
  },
  "payments": [
    {
      "payment_id": 1,
      "tenant_name": "John Doe",
      "dorm_name": "Blue Haven",
      "room_type": "Single Room",
      "amount": "1500.00",
      "status": "pending",
      "due_date": "2025-10-23",
      "payment_date": "2025-10-16",
      "receipt_image": "receipt_123.jpg"
    }
  ]
}
```

## Receipt Image URL Format
```
http://cozydorms.life/uploads/receipts/[receipt_image]
```

## Benefits

### For Owners:
✅ **Quick payment verification** - View receipts instantly
✅ **Easy payment completion** - One-click marking as paid
✅ **Reject invalid payments** - Handle disputes easily
✅ **Better organization** - Functional filters
✅ **Search capability** - Find payments quickly
✅ **Clear status tracking** - Visual status badges

### For System:
✅ **Proper workflow** - Complete payment lifecycle
✅ **Audit trail** - All actions logged
✅ **Data integrity** - Status updates tracked
✅ **Better UX** - Loading states and confirmations
✅ **Error handling** - Graceful error messages

## Summary

✅ **View Receipt** - Full payment details with image
✅ **Complete Payment** - Mark as paid with confirmation
✅ **Reject Payment** - Reject with confirmation dialog
✅ **Functional Filters** - Group similar statuses
✅ **Search** - By tenant or dorm name
✅ **Loading States** - Prevent double-clicks
✅ **Error Handling** - User-friendly messages
✅ **Auto-refresh** - List updates after actions

The owner payment screen is now fully functional with complete payment management capabilities! 🎉
