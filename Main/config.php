<?php
// ===============================
// DATABASE CONFIGURATION
// ===============================

// Primary (remote) server — GoDaddy
$REMOTE_DB_HOST = '50.63.129.30';
$REMOTE_DB_NAME = 'cozydorms';
$REMOTE_DB_USER = 'cozyadmin';
$REMOTE_DB_PASS = 'PsBn9c4PZ2BMRMq';

// Local fallback (XAMPP)
$LOCAL_DB_HOST = '127.0.0.1';
$LOCAL_DB_NAME = 'cozydorms';
$LOCAL_DB_USER = 'root';
$LOCAL_DB_PASS = '';

// Charset
$db_charset = 'utf8mb4';

// ===============================
// CONNECTION LOGIC
// ===============================
try {
    // Try remote first
    $pdo = new PDO(
        "mysql:host=$REMOTE_DB_HOST;dbname=$REMOTE_DB_NAME;charset=$db_charset",
        $REMOTE_DB_USER,
        $REMOTE_DB_PASS,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        ]
    );
    error_log("✅ Connected to REMOTE database successfully.");
} catch (PDOException $e) {
    // Log remote failure
    error_log("⚠️ Remote DB connection failed: " . $e->getMessage());

    try {
        // Try local fallback
        $pdo = new PDO(
            "mysql:host=$LOCAL_DB_HOST;dbname=$LOCAL_DB_NAME;charset=$db_charset",
            $LOCAL_DB_USER,
            $LOCAL_DB_PASS,
            [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            ]
        );
        error_log("✅ Connected to LOCAL database successfully.");
    } catch (PDOException $localError) {
        // Log both failures
        error_log("❌ Local DB connection failed: " . $localError->getMessage());
        // Display friendly message
        die("Database connection failed (check logs).");
    }
}

define('ADMIN_SECRET_KEY', 'cozydorms123');
