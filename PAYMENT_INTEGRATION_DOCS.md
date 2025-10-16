# Payment System Integration - Mobile App

## Overview
Successfully integrated the payment system from the website into the mobile app with full database synchronization.

## APIs Created

### 1. Student Payments API
**File:** `Main/modules/mobile-api/student_payments_api.php`
**Endpoint:** `GET http://cozydorms.life/modules/mobile-api/student_payments_api.php?student_email={email}`

**Features:**
- Fetches all payments for a student
- Calculates payment statistics (pending count, overdue count, total due, paid amount)
- Includes booking and dorm details
- Calculates days until due or days overdue
- Marks overdue payments
- Returns receipt URLs

**Response Format:**
```json
{
  "ok": true,
  "statistics": {
    "pending_count": 1,
    "overdue_count": 1,
    "total_due": 2000,
    "paid_amount": 4000,
    "total_payments": 2
  },
  "payments": [
    {
      "payment_id": 13,
      "amount": 2000,
      "status": "pending",
      "due_date": "2025-10-14",
      "dorm_name": "Anna's Haven Dormitory",
      "room_type": "Single",
      "is_overdue": true,
      "receipt_url": null,
      "due_status": "1 days overdue"
    }
  ]
}
```

### 2. Upload Receipt API
**File:** `Main/modules/mobile-api/upload_receipt_api.php`
**Endpoint:** `POST http://cozydorms.life/modules/mobile-api/upload_receipt_api.php`

**Features:**
- Accepts base64-encoded images
- Validates payment ownership and status
- Saves receipt to `uploads/receipts/` directory
- Updates payment status to 'submitted'
- Returns receipt URL

**Request Format:**
```json
{
  "payment_id": 13,
  "student_email": "student@email.com",
  "receipt_base64": "data:image/jpeg;base64,...",
  "receipt_filename": "receipt.jpg"
}
```

**Response Format:**
```json
{
  "ok": true,
  "message": "Receipt uploaded successfully. Awaiting admin confirmation.",
  "payment_id": 13,
  "receipt_url": "http://cozydorms.life/uploads/receipts/receipt_13_1234567890.jpg"
}
```

## Mobile UI

### Student Payments Screen
**File:** `mobile/lib/MobileScreen/student_payments.dart`

**Features:**
1. **Statistics Dashboard**
   - Pending payments count
   - Overdue payments count
   - Total amount due
   - Total amount paid

2. **Payment List**
   - Dorm name and address
   - Room type
   - Payment amount
   - Due date with countdown/overdue indicator
   - Status badges (Pending, Submitted, Paid, Rejected, Expired)
   - Color-coded status indicators

3. **Actions**
   - Upload receipt for pending payments (image picker integration)
   - View receipt for submitted/paid payments
   - Pull to refresh

4. **Status Indicators**
   - 🟢 Green for Paid
   - 🟠 Orange for Pending
   - 🔵 Blue for Submitted
   - 🔴 Red for Rejected/Overdue
   - ⚪ Grey for Expired

## Integration with Student Home

The payments screen is accessible from:
- Quick action button on student home screen
- Shows "Payments Due" count in statistics

## Dependencies Added

**pubspec.yaml:**
```yaml
image_picker: ^1.0.7
```

## Database Schema

The system uses the existing `payments` table:
- `payment_id`: Primary key
- `booking_id`: Foreign key to bookings
- `student_id`: Foreign key to users
- `owner_id`: Foreign key to users (dorm owner)
- `amount`: Payment amount (decimal)
- `status`: enum('pending','paid','expired','rejected','submitted')
- `payment_date`: Timestamp of payment
- `due_date`: Payment due date
- `receipt_image`: Filename of uploaded receipt
- `notes`: Optional notes
- `reminder_sent`: Boolean flag for reminders

## How It Works

1. **Student Views Payments**
   - Opens payments screen from student home
   - API fetches all payments with full details
   - Statistics calculated and displayed
   - Payments sorted by creation date (newest first)

2. **Student Uploads Receipt**
   - Clicks "Upload Receipt" on pending payment
   - Selects image from gallery (using image_picker)
   - Image converted to base64
   - Sent to upload API
   - Status changes to "submitted"
   - Admin can then verify and approve

3. **Payment Status Flow**
   ```
   pending → [student uploads] → submitted → [admin approves] → paid
                                           ↘ [admin rejects] → rejected
   ```

4. **Overdue Detection**
   - Automatically calculated based on due_date vs current date
   - Marked with red indicator
   - Shows "X days overdue"

## Testing

Tested with:
- **Student Email:** chloe.manalo@email.net
- **Result:** Successfully retrieved 2 payments
  - 1 pending (overdue)
  - 1 paid

## Files Modified/Created

1. ✅ `Main/modules/mobile-api/student_payments_api.php` - Created
2. ✅ `Main/modules/mobile-api/upload_receipt_api.php` - Updated
3. ✅ `mobile/lib/MobileScreen/student_payments.dart` - Created
4. ✅ `mobile/lib/MobileScreen/student_home.dart` - Updated
5. ✅ `mobile/pubspec.yaml` - Updated

## Next Steps

1. Test receipt upload functionality on mobile device
2. Add PDF receipt viewer support
3. Add payment history filtering
4. Add push notifications for payment reminders
5. Add in-app receipt preview before upload
