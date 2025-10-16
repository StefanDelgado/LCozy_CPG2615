# Room Selection UI Quick Fix

## What Was Changed

### 1. Clickable Rooms ✅
Rooms in Rooms tab now navigate to booking form with room pre-selected.

### 2. Improved Selection Colors ✅
Changed from harsh bright orange to soft blue:

**Before:**
- Orange background: `orange.withAlpha(0.1)` ❌
- Orange border ❌
- Orange check icon ❌

**After:**
- Soft blue background: `Colors.blue.shade50` ✅
- Blue border: `Colors.blue.shade600` ✅  
- White check on blue circle ✅
- Elevated appearance ✅

## Files Modified

1. `rooms_tab.dart` - Made clickable, added navigation
2. `booking_form_screen.dart` - Soft blue UI, auto-selection
3. `view_details_screen.dart` - Pass required data

## Testing

1. Open dorm details → Rooms tab
2. Tap any available room
3. Booking form opens with room already selected
4. Selection now uses soft blue (easier on eyes)

---

**Much better visual experience!** 🎨
