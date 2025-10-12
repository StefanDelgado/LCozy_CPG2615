<?php
require_once __DIR__ . '/auth.php';
require_role('admin');

$logFile = __DIR__ . '/cron/payment_automation.log';

if (!file_exists($logFile)) {
    die('Log file not found.');
}

header('Content-Type: text/plain');
header('Content-Disposition: attachment; filename="payment_automation.log"');
readfile($logFile);
exit;
?>