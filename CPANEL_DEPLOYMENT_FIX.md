# cPanel Git Deployment Fix - Weird Processes Issue

## 🔴 Problem Identified

After the structure overhaul, cPanel Git deployment was having issues because:

### **The Root Cause:**
Your cPanel Git is configured to deploy from the **Main** subfolder:
```
Repository Path: /home/yyju4g9j6ey3/repositories/LCozy_CPG2615/Main
```

But the `.cpanel.yml` file was trying to copy files **from Main/** folder, creating a **double path** issue:
```bash
# In .cpanel.yml (WRONG):
/bin/cp Main/config.php $DEPLOYPATH

# cPanel executes from Main/ folder, so actual path becomes:
/repositories/LCozy_CPG2615/Main/Main/config.php  ← DOESN'T EXIST!
```

This caused:
- ❌ Files not copying correctly
- ❌ Weird process behavior
- ❌ Incomplete deployments
- ❌ Missing files on server

---

## ✅ Solution Applied

### **Updated Both .cpanel.yml Files:**

1. **Root `.cpanel.yml`** (at `LCozy_CPG2615/.cpanel.yml`)
   - Uses `Main/` prefix for all paths
   - For when cPanel deploys from repository root

2. **Main `.cpanel.yml`** (at `LCozy_CPG2615/Main/.cpanel.yml`) ✨ **NEW**
   - No `Main/` prefix (already in Main folder)
   - For when cPanel deploys from Main subfolder
   - **This is the one cPanel will use based on your config**

---

## 📋 What Changed

### **Root `.cpanel.yml` (Repository Root Deployment)**

```yaml
# Files referenced WITH Main/ prefix:
- /bin/cp Main/config.php $DEPLOYPATH
- /bin/cp Main/index.php $DEPLOYPATH
- /bin/cp -R Main/auth $DEPLOYPATH
- /bin/cp -R Main/dashboards $DEPLOYPATH
# ... etc
```

### **Main/.cpanel.yml (Main Subfolder Deployment)** ⭐ **ACTIVE**

```yaml
# Files referenced WITHOUT Main/ prefix:
- /bin/cp config.php $DEPLOYPATH
- /bin/cp index.php $DEPLOYPATH
- /bin/cp -R auth $DEPLOYPATH
- /bin/cp -R dashboards $DEPLOYPATH
# ... etc
```

---

## 🎯 Deployment Path Configuration

Based on your cPanel screenshot:

```
Repository Path: /home/yyju4g9j6ey3/repositories/LCozy_CPG2615/Main
                                                                 ^^^^
                                                          cPanel starts HERE
```

**Therefore:**
- ✅ cPanel looks for `.cpanel.yml` in: `/repositories/LCozy_CPG2615/Main/.cpanel.yml`
- ✅ All copy commands are relative to: `/repositories/LCozy_CPG2615/Main/`
- ✅ Files like `auth/`, `config.php` are directly accessible (no Main/ prefix needed)

---

## 🚀 Deploy the Fix

### **Step 1: Commit and Push**

```bash
cd "c:\xampp\htdocs\WebDesign_BSITA-2\2nd sem\Joshan_System\LCozy_CPG2615"

# Add both .cpanel.yml files
git add .cpanel.yml
git add Main/.cpanel.yml

# Commit
git commit -m "Fix cPanel deployment: Correct paths for Main subfolder deployment"

# Push
git push origin main
```

### **Step 2: Verify Deployment**

After pushing, check cPanel Git interface:
- Should see new commit deployed
- No error messages
- Deployment time updates

### **Step 3: Test Website**

```
✅ http://cozydorms.life/auth/login.php
✅ http://cozydorms.life/dashboards/admin_dashboard.php
✅ http://cozydorms.life/modules/available_dorms.php
```

---

## 🔧 Improvements Made

### **1. Better File Cleanup**
```yaml
# Removes old duplicate files before deploying
- /bin/rm -f $DEPLOYPATH/login.php
- /bin/rm -f $DEPLOYPATH/register.php
# ... etc
```

### **2. Proper Uploads Handling**
```yaml
# Creates upload directories if they don't exist
- /bin/mkdir -p $DEPLOYPATH/uploads
- /bin/mkdir -p $DEPLOYPATH/uploads/receipts
- /bin/mkdir -p $DEPLOYPATH/uploads/rooms

# Preserves existing uploads (doesn't overwrite)
- /bin/cp -n -R uploads/* $DEPLOYPATH/uploads/ 2>/dev/null || true
```

### **3. Correct Permissions**
```yaml
# Sets proper permissions recursively
- /bin/chmod -R 755 $DEPLOYPATH/auth
- /bin/chmod -R 755 $DEPLOYPATH/dashboards
- /bin/chmod -R 775 $DEPLOYPATH/uploads
- /bin/chmod 644 $DEPLOYPATH/config.php
- /bin/chmod 644 $DEPLOYPATH/*.php
```

### **4. Error Handling**
```yaml
# Uses || true to continue on errors (like empty uploads/)
- /bin/cp -n -R uploads/* $DEPLOYPATH/uploads/ 2>/dev/null || true
```

---

## 🔍 Troubleshooting

### **Still having issues after push?**

#### **1. Check which .cpanel.yml is being used:**

In cPanel Terminal or SSH:
```bash
# Check if Main/.cpanel.yml exists
ls -la /home/yyju4g9j6ey3/repositories/LCozy_CPG2615/Main/.cpanel.yml

# View its contents
cat /home/yyju4g9j6ey3/repositories/LCozy_CPG2615/Main/.cpanel.yml
```

#### **2. Check deployment logs:**

cPanel → Git Version Control → View Deployment Log
- Look for error messages
- Check which files were copied
- Verify paths are correct

#### **3. Manual verification:**

```bash
# Check what files exist in public_html
ls -la /home/yyju4g9j6ey3/public_html/

# Should see:
# auth/
# dashboards/
# modules/
# config.php
# index.php
```

#### **4. Force re-deployment:**

In cPanel Git Version Control:
1. Click "Update from Remote"
2. Then click "Deploy HEAD Commit"
3. Check deployment log for errors

---

## 📊 Deployment Checklist

After deploying, verify:

- [ ] Old files removed from root (login.php, register.php, etc.)
- [ ] New directories exist (auth/, dashboards/, admin/)
- [ ] config.php exists in root
- [ ] index.php exists in root
- [ ] uploads/ directory preserved with existing files
- [ ] File permissions correct (755 for dirs, 644 for PHP files)
- [ ] Login page works: `/auth/login.php`
- [ ] Dashboards accessible
- [ ] No 404 errors on navigation

---

## 🎯 Understanding the Fix

### **Before (BROKEN):**
```
cPanel Repository Path: /repositories/LCozy_CPG2615/Main/
.cpanel.yml location:   /repositories/LCozy_CPG2615/.cpanel.yml
.cpanel.yml commands:   /bin/cp auth/ $DEPLOYPATH
Actual path executed:   /repositories/LCozy_CPG2615/Main/auth/  ✅ WORKS

But when .cpanel.yml had Main/ prefix:
.cpanel.yml commands:   /bin/cp Main/auth/ $DEPLOYPATH
Actual path executed:   /repositories/LCozy_CPG2615/Main/Main/auth/  ❌ FAILS!
```

### **After (FIXED):**
```
cPanel Repository Path: /repositories/LCozy_CPG2615/Main/
.cpanel.yml location:   /repositories/LCozy_CPG2615/Main/.cpanel.yml  ← cPanel uses THIS
.cpanel.yml commands:   /bin/cp auth/ $DEPLOYPATH
Actual path executed:   /repositories/LCozy_CPG2615/Main/auth/  ✅ CORRECT!
```

---

## 💡 Alternative Solution

If you want to change cPanel to deploy from repository root instead:

### **In cPanel Git Version Control:**

1. **Edit Repository:**
   - Change Repository Path to: `/home/yyju4g9j6ey3/repositories/LCozy_CPG2615`
   - (Remove the `/Main` at the end)

2. **Then cPanel will use:**
   - `.cpanel.yml` from root (with Main/ prefixes)
   - Deploy from repo root

**But current solution is simpler** (no cPanel config changes needed).

---

## 📝 Files Modified

1. ✅ `.cpanel.yml` (root) - Updated with Main/ prefixes
2. ✅ `Main/.cpanel.yml` (NEW) - Created without Main/ prefixes
3. ✅ Both handle cleanup and proper permissions

---

## ✅ Status

- ✅ Root cause identified
- ✅ Correct .cpanel.yml created for Main/ deployment
- ✅ File cleanup added
- ✅ Upload preservation added
- ✅ Proper permissions set
- ⏳ Ready to commit and deploy
- ⏳ Pending: Test after deployment

---

**Fixed Date:** October 17, 2025  
**Issue:** Double Main/ path causing deployment failures  
**Solution:** Created Main/.cpanel.yml without Main/ prefix  
**Status:** Ready for deployment

---

## 🚀 Next Action

```bash
# Commit and push the fix
git add .
git commit -m "Fix cPanel deployment paths for Main subfolder"
git push origin main

# Then check: http://cozydorms.life/auth/login.php
```

The weird processes should stop, and deployment should work smoothly! 🎉
