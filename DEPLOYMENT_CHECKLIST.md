# 🚀 Quick Deployment Checklist

## Pre-Deployment (Do Once)

### ✅ Step 1: Backup Everything
```bash
# Backup database
mysqldump -u root -p cozydorms > backup_$(date +%Y%m%d_%H%M%S).sql

# Backup files (optional)
cp -r Main/ Main_backup_$(date +%Y%m%d)/
```

### ✅ Step 2: Run Database Migration
```bash
# Option A: Via phpMyAdmin
1. Open http://localhost/phpmyadmin
2. Select 'cozydorms' database
3. Click "SQL" tab
4. Copy entire database_migrations.sql
5. Paste and click "Go"

# Option B: Command Line
mysql -u root -p cozydorms < database_migrations.sql
```

### ✅ Step 3: Verify Migration
```sql
-- Check tables
SHOW TABLES LIKE 'tenants';
SHOW TABLES LIKE 'dorm_images';
SHOW TABLES LIKE 'user_preferences';
SHOW TABLES LIKE 'payment_schedules';

-- Check triggers
SHOW TRIGGERS;

-- Check views
SHOW FULL TABLES WHERE TABLE_TYPE LIKE 'VIEW';

-- Verify data
SELECT COUNT(*) as TotalTenants FROM tenants;
SELECT COUNT(*) as BookingsWithRef FROM bookings WHERE booking_reference IS NOT NULL;
```

### ✅ Step 4: Test Access
```
Login as Owner:
1. Go to: http://localhost/Main/auth/login.php
2. Login with owner credentials
3. Navigate to: Tenant Management
4. Verify page loads correctly
5. Test search function
6. Test quick actions
```

---

## Quick Commands Reference

### Database
```sql
-- View all booking statuses
SELECT booking_id, status, booking_reference FROM bookings;

-- View all payment types
SELECT payment_id, payment_type, status, amount FROM payments ORDER BY created_at DESC LIMIT 10;

-- View active tenants
SELECT * FROM view_active_tenants;

-- View owner stats
SELECT * FROM view_owner_stats WHERE owner_id = ?;
```

### Create Sample Tenant
```sql
-- If you need to manually create a tenant for testing
INSERT INTO tenants (booking_id, student_id, dorm_id, room_id, status, check_in_date, expected_checkout)
SELECT b.booking_id, b.student_id, r.dorm_id, b.room_id, 'active', b.start_date, b.end_date
FROM bookings b
JOIN rooms r ON b.room_id = r.room_id
WHERE b.booking_id = ? AND b.status = 'approved';
```

### Create Payment with Type
```php
// Downpayment
$stmt = $pdo->prepare("
  INSERT INTO payments (booking_id, student_id, owner_id, amount, payment_type, due_date, status)
  VALUES (?, ?, ?, ?, 'downpayment', ?, 'pending')
");

// Monthly
$stmt = $pdo->prepare("
  INSERT INTO payments (booking_id, student_id, owner_id, amount, payment_type, due_date, status)
  VALUES (?, ?, ?, ?, 'monthly', ?, 'pending')
");
```

---

## Status Reference

### Booking Status
```
pending     → Waiting for owner approval
approved    → Owner approved, waiting for payment/move-in
active      → Student has moved in (currently occupying)
completed   → Tenancy ended normally
rejected    → Owner declined
cancelled   → Student cancelled
```

### Payment Status
```
pending     → Payment not yet made
submitted   → Receipt uploaded by student
processing  → Owner reviewing receipt
paid        → Owner confirmed payment
verified    → System/admin verified
expired     → Past due date
rejected    → Invalid receipt/payment
```

### Tenant Status
```
active      → Currently occupying room
completed   → Tenancy ended normally
terminated  → Early termination
```

### Payment Types
```
downpayment → Initial deposit before move-in (REQUIRED)
monthly     → Regular monthly rent (RECURRING)
utility     → Electricity, water, internet bills
deposit     → Security/damage deposit (REFUNDABLE)
other       → Miscellaneous fees
```

---

## Navigation Paths

### Owner Menu
```
Dashboard         → /Main/dashboards/owner_dashboard.php
Tenant Management → /Main/modules/owner/owner_tenants.php  ✨ NEW
Manage Dorms      → /Main/modules/owner/owner_dorms.php
Bookings          → /Main/modules/owner/owner_bookings.php
Payments          → /Main/modules/owner/owner_payments.php
Messages          → /Main/modules/owner/owner_messages.php
Announcements     → /Main/modules/owner/owner_announcements.php
```

---

## Troubleshooting

### Issue: "Table 'tenants' doesn't exist"
**Fix:** Run database migration script

### Issue: "No tenants showing"
**Fix:** Check if bookings are approved:
```sql
-- See approved bookings
SELECT * FROM bookings WHERE status = 'approved';

-- Manually create tenant records if needed
INSERT INTO tenants (booking_id, student_id, dorm_id, room_id, status, check_in_date, expected_checkout)
SELECT b.booking_id, b.student_id, r.dorm_id, b.room_id, 'active', b.start_date, b.end_date
FROM bookings b
JOIN rooms r ON b.room_id = r.room_id
WHERE b.status = 'approved';
```

### Issue: "Payment type not showing"
**Fix:** Check column exists:
```sql
SHOW COLUMNS FROM payments LIKE 'payment_type';

-- If doesn't exist, run migration again
```

### Issue: "Triggers not working"
**Fix:** Check triggers exist:
```sql
SHOW TRIGGERS;

-- If missing, run the trigger section from migration script
```

---

## Files Checklist

### ✅ Created
- [x] `database_migrations.sql`
- [x] `Main/modules/owner/owner_tenants.php`
- [x] `IMPLEMENTATION_GUIDE.md`
- [x] `IMPLEMENTATION_SUMMARY.md`
- [x] `SYSTEM_ARCHITECTURE.md`
- [x] `DEPLOYMENT_CHECKLIST.md` (this file)

### ✅ Modified
- [x] `Main/dashboards/owner_dashboard.php`
- [x] `Main/partials/header.php`

---

## Testing Checklist

### Database
- [ ] Backup created
- [ ] Migration executed successfully
- [ ] All tables exist (tenants, dorm_images, etc.)
- [ ] Triggers created (3 triggers)
- [ ] Views created (3 views)
- [ ] Sample data in tenants table

### Tenant Management Page
- [ ] Page loads without errors
- [ ] Statistics display correctly
- [ ] Current tenants tab shows data
- [ ] Past tenants tab shows data
- [ ] Search works
- [ ] Status badges correct colors
- [ ] Message button works
- [ ] View Payments button works
- [ ] Responsive on mobile

### Navigation
- [ ] Dashboard has "View Tenants" button
- [ ] Sidebar has "Tenant Management" link
- [ ] Links go to correct page
- [ ] Access restricted to owners only

### Workflow
- [ ] New booking creates tenant (when approved)
- [ ] Payment updates tenant.total_paid
- [ ] Completed booking updates tenant status
- [ ] Booking reference generated (BK00000001)
- [ ] Payment types selectable

---

## One-Line Deployment

For quick deployment (after backup):

```bash
mysql -u root -p cozydorms < database_migrations.sql && echo "✅ Migration Complete! Test at: http://localhost/Main/modules/owner/owner_tenants.php"
```

---

## Emergency Rollback

If something goes wrong:

```sql
-- Restore from backup
mysql -u root -p cozydorms < backup_YYYYMMDD_HHMMSS.sql

-- OR drop new objects only
DROP TABLE IF EXISTS payment_schedules;
DROP TABLE IF EXISTS user_preferences;
DROP TABLE IF EXISTS dorm_images;
DROP TABLE IF EXISTS tenants;
DROP TRIGGER IF EXISTS create_tenant_on_booking_approved;
DROP TRIGGER IF EXISTS update_tenant_paid_on_payment;
DROP TRIGGER IF EXISTS update_tenant_on_booking_complete;
DROP VIEW IF EXISTS view_tenant_payments;
DROP VIEW IF EXISTS view_owner_stats;
DROP VIEW IF EXISTS view_active_tenants;
```

---

## Success Indicators

### ✅ You'll know it's working when:
1. Tenant Management page loads without errors
2. You see tenant cards with information
3. Search filters results instantly
4. Quick action buttons work
5. Statistics show real numbers
6. No PHP errors in error log

---

## Support

### Documentation
- `IMPLEMENTATION_GUIDE.md` - Full implementation details
- `IMPLEMENTATION_SUMMARY.md` - Quick summary
- `SYSTEM_ARCHITECTURE.md` - Visual diagrams
- `OWNER_FEATURES_PARITY.md` - Feature comparison

### Key Files
- Database: `database_migrations.sql`
- Tenant Page: `Main/modules/owner/owner_tenants.php`
- Owner Dashboard: `Main/dashboards/owner_dashboard.php`
- Header: `Main/partials/header.php`

---

## What's Next?

### Phase 2: Location Picker (Next Priority)
- [ ] Get Google Maps API key
- [ ] Create location picker widget
- [ ] Update dorm creation form
- [ ] Add address autocomplete
- [ ] Save lat/lng to database

**Estimated Time:** 6-8 hours  
**Priority:** HIGH 🔴

---

**Quick Start:**
1. Backup database ✅
2. Run migration script ✅
3. Login as owner ✅
4. Test tenant page ✅
5. Done! 🎉

---

**Created:** October 18, 2025  
**Status:** READY FOR DEPLOYMENT ✅
