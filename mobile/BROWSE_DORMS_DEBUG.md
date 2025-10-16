# Student Browse Dorms Debug Enhancement

## Added Comprehensive Debug Logging

### 1. Browse Dorms Screen (`browse_dorms_screen.dart`)

**fetchDorms() Debug Output:**
```
🔵 [Browse] Starting fetchDorms for user: ethan.castillo@email.com
🔵 [Browse] Calling provider.fetchAllDorms...
📊 [Browse] Fetched X dorms from provider
📍 [Browse] First dorm details:
   - ID: 6
   - Name: Anna's Haven Dormitory
   - Address: 12th Street, Lacson Extension, Bacolod City
   - Latitude: 10.676500
   - Longitude: 122.950900
   - Full data: {...}
⚠️ [Browse] No dorms returned from provider!
   - Provider error: ...
   - Provider loading: ...
🔍 [Browse] Applying search filter: "search term"
🔍 [Browse] After search filter: X dorms
✅ [Browse] Set state with X dorms
```

**_applyNearMeFilter() Debug Output:**
```
📍 [Filter] Starting Near Me filter...
📍 [Filter] User location: LatLng(...)
📍 [Filter] Radius: 5.0 km
📍 [Filter] Total dorms to filter: X
   ⚠️ Dorm "Blue Haven Dormitory" has no valid location (lat: null, lng: null)
   ✅ Dorm "Anna's Haven Dormitory" is 2.34 km away (within radius)
📊 [Filter] Results:
   - Valid locations: X
   - Invalid locations: X
   - Within radius: X
✅ [Filter] Applied Near Me filter, showing X dorms
```

### 2. Dorm Provider (`dorm_provider.dart`)

**fetchAllDorms() Debug Output:**
```
🔵 [Provider] fetchAllDorms called with email: ethan.castillo@email.com
🔵 [Provider] Calling dormService.getAllDorms...
🔵 [Provider] Service returned: {success, data, message}
✅ [Provider] Success! Got X dorms
   First dorm: Anna's Haven Dormitory (ID: 6)
❌ [Provider] Failed: error message
❌ [Provider] Exception: exception details
```

### 3. Dorm Service (`dorm_service.dart`)

**getAllDorms() Debug Output (Already Existed):**
```
🌐 API Call: http://cozydorms.life/modules/mobile-api/student_dashboard_api.php?student_email=...
📡 Response Status: 200
📦 Response Body: {...}
📊 Decoded data type: _Map<String, dynamic>
✅ Found dorms in Map: X dorms
✅ Found dorms as List: X dorms
⚠️ Map without dorms key. Keys: [...]
⚠️ Unknown data format
```

## What to Check

### Test Steps:
1. **Login as student** → ethan.castillo@email.com
2. **Navigate to Browse Dorms**
3. **Check terminal output** for debug logs

### Expected Debug Flow:
```
🔵 [Browse] Starting fetchDorms for user: ethan.castillo@email.com
  ↓
🔵 [Provider] fetchAllDorms called with email: ethan.castillo@email.com
  ↓
🔵 [Provider] Calling dormService.getAllDorms...
  ↓
🌐 API Call: http://cozydorms.life/.../student_dashboard_api.php?student_email=...
  ↓
📡 Response Status: 200
📦 Response Body: {...}
  ↓
📊 Decoded data type: _Map<String, dynamic>
  ↓
✅ Found dorms in Map: 13 dorms
  ↓
✅ [Provider] Success! Got 13 dorms
  ↓
📊 [Browse] Fetched 13 dorms from provider
  ↓
📍 [Browse] First dorm details: {...}
  ↓
✅ [Browse] Set state with 13 dorms
```

## Common Issues to Look For

### Issue 1: No Dorms Returned
**Debug Output:**
```
⚠️ [Browse] No dorms returned from provider!
   - Provider error: ...
```
**Check:**
- API response format
- Student email parameter
- Database data

### Issue 2: Dorms Filtered Out by Location
**Debug Output:**
```
📊 [Filter] Results:
   - Valid locations: 0
   - Invalid locations: 13
```
**Reason:**
- Dorms have null/zero lat/lng
- Need to update locations via Edit Dorm

### Issue 3: API Returns Wrong Format
**Debug Output:**
```
⚠️ Map without dorms key. Keys: [ok, data, message]
```
**Reason:**
- API uses different field names
- Need to update DormService parsing

### Issue 4: Search Filter Mismatch
**Debug Output:**
```
🔍 [Browse] Applying search filter: "dormitory"
🔍 [Browse] After search filter: 0 dorms
```
**Reason:**
- Field names don't match (using 'title' vs 'name')
- Already fixed in code: checks both 'title'/'name' and 'location'/'address'

## Fixes Applied

### 1. **Search Filter Field Names**
Changed from only checking 'title' and 'location' to also check 'name' and 'address':
```dart
final t = (p['title'] ?? p['name'] ?? '').toString().toLowerCase();
final l = (p['location'] ?? p['address'] ?? '').toString().toLowerCase();
```

### 2. **Filter Validation Enhancement**
Added check for zero coordinates (not just null):
```dart
if (lat == null || lng == null || lat == 0.0 || lng == 0.0) {
  invalidLocationCount++;
  print('   ⚠️ Dorm has no valid location');
  return false;
}
```

### 3. **Comprehensive Logging**
Added logging at every step:
- Screen level (Browse)
- Provider level
- Service level (already existed)
- Filter level

## Next Steps

1. **Run the app** with hot restart
2. **Login as student** (ethan.castillo@email.com)
3. **Navigate to Browse Dorms**
4. **Copy terminal output** and share
5. **Analyze logs** to find the issue

## Possible Outcomes

### Scenario A: API Not Returning Dorms
```
📡 Response Status: 200
📦 Response Body: {"dorms": []}
✅ Found dorms in Map: 0 dorms
```
**Fix:** Check API endpoint and database

### Scenario B: Dorms Have No Location
```
📊 [Browse] Fetched 13 dorms
📍 [Filter] Invalid locations: 13
```
**Fix:** Use Edit Dorm to set locations

### Scenario C: Field Name Mismatch
```
📍 [Browse] First dorm details:
   - Name: undefined
   - Address: undefined
```
**Fix:** Check actual field names in API response

### Scenario D: Everything Works
```
✅ [Browse] Set state with 13 dorms
   ✅ Dorm "Anna's Haven" is 2.34 km away
```
**Success:** Dorms showing correctly!
