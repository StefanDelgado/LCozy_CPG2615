<?php
// Simple mail helper using PHPMailer if available, falls back to mail()

function send_mail($to, $subject, $body, $altBody = null, $from = null) {
    $logFile = __DIR__ . '/mail_debug.log';
    $time = date('Y-m-d H:i:s');
    file_put_contents($logFile, "[$time] send_mail called to=$to subject=" . preg_replace('/\s+/', ' ', $subject) . "\n", FILE_APPEND);

    // prefer PHPMailer if present
    if (file_exists(__DIR__ . '/../../vendor/autoload.php')) {
        require_once __DIR__ . '/../../vendor/autoload.php';
        $mail = new PHPMailer\PHPMailer\PHPMailer(true);
        try {
            file_put_contents($logFile, "[$time] PHPMailer autoload found, attempting SMTP\n", FILE_APPEND);
            $mail->isSMTP();
            $mail->Host = SMTP_HOST;
            $mail->SMTPAuth = true;
            $mail->Username = SMTP_USER;
            $mail->Password = SMTP_PASS;
            $mail->SMTPSecure = SMTP_SECURE;
            $mail->Port = SMTP_PORT;

            $mail->setFrom($from ?? MAIL_FROM, 'CozyDorms');
            $mail->addAddress($to);
            $mail->isHTML(false);
            $mail->Subject = $subject;
            $mail->Body = $body;
            if ($altBody) $mail->AltBody = $altBody;

            $mail->send();
            file_put_contents($logFile, "[$time] PHPMailer send() succeeded\n", FILE_APPEND);
            return true;
        } catch (Exception $e) {
            $err = $e->getMessage();
            error_log('PHPMailer error: ' . $err);
            file_put_contents($logFile, "[$time] PHPMailer error: " . $err . "\n", FILE_APPEND);
            // fallback to mail()
        }
    }

    // fallback to PHP mail()
    $headers = 'From: ' . ($from ?? MAIL_FROM) . "\r\n" .
               'Reply-To: ' . ($from ?? MAIL_FROM) . "\r\n" .
               'X-Mailer: PHP/' . phpversion();
    $result = mail($to, $subject, $body, $headers);
    file_put_contents($logFile, "[$time] mail() result: " . ($result ? 'true' : 'false') . "\n", FILE_APPEND);
    if (!$result) {
        $last = error_get_last();
        file_put_contents($logFile, "[$time] mail() error: " . print_r($last, true) . "\n", FILE_APPEND);
    }
    return $result;
}
