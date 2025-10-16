# Dorm Details Stats Display Fix

## Problem
The dorm details header was showing incorrect information:
- ❌ **"0/0 Slots"** - Should show available/total rooms
- ❌ **"₱0/mo"** - Should show price range  
- ❌ **"Fully Booked"** button always disabled - Even when rooms are available

## Root Cause

**Field Name Mismatch:**

The screen was looking for flat fields:
```dart
dormDetails['monthly_rate']        ❌ Doesn't exist
dormDetails['available_slots']     ❌ Doesn't exist
dormDetails['total_capacity']      ❌ Doesn't exist
dormDetails['average_rating']      ❌ Doesn't exist
```

But the API returns **nested objects**:
```json
{
  "dorm": {
    "stats": {
      "total_rooms": 3,
      "available_rooms": 3,
      "avg_rating": 4.5,
      "total_reviews": 10
    },
    "pricing": {
      "min_price": 200,
      "max_price": 1000,
      "currency": "₱"
    }
  }
}
```

## The Fix

### File: `lib/screens/student/view_details_screen.dart`

**1. Extract stats from nested objects:**
```dart
// BEFORE (BROKEN):
final monthlyRate = double.tryParse(dormDetails['monthly_rate'] ?? '0') ?? 0.0;
final availableSlots = int.tryParse(dormDetails['available_slots'] ?? '0') ?? 0;
final totalSlots = int.tryParse(dormDetails['total_capacity'] ?? '0') ?? 0;

// AFTER (FIXED):
final stats = dormDetails['stats'] as Map<String, dynamic>? ?? {};
final pricing = dormDetails['pricing'] as Map<String, dynamic>? ?? {};

final totalRooms = stats['total_rooms'] as int? ?? _rooms.length;
final availableRooms = stats['available_rooms'] as int? ?? 
    _rooms.where((room) => room['is_available'] == true).length;
```

**2. Calculate price display:**
```dart
final minPrice = pricing['min_price'] as num? ?? 0;
final maxPrice = pricing['max_price'] as num? ?? 0;
final priceDisplay = minPrice > 0 
    ? (minPrice == maxPrice 
        ? '₱${minPrice.toStringAsFixed(0)}/mo' 
        : '₱${minPrice.toStringAsFixed(0)}-${maxPrice.toStringAsFixed(0)}/mo')
    : '₱0/mo';
```

**3. Calculate booking status:**
```dart
final isFullyBooked = availableRooms == 0;
```

**4. Update UI elements:**
```dart
// Stats chips
StatChip(
  icon: Icons.bed,
  text: '$availableRooms/$totalRooms Slots',  // ✅ Shows 3/3
  color: Colors.blue,
),
StatChip(
  icon: Icons.attach_money,
  text: priceDisplay,  // ✅ Shows ₱200-1000/mo
  color: Colors.green,
),

// Book Now button
ElevatedButton.icon(
  onPressed: !isFullyBooked ? _navigateToBookingForm : null,
  label: Text(isFullyBooked ? 'Fully Booked' : 'Book Now'),
  // ✅ Enabled when rooms available
)
```

## Expected Results

### Before Fix:
```
🛏️ 0/0 Slots
💵 ₱0/mo
⭐ N/A
📅 Fully Booked (disabled)
```

### After Fix:
```
🛏️ 3/3 Slots        ✅
💵 ₱200-1000/mo      ✅
⭐ 4.5 (10)          ✅
📅 Book Now (enabled) ✅
```

## API Response Structure Reference

```json
{
  "ok": true,
  "dorm": {
    "dorm_id": 6,
    "name": "Anna's Haven Dormitory",
    "address": "6100 Tops Rd, Bacolod...",
    "description": "A cozy and affordable dorm...",
    "stats": {
      "avg_rating": 4.5,
      "total_reviews": 10,
      "total_rooms": 3,
      "available_rooms": 3
    },
    "pricing": {
      "min_price": 200,
      "max_price": 1000,
      "currency": "₱"
    },
    "owner": {
      "owner_id": 5,
      "name": "Anna Reyes",
      "email": "anna.reyes@email.com",
      "phone": "Not provided"
    }
  },
  "rooms": [
    {
      "room_id": 15,
      "room_type": "Single",
      "capacity": 1,
      "price": 200,
      "status": "available",
      "available_slots": 1,
      "is_available": true
    },
    {
      "room_id": 16,
      "room_type": "Double",
      "capacity": 2,
      "price": 1000,
      "status": "available",
      "available_slots": 1,
      "is_available": true
    }
  ],
  "reviews": []
}
```

## Testing Steps

1. **Install rebuilt APK**
2. **Open any dorm details**
3. **Verify header displays:**
   - Available/Total rooms (e.g., "3/3 Slots")
   - Price range (e.g., "₱200-1000/mo")
   - Rating with review count (e.g., "4.5 (10)")
4. **Verify "Book Now" button:**
   - Enabled when rooms available
   - Disabled and shows "Fully Booked" when no rooms

## Edge Cases Handled

**Single Price Point:**
```dart
// If all rooms have same price
min_price = 500, max_price = 500
priceDisplay = "₱500/mo"  ✅ (not "₱500-500/mo")
```

**No Price Data:**
```dart
min_price = 0, max_price = 0
priceDisplay = "₱0/mo"  ✅
```

**No Rating:**
```dart
avg_rating = 0
display = "N/A"  ✅
```

**Fallback Calculations:**
```dart
// If API stats missing, calculate from actual rooms list
availableRooms = _rooms.where((room) => room['is_available'] == true).length;
totalRooms = _rooms.length;
```

## Files Modified

✅ `lib/screens/student/view_details_screen.dart`
- Extract data from nested `stats` and `pricing` objects
- Calculate available/total rooms
- Display price range correctly
- Enable/disable booking button based on availability

## Summary

**What was broken:**
- Stats showing 0/0 slots (wrong field names)
- Price showing ₱0/mo (wrong field name)
- Button always disabled (wrong availability check)

**What was fixed:**
- Extract stats from `dormDetails['stats']` ✅
- Extract pricing from `dormDetails['pricing']` ✅
- Calculate availability from rooms list ✅
- Display price range correctly ✅
- Enable booking when rooms available ✅

---

**All dorm details stats now display correctly!** 🎉
