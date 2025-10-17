# Web Application Organization Plan

## Current Structure Issues
- 15+ PHP files in root directory
- Mixed authentication, dashboards, and utility files
- Hard to navigate and maintain

## Proposed Organized Structure

```
Main/
├── index.php                    (Entry point - stays in root)
├── config.php                   (Core config - stays in root)
├── .htaccess                    (URL rewriting - will be created)
│
├── public/                      (Publicly accessible files)
│   ├── index.html              (Landing page)
│   ├── home.html               (Home page)
│   ├── 404.shtml               (Error page)
│   └── layout-styles.css       (Public styles)
│
├── auth/                        (Authentication)
│   ├── login.php
│   ├── register.php
│   ├── register_admin.php
│   ├── logout.php
│   └── auth.php                (Auth helper)
│
├── dashboards/                  (Role-based dashboards)
│   ├── admin_dashboard.php     (renamed from dashboard.php)
│   ├── owner_dashboard.php
│   └── student_dashboard.php
│
├── admin/                       (Admin utilities)
│   ├── download_log.php
│   └── test-pdo.php
│
├── assets/                      (CSS, JS, Images - already organized)
├── modules/                     (Feature modules - already organized)
├── partials/                    (Reusable components - already organized)
├── uploads/                     (User uploads - already organized)
├── cron/                        (Scheduled tasks - already organized)
└── cgi-bin/                     (CGI scripts - already organized)
```

## Changes Needed

### 1. Move Files
- `login.php` → `auth/login.php`
- `register.php` → `auth/register.php`
- `register_admin.php` → `auth/register_admin.php`
- `logout.php` → `auth/logout.php`
- `auth.php` → `auth/auth.php`
- `dashboard.php` → `dashboards/admin_dashboard.php`
- `owner_dashboard.php` → `dashboards/owner_dashboard.php`
- `student_dashboard.php` → `dashboards/student_dashboard.php`
- `home.html`, `index.html` → `public/`
- `404.shtml` → `public/`
- `layout-styles.css` → `public/`
- `download_log.php`, `test-pdo.php` → `admin/`

### 2. Update index.php
Update paths to new locations

### 3. Update All PHP Files
Update `require_once` paths to reflect new structure

### 4. Create .htaccess (Optional)
For cleaner URLs and proper routing

## Benefits
- ✅ Organized by functionality
- ✅ Easy to navigate
- ✅ Better security (auth files grouped)
- ✅ Scalable structure
- ✅ Professional organization
