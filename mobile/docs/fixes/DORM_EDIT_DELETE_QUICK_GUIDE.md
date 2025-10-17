# Dorm Management Quick Reference

## 🎯 What Was Fixed

**Problem:** Dorms don't show on Browse Dorms because of invalid Google Maps locations.

**Solution:** Added edit/delete buttons + Google Maps location picker for all dorm operations.

---

## ✅ New Features

### 1. Edit Dorm ✅
- Tap **blue pencil icon** on dorm card
- Update any field (name, address, description, features)
- **Use Google Maps to fix/update location**
- Drag marker or search address
- Save changes

### 2. Delete Dorm ✅
- Tap **red trash icon** on dorm card
- Confirmation dialog appears
- Deletes dorm + all rooms + all bookings
- Cannot be undone

### 3. Location Picker (Add & Edit) ✅
Both dialogs now include:
- **Interactive Google Maps**
- **Draggable marker** for precise location
- **Address search** to find location
- **Current location button** (GPS)
- **Auto-fill address** from map
- **Validation** ensures location exists

---

## 📱 How to Use

### Fix Existing Dorms (Invalid Location)

**Problem:** Old dorm doesn't show on Browse Dorms map

**Solution:**
1. Login as dorm owner
2. Go to **Manage Dorms**
3. Find the dorm with missing location
4. Tap **Edit icon** (blue pencil)
5. Scroll to **Dorm Location** section
6. Use one of these methods:
   - **Search:** Type address in search bar
   - **Drag:** Drag the red marker to correct spot
   - **GPS:** Tap "Use Current Location" button
7. Verify address auto-fills correctly
8. Tap **Update Dorm**
9. ✅ Dorm now shows on Browse Dorms map!

### Add New Dorm (With Valid Location)

1. Go to **Manage Dorms**
2. Tap **+ button** (floating action button)
3. Fill in dorm details
4. Scroll to **Dorm Location**
5. Select location on map (search, drag, or GPS)
6. Verify coordinates and address
7. Tap **Add Dorm**
8. ✅ Dorm appears with valid location

### Edit Dorm Details

1. Tap **Edit icon** on any dorm card
2. Change any field you want
3. Update location if needed
4. Tap **Update Dorm**

### Delete Dorm

1. Tap **Delete icon** on dorm card
2. Read confirmation (shows dorm name)
3. Tap **Delete** to confirm
4. ⚠️ This removes dorm, rooms, and bookings
5. Cannot be undone

---

## 🗺️ Location Picker Tips

### Methods to Select Location

**1. Address Search:**
```
Type: "123 Main Street, Manila"
→ Map centers on address
→ Marker placed automatically
→ Address fills in field
```

**2. GPS Current Location:**
```
Tap "Use Current Location" button
→ Gets your GPS coordinates
→ Centers map on your location
→ Use if you're at the dorm
```

**3. Drag Marker:**
```
Tap and hold marker
→ Drag to exact location
→ Address updates automatically
→ Most precise method
```

**4. Tap Map:**
```
Tap anywhere on map
→ Marker moves there
→ Address geocodes
→ Quick selection
```

---

## 🎨 UI Elements

### Dorm Card (Manage Dorms)
```
┌──────────────────────────────┐
│ Cozy Place Dorm         ✏️ 🗑️│
│ 123 Main St, Manila          │
│ Comfortable dormitory...     │
│ [Manage Rooms]               │
└──────────────────────────────┘
   ✏️ = Edit    🗑️ = Delete
```

### Edit Dialog
```
┌─────────────────────────────┐
│ Edit Dormitory              │
├─────────────────────────────┤
│ Dorm Name: [...]            │
│ Address: [...]              │
│ Description: [...]          │
│ Features: [...]             │
│                             │
│ Dorm Location ✓             │
│ [Google Maps with Marker]   │
│ Lat: 14.5995  Lng: 120.9842 │
│                             │
│ [Cancel]    [Update Dorm]   │
└─────────────────────────────┘
```

---

## ⚠️ Important Notes

### Location is Required
- ❌ Cannot add/update dorm without location
- ✅ Ensures all dorms show on Browse Dorms
- ✅ Enables "Near Me" feature
- ✅ Accurate distance calculations

### Delete is Permanent
- Deletes dorm
- Deletes all rooms in dorm
- Deletes all bookings/reservations
- **Cannot be undone**
- Use with caution

### Address Auto-fill
- When you select location on map
- Address automatically fills in
- You can still edit it manually
- But coordinates come from map

---

## 🐛 Troubleshooting

### "Please select a location on the map"
**Problem:** Tried to save without selecting location

**Solution:** 
- Use map to select location
- Drag marker, search address, or use GPS
- Green checkmark appears when location set

### Dorm still doesn't show on Browse Dorms
**Problem:** Location might still be invalid

**Solution:**
1. Edit the dorm again
2. Verify latitude/longitude are not null
3. Use map to select proper location
4. Make sure address is in correct format
5. Save and refresh Browse Dorms

### Map shows wrong location
**Problem:** Old dorm has incorrect coordinates

**Solution:**
1. Edit the dorm
2. Map shows current (wrong) location
3. Search for correct address
4. Or drag marker to correct spot
5. Save updated location

### Can't delete dorm
**Problem:** API error or network issue

**Solution:**
- Check internet connection
- Try again later
- Check if dorm has active bookings
- Contact support if persists

---

## 📊 Backend Files Created

### API Endpoints (Already Created)
1. **update_dorm_api.php** - Updates dorm details
2. **delete_dorm_api.php** - Deletes dorm and related data
3. **add_dorm_api.php** - Enhanced with location support

### Database Columns Used
```sql
latitude  DECIMAL(10,8)  -- GPS latitude
longitude DECIMAL(11,8)  -- GPS longitude
```

---

## 🚀 Testing Steps

### Test Edit with Location Fix
1. ✅ Open Manage Dorms
2. ✅ Find dorm without location
3. ✅ Tap Edit icon
4. ✅ See existing data loaded
5. ✅ Map shows (or shows fallback)
6. ✅ Search for address
7. ✅ Verify map updates
8. ✅ Verify address fills
9. ✅ Tap Update Dorm
10. ✅ See success message
11. ✅ Open Browse Dorms (student)
12. ✅ Verify dorm now appears on map

### Test Delete
1. ✅ Tap Delete icon
2. ✅ See confirmation dialog
3. ✅ Verify dorm name shown
4. ✅ Tap Cancel → nothing happens
5. ✅ Tap Delete again
6. ✅ Tap Delete button
7. ✅ See success message
8. ✅ Dorm removed from list

---

## 💡 Pro Tips

### For Accurate Location
- Use street view in Google Maps (web) first
- Copy exact address
- Paste in search box
- Verify marker placement
- Fine-tune with drag if needed

### For Existing Dorms
- Edit one by one
- Start with most popular dorms
- Notify students when done
- Check Browse Dorms to verify

### For New Dorms
- Always use location picker
- Never skip location
- Verify address matches physical location
- Test in Browse Dorms after adding

---

## ✅ Benefits

### For Owners
- ✅ Fix all invalid locations
- ✅ Update dorm info anytime
- ✅ Visual location selection
- ✅ No technical knowledge needed

### For Students
- ✅ All dorms show on map
- ✅ Accurate locations
- ✅ "Near Me" works correctly
- ✅ Better browsing experience

### For System
- ✅ Data integrity
- ✅ Complete CRUD operations
- ✅ Better maps integration
- ✅ Reduced support issues

---

**Status:** ✅ Ready to use  
**No compilation errors**  
**Backend APIs created**  
**Ready for testing on device**

---

*This solves the "dorms don't show up" issue by ensuring all dorms have valid Google Maps locations!*
