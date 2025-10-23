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
        $authTypes = ['LOGIN', 'PLAIN', 'CRAM-MD5'];
        $ports = [SMTP_PORT, 587];
        $secures = [SMTP_SECURE, 'tls'];
        $success = false;
        foreach ($ports as $port) {
            foreach ($secures as $secure) {
                foreach ($authTypes as $authType) {
                    try {
                        file_put_contents($logFile, "[$time] Trying SMTP port=$port secure=$secure AuthType=$authType\n", FILE_APPEND);
                        $mail = new PHPMailer\PHPMailer\PHPMailer(true);
                        $mail->isSMTP();
                        $mail->Host = SMTP_HOST;
                        $mail->SMTPAuth = true;
                        $mail->Username = SMTP_USER;
                        $mail->Password = SMTP_PASS;
                        $mail->SMTPSecure = $secure;
                        $mail->Port = $port;
                        $mail->AuthType = $authType;
                        $mail->SMTPDebug = 2;
                        $mail->Debugoutput = function($str, $level) use ($logFile, $time, $port, $secure, $authType) {
                            file_put_contents($logFile, "[$time] SMTPDebug [port=$port secure=$secure AuthType=$authType]: $str\n", FILE_APPEND);
                        };

                        $mail->setFrom($from ?? MAIL_FROM, 'CozyDorms');
                        $mail->addAddress($to);
                        $mail->isHTML(false);
                        $mail->Subject = $subject;
                        $mail->Body = $body;
                        if ($altBody) $mail->AltBody = $altBody;

                        $mail->send();
                        file_put_contents($logFile, "[$time] PHPMailer send() succeeded (port=$port secure=$secure AuthType=$authType)\n", FILE_APPEND);
                        $success = true;
                        break 3;
                    } catch (Exception $e) {
                        $err = $e->getMessage();
                        error_log("PHPMailer error (port=$port secure=$secure AuthType=$authType): " . $err);
                        file_put_contents($logFile, "[$time] PHPMailer error (port=$port secure=$secure AuthType=$authType): $err\n", FILE_APPEND);
                        $attempts[] = ['port' => $port, 'secure' => $secure, 'authType' => $authType, 'error' => $err];
                    }
                }
                if ($success) break;
            }
            if ($success) break;
        }
        // record attempts summary
        file_put_contents($logFile, "[$time] PHPMailer attempts: " . json_encode($attempts) . "\n", FILE_APPEND);
        if ($success) return true;
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
