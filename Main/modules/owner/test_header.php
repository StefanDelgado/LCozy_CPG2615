<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);

echo "Before require auth<br>";
require_once __DIR__ . '/../../auth/auth.php';
echo "After require auth<br>";

require_role('owner');
echo "After require role<br>";

require_once __DIR__ . '/../../config.php';
echo "After require config<br>";

$page_title = "Test Page";
echo "Before include header<br>";
include __DIR__ . '/../../partials/header.php';
echo "After include header<br>";
?>

<h1>If you see this, the header works!</h1>

<?php include __DIR__ . '/../../partials/footer.php'; ?>
