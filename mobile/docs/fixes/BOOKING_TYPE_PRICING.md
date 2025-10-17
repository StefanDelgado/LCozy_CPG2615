# Booking Type Price Calculation - Complete Implementation

## Overview
Implemented dynamic price calculation based on booking type:
- **Shared Booking**: Price is divided by room capacity
- **Whole Room Booking**: Student pays the full room price

## Changes Made

### 1. Backend API Updates

#### File: `Main/modules/mobile-api/create_booking_api.php`

**Added Price Calculation Logic:**
```php
// Calculate price based on booking type
$base_price = (float)$booking['base_price'];
$capacity = (int)$booking['capacity'];

if ($booking_type === 'shared' && $capacity > 0) {
    // For shared booking, divide price by room capacity
    $calculated_price = $base_price / $capacity;
} else {
    // For whole room booking, use full price
    $calculated_price = $base_price;
}
```

**API Response Now Includes:**
- `base_price`: Original room price
- `capacity`: Room capacity
- `price`: Calculated price based on booking type

#### File: `Main/modules/mobile-api/owner_bookings_api.php`

**Updated SQL Query:**
```sql
SELECT 
    ...
    r.price as base_price,
    r.capacity,
    b.booking_type,
    ...
```

**Added Same Price Calculation:**
```php
// Calculate price based on booking type
$base_price = (float)$b['base_price'];
$capacity = (int)$b['capacity'];
$booking_type = strtolower($b['booking_type'] ?? 'shared');

if ($booking_type === 'shared' && $capacity > 0) {
    $calculated_price = $base_price / $capacity;
} else {
    $calculated_price = $base_price;
}
```

**API Response Now Includes:**
- `booking_type`: "Whole" or "Shared"
- `base_price`: Original room price
- `capacity`: Room capacity
- `price`: Calculated price (formatted with ₱)

### 2. Owner's Booking Screen Updates

#### File: `mobile/lib/widgets/owner/bookings/booking_card.dart`

**Added Booking Type Display:**
```dart
final bookingType = booking['booking_type']?.toString() ?? 'Shared';

// In the card layout:
_InfoRow(label: 'Dorm', value: dormName),
_InfoRow(label: 'Room', value: roomType),
_InfoRow(label: 'Type', value: bookingType),  // ← NEW
_InfoRow(label: 'Duration', value: duration),
_InfoRow(label: 'Price', value: price),
```

**Now Shows:**
- ✅ Dorm name
- ✅ Room type
- ✅ **Booking Type** (Shared/Whole) - NEW
- ✅ Duration
- ✅ **Calculated Price** (based on booking type)

### 3. Student Booking Form Updates

#### File: `mobile/lib/screens/student/booking_form_screen.dart`

**Enhanced Booking Summary:**
```dart
_buildInfoRow('Room Type', selectedRoom!['room_type']),
_buildInfoRow('Booking Type', bookingType.toUpperCase()),
_buildInfoRow('Room Capacity', '${selectedRoom!['capacity']} person(s)'),
_buildInfoRow('Base Price', '₱${selectedRoom!['price']}/month'),

// Show calculated price based on booking type
if (bookingType == 'shared')
  _buildInfoRow(
    'Your Share',
    '₱${(price / capacity).toStringAsFixed(2)}/month',
    highlight: true,
  )
else
  _buildInfoRow(
    'Total Price',
    '₱${selectedRoom!['price']}/month',
    highlight: true,
  ),
```

**Updated _buildInfoRow Method:**
```dart
Widget _buildInfoRow(String label, String value, {bool highlight = false}) {
  // Highlights price in green with larger font
}
```

## Price Calculation Examples

### Example 1: Shared Booking
- **Room Base Price**: ₱6,000/month
- **Room Capacity**: 4 persons
- **Booking Type**: Shared
- **Student Pays**: ₱6,000 ÷ 4 = **₱1,500/month** ✅

### Example 2: Whole Room Booking
- **Room Base Price**: ₱6,000/month
- **Room Capacity**: 4 persons
- **Booking Type**: Whole
- **Student Pays**: **₱6,000/month** ✅

### Example 3: Single Room
- **Room Base Price**: ₱3,000/month
- **Room Capacity**: 1 person
- **Booking Type**: Shared (only option)
- **Student Pays**: ₱3,000 ÷ 1 = **₱3,000/month** ✅

## UI Display Updates

### Owner's Booking Screen
**Before:**
```
Dorm: Cozy Dorm
Room: Standard Room
Duration: 6 months
Price: ₱6,000.00
```

**After:**
```
Dorm: Cozy Dorm
Room: Standard Room
Type: Shared          ← NEW
Duration: 6 months
Price: ₱1,500.00      ← CALCULATED (6000÷4)
```

### Student's Booking Form
**Before:**
```
Room Type: Standard Room
Booking Type: SHARED
Monthly Rate: ₱6,000
```

**After:**
```
Room Type: Standard Room
Booking Type: SHARED
Room Capacity: 4 person(s)          ← NEW
Base Price: ₱6,000/month            ← NEW (shows full price)
Your Share: ₱1,500.00/month         ← NEW (highlighted in green)
```

## Benefits

### For Students:
✅ **Clear Price Transparency** - See both base price and what they'll actually pay
✅ **Easy Comparison** - Compare shared vs whole room costs
✅ **No Surprises** - Know exact monthly payment upfront
✅ **Highlighted Price** - Important price info stands out

### For Owners:
✅ **See Booking Type** - Know if student booked shared or whole room
✅ **Accurate Pricing** - System calculates correct price automatically
✅ **Better Tracking** - Can see what each student is paying
✅ **Fair Distribution** - Shared rooms divide cost evenly

### For System:
✅ **Automated Calculation** - No manual price adjustments needed
✅ **Consistent Logic** - Same calculation in all APIs
✅ **Accurate Records** - Correct prices stored and displayed
✅ **Scalable** - Works for any room capacity

## Testing Scenarios

Test the following cases:

### 1. Shared Booking (Capacity > 1)
- **Room**: 4-person capacity, ₱8,000 base price
- **Booking Type**: Shared
- **Expected Result**: Student sees ₱2,000/month
- **Owner Sees**: Type: Shared, Price: ₱2,000.00

### 2. Whole Room Booking
- **Room**: 4-person capacity, ₱8,000 base price
- **Booking Type**: Whole
- **Expected Result**: Student sees ₱8,000/month
- **Owner Sees**: Type: Whole, Price: ₱8,000.00

### 3. Single Room
- **Room**: 1-person capacity, ₱3,000 base price
- **Booking Type**: Shared (only option)
- **Expected Result**: Student sees ₱3,000/month
- **Owner Sees**: Type: Shared, Price: ₱3,000.00

### 4. Mixed Bookings
- Create multiple bookings with different types
- Verify each shows correct price
- Check pending and approved tabs both display correctly

## API Response Structure

### Create Booking Response:
```json
{
  "ok": true,
  "message": "Booking request submitted successfully!",
  "booking": {
    "booking_id": 123,
    "status": "pending",
    "booking_type": "shared",
    "base_price": 6000,
    "capacity": 4,
    "price": 1500.00
  }
}
```

### Get Bookings Response:
```json
{
  "ok": true,
  "bookings": [
    {
      "booking_id": 123,
      "booking_type": "Shared",
      "base_price": 6000,
      "capacity": 4,
      "price": "₱1,500.00",
      "duration": "6 months"
    }
  ]
}
```

## Summary

✅ **Price Calculation**: Automatic based on booking type
✅ **Shared Rooms**: Price divided by capacity
✅ **Whole Rooms**: Full price charged
✅ **Owner Display**: Shows booking type and calculated price
✅ **Student Display**: Shows breakdown with highlighted final price
✅ **API Updates**: Both create and fetch endpoints updated
✅ **UI Updates**: Booking cards and forms enhanced

The system now provides complete price transparency and accurate calculations for all booking types!
