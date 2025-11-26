# Checkout API Documentation

This directory contains mobile API endpoints for the checkout functionality in the CozyDorms system.

## Overview

The checkout system allows tenants to request checkout from their active bookings, and owners to approve/disapprove/complete these requests through a three-stage workflow.

## Workflow

```
1. Tenant: Request Checkout (active/approved booking)
   ↓
2. Owner: Approve or Disapprove
   ↓ (if approved)
3. Owner: Mark as Complete
   ↓
4. Tenant moved to Past Tenants
```

## API Endpoints

### 1. Request Checkout (Student/Tenant)

**Endpoint:** `POST /mobile-api/checkout/request_checkout.php`

**Description:** Submit a checkout request for an active booking.

**Request Body:**
```json
{
  "student_id": 123,
  "booking_id": 456,
  "reason": "Optional reason for checkout"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Checkout request submitted successfully",
  "data": {
    "request_id": 789,
    "booking_id": 456,
    "status": "requested",
    "created_at": "2025-11-26 10:30:00"
  }
}
```

**Error Responses:**
- `400` - Missing required fields
- `400` - Booking status doesn't allow checkout
- `400` - Checkout request already exists
- `404` - Booking not found
- `500` - Server error

---

### 2. Get Student Bookings

**Endpoint:** `GET /mobile-api/checkout/get_student_bookings.php?student_id=123`

**Description:** Get all active bookings for a student (for checkout request screen).

**Success Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "booking_id": 456,
      "room_id": 18,
      "dorm_id": 5,
      "dorm_name": "Sunshine Dorms",
      "dorm_address": "123 Main St",
      "room_type": "Single",
      "booking_type": "shared",
      "price": 3000.00,
      "start_date": "2025-01-01",
      "end_date": "2025-07-01",
      "status": "active",
      "created_at": "2025-01-01 09:00:00",
      "can_request_checkout": true,
      "checkout_status": null,
      "checkout_requested_at": null
    }
  ],
  "count": 1
}
```

---

### 3. Get Owner's Checkout Requests

**Endpoint:** `GET /mobile-api/checkout/get_owner_requests.php?owner_id=123`

**Description:** Get all checkout requests for properties owned by this owner.

**Success Response (200):**
```json
{
  "success": true,
  "data": {
    "all": [ /* array of all requests */ ],
    "grouped": {
      "pending": [ /* requests with status 'requested' */ ],
      "approved": [ /* requests with status 'approved' */ ],
      "completed": [ /* requests with status 'completed' */ ],
      "disapproved": [ /* requests with status 'disapproved' */ ]
    }
  },
  "count": {
    "total": 10,
    "pending": 3,
    "approved": 2,
    "completed": 4,
    "disapproved": 1
  }
}
```

**Request Object Structure:**
```json
{
  "request_id": 789,
  "booking_id": 456,
  "tenant_id": 123,
  "tenant_name": "John Doe",
  "tenant_email": "john@example.com",
  "dorm_id": 5,
  "dorm_name": "Sunshine Dorms",
  "dorm_address": "123 Main St",
  "room_id": 18,
  "room_type": "Single",
  "price": 3000.00,
  "booking_type": "shared",
  "start_date": "2025-01-01",
  "end_date": "2025-07-01",
  "request_reason": "Moving to another city",
  "status": "requested",
  "booking_status": "checkout_requested",
  "created_at": "2025-11-26 10:30:00",
  "updated_at": "2025-11-26 10:30:00",
  "processed_at": null,
  "processed_by": null,
  "can_approve": true,
  "can_complete": false
}
```

---

### 4. Approve Checkout Request

**Endpoint:** `POST /mobile-api/checkout/approve_checkout.php`

**Description:** Approve a pending checkout request (Owner only).

**Request Body:**
```json
{
  "request_id": 789,
  "owner_id": 123
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Checkout request approved successfully",
  "data": {
    "request_id": 789,
    "booking_id": 456,
    "status": "approved",
    "processed_at": "2025-11-26 11:00:00"
  }
}
```

**Side Effects:**
- Updates `checkout_requests.status` to `'approved'`
- Updates `bookings.status` to `'checkout_approved'`
- Sends notification message to tenant

---

### 5. Disapprove Checkout Request

**Endpoint:** `POST /mobile-api/checkout/disapprove_checkout.php`

**Description:** Disapprove/reject a pending checkout request (Owner only).

**Request Body:**
```json
{
  "request_id": 789,
  "owner_id": 123
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Checkout request disapproved",
  "data": {
    "request_id": 789,
    "booking_id": 456,
    "status": "disapproved",
    "processed_at": "2025-11-26 11:00:00"
  }
}
```

**Side Effects:**
- Updates `checkout_requests.status` to `'disapproved'`
- Reverts `bookings.status` back to `'active'`
- Sends notification message to tenant

---

### 6. Complete Checkout

**Endpoint:** `POST /mobile-api/checkout/complete_checkout.php`

**Description:** Mark an approved checkout as completed (Owner only). This finalizes the checkout process.

**Request Body:**
```json
{
  "request_id": 789,
  "owner_id": 123
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Checkout completed successfully. Tenant moved to past tenants.",
  "data": {
    "request_id": 789,
    "booking_id": 456,
    "status": "completed",
    "processed_at": "2025-11-26 12:00:00"
  }
}
```

**Side Effects:**
- Updates `checkout_requests.status` to `'completed'`
- Updates `bookings.status` to `'completed'`
- Sets `bookings.end_date` if not already set
- Updates `tenants.status` to `'completed'` (if table exists)
- Sets `tenants.checkout_date` to current date
- Sends final notification message to tenant

**Validation:**
- Request must be in `'approved'` status (cannot skip approval step)
- Only the property owner can complete

---

### 7. Get Past Tenants

**Endpoint:** `GET /mobile-api/checkout/get_past_tenants.php?owner_id=123`

**Description:** Get historical data of completed checkouts (Owner only).

**Success Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "tenant_id": 50,
      "booking_id": 456,
      "tenant_name": "John Doe",
      "tenant_email": "john@example.com",
      "dorm_id": 5,
      "dorm_name": "Sunshine Dorms",
      "dorm_address": "123 Main St",
      "room_id": 18,
      "room_type": "Single",
      "booking_type": "shared",
      "price": 3000.00,
      "check_in_date": "2025-01-01",
      "checkout_date": "2025-11-26",
      "duration_days": 329,
      "total_paid": 18000.00,
      "outstanding_balance": 0.00,
      "payment_status": "complete"
    }
  ],
  "count": 1
}
```

---

## Database Tables Used

### `checkout_requests`
- `id` - Primary key
- `booking_id` - Foreign key to bookings
- `tenant_id` - Foreign key to users (student)
- `owner_id` - Foreign key to users (owner)
- `request_reason` - Optional text reason
- `status` - enum: 'requested', 'approved', 'disapproved', 'completed'
- `processed_by` - User ID who processed
- `created_at`, `updated_at`, `processed_at` - Timestamps

### `bookings`
Status values used in checkout:
- `active` / `approved` - Can request checkout
- `checkout_requested` - Request submitted
- `checkout_approved` - Owner approved
- `completed` - Checkout finalized

### `tenants`
- Records are created when booking is approved
- Updated to `status='completed'` when checkout finalized
- `checkout_date` set to current date

### `messages`
- Automatic notifications sent at each stage:
  - Tenant requests → Owner notified
  - Owner approves → Tenant notified
  - Owner disapproves → Tenant notified
  - Owner completes → Tenant notified

---

## Security & Validation

All endpoints include:
- ✅ **Authorization checks** - Verify user owns the resource
- ✅ **Input validation** - Required fields checked
- ✅ **Status validation** - Prevent invalid state transitions
- ✅ **SQL injection protection** - Prepared statements used
- ✅ **Transaction safety** - ROLLBACK on errors
- ✅ **Error logging** - All exceptions logged

---

## Status Transition Rules

| Current Status | Allowed Actions | New Status |
|---------------|----------------|------------|
| requested | approve | approved |
| requested | disapprove | disapproved |
| approved | complete | completed |
| disapproved | - | (final) |
| completed | - | (final) |

---

## Integration Notes

### For Mobile App Developers:

1. **Student Screens:**
   - Bookings list (show checkout status badge)
   - Request checkout form (with optional reason field)
   - Checkout request status view

2. **Owner Screens:**
   - Pending requests list (with approve/disapprove buttons)
   - Approved requests list (with complete button)
   - Past tenants history

3. **Notifications:**
   - Display message notifications for checkout updates
   - Consider push notifications for real-time alerts

4. **Error Handling:**
   - Handle 400 errors (validation failures)
   - Handle 404 errors (not found)
   - Handle 500 errors (server errors)
   - Display user-friendly error messages

---

## Testing

Use tools like Postman or curl to test endpoints:

```bash
# Test request checkout
curl -X POST http://localhost/mobile-api/checkout/request_checkout.php \
  -H "Content-Type: application/json" \
  -d '{"student_id":123,"booking_id":456,"reason":"Moving out"}'

# Test get requests
curl http://localhost/mobile-api/checkout/get_owner_requests.php?owner_id=123
```

---

## Change Log

**v1.0.0** - 2025-11-26
- Initial implementation
- All 7 endpoints created
- Transaction safety added
- Notification system integrated
