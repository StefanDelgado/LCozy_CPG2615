<?php
// Primary (remote) server
$REMOTE_DB_HOST = 'localhost';
$REMOTE_DB_NAME = 'cozydorms';
$REMOTE_DB_USER = 'cozyadmin';
$REMOTE_DB_PASS = 'PsBn9c4PZ2BMRMq';

// Local fallback
$LOCAL_DB_HOST = '127.0.0.1';
$LOCAL_DB_NAME = 'cozydorms';
$LOCAL_DB_USER = 'root';
$LOCAL_DB_PASS = '';

try {
    // Try connecting to remote server first
    $pdo = new PDO("mysql:host=$REMOTE_DB_HOST;dbname=$REMOTE_DB_NAME;charset=utf8mb4", $REMOTE_DB_USER, $REMOTE_DB_PASS, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);
} catch (PDOException $e) {
    // If remote connection fails, fallback to local
    error_log("Remote DB connection failed: " . $e->getMessage());
    
    try {
        $pdo = new PDO("mysql:host=$LOCAL_DB_HOST;dbname=$LOCAL_DB_NAME;charset=utf8mb4", $LOCAL_DB_USER, $LOCAL_DB_PASS, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        ]);
    } catch (PDOException $e_local) {
        die("Both remote and local database connections failed: " . $e_local->getMessage());
    }
}

define('ADMIN_SECRET_KEY', 'cozydorms123');
