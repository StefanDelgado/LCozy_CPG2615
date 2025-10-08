<?php
// Primary (remote) server
$REMOTE_DB_HOST = '50.63.129.30';
$REMOTE_DB_NAME = 'cozydorms';
$REMOTE_DB_USER = 'cozyadmin';
$REMOTE_DB_PASS = 'PsBn9c4PZ2BMRMq';

// Local fallback
$LOCAL_DB_HOST = '127.0.0.1';
$LOCAL_DB_NAME = 'cozydorms';
$LOCAL_DB_USER = 'root';
$LOCAL_DB_PASS = '';

$dsn = "mysql:host={$db_host};dbname={$db_name};charset={$db_charset}";

$options = [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES   => false,
];

try {
    $pdo = new PDO($dsn, $db_user, $db_pass, $options);
} catch (PDOException $e) {
    // In production avoid echoing or showing DB errors — log them instead
    error_log("DB Connection failed: " . $e->getMessage());
    // For initial setup you can die with a message:
    die("Database connection failed (check logs).");
}

define('ADMIN_SECRET_KEY', 'cozydorms123');
