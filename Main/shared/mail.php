<?php
// Simple mail helper using PHPMailer if available, falls back to mail()

function send_mail($to, $subject, $body, $altBody = null, $from = null) {
    // prefer PHPMailer if present
    if (file_exists(__DIR__ . '/../../vendor/autoload.php')) {
        require_once __DIR__ . '/../../vendor/autoload.php';
        $mail = new PHPMailer\PHPMailer\PHPMailer(true);
        try {
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
            return true;
        } catch (Exception $e) {
            error_log('PHPMailer error: ' . $e->getMessage());
            // fallback to mail()
        }
    }

    // fallback
    $headers = 'From: ' . ($from ?? MAIL_FROM) . "\r\n" .
               'Reply-To: ' . ($from ?? MAIL_FROM) . "\r\n" .
               'X-Mailer: PHP/' . phpversion();
    return mail($to, $subject, $body, $headers);
}
