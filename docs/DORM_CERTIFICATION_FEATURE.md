# Dorm Certification Management Feature

## Overview
This feature allows dorm owners to upload, manage, and display certifications for their dormitories. Certifications include business permits, fire safety certificates, sanitary permits, and other legal documents that verify the dorm's compliance with regulations.

## Features Implemented

### 1. Database Schema
**New Table: `dorm_certifications`**
- `certification_id` (Primary Key)
- `dorm_id` (Foreign Key → dormitories)
- `file_name` (Original filename)
- `file_path` (Server storage path)
- `certification_type` (Business Permit, Fire Safety, etc.)
- `uploaded_at` (Timestamp)

**Location:** `database_updates/add_dorm_certifications.sql`

### 2. Backend API Endpoints

#### Upload Certification
**Endpoint:** `POST /modules/mobile-api/dorms/upload_certification.php`
**Parameters:**
- `dorm_id` (int) - ID of the dorm
- `owner_email` (string) - Owner's email for authorization
- `certification_file` (file) - The certification document
- `certification_type` (string, optional) - Type of certification

**Validation:**
- File types: PDF, JPG, JPEG, PNG
- Max file size: 5MB
- Owner authorization check

**Response:**
```json
{
  "success": true,
  "message": "Certification uploaded successfully",
  "certification_id": 123,
  "file_path": "uploads/certifications/cert_1_abc123.pdf"
}
```

#### Get Certifications
**Endpoint:** `GET /modules/mobile-api/dorms/get_certifications.php?dorm_id=1`
**Parameters:**
- `dorm_id` (int) - ID of the dorm

**Response:**
```json
{
  "success": true,
  "certifications": [
    {
      "certification_id": 1,
      "dorm_id": 1,
      "file_name": "business_permit.pdf",
      "file_path": "uploads/certifications/cert_1_abc123.pdf",
      "certification_type": "Business Permit",
      "uploaded_at": "2025-11-26 10:30:00"
    }
  ],
  "count": 1
}
```

#### Delete Certification
**Endpoint:** `POST /modules/mobile-api/dorms/delete_certification.php`
**Body:**
```json
{
  "certification_id": 123,
  "owner_email": "owner@example.com"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Certification deleted successfully"
}
```

### 3. Mobile App Components

#### CertificationService
**Location:** `mobile/lib/services/certification_service.dart`

**Methods:**
- `uploadCertification()` - Upload a certification file
- `getCertifications()` - Retrieve all certifications for a dorm
- `deleteCertification()` - Delete a certification
- `getCertificationUrl()` - Get public URL for viewing

#### CertificationManagementWidget
**Location:** `mobile/lib/widgets/owner/dorms/certification_management_widget.dart`

**Features:**
- Display list of certifications with icons
- Upload button with file picker
- Certification type selection dialog
- View certification (opens in browser)
- Delete certification with confirmation
- Loading states and error handling

**Props:**
- `dormId` - The dorm ID
- `ownerEmail` - Owner's email for authorization
- `isReadOnly` - Optional, disables editing (default: false)

#### DormDetailsScreen
**Location:** `mobile/lib/screens/owner/dorm_details_screen.dart`

**Features:**
- Display dorm information (name, address, description, features)
- Integrated certification management widget
- Status badges (Active, Deposit info)
- Icon-based information display

### 4. Integration Points

#### DormCard Widget
**Location:** `mobile/lib/widgets/owner/dorms/dorm_card.dart`

**Enhanced with:**
- New `onViewDetails` callback
- "View Details & Certifications" option in menu
- Navigation to DormDetailsScreen

#### OwnerDormsScreen
**Location:** `mobile/lib/screens/owner/owner_dorms_screen.dart`

**Enhanced with:**
- Import of DormDetailsScreen
- `onViewDetails` callback implementation
- Navigation to details screen with owner email

## User Workflow

### Upload Certification
1. Owner navigates to "My Dorms" screen
2. Taps 3-dot menu on dorm card
3. Selects "View Details & Certifications"
4. Taps "+" button in Certifications section
5. Selects file from device (PDF, JPG, PNG)
6. Chooses certification type from dropdown or enters custom name
7. File uploads to server
8. Certification appears in list

### View Certification
1. In dorm details screen
2. Tap "👁️" (eye icon) on certification card
3. File opens in external browser/viewer

### Delete Certification
1. In dorm details screen
2. Tap "🗑️" (delete icon) on certification card
3. Confirm deletion in dialog
4. File removed from server and database

## File Storage

**Directory Structure:**
```
Main/
  uploads/
    certifications/
      cert_1_abc123.pdf
      cert_2_def456.jpg
      cert_3_ghi789.png
```

**Naming Convention:**
`cert_{dormId}_{uniqueId}.{extension}`

## Security Features

1. **Owner Authorization:**
   - All operations verify owner owns the dorm
   - Email-based authentication
   - SQL joins prevent unauthorized access

2. **File Validation:**
   - Allowed types: PDF, JPG, JPEG, PNG only
   - Max size: 5MB
   - MIME type checking

3. **Cascading Deletion:**
   - When dorm is deleted, certifications are automatically removed
   - Foreign key constraint ensures data integrity

## Dependencies

### Mobile (pubspec.yaml)
```yaml
file_picker: ^6.1.1  # For selecting files
url_launcher: ^6.2.1 # For opening documents (already included)
```

### Backend (PHP)
- PDO for database operations
- file_exists(), unlink() for file management
- move_uploaded_file() for uploads

## Database Migration

**Run this SQL:**
```sql
CREATE TABLE IF NOT EXISTS `dorm_certifications` (
  `certification_id` int(11) NOT NULL AUTO_INCREMENT,
  `dorm_id` int(11) NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `certification_type` varchar(100) DEFAULT NULL,
  `uploaded_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`certification_id`),
  KEY `dorm_id` (`dorm_id`),
  CONSTRAINT `dorm_certifications_ibfk_1` 
    FOREIGN KEY (`dorm_id`) 
    REFERENCES `dormitories` (`dorm_id`) 
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
```

**Create Upload Directory:**
```bash
mkdir -p Main/uploads/certifications
chmod 755 Main/uploads/certifications
```

## Testing Checklist

### Backend Testing
- [ ] Upload PDF certification
- [ ] Upload JPG/PNG certification
- [ ] Try uploading >5MB file (should fail)
- [ ] Try uploading .exe or .zip file (should fail)
- [ ] Get certifications for dorm with 0 certs
- [ ] Get certifications for dorm with multiple certs
- [ ] Delete certification
- [ ] Try uploading without authorization (should fail)
- [ ] Try deleting another owner's certification (should fail)

### Mobile Testing
- [ ] View dorm details screen
- [ ] Certification list displays correctly
- [ ] Upload certification flow
- [ ] File picker opens
- [ ] Certification type dialog works
- [ ] View certification (opens in browser)
- [ ] Delete certification with confirmation
- [ ] Empty state displays when no certifications
- [ ] Loading states work properly
- [ ] Error messages display correctly

## Future Enhancements

1. **Certification Verification:**
   - Admin approval workflow
   - Verification status badges
   - Expiration date tracking

2. **Advanced Features:**
   - OCR for automatic document parsing
   - Certification reminders before expiration
   - Download certifications as ZIP
   - Share certifications with potential tenants

3. **UI Improvements:**
   - Preview thumbnails for images
   - PDF preview in-app
   - Drag-and-drop upload
   - Bulk upload multiple files

4. **Analytics:**
   - Track which dorms have complete certifications
   - Generate compliance reports
   - Alert owners of missing certifications

## Error Handling

### Common Errors
1. **"Missing required fields"** - Missing dorm_id or owner_email
2. **"Unauthorized or dorm not found"** - Owner doesn't own this dorm
3. **"Invalid file type"** - File is not PDF/JPG/PNG
4. **"File size exceeds 5MB"** - File too large
5. **"Failed to upload file"** - Server write permissions issue
6. **"Cannot open file"** - URL launcher not installed/configured

## API Response Examples

### Success Response
```json
{
  "success": true,
  "message": "Certification uploaded successfully",
  "certification_id": 5,
  "file_path": "uploads/certifications/cert_15_673f5a8b2d419.pdf"
}
```

### Error Response
```json
{
  "success": false,
  "error": "Invalid file type. Only PDF, JPG, JPEG, and PNG are allowed"
}
```

## File Locations Summary

### Backend PHP Files
```
Main/
├── modules/
│   └── mobile-api/
│       └── dorms/
│           ├── upload_certification.php
│           ├── delete_certification.php
│           └── get_certifications.php
└── uploads/
    └── certifications/
        └── (uploaded files)
```

### Mobile Dart Files
```
mobile/lib/
├── services/
│   └── certification_service.dart
├── widgets/
│   └── owner/
│       └── dorms/
│           └── certification_management_widget.dart
└── screens/
    └── owner/
        └── dorm_details_screen.dart
```

### Database Files
```
database_updates/
└── add_dorm_certifications.sql
```

## Conclusion
This feature provides a comprehensive certification management system for dorm owners, ensuring compliance documentation is easily accessible and manageable through the mobile app. The system is secure, user-friendly, and scalable for future enhancements.
