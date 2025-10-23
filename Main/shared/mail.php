<?php
// Simple mail helper using PHPMailer if available, falls back to mail()

function send_mail($to, $subject, $body, $altBody = null, $from = null) {
    $logFile = __DIR__ . '/mail_debug.log';
    $time = date('Y-m-d H:i:s');
    file_put_contents($logFile, "[$time] send_mail called to=$to subject=" . preg_replace('/\s+/', ' ', $subject) . "\n", FILE_APPEND);

    // prefer PHPMailer if present
    if (file_exists(__DIR__ . '/../../vendor/autoload.php')) {
        require_once __DIR__ . '/../../vendor/autoload.php';
        // attempt using configured SMTP settings first
        $attempts = [];
        try {
            file_put_contents($logFile, "[$time] PHPMailer autoload found, attempting SMTP (configured settings)\n", FILE_APPEND);
            $mail = new PHPMailer\PHPMailer\PHPMailer(true);
            $mail->isSMTP();
            $mail->Host = SMTP_HOST;
            $mail->SMTPAuth = true;
            $mail->Username = SMTP_USER;
            $mail->Password = SMTP_PASS;
            $mail->SMTPSecure = SMTP_SECURE;
            $mail->Port = SMTP_PORT;
            $mail->AuthType = 'LOGIN'; // Explicitly set auth type
            $mail->SMTPDebug = 2; // Enable verbose debug output
            $mail->Debugoutput = function($str, $level) use ($logFile, $time) {
                file_put_contents($logFile, "[$time] SMTPDebug: $str\n", FILE_APPEND);
            };

            $mail->setFrom($from ?? MAIL_FROM, 'CozyDorms');
            $mail->addAddress($to);
            $mail->isHTML(false);
            $mail->Subject = $subject;
            $mail->Body = $body;
            if ($altBody) $mail->AltBody = $altBody;

            $mail->send();
            file_put_contents($logFile, "[$time] PHPMailer send() succeeded (port " . SMTP_PORT . ")\n", FILE_APPEND);
            return true;
        } catch (Exception $e) {
            $err = $e->getMessage();
            error_log('PHPMailer error (primary): ' . $err);
            file_put_contents($logFile, "[$time] PHPMailer primary error: " . $err . "\n", FILE_APPEND);
            $attempts[] = ['port' => SMTP_PORT, 'secure' => SMTP_SECURE, 'error' => $err];
            // try fallback to TLS on 587 if primary was SSL/465
            $fallback_port = 587;
            $fallback_secure = 'tls';
            try {
                file_put_contents($logFile, "[$time] Attempting fallback SMTP on port $fallback_port with $fallback_secure\n", FILE_APPEND);
                $mail = new PHPMailer\PHPMailer\PHPMailer(true);
                $mail->isSMTP();
                $mail->Host = SMTP_HOST;
                $mail->SMTPAuth = true;
                $mail->Username = SMTP_USER;
                $mail->Password = SMTP_PASS;
                $mail->SMTPSecure = $fallback_secure;
                $mail->Port = $fallback_port;
                $mail->AuthType = 'LOGIN'; // Explicitly set auth type
                $mail->SMTPDebug = 2; // Enable verbose debug output
                $mail->Debugoutput = function($str, $level) use ($logFile, $time) {
                    file_put_contents($logFile, "[$time] SMTPDebug: $str\n", FILE_APPEND);
                };

                $mail->setFrom($from ?? MAIL_FROM, 'CozyDorms');
                $mail->addAddress($to);
                $mail->isHTML(false);
                $mail->Subject = $subject;
                $mail->Body = $body;
                if ($altBody) $mail->AltBody = $altBody;

                $mail->send();
                file_put_contents($logFile, "[$time] PHPMailer send() succeeded (port $fallback_port)\n", FILE_APPEND);
                return true;
            } catch (Exception $e2) {
                $err2 = $e2->getMessage();
                error_log('PHPMailer error (fallback): ' . $err2);
                file_put_contents($logFile, "[$time] PHPMailer fallback error: " . $err2 . "\n", FILE_APPEND);
                $attempts[] = ['port' => $fallback_port, 'secure' => $fallback_secure, 'error' => $err2];
                // if both PHPMailer attempts failed, continue to mail() fallback
            }
        }
        // record attempts summary
        file_put_contents($logFile, "[$time] PHPMailer attempts: " . json_encode($attempts) . "\n", FILE_APPEND);
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
