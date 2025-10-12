<?php
// cron/payment_automation.php
require_once __DIR__ . '/../config.php';

// --- 1️⃣ AUTO-EXPIRE UNPAID PAYMENTS (after 48h of creation) ---
$expireStmt = $pdo->prepare("
    UPDATE payments
    SET status = 'overdue', updated_at = NOW()
    WHERE status IN ('pending','submitted')
      AND TIMESTAMPDIFF(HOUR, created_at, NOW()) >= 48
");
$expireStmt->execute();
$expiredCount = $expireStmt->rowCount();

// --- 2️⃣ AUTO-CREATE MONTHLY PAYMENT REMINDERS (every 25th of month) ---
$createdCount = 0;
if (date('d') == 25) {
    $stmt = $pdo->prepare("
        INSERT INTO payments (booking_id, student_id, owner_id, amount, status, due_date, created_at)
        SELECT 
            b.booking_id,
            b.student_id,
            d.owner_id,
            r.price AS amount,
            'pending',
            LAST_DAY(CURDATE()) AS due_date,
            NOW()
        FROM bookings b
        JOIN rooms r ON b.room_id = r.room_id
        JOIN dormitories d ON r.dorm_id = d.dorm_id
        WHERE b.status = 'approved'
        AND NOT EXISTS (
            SELECT 1 FROM payments p 
            WHERE p.booking_id = b.booking_id
              AND MONTH(p.due_date) = MONTH(CURDATE())
              AND YEAR(p.due_date) = YEAR(CURDATE())
        )
    ");
    $stmt->execute();
    $createdCount = $stmt->rowCount();
}

// --- 3️⃣ SEND MONTH-END REMINDERS (within 3 days before end of month) ---
$today = new DateTime();
$endOfMonth = (clone $today)->modify('last day of this month');
$daysLeft = $today->diff($endOfMonth)->days;

if ($daysLeft <= 3) {
    $reminderStmt = $pdo->query("
        SELECT p.payment_id, p.amount, p.due_date, u.email, u.name
        FROM payments p
        JOIN users u ON p.student_id = u.user_id
        WHERE p.status IN ('pending','submitted')
          AND MONTH(p.due_date) = MONTH(CURDATE())
          AND YEAR(p.due_date) = YEAR(CURDATE())
    ");

    $reminders = $reminderStmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($reminders as $r) {
        $to = $r['email'];
        $subject = "Payment Reminder — CozyDorms";
        $message = "
            <p>Hi <strong>{$r['name']}</strong>,</p>
            <p>This is a friendly reminder that your dorm payment of <strong>₱" . number_format($r['amount'], 2) . "</strong> 
            is due on <strong>" . date('F j, Y', strtotime($r['due_date'])) . "</strong>.</p>
            <p>Please ensure you submit your receipt on time to avoid late fees or booking cancellation.</p>
            <p>Thank you,<br>CozyDorms Management</p>
        ";
        $headers = "MIME-Version: 1.0\r\n";
        $headers .= "Content-type:text/html;charset=UTF-8\r\n";
        $headers .= "From: CozyDorms <no-reply@yourdomain.com>\r\n";

        @mail($to, $subject, $message, $headers);
    }

    $reminderCount = count($reminders);
} else {
    $reminderCount = 0;
}

// --- 4️⃣ LOG RESULTS ---
$logMsg = sprintf(
    "[%s] Auto-expired: %d | Reminders created: %d | Emails sent: %d\n",
    date('Y-m-d H:i:s'),
    $expiredCount,
    $createdCount,
    $reminderCount
);

file_put_contents(__DIR__ . '/payment_automation.log', $logMsg, FILE_APPEND);

echo nl2br($logMsg);