<?php
require_once __DIR__ . '/config.php';
if (isset($pdo) && $pdo instanceof PDO) {
    echo "PDO OK. Server: " . getenv('HTTP_HOST');
    $stmt = $pdo->query("SELECT NOW() as now");
    $r = $stmt->fetch();
    echo "<br>DB Time: " . htmlspecialchars($r['now']);
} else {
    echo "PDO NOT OK. Check config.php and DB credentials.";
}
?>