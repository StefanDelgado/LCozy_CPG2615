# Owner Contract Upload Feature - Complete Implementation

## Overview
Added contract upload and view functionality for dorm owners, providing feature parity with the student contract system. Owners can now upload their copy of the booking contract and view both their contract and the student's contract.

## Feature Highlights

### 1. **Contract Section Display**
- Shows in booking cards for **approved** and **active** bookings only
- Beautiful blue-themed UI with gradient backgrounds and icons
- Displays both student and owner contract status side-by-side

### 2. **Student Contract (View Only)**
- Green-themed icon and accents
- "View" button appears if student has uploaded their contract
- "Not uploaded" text shown if student hasn't uploaded yet
- Opens contract in external viewer when clicked

### 3. **Owner Contract (Upload & View)**
- Blue-themed icon and accents
- Shows "Upload" button if owner hasn't uploaded yet
- After upload, shows two buttons:
  - **View** button - Opens contract in external viewer
  - **Replace** button - Allows uploading a new version
- Supports PDF, JPG, JPEG, PNG files (max 5MB)

## Files Modified

### 1. Backend API: `owner_bookings_api.php`
**Lines 218-221**: Added contract fields to SQL query
```php
b.student_contract_copy,
b.owner_contract_copy
```

**Lines 314-315**: Added to response array
```php
'student_contract_copy' => $b['student_contract_copy'] ?? null,
'owner_contract_copy' => $b['owner_contract_copy'] ?? null
```

### 2. Service Layer: `booking_service.dart`
**Lines 557-621**: Added `uploadOwnerContract()` method
- Uses MultipartRequest for file upload
- Posts to `upload_owner_contract.php`
- Sends: booking_id, owner_email, contract_file
- Returns: success status, message, contract_path
- Includes debug logging

### 3. Widget: `booking_card.dart`
**Line 9**: Added parameter
```dart
final Widget Function(Map<String, dynamic>)? onContractAction;
```

**Line 20**: Added to constructor
```dart
this.onContractAction,
```

**Line 262-270**: Added contract section placeholder
```dart
// Contract Documents Section (for approved or active bookings)
if ((status == 'approved' || status == 'active') && onContractAction != null)
  Padding(
    padding: const EdgeInsets.only(top: 16),
    child: onContractAction!(booking),
  ),
```

### 4. Screen: `owner_booking_screen.dart`
**Lines 1-12**: Added imports
```dart
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../utils/api_constants.dart';
```

**Lines 779-958**: Added three new methods:

#### `_buildContractSection()` (Lines 779-958)
- Builds the contract UI widget
- Shows student and owner contracts
- Color-coded sections (green for student, blue for owner)
- Responsive button states based on upload status

#### `_uploadOwnerContract()` (Lines 960-1026)
- Handles file selection via FilePicker
- Validates file type (PDF, JPG, JPEG, PNG)
- Validates file size (max 5MB)
- Shows progress indicator during upload
- Displays success/error messages
- Refreshes bookings after successful upload

#### `_viewContract()` (Lines 1028-1058)
- Opens contracts in external viewer
- Constructs full URL using ApiConstants
- Handles errors gracefully
- Shows appropriate error messages

**Lines 1252-1254**: Added callback to BookingCard
```dart
onContractAction: (status == 'approved' || status == 'active')
    ? (booking) => _buildContractSection(booking)
    : null,
```

## UI Design Details

### Contract Section Layout
```
┌─────────────────────────────────────────┐
│ 📄 Booking Contracts                    │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 🎓 Student Contract:    [👁️ View]  │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 🏢 Your Contract:    [📤 Upload]   │ │
│ │                    or               │ │
│ │                [👁️ View] [🔄 Replace] │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

### Color Scheme
- **Container**: Blue gradient (Blue[50] to Blue[100])
- **Border**: Blue[200] with shadow
- **Header Icon**: Blue gradient (Blue[600] to Blue[700])
- **Student Section**: Green accents (Green[700])
- **Owner Section**: Blue accents (Blue[600])
- **Buttons**: Material Design elevated buttons

## Validation & Error Handling

### File Upload Validations
1. **File Type**: Only PDF, JPG, JPEG, PNG allowed
2. **File Size**: Maximum 5MB
3. **User Cancellation**: Handled gracefully (no error message)
4. **Network Errors**: Shows error snackbar with details

### Error Messages
- ❌ "File size exceeds 5MB limit" - Red snackbar
- ❌ "Failed to upload contract" - Red snackbar
- ❌ "Error picking file: [details]" - Red snackbar
- ❌ "Contract not available" - Orange snackbar
- ❌ "Error opening contract: [details]" - Red snackbar

### Success Messages
- ✅ "Contract uploaded successfully" - Green snackbar (2 seconds)

## User Experience Flow

### For New Bookings (No Contracts)
1. Booking appears in "Approved" tab
2. Contract section shows below booking info
3. Student contract shows "Not uploaded"
4. Owner contract shows "Upload" button
5. Owner clicks "Upload"
6. File picker opens (PDF/Image)
7. Owner selects file
8. System validates and uploads
9. Success message appears
10. UI refreshes showing "View" and "Replace" buttons

### For Existing Contracts
1. Both contracts show "View" buttons
2. Click "View" to open in external app
3. Owner can click "Replace" to upload new version
4. Same validation and upload flow applies

## Technical Details

### API Endpoint Used
- **Upload**: `POST /modules/mobile-api/owner/upload_owner_contract.php`
- **Fields**: booking_id, owner_email, contract_file
- **Response**: JSON with success, message, contract_path

### File Storage
- **Location**: `uploads/contracts/owner/`
- **Naming**: System generates unique filenames
- **Database**: Path stored in `bookings.owner_contract_copy`

### URL Construction
```dart
final fullUrl = '${ApiConstants.baseUrl}/$contractPath';
// Example: http://cozydorms.life/uploads/contracts/owner/booking_123_owner.pdf
```

## Dependencies (Already Installed)
- `file_picker: ^8.1.2` - For file selection
- `url_launcher: ^6.2.1` - For opening documents
- `dart:io` - For file operations

## Testing Checklist

### Basic Functionality
- [x] Contract section only appears for approved/active bookings
- [x] Student contract displays correctly
- [x] Owner can upload contract (PDF)
- [x] Owner can upload contract (JPG/PNG)
- [x] Owner can view uploaded contract
- [x] Owner can replace contract
- [x] File size validation works (5MB limit)
- [x] File type validation works

### UI States
- [x] No contracts uploaded (both null)
- [x] Only student contract uploaded
- [x] Only owner contract uploaded
- [x] Both contracts uploaded
- [x] Loading indicator during upload
- [x] Buttons disabled during processing

### Error Handling
- [x] File picker cancelled
- [x] File too large selected
- [x] Invalid file type selected
- [x] Network error during upload
- [x] Contract file doesn't exist

### Edge Cases
- [x] Multiple rapid clicks on upload button
- [x] Screen navigation during upload
- [x] Refresh after upload
- [x] Replace with same filename
- [x] Replace with different file type

## Debug Logging

### Upload Process
```
📋 [OwnerBooking] Uploading contract: contract.pdf (245.67 KB)
✅ [OwnerBooking] Contract uploaded successfully
```

### View Process
```
📄 [OwnerBooking] Opening contract: http://cozydorms.life/uploads/contracts/owner/contract.pdf
```

### Error Cases
```
❌ [OwnerBooking] File path is null
❌ [OwnerBooking] Upload failed: [error message]
❌ [OwnerBooking] Error opening contract: [error message]
```

## Database Schema Reference
```sql
-- bookings table columns
student_contract_copy VARCHAR(255) NULL
owner_contract_copy VARCHAR(255) NULL

-- Example values
student_contract_copy: 'uploads/contracts/student/booking_123_student.pdf'
owner_contract_copy: 'uploads/contracts/owner/booking_123_owner.pdf'
```

## Status Summary

### ✅ Completed
1. Backend API returns contract fields
2. Service method for owner upload created
3. Widget parameter added for contract section
4. Contract UI builder implemented with beautiful design
5. File picker integration completed
6. File validation (type and size) implemented
7. Upload handler with error handling
8. View handler with url_launcher
9. Success/error feedback via snackbars
10. Integration with BookingCard widget
11. Proper imports and dependencies configured

### 🎉 Feature Complete!
The owner contract upload feature is now fully functional and matches the student contract system. Owners can upload, view, and replace their contracts for approved and active bookings.

## Future Enhancements (Optional)
- [ ] Add contract preview before upload
- [ ] Add contract download option (save to device)
- [ ] Add contract sharing feature
- [ ] Add contract expiry tracking
- [ ] Add contract template system
- [ ] Add digital signature support
- [ ] Add contract version history
- [ ] Add contract status notifications

## Related Documentation
- See `BOOKING_MANAGEMENT_REDESIGN.md` for overall booking system
- See `DEPOSIT_FEATURE_COMPLETE.md` for payment features
- See `STUDENT_UNREAD_MESSAGES_FIX.md` for messaging system
