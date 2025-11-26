# Certification Feature - Quick Setup Guide

## Step 1: Database Setup

Run the following SQL in your database (phpMyAdmin or MySQL client):

```sql
CREATE TABLE IF NOT EXISTS `dorm_certifications` (
  `certification_id` int(11) NOT NULL AUTO_INCREMENT,
  `dorm_id` int(11) NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `certification_type` varchar(100) DEFAULT NULL COMMENT 'e.g., Business Permit, Fire Safety, Sanitary Permit, etc.',
  `uploaded_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`certification_id`),
  KEY `dorm_id` (`dorm_id`),
  CONSTRAINT `dorm_certifications_ibfk_1` FOREIGN KEY (`dorm_id`) REFERENCES `dormitories` (`dorm_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
```

## Step 2: File Permissions

The uploads directory has been created automatically:
- `Main/uploads/certifications/`

Ensure it has write permissions (already done on Windows/XAMPP).

## Step 3: Mobile App

Dependencies have been installed:
- ✅ file_picker: ^6.1.1

## Step 4: Testing the Feature

### On Mobile App:

1. **Navigate to Dorm Details:**
   - Open app as owner
   - Go to "My Dorms"
   - Tap 3-dot menu on any dorm
   - Select "View Details & Certifications"

2. **Upload Certification:**
   - Tap the "+" button in Certifications section
   - Select a PDF, JPG, or PNG file (<5MB)
   - Choose certification type (e.g., "Business Permit")
   - Wait for upload confirmation

3. **View Certification:**
   - Tap the eye icon (👁️) on any certification
   - File opens in browser/viewer

4. **Delete Certification:**
   - Tap the trash icon (🗑️) on any certification
   - Confirm deletion
   - Certification removed

### Expected Behavior:

✅ **Empty State:** Shows "No certifications uploaded yet"
✅ **Upload Success:** Shows green snackbar "Certification uploaded successfully"
✅ **Upload Error:** Shows red snackbar with error message
✅ **File Validation:** Rejects files >5MB or wrong type
✅ **Authorization:** Only dorm owner can upload/delete

## Step 5: Verify Backend

### Test Upload API:
```bash
# Use Postman or curl
POST http://localhost/modules/mobile-api/dorms/upload_certification.php

Form Data:
- dorm_id: 1
- owner_email: owner@example.com
- certification_file: [select a PDF file]
- certification_type: Business Permit
```

### Test Get Certifications:
```bash
GET http://localhost/modules/mobile-api/dorms/get_certifications.php?dorm_id=1
```

### Test Delete:
```bash
POST http://localhost/modules/mobile-api/dorms/delete_certification.php
Content-Type: application/json

{
  "certification_id": 1,
  "owner_email": "owner@example.com"
}
```

## Common Issues & Solutions

### Issue: "Failed to upload file"
**Solution:** Check that `Main/uploads/certifications/` exists and has write permissions

### Issue: "Unauthorized or dorm not found"
**Solution:** Verify the owner email matches the dorm owner in the database

### Issue: "Invalid file type"
**Solution:** Only PDF, JPG, JPEG, and PNG files are allowed

### Issue: "Cannot open file"
**Solution:** Ensure url_launcher is properly configured in the app

### Issue: File picker not opening
**Solution:** 
- Check file_picker dependency is installed
- Restart the app
- Check device permissions

## Feature Locations

### Backend Files:
```
Main/modules/mobile-api/dorms/
├── upload_certification.php
├── delete_certification.php
└── get_certifications.php
```

### Mobile Files:
```
mobile/lib/
├── services/certification_service.dart
├── widgets/owner/dorms/certification_management_widget.dart
└── screens/owner/dorm_details_screen.dart
```

### Database:
```
database_updates/add_dorm_certifications.sql
```

## Next Steps

1. ✅ Run database migration
2. ✅ Verify directory permissions
3. ✅ Install mobile dependencies (flutter pub get)
4. ⬜ Test on emulator/device
5. ⬜ Test file upload flow
6. ⬜ Test file viewing
7. ⬜ Test file deletion
8. ⬜ Test with different file types
9. ⬜ Test error scenarios

## Certification Types Available

When uploading, owners can select from:
- Business Permit
- Fire Safety Certificate
- Sanitary Permit
- Barangay Clearance
- Building Permit
- Other (custom)

## Security Features

✅ Owner authorization check
✅ File type validation
✅ File size limit (5MB)
✅ Cascading deletion (when dorm is deleted)
✅ SQL injection protection (prepared statements)

## Support

For issues or questions, check:
- Full documentation: `docs/DORM_CERTIFICATION_FEATURE.md`
- Error logs: Check PHP error log and Flutter console
- Database: Verify tables exist and have correct structure
