<?php
// Main/modules/student/student_verification_upload.php

require_once __DIR__ . '/../../auth/auth.php';
require_role('student', 'superadmin');

require_once __DIR__ . '/../../config.php';

$student = current_user();
$student_id = $student['id'];

$error = "";
$success = "";

if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    if (!isset($_FILES['student_id']) || $_FILES['student_id']['error'] !== UPLOAD_ERR_OK) {
        $error = "Please upload a valid ID image.";
    } else {

        $file = $_FILES['student_id'];
        $allowed_types = ['image/jpeg', 'image/png', 'image/jpg', 'application/pdf'];
        $max_size = 5 * 1024 * 1024; // 5MB

        if (!in_array($file['type'], $allowed_types)) {
            $error = "Invalid file type. Allowed: JPG, PNG, PDF.";
        } elseif ($file['size'] > $max_size) {
            $error = "File is too large. Maximum size is 5MB.";
        } else {

            // Ensure upload folder exists
            $upload_dir = __DIR__ . '/../../upload/';
            if (!is_dir($upload_dir)) {
                mkdir($upload_dir, 0777, true);
            }

            // Unique filename
            $ext = pathinfo($file['name'], PATHINFO_EXTENSION);
            $new_filename = 'student_id_' . $student_id . '_' . time() . '.' . $ext;
            $destination = $upload_dir . $new_filename;

            if (move_uploaded_file($file['tmp_name'], $destination)) {

                // Save file to DB
                $stmt = $pdo->prepare("
                    UPDATE users 
                    SET student_id_image = :file, student_verification_status = 'pending'
                    WHERE id = :id
                ");

                $stmt->execute([
                    ':file' => $new_filename,
                    ':id' => $student_id
                ]);

                $success = "Your student ID has been submitted for verification.";
            } else {
                $error = "Failed to upload file.";
            }
        }
    }
}

$page_title = "Student Verification Upload";
require_once __DIR__ . '/../../partials/header.php';
?>

<div class="page-header">
    <h1>Student ID Verification</h1>
    <p>Upload your student ID to verify your student status.</p>
</div>

<div class="card">

<?php if ($error): ?>
    <p class="error"><?= htmlspecialchars($error) ?></p>
<?php endif; ?>

<?php if ($success): ?>
    <p class="success"><?= htmlspecialchars($success) ?></p>
<?php endif; ?>

<form method="post" enctype="multipart/form-data">
    <label>Upload Student ID (JPG, PNG, PDF only):</label>
    <input type="file" name="student_id" required>

    <br><br>
    <button type="submit" class="btn btn-primary">Submit Verification</button>
</form>

</div>

<?php require_once __DIR__ . '/../../partials/footer.php'; ?>
