# Quick Reference - File Locations

## 🔐 Authentication
```
Main/auth/
├── login.php          → Login page
├── register.php       → Student registration
├── register_admin.php → Admin/Owner registration
├── logout.php         → Logout handler
└── auth.php          → Auth functions
```

**Access:** `http://your-domain/auth/login.php`

## 📊 Dashboards
```
Main/dashboards/
├── admin_dashboard.php    → Admin control panel
├── owner_dashboard.php    → Owner management
└── student_dashboard.php  → Student portal
```

**Access:** `http://your-domain/dashboards/[role]_dashboard.php`

## 🔧 Admin Utilities
```
Main/admin/
├── download_log.php → Download error logs
└── test-pdo.php     → Test database connection
```

## 🌐 Public Pages
```
Main/public/
├── index.html       → Landing page
├── home.html        → Homepage
└── layout-styles.css → Public styles
```

## 📦 Feature Modules
```
Main/modules/
├── available_dorms.php
├── student_reservations.php
├── owner_dorms.php
├── user_management.php
└── ... (20+ module files)
```

**Access:** `http://your-domain/modules/[module_name].php`

## 🧩 Shared Components
```
Main/partials/
├── header.php  → Top navigation & sidebar
├── footer.php  → Footer component
└── sidebar.php → Legacy sidebar
```

## 📁 Other Directories
```
Main/
├── assets/   → CSS, JS, images
├── uploads/  → User uploaded files
├── cgi-bin/  → CGI scripts
└── cron/     → Scheduled tasks
```

## 🔑 Root Level Files
```
Main/
├── config.php → Database configuration
└── index.php  → Entry point (role-based redirect)
```

## 🔗 Path Patterns

### From Auth Files
```php
require_once __DIR__ . '/../config.php';
header('Location: ../dashboards/student_dashboard.php');
```

### From Dashboard Files
```php
require_once __DIR__ . '/../auth/auth.php';
include '../partials/header.php';
```

### From Module Files
```php
require_once __DIR__ . '/../auth/auth.php';
require_once __DIR__ . '/../config.php';
```

### From Partials
```php
require_once __DIR__ . '/../auth/auth.php';
require_once __DIR__ . '/../config.php';
```

## 🌍 Access URLs

### Development (localhost)
```
Login:    http://localhost/auth/login.php
Admin:    http://localhost/dashboards/admin_dashboard.php
Owner:    http://localhost/dashboards/owner_dashboard.php
Student:  http://localhost/dashboards/student_dashboard.php
Modules:  http://localhost/modules/[module].php
```

### Production (cozydorms.life)
```
Login:    https://cozydorms.life/auth/login.php
Admin:    https://cozydorms.life/dashboards/admin_dashboard.php
Owner:    https://cozydorms.life/dashboards/owner_dashboard.php
Student:  https://cozydorms.life/dashboards/student_dashboard.php
Modules:  https://cozydorms.life/modules/[module].php
```

## ⚡ Quick Commands

### Navigate to directories
```powershell
cd "c:\xampp\htdocs\WebDesign_BSITA-2\2nd sem\Joshan_System\LCozy_CPG2615\Main"
cd auth         # Authentication files
cd dashboards   # Dashboard files
cd modules      # Feature modules
cd partials     # Shared components
```

### Find files
```powershell
Get-ChildItem -Recurse -Filter "*dashboard*"
Get-ChildItem auth\*.php
Get-ChildItem modules\*.php
```

### Check for errors
```powershell
# Check PHP syntax
php -l auth/login.php
php -l dashboards/admin_dashboard.php
```

## 🎯 Common Tasks

### Add a new authentication page
1. Create file in `auth/`
2. Use: `require_once __DIR__ . '/../config.php';`
3. Link from: `auth/login.php` or `auth/register.php`

### Add a new dashboard
1. Create file in `dashboards/`
2. Use: `require_once __DIR__ . '/../auth/auth.php';`
3. Include: `'../partials/header.php'`
4. Update `index.php` redirect logic

### Add a new module
1. Create file in `modules/`
2. Use: `require_once __DIR__ . '/../auth/auth.php';`
3. Link from: appropriate dashboard or header menu

### Add a new admin utility
1. Create file in `admin/`
2. Use: `require_once __DIR__ . '/../auth/auth.php';`
3. Add role check: `if ($user['role'] !== 'admin') { die('Access denied'); }`

## 📝 Notes

- **Always use relative paths** from file location
- **Test locally first** before deploying
- **Check file permissions** after moving files
- **Update .htaccess** if using URL rewriting
- **Backup before making changes**

## 🔄 Migration Status

✅ Files organized into directories  
✅ All paths updated  
✅ No syntax errors  
⏳ Testing pending  
⏳ Old files cleanup pending  

---

**Last Updated:** 2024  
**Maintained By:** CozyDorms Development Team
