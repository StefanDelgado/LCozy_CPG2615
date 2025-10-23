<?php
require_once __DIR__ . '/../config.php';

header('Content-Type: text/plain; charset=utf-8');
echo "SMTP Test\n";
echo "Host: " . (defined('SMTP_HOST') ? SMTP_HOST : 'not set') . "\n";
echo "Port: " . (defined('SMTP_PORT') ? SMTP_PORT : 'not set') . "\n";
echo "User: " . (defined('SMTP_USER') ? SMTP_USER : 'not set') . "\n";
echo "Secure: " . (defined('SMTP_SECURE') ? SMTP_SECURE : 'not set') . "\n\n";

if (!defined('SMTP_HOST') || !defined('SMTP_PORT')) {
    echo "SMTP_HOST or SMTP_PORT not configured in config.php\n";
    exit;
}

$host = SMTP_HOST;
$port = SMTP_PORT;
$secure = defined('SMTP_SECURE') ? SMTP_SECURE : '';
$user = defined('SMTP_USER') ? SMTP_USER : '';
$pass = defined('SMTP_PASS') ? SMTP_PASS : '';

$transport = ($secure === 'ssl') ? 'ssl' : 'tcp';
$uri = ($transport === 'ssl' ? 'ssl://' : '') . $host . ':' . $port;

echo "Trying to connect to $uri ...\n";
$timeout = 10;
$fp = @stream_socket_client($uri, $errno, $errstr, $timeout);
if (!$fp) {
    echo "Connection failed: $errno - $errstr\n";
    exit;
}

stream_set_timeout($fp, $timeout);
$banner = fgets($fp, 512);
echo "Server banner: " . trim($banner) . "\n";

function smtp_read($fp) {
    $data = '';
    while (($line = fgets($fp, 515)) !== false) {
        $data .= $line;
        // lines that do not start with 3-digit and '-' indicate end
        if (preg_match('/^[0-9]{3} /', $line)) break;
    }
    return $data;
}

fputs($fp, "EHLO localhost\r\n");
$ehlo = smtp_read($fp);
echo "EHLO response:\n" . $ehlo . "\n";

if ($user && $pass) {
    echo "Attempting AUTH LOGIN...\n";
    fputs($fp, "AUTH LOGIN\r\n");
    $r = smtp_read($fp);
    echo $r;
    fputs($fp, base64_encode($user) . "\r\n");
    $r = smtp_read($fp);
    echo $r;
    fputs($fp, base64_encode($pass) . "\r\n");
    $r = smtp_read($fp);
    echo $r;
    if (strpos($r, '235') === 0) {
        echo "Authentication: SUCCESS\n";
    } else {
        echo "Authentication: FAILED\n";
    }
} else {
    echo "No SMTP_USER/SMTP_PASS configured; skipping AUTH test.\n";
}

fputs($fp, "QUIT\r\n");
fclose($fp);
echo "Done.\n";

?>
