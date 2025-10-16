# Edit Dorm Location Enhancement

## Problem
Old dorm data in the database only has `address` field but missing `latitude` and `longitude`. When editing these dorms, the location wasn't initialized properly on the map.

## Solution

### 1. **Smart Location Initialization**
The Edit Dorm dialog now:
- ✅ Shows existing address in text field
- ✅ Pre-fills address in map search box
- ✅ Initializes map with lat/lng if available
- ✅ Falls back to current location if no coordinates
- ✅ Shows helpful hints when location is missing

### 2. **Visual Indicators**
Added clear status indicators:
- 🟢 **"Location Set"** - When dorm has valid coordinates
- 🟠 **"No Location"** - When coordinates are missing
- 📍 **Info Box** - Guides user to search address
- 📊 **Coordinates Display** - Shows lat/lng when set

### 3. **User Flow for Old Data**

**When editing a dorm without coordinates:**
1. Dialog opens with address in text field
2. Shows orange warning: "No Location"
3. Displays info box: "Search the address below to set map location"
4. Shows snackbar hint for 4 seconds
5. User can:
   - Type address in map search box → Click search button
   - Or manually edit address field → Search in map
   - Or drag marker to correct location
   - Or use "My Location" button

**After setting location:**
1. Status changes to green "Location Set"
2. Info box disappears
3. Coordinates displayed below address
4. Map marker positioned correctly
5. Address auto-updated from reverse geocoding

## Files Modified

### `lib/widgets/owner/dorms/edit_dorm_dialog.dart`

**Changes:**
1. **Enhanced initState():**
   ```dart
   - Check if lat/lng are zero (0.0) → treat as missing
   - Show snackbar hint if location missing but address exists
   - Guide user to search address in map
   ```

2. **Better Location Section:**
   ```dart
   - Status indicator (green checkmark or orange warning)
   - Info box when location missing
   - Display both address and coordinates
   - Clearer visual hierarchy
   ```

## How It Works

### For Dorms with Location (New Data)
```
latitude: 10.676500
longitude: 122.950900
address: "Lacson Street, Bacolod City"
```
→ Map initializes at correct location ✅

### For Dorms without Location (Old Data)
```
latitude: null or 0
longitude: null or 0
address: "12th Street, Lacson Extension, Bacolod City"
```
→ Shows warning, user searches address, map finds location ✅

## Location Picker Features

The `LocationPickerWidget` already supports:
- 🔍 **Address Search** - Type and search any address
- 📍 **Draggable Marker** - Move marker anywhere
- 🗺️ **Reverse Geocoding** - Get address from marker position
- 📱 **My Location** - Use current GPS location
- ✏️ **Auto-fill** - Selected address fills the main address field

## Testing Steps

1. **Edit Old Dorm (no coordinates):**
   - [ ] Opens with address shown
   - [ ] Shows "No Location" warning
   - [ ] Info box visible
   - [ ] Snackbar hint appears
   - [ ] Search address in map works
   - [ ] Marker appears at correct location
   - [ ] Address field updates
   - [ ] Status changes to "Location Set"
   - [ ] Save updates database with lat/lng

2. **Edit New Dorm (has coordinates):**
   - [ ] Opens with marker at correct position
   - [ ] Shows "Location Set" status
   - [ ] No info box or warnings
   - [ ] Can drag marker to adjust
   - [ ] Can search new address
   - [ ] Updates work properly

3. **Validation:**
   - [ ] Cannot save without selecting location
   - [ ] Shows error if no coordinates set
   - [ ] Coordinates must be valid lat/lng

## Benefits

✅ **Fixes Old Data** - Easy way to add coordinates to existing dorms
✅ **Clear Guidance** - Users know exactly what to do
✅ **Flexible** - Multiple ways to set location
✅ **Visual Feedback** - Status indicators show progress
✅ **Validation** - Ensures location is set before saving
✅ **Sync with Map** - Address field and map stay synchronized

## Database Update

When owner edits and saves:
```sql
UPDATE dormitories 
SET latitude = 10.676500, 
    longitude = 122.950900,
    address = "12th Street, Lacson Extension, Bacolod City"
WHERE dorm_id = 6
```

Now the dorm will show up in:
- Browse Dorms map (student view)
- Dorm listings with proper location
- Google Maps integrations
