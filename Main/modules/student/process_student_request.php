<?php
require_once '../../config.php';

if (!isset($_GET['id'], $_GET['action'])) {
    die("Invalid request.");
}

$student_id = $_GET['id'];
$action = $_GET['action'];

if (!in_array($action, ['approve', 'disapprove'])) {
    die("Invalid action.");
}

$new_status = ($action === 'approve') ? 'approved' : 'disapproved';

try {
    $stmt = $pdo->prepare("
        UPDATE users 
        SET student_verification_status = :status
        WHERE id = :id AND role = 'student'
    ");

    $stmt->execute([
        ':status' => $new_status,
        ':id' => $student_id
    ]);

    header("Location: student_management.php?success=1");
    exit;

} catch (PDOException $e) {
    die("Database error: " . $e->getMessage());
}
