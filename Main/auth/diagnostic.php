<?php
// Diagnostic page to check server configuration
// Access at: http://cozydorms.life/auth/diagnostic.php
// DELETE THIS FILE after troubleshooting!

error_reporting(E_ALL);
ini_set('display_errors', 1);

echo "<h1>CozyDorms Diagnostic Report</h1>";
echo "<hr>";

// 1. PHP Version
echo "<h2>1. PHP Version</h2>";
echo "PHP Version: " . phpversion() . "<br>";
echo "Required: PHP 7.4 or higher<br>";
echo "Status: " . (version_compare(phpversion(), '7.4.0', '>=') ? '✅ OK' : '❌ FAILED') . "<br>";

// 2. Check file paths
echo "<hr><h2>2. File Paths</h2>";
echo "Current file: " . __FILE__ . "<br>";
echo "Current directory: " . __DIR__ . "<br>";
echo "Document root: " . $_SERVER['DOCUMENT_ROOT'] . "<br>";
echo "Script path: " . $_SERVER['SCRIPT_FILENAME'] . "<br>";

// 3. Check config.php
echo "<hr><h2>3. Config File Test</h2>";
$config_path = __DIR__ . '/../config.php';
echo "Looking for config.php at: $config_path<br>";
if (file_exists($config_path)) {
    echo "✅ config.php EXISTS<br>";
    try {
        require_once $config_path;
        echo "✅ config.php LOADED successfully<br>";
        
        // Check PDO connection
        if (isset($pdo)) {
            echo "✅ Database connection object exists<br>";
            try {
                $stmt = $pdo->query("SELECT 1");
                echo "✅ Database query test SUCCESSFUL<br>";
            } catch (Exception $e) {
                echo "❌ Database query FAILED: " . $e->getMessage() . "<br>";
            }
        } else {
            echo "❌ \$pdo variable not set<br>";
        }
    } catch (Exception $e) {
        echo "❌ config.php LOAD FAILED: " . $e->getMessage() . "<br>";
    }
} else {
    echo "❌ config.php NOT FOUND<br>";
}

// 4. Check auth.php
echo "<hr><h2>4. Auth File Test</h2>";
$auth_path = __DIR__ . '/auth.php';
echo "Looking for auth.php at: $auth_path<br>";
if (file_exists($auth_path)) {
    echo "✅ auth.php EXISTS<br>";
    try {
        require_once $auth_path;
        echo "✅ auth.php LOADED successfully<br>";
        
        // Check functions
        if (function_exists('current_user')) {
            echo "✅ current_user() function exists<br>";
        } else {
            echo "❌ current_user() function NOT FOUND<br>";
        }
        
        if (function_exists('redirect_to_dashboard')) {
            echo "✅ redirect_to_dashboard() function exists<br>";
        } else {
            echo "❌ redirect_to_dashboard() function NOT FOUND<br>";
        }
    } catch (Exception $e) {
        echo "❌ auth.php LOAD FAILED: " . $e->getMessage() . "<br>";
    }
} else {
    echo "❌ auth.php NOT FOUND<br>";
}

// 5. Check directory structure
echo "<hr><h2>5. Directory Structure</h2>";
$base_path = __DIR__ . '/..';
$required_dirs = ['auth', 'dashboards', 'modules', 'partials', 'assets', 'uploads'];
foreach ($required_dirs as $dir) {
    $dir_path = $base_path . '/' . $dir;
    if (is_dir($dir_path)) {
        echo "✅ /$dir/ directory exists<br>";
    } else {
        echo "❌ /$dir/ directory NOT FOUND<br>";
    }
}

// 6. Check required dashboard files
echo "<hr><h2>6. Dashboard Files</h2>";
$dashboard_files = [
    'dashboards/admin_dashboard.php',
    'dashboards/owner_dashboard.php',
    'dashboards/student_dashboard.php'
];
foreach ($dashboard_files as $file) {
    $file_path = $base_path . '/' . $file;
    if (file_exists($file_path)) {
        echo "✅ /$file exists<br>";
    } else {
        echo "❌ /$file NOT FOUND<br>";
    }
}

// 7. PHP Extensions
echo "<hr><h2>7. PHP Extensions</h2>";
$required_extensions = ['pdo', 'pdo_mysql', 'mysqli', 'mbstring', 'json'];
foreach ($required_extensions as $ext) {
    if (extension_loaded($ext)) {
        echo "✅ $ext extension loaded<br>";
    } else {
        echo "❌ $ext extension NOT LOADED<br>";
    }
}

// 8. Session test
echo "<hr><h2>8. Session Test</h2>";
if (session_status() === PHP_SESSION_ACTIVE) {
    echo "✅ Session is already active<br>";
    echo "Session ID: " . session_id() . "<br>";
} else {
    try {
        session_start();
        echo "✅ Session started successfully<br>";
        echo "Session ID: " . session_id() . "<br>";
    } catch (Exception $e) {
        echo "❌ Session start FAILED: " . $e->getMessage() . "<br>";
    }
}

// 9. File permissions
echo "<hr><h2>9. File Permissions</h2>";
$check_files = [
    '../config.php',
    'auth.php',
    'login.php',
    '../uploads'
];
foreach ($check_files as $file) {
    $file_path = __DIR__ . '/' . $file;
    if (file_exists($file_path)) {
        $perms = substr(sprintf('%o', fileperms($file_path)), -4);
        echo "$file: $perms<br>";
    }
}

// 10. Server info
echo "<hr><h2>10. Server Information</h2>";
echo "Server Software: " . $_SERVER['SERVER_SOFTWARE'] . "<br>";
echo "Server Name: " . $_SERVER['SERVER_NAME'] . "<br>";
echo "Document Root: " . $_SERVER['DOCUMENT_ROOT'] . "<br>";
echo "Current User: " . get_current_user() . "<br>";

echo "<hr>";
echo "<p style='color: red; font-weight: bold;'>⚠️ DELETE THIS FILE AFTER TROUBLESHOOTING!</p>";
echo "<p>This file exposes sensitive server information.</p>";
?>
