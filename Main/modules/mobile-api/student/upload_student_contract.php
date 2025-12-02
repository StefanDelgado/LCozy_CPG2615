<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

require_once '../../../config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['success' => false, 'error' => 'Invalid request method']);
    exit;
}

try {
    // Get form data
    $booking_id = isset($_POST['booking_id']) ? intval($_POST['booking_id']) : 0;
    $student_email = isset($_POST['student_email']) ? trim($_POST['student_email']) : '';

    if (empty($booking_id) || empty($student_email)) {
        echo json_encode(['success' => false, 'error' => 'Missing required fields']);
        exit;
    }

    // Check if file was uploaded
    if (!isset($_FILES['contract_document']) || $_FILES['contract_document']['error'] !== UPLOAD_ERR_OK) {
        $error_msg = 'No file uploaded';
        if (isset($_FILES['contract_document']['error'])) {
            switch ($_FILES['contract_document']['error']) {
                case UPLOAD_ERR_INI_SIZE:
                case UPLOAD_ERR_FORM_SIZE:
                    $error_msg = 'File too large';
                    break;
                case UPLOAD_ERR_PARTIAL:
                    $error_msg = 'File upload incomplete';
                    break;
                case UPLOAD_ERR_NO_FILE:
                    $error_msg = 'No file selected';
                    break;
                default:
                    $error_msg = 'Upload error occurred';
            }
        }
        echo json_encode(['success' => false, 'error' => $error_msg]);
        exit;
    }

    // Get student ID
    $stmt = $pdo->prepare("SELECT user_id FROM users WHERE email = ? AND role = 'student'");
    $stmt->execute([$student_email]);
    $student = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$student) {
        echo json_encode(['success' => false, 'error' => 'Student not found']);
        exit;
    }

    $student_id = $student['user_id'];

    // Verify booking exists and belongs to this student
    $stmt = $pdo->prepare("
        SELECT b.booking_id, b.status, b.student_id, b.student_contract_copy,
               d.name as dorm_name
        FROM bookings b
        JOIN rooms r ON b.room_id = r.room_id
        JOIN dormitories d ON r.dorm_id = d.dorm_id
        WHERE b.booking_id = ?
    ");
    $stmt->execute([$booking_id]);
    $booking = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$booking) {
        echo json_encode(['success' => false, 'error' => 'Booking not found']);
        exit;
    }

    // Verify student owns this booking
    if ($booking['student_id'] != $student_id) {
        echo json_encode(['success' => false, 'error' => 'Unauthorized: This is not your booking']);
        exit;
    }

    // Check if booking is approved (can only upload contract after approval)
    if (!in_array($booking['status'], ['approved', 'active'])) {
        echo json_encode([
            'success' => false, 
            'error' => 'Contract can only be uploaded for approved or active bookings'
        ]);
        exit;
    }

    // Validate file type by extension (more reliable than MIME type)
    $file_extension = strtolower(pathinfo($_FILES['contract_document']['name'], PATHINFO_EXTENSION));
    $allowed_extensions = ['pdf', 'jpg', 'jpeg', 'png'];
    
    if (!in_array($file_extension, $allowed_extensions)) {
        echo json_encode([
            'success' => false, 
            'error' => 'Invalid file type. Please upload PDF, JPG, or PNG files only. Uploaded: ' . $file_extension
        ]);
        exit;
    }
    
    // Optional: Also check MIME type as secondary validation
    $allowed_mime_types = [
        'application/pdf',
        'image/jpeg',
        'image/jpg', 
        'image/pjpeg',
        'image/png',
        'image/x-png',
        'application/octet-stream' // Some devices use this
    ];
    $file_mime = $_FILES['contract_document']['type'];
    
    // Log the MIME type for debugging
    error_log("File upload - Extension: $file_extension, MIME: $file_mime");
    
    // Only validate MIME if it's set (some clients don't send it)
    if (!empty($file_mime) && !in_array(strtolower($file_mime), $allowed_mime_types)) {
        // If extension is valid but MIME doesn't match, log warning but allow
        error_log("Warning: MIME type mismatch but extension is valid. MIME: $file_mime, Extension: $file_extension");
    }

    // Validate file size (max 5MB)
    $max_size = 5 * 1024 * 1024; // 5MB
    if ($_FILES['contract_document']['size'] > $max_size) {
        echo json_encode(['success' => false, 'error' => 'File too large. Maximum size is 5MB']);
        exit;
    }

    // Create upload directory if it doesn't exist
    $upload_dir = '../../../uploads/contracts/student/';
    if (!file_exists($upload_dir)) {
        mkdir($upload_dir, 0755, true);
    }

    // Generate unique filename
    $file_extension = pathinfo($_FILES['contract_document']['name'], PATHINFO_EXTENSION);
    $new_filename = 'student_contract_' . $booking_id . '_' . time() . '.' . $file_extension;
    $upload_path = $upload_dir . $new_filename;
    $db_path = 'uploads/contracts/student/' . $new_filename;

    // Delete old contract file if exists
    if (!empty($booking['student_contract_copy'])) {
        $old_file = '../../../' . $booking['student_contract_copy'];
        if (file_exists($old_file)) {
            unlink($old_file);
        }
    }

    // Move uploaded file
    if (!move_uploaded_file($_FILES['contract_document']['tmp_name'], $upload_path)) {
        echo json_encode(['success' => false, 'error' => 'Failed to save file']);
        exit;
    }

    // Update database
    $stmt = $pdo->prepare("
        UPDATE bookings 
        SET student_contract_copy = ?,
            student_contract_uploaded_at = NOW(),
            updated_at = NOW()
        WHERE booking_id = ?
    ");
    $stmt->execute([$db_path, $booking_id]);

    echo json_encode([
        'success' => true,
        'message' => 'Contract uploaded successfully',
        'booking_id' => $booking_id,
        'file_path' => $db_path
    ]);

} catch (PDOException $e) {
    error_log('Database error in upload_student_contract.php: ' . $e->getMessage());
    error_log('Stack trace: ' . $e->getTraceAsString());
    echo json_encode(['success' => false, 'error' => 'Database error: ' . $e->getMessage()]);
} catch (Exception $e) {
    error_log('Error in upload_student_contract.php: ' . $e->getMessage());
    error_log('Stack trace: ' . $e->getTraceAsString());
    echo json_encode(['success' => false, 'error' => 'Error: ' . $e->getMessage()]);
}
