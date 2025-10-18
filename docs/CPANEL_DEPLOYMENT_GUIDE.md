# cPanel Deployment Guide - CozyDorms

## 📦 Deployment Configuration

The `.cpanel.yml` file has been updated to deploy your newly organized structure to cPanel.

### What Gets Deployed

#### Root Files
```
✅ config.php      → Database configuration
✅ index.php       → Entry point with role-based routing
✅ 404.shtml       → Custom 404 page
```

#### Organized Directories
```
✅ auth/           → Authentication system (login, register, logout)
✅ dashboards/     → Role-based dashboards (admin, owner, student)
✅ admin/          → Admin utilities (download_log, test-pdo)
✅ public/         → Public HTML/CSS files
✅ modules/        → Feature modules
✅ partials/       → Shared UI components (header, footer)
✅ assets/         → CSS, JS, images
✅ uploads/        → User uploaded files
✅ cgi-bin/        → CGI scripts
✅ cron/           → Scheduled tasks
```

---

## 🚀 How to Deploy

### Method 1: Git Push (Recommended)

If your cPanel has Git Version Control enabled:

```bash
# Commit your changes
git add .
git commit -m "Organized web structure with new folder layout"
git push origin main
```

cPanel will automatically:
1. Detect the push
2. Read `.cpanel.yml`
3. Execute deployment tasks
4. Copy files to `/home/yyju4g9j6ey3/public_html/`

### Method 2: Manual File Manager

If Git deployment isn't set up:

1. **Compress locally:**
   ```powershell
   cd "c:\xampp\htdocs\WebDesign_BSITA-2\2nd sem\Joshan_System\LCozy_CPG2615\Main"
   Compress-Archive -Path * -DestinationPath ..\Main.zip
   ```

2. **Upload to cPanel:**
   - Login to cPanel
   - Go to File Manager
   - Navigate to `public_html/`
   - Upload `Main.zip`
   - Extract the archive

3. **Set permissions:**
   - Select `uploads/` folder → Change Permissions → 755 or 775
   - Select `error_log` → Change Permissions → 644

---

## ⚙️ Post-Deployment Configuration

### 1. Update config.php (if needed)

Make sure your production database credentials are set:

```php
// Production database settings
$db_host = 'localhost';
$db_name = 'your_production_db';
$db_user = 'your_db_user';
$db_pass = 'your_db_password';
```

### 2. Verify File Permissions

```
Directories: 755 (rwxr-xr-x)
PHP Files:   644 (rw-r--r--)
Uploads:     755 or 775
```

### 3. Test Key URLs

After deployment, test these URLs:

```
✅ https://cozydorms.life/
✅ https://cozydorms.life/auth/login.php
✅ https://cozydorms.life/dashboards/admin_dashboard.php
✅ https://cozydorms.life/modules/available_dorms.php
```

### 4. Setup .htaccess (Optional)

Create/update `.htaccess` in public_html for clean URLs:

```apache
# Enable rewrite engine
RewriteEngine On

# Redirect to HTTPS
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]

# Custom error pages
ErrorDocument 404 /404.shtml

# Protect sensitive files
<FilesMatch "^(config\.php|\.cpanel\.yml|\.git)">
    Order allow,deny
    Deny from all
</FilesMatch>

# Prevent directory browsing
Options -Indexes

# Set default index files
DirectoryIndex index.php index.html
```

---

## 🔍 Troubleshooting

### Issue: 404 Errors after deployment

**Solution:**
```bash
# Check file paths in cPanel File Manager
# Verify structure matches:
public_html/
├── auth/
├── dashboards/
├── modules/
└── config.php
```

### Issue: Database connection errors

**Solution:**
- Verify `config.php` has correct production credentials
- Check database name matches cPanel database
- Ensure database user has all privileges
- Test connection with `admin/test-pdo.php`

### Issue: File permission errors

**Solution:**
```bash
# In cPanel Terminal or SSH:
cd /home/yyju4g9j6ey3/public_html/
chmod 755 auth/ dashboards/ modules/ admin/
chmod 775 uploads/
chmod 644 *.php
```

### Issue: CSS/JS not loading

**Solution:**
- Check `assets/` folder deployed correctly
- Verify paths in HTML don't use absolute URLs
- Clear browser cache
- Check browser console for 404 errors

### Issue: Sessions not working

**Solution:**
```php
// Add to config.php if needed:
ini_set('session.save_path', '/home/yyju4g9j6ey3/tmp');
session_start();
```

---

## 📋 Pre-Deployment Checklist

Before deploying to production:

### Security
- [ ] Remove or protect `test-pdo.php` in production
- [ ] Set strong database passwords
- [ ] Enable HTTPS/SSL
- [ ] Add `.htaccess` protection
- [ ] Remove development files (.md docs)

### Testing
- [ ] Test login/logout locally
- [ ] Test all three dashboard types
- [ ] Test module navigation
- [ ] Check mobile API endpoints
- [ ] Verify file uploads work
- [ ] Test payment system

### Configuration
- [ ] Update `config.php` with production DB
- [ ] Update API base URL if needed
- [ ] Set correct timezone in PHP
- [ ] Configure error reporting (disable in prod)
- [ ] Setup backup schedule

### Performance
- [ ] Enable PHP OPcache
- [ ] Compress assets (CSS/JS)
- [ ] Optimize images in assets/
- [ ] Enable browser caching
- [ ] Setup CDN (optional)

---

## 🔄 Continuous Deployment

### Setup Git Deployment in cPanel

1. **Go to:** cPanel → Git Version Control → Create

2. **Configure:**
   ```
   Repository Path: /home/yyju4g9j6ey3/repositories/LCozy_CPG2615
   Clone URL: https://github.com/StefanDelgado/LCozy_CPG2615.git
   Deployment Path: /home/yyju4g9j6ey3/public_html/
   ```

3. **Enable:** Automatic deployment on push

4. **Deploy:**
   ```bash
   git push origin main
   # cPanel automatically deploys using .cpanel.yml
   ```

---

## 📞 Support

### cPanel Resources
- File Manager: `cPanel → Files → File Manager`
- Database: `cPanel → Databases → phpMyAdmin`
- Error Logs: `cPanel → Metrics → Errors`
- Git Deploy: `cPanel → Files → Git Version Control`

### Logs Location
```
Error Log: /home/yyju4g9j6ey3/public_html/error_log
Access Log: /home/yyju4g9j6ey3/access-logs/
PHP Errors: Check cPanel Error Log interface
```

### Quick Commands (SSH/Terminal)
```bash
# Navigate to site
cd /home/yyju4g9j6ey3/public_html/

# Check PHP version
php -v

# Check file permissions
ls -la

# View error log
tail -50 error_log

# Clear error log
> error_log
```

---

## ✅ Deployment Complete!

After successful deployment, your site structure will be:

```
https://cozydorms.life/
├── auth/login.php              ← Login page
├── dashboards/admin_dashboard.php    ← Admin panel
├── dashboards/owner_dashboard.php    ← Owner panel
├── dashboards/student_dashboard.php  ← Student portal
├── modules/[feature].php       ← Feature modules
└── uploads/                    ← User files
```

**Testing URL:** https://cozydorms.life/auth/login.php

---

**Last Updated:** October 2024  
**Deployment Path:** `/home/yyju4g9j6ey3/public_html/`  
**Repository:** https://github.com/StefanDelgado/LCozy_CPG2615
