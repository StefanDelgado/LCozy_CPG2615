<?php
// Primary (remote) server - GoDaddy MySQL
$REMOTE_DB_HOST = 'localhost'; // For cPanel MySQL, usually 'localhost'
$REMOTE_DB_NAME = 'cozydorms';
$REMOTE_DB_USER = 'cozyadmin';
$REMOTE_DB_PASS = 'PsBn9c4PZ2BMRMq';

// Local fallback (XAMPP)
$LOCAL_DB_HOST = '127.0.0.1';
$LOCAL_DB_NAME = 'cozydorms';
$LOCAL_DB_USER = 'root';
$LOCAL_DB_PASS = '';

try {
    // Try connecting to remote server first
    $pdo = new PDO(
        "mysql:host=$REMOTE_DB_HOST;dbname=$REMOTE_DB_NAME;charset=utf8mb4",
        $REMOTE_DB_USER,
        $REMOTE_DB_PASS,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        ]
    );
    // Optional: log success for debugging
    error_log("✅ Connected to REMOTE database.");
} catch (PDOException $e) {
    // Log the remote connection error
    error_log("⚠️ Remote DB connection failed: " . $e->getMessage());

    try {
        // Attempt local fallback connection
        $pdo = new PDO(
            "mysql:host=$LOCAL_DB_HOST;dbname=$LOCAL_DB_NAME;charset=utf8mb4",
            $LOCAL_DB_USER,
            $LOCAL_DB_PASS,
            [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            ]
        );
        error_log("✅ Fallback: Connected to LOCAL database.");
    } catch (PDOException $localError) {
        // Both remote and local connections failed
        error_log("❌ Local DB connection failed: " . $localError->getMessage());
        // Display user-friendly error
        die("Database connection failed. Please try again later.");
    }
}

define('ADMIN_SECRET_KEY', 'cozydorms123');
