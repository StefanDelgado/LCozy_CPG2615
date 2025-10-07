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
    // Attempt remote connection
    $pdo = new PDO(
        "mysql:host=$REMOTE_DB_HOST;dbname=$REMOTE_DB_NAME;charset=utf8mb4",
        $REMOTE_DB_USER,
        $REMOTE_DB_PASS,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        ]
    );
    echo "<p style='color:green;'>Connected to <strong>REMOTE</strong> database successfully.</p>";
} catch (PDOException $remoteError) {
    // Show and log the remote connection error
    echo "<p style='color:red;'>
        ⚠️ Remote database connection failed:<br>
        <strong>" . htmlspecialchars($remoteError->getMessage()) . "</strong>
    </p>";
    error_log("Remote DB connection failed: " . $remoteError->getMessage());

    // Try connecting to local fallback
    try {
        $pdo = new PDO(
            "mysql:host=$LOCAL_DB_HOST;dbname=$LOCAL_DB_NAME;charset=utf8mb4",
            $LOCAL_DB_USER,
            $LOCAL_DB_PASS,
            [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            ]
        );
        echo "<p style='color:orange;'>Connected to <strong>LOCAL</strong> database as fallback.</p>";
    } catch (PDOException $localError) {
        // Both failed
        die("<p style='color:red;'>❌ Both remote and local database connections failed:<br><strong>"
            . htmlspecialchars($localError->getMessage()) . "</strong></p>");
    }
}

define('ADMIN_SECRET_KEY', 'cozydorms123');
