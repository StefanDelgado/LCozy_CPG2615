# Super Admin Quick Setup Guide

## 🚀 5-Minute Installation

Follow these steps to implement the Super Admin system:

---

### Step 1: Run Database Migration (2 minutes)

#### Option A: Using phpMyAdmin (Recommended)
1. Open **phpMyAdmin** in your browser: `http://localhost/phpmyadmin`
2. Click on **cozydorms** database in the left sidebar
3. Click on **Import** tab at the top
4. Click **Choose File** button
5. Navigate to: `database_updates/add_superadmin_system.sql`
6. Click **Go** at the bottom
7. Wait for "Import has been successfully finished" message

#### Option B: Using Command Line
```bash
# Navigate to your project folder
cd c:\xampp\htdocs\WebDesign_BSITA-2\2nd sem\Joshan_System\LCozy_CPG2615

# Run the migration
mysql -u root cozydorms < database_updates\add_superadmin_system.sql
```

---

### Step 2: Verify Installation (1 minute)

Open phpMyAdmin and run these verification queries:

```sql
-- Check super admin exists
SELECT user_id, name, email, role FROM users WHERE role = 'superadmin';
-- Expected: 1 row with user_id = 1, role = 'superadmin'

-- Check new tables exist
SHOW TABLES LIKE 'admin_%';
-- Expected: admin_audit_log, admin_approval_requests, admin_privileges
```

---

### Step 3: Access Super Admin Dashboard (1 minute)

1. **Start your XAMPP** (if not running):
   - Open XAMPP Control Panel
   - Start **Apache** and **MySQL**

2. **Login to the system**:
   - Go to: `http://localhost/WebDesign_BSITA-2/2nd sem/Joshan_System/LCozy_CPG2615/Main/auth/login.php`
   - Login with the **super admin account** (user_id = 1)
   - Usually the first admin account you created

3. **Access Super Admin Panel**:
   - Go to: `http://localhost/.../Main/modules/admin/superadmin_management.php`
   - Or click "Super Admin" link in the admin sidebar

4. **You should see**:
   - Statistics cards at the top
   - Admin approval requests section (may be empty)
   - Admin users list
   - Recent activity audit log

---

### Step 4: Create Test Data (Optional - 1 minute)

To test the system, create a sample admin request:

```sql
-- Create a test admin request (use an existing user_id)
INSERT INTO admin_approval_requests (requester_user_id, reason, status)
VALUES (2, 'Test admin request for demonstration purposes', 'pending');

-- Create a regular admin for testing (use an existing user_id)
UPDATE users SET role = 'admin' WHERE user_id = 3;

-- Grant test privileges
INSERT INTO admin_privileges (admin_user_id, privilege_name, granted_by)
VALUES 
    (3, 'manage_users', 1),
    (3, 'view_reports', 1);
```

Now refresh the super admin dashboard - you should see:
- 1 pending request
- 1 admin user (besides yourself)
- Activity in the audit log

---

## ✅ Quick Test Checklist

Test these features to ensure everything works:

### Super Admin Functions:
1. [ ] Can access `superadmin_management.php` successfully
2. [ ] Statistics display correctly (Total Admins, Pending Requests, etc.)
3. [ ] Can see admin requests (if any)
4. [ ] Can approve an admin request (click Approve button)
5. [ ] Can manage privileges (click Manage button on an admin)
6. [ ] Can revoke admin access (click Revoke button)
7. [ ] Audit log shows all actions

### Security Tests:
1. [ ] Logout and login as a regular admin (role='admin')
2. [ ] Try to access `superadmin_management.php` → Should get "403 Forbidden"
3. [ ] Regular admin cannot see super admin users in lists
4. [ ] User ID 1 cannot be edited or deleted

---

## 🎯 Key URLs

Once installed, bookmark these:

```
Super Admin Dashboard:
http://localhost/.../Main/modules/admin/superadmin_management.php

Admin Management:
http://localhost/.../Main/modules/admin/user_management.php

Your specific path (replace ...):
http://localhost/WebDesign_BSITA-2/2nd sem/Joshan_System/LCozy_CPG2615/Main/modules/admin/superadmin_management.php
```

---

## 📋 Super Admin Privileges

As a super admin, you can now:

### ✅ Approve Admin Requests
- View all pending admin requests
- Approve requests → User becomes admin with default privileges
- Reject requests → User stays as regular user
- See approval history

### ✅ Manage Admin Privileges
Seven (7) privilege types available:
1. **manage_users** - Create, edit, delete users
2. **approve_owners** - Verify owner accounts
3. **manage_reviews** - Moderate reviews
4. **manage_payments** - Handle payment disputes
5. **manage_dorms** - Approve dorm listings
6. **view_reports** - Access analytics
7. **manage_bookings** - Manage booking disputes

### ✅ Revoke Admin Access
- Remove admin privileges completely
- User returns to 'student' role
- All privileges deleted

### ✅ View Audit Logs
- See all admin actions
- Track who did what and when
- IP addresses logged for security

---

## 🔒 Security Features

Your system now has:

✅ **Role Hierarchy**: superadmin > admin > owner > student  
✅ **Privilege Control**: Granular permissions for admins  
✅ **Audit Trail**: Every action logged  
✅ **Protected Super Admin**: Cannot be edited or deleted  
✅ **SQL Injection Prevention**: All queries use prepared statements  
✅ **XSS Protection**: All output escaped  
✅ **Transaction Safety**: Data integrity guaranteed  

---

## 🐛 Troubleshooting

### Problem: "Forbidden: This page is restricted"
**Solution**: You're not logged in as super admin. Check:
```sql
SELECT user_id, email, role FROM users WHERE user_id = 1;
-- Role should be 'superadmin'
```

### Problem: Tables don't exist
**Solution**: Run the migration again:
```bash
mysql -u root cozydorms < database_updates\add_superadmin_system.sql
```

### Problem: User ID 1 is not superadmin
**Solution**: Update manually:
```sql
UPDATE users SET role = 'superadmin' WHERE user_id = 1;
```

### Problem: Page shows errors
**Solution**: Check database connection in `config.php`

### Problem: No statistics showing
**Solution**: Tables are empty initially - that's normal! Create test data.

---

## 📚 Documentation

For detailed information, read:

1. **`docs/SUPER_ADMIN_SYSTEM.md`** - Complete documentation (20+ pages)
   - Full feature explanation
   - Database schema details
   - Security features
   - Usage examples
   - API reference

2. **`docs/SUPER_ADMIN_IMPLEMENTATION.md`** - Implementation summary
   - What was built
   - How it works
   - Testing results
   - Next steps

3. **`database_updates/add_superadmin_system.sql`** - Database schema
   - All table structures
   - Comments explaining each field
   - Sample queries

---

## 🎉 Success!

If you can:
- ✅ Access the super admin dashboard
- ✅ See the statistics cards
- ✅ View the admin list
- ✅ See the audit log

**Congratulations!** 🎊 Your Super Admin system is fully functional!

---

## 💡 Next Steps

### Immediate:
1. Change the super admin password for security
2. Review the documentation
3. Test all features with real data

### Soon:
1. Create additional admin users
2. Assign specific privileges to each admin
3. Monitor the audit log regularly
4. Set up email notifications (future feature)

### Future Enhancements:
1. Admin request form for users (web interface)
2. Mobile app admin management
3. Privilege templates
4. Advanced reporting

---

## 📞 Need Help?

**Common Questions:**

**Q: How do I create a new admin?**  
A: Wait for an admin request, then approve it OR manually update a user:
```sql
UPDATE users SET role = 'admin' WHERE user_id = ?;
```

**Q: Can I have multiple super admins?**  
A: Yes! Update more users to role='superadmin':
```sql
UPDATE users SET role = 'superadmin' WHERE user_id = 5;
```

**Q: How do I check someone's privileges?**  
A: In super admin dashboard OR run:
```sql
SELECT privilege_name FROM admin_privileges WHERE admin_user_id = ?;
```

**Q: What's the default password for user_id = 1?**  
A: Check your database or reset it:
```sql
UPDATE users SET password = ? WHERE user_id = 1;
-- Use password_hash('newpassword', PASSWORD_DEFAULT) for the hash
```

---

**Installation Time**: 5 minutes  
**Difficulty**: Easy  
**Status**: Production Ready ✅  
**Version**: 1.0.0

**Enjoy your new Super Admin system!** 🚀👑
