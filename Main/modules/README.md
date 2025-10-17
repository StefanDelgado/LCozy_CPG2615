# Modules Directory Organization

This directory contains all the feature modules for the CozyDorms system, organized by role and function.

## Directory Structure

### 📁 admin/
**Administrator-only modules**
- `admin_payments.php` - Payment management and oversight
- `admin_reviews.php` - Review moderation
- `announcements.php` - System-wide announcements
- `booking_oversight.php` - Booking management and approval
- `map_radius.php` - Map settings and radius configuration
- `owner_verification.php` - Dorm owner verification process
- `post_reservation.php` - Post-booking management
- `reports.php` - Analytics and reporting
- `room_management.php` - Room inventory oversight
- `system_config.php` - System configuration settings
- `user_management.php` - User account management

### 📁 owner/
**Dorm owner modules**
- `owner_announcements.php` - Owner announcements dashboard
- `owner_bookings.php` - Manage property bookings
- `owner_dorms.php` - Dormitory listing management
- `owner_messages.php` - Owner messaging interface
- `owner_payments.php` - Payment tracking for owners
- `owner_reviews.php` - Review management for properties

### 📁 student/
**Student user modules**
- `student_announcements.php` - View announcements
- `student_messages.php` - Student messaging interface
- `student_payments.php` - Payment history and management
- `student_receipt.php` - Receipt viewing/download
- `student_reservations.php` - Booking and reservation management
- `student_reviews.php` - Submit and view reviews

### 📁 shared/
**Common modules accessible by multiple roles**
- `available_dorms.php` - Browse available dormitories
- `dorm_details.php` - Detailed dorm information page
- `dorm_listings.php` - Dorm listing view
- `download.php` - File download handler
- `messaging.php` - Messaging system interface
- `payments.php` - Payment processing
- `upload_receipt.php` - Receipt upload functionality

### 📁 api/
**API endpoints and AJAX handlers**
- `expire_bookings.php` - Booking expiration cron job
- `fetch_messages.php` - AJAX message fetching
- `fetch_payments.php` - AJAX payment data retrieval

### 📁 mobile-api/
**Mobile app API endpoints** (Previously organized)
- Contains 10 feature-based subdirectories for Flutter app integration

## Path Updates Required

After reorganization, all links to these files need to be updated:

### Old Format:
```php
<a href="../modules/admin_payments.php">Payments</a>
```

### New Format:
```php
<a href="../modules/admin/admin_payments.php">Payments</a>
```

## Files by Feature

### 💳 Payments
- Admin: `admin/admin_payments.php`
- Owner: `owner/owner_payments.php`
- Student: `student/student_payments.php`
- Shared: `shared/payments.php`, `shared/upload_receipt.php`
- API: `api/fetch_payments.php`

### 💬 Messaging
- Owner: `owner/owner_messages.php`
- Student: `student/student_messages.php`
- Shared: `shared/messaging.php`
- API: `api/fetch_messages.php`

### 🏠 Dormitories
- Owner: `owner/owner_dorms.php`
- Shared: `shared/available_dorms.php`, `shared/dorm_details.php`, `shared/dorm_listings.php`

### 📝 Bookings & Reservations
- Admin: `admin/booking_oversight.php`, `admin/post_reservation.php`
- Owner: `owner/owner_bookings.php`
- Student: `student/student_reservations.php`
- API: `api/expire_bookings.php`

### ⭐ Reviews
- Admin: `admin/admin_reviews.php`
- Owner: `owner/owner_reviews.php`
- Student: `student/student_reviews.php`

### 📢 Announcements
- Admin: `admin/announcements.php`
- Owner: `owner/owner_announcements.php`
- Student: `student/student_announcements.php`

## Naming Convention

Files follow the pattern: `{role}_{feature}.php`
- **role**: admin, owner, student, or omitted for shared
- **feature**: descriptive feature name

## Last Updated
October 18, 2025 - Initial organization
