# Booking Duration Display Fix

## Problem
When viewing booking requests, the "Duration" field was showing "whole" instead of the actual booking period (e.g., "6 months").

## Root Cause

The `owner_bookings_api.php` was incorrectly mapping the `booking_type` field (which stores "whole" or "shared") to the `duration` field shown in the UI.

### Original Query:
```sql
SELECT 
    ...
    b.booking_type as duration,  -- ❌ WRONG: Maps "whole/shared" to duration
    b.start_date,
    ...
```

### Original Formatting:
```php
'duration' => $b['duration'] ?? 'Not specified',  // Shows "whole" or "shared"
```

## Solution

### 1. Fixed SQL Query
Added `end_date` to the query and kept `booking_type` separate:

```sql
SELECT 
    ...
    b.booking_type,        -- ✅ Keep as booking type
    b.start_date,          -- ✅ Start date
    b.end_date,            -- ✅ End date (added)
    ...
```

### 2. Calculate Duration Properly
Now calculates the actual duration from date range:

```php
// Calculate duration from start_date and end_date
$duration = 'Not specified';
if (!empty($b['start_date']) && !empty($b['end_date'])) {
    $start = new DateTime($b['start_date']);
    $end = new DateTime($b['end_date']);
    $interval = $start->diff($end);
    
    $months = $interval->m + ($interval->y * 12);
    $days = $interval->d;
    
    if ($months > 0) {
        $duration = $months . ' month' . ($months > 1 ? 's' : '');
        if ($days > 0) {
            $duration .= ' ' . $days . ' day' . ($days > 1 ? 's' : '');
        }
    } else if ($days > 0) {
        $duration = $days . ' day' . ($days > 1 ? 's' : '');
    }
}
```

### 3. Added Booking Type Field
Separated booking type from duration:

```php
return [
    ...
    'booking_type' => ucfirst($b['booking_type'] ?? 'shared'), // 'Whole' or 'Shared'
    'duration' => $duration,                                    // '6 months' or '180 days'
    'start_date' => $b['start_date'],
    'end_date' => $b['end_date'] ?? null,
    ...
];
```

## API Response Changes

### Before:
```json
{
  "booking_type": "whole",
  "duration": "whole",        // ❌ Wrong data
  "start_date": "2025-01-15"
}
```

### After:
```json
{
  "booking_type": "Whole",            // ✅ Correct: Room booking type
  "duration": "6 months",             // ✅ Correct: Calculated duration
  "start_date": "2025-01-15",
  "end_date": "2025-07-15"           // ✅ Added: End date
}
```

## Duration Display Examples

| Start Date | End Date | Duration Display |
|------------|----------|------------------|
| 2025-01-15 | 2025-07-15 | "6 months" |
| 2025-01-15 | 2025-07-20 | "6 months 5 days" |
| 2025-01-15 | 2025-02-14 | "30 days" |
| 2025-01-15 | 2025-01-16 | "1 day" |
| 2025-01-15 | 2026-01-15 | "12 months" |

## Benefits

✅ **Duration shows actual time period** - "6 months" instead of "whole"
✅ **Booking type preserved** - Still shows if room is booked as "Whole" or "Shared"
✅ **More informative** - Shows both duration and booking type
✅ **Accurate calculation** - Properly calculates months and days from date range

## Testing

Test the following scenarios:

1. **6-month booking:**
   - Start: 2025-01-15
   - End: 2025-07-15
   - Expected duration: "6 months"

2. **1-year booking:**
   - Start: 2025-01-15
   - End: 2026-01-15
   - Expected duration: "12 months"

3. **Custom duration:**
   - Start: 2025-01-15
   - End: 2025-04-20
   - Expected duration: "3 months 5 days"

4. **Short stay:**
   - Start: 2025-01-15
   - End: 2025-01-30
   - Expected duration: "15 days"

## Fields Now Available

The booking response now includes:
- `booking_type`: "Whole" or "Shared"
- `duration`: Calculated from date range (e.g., "6 months")
- `start_date`: Booking start date
- `end_date`: Booking end date
- `dorm_name`: Dormitory name (fixed in previous update)

All bookings will now display the correct duration immediately!
