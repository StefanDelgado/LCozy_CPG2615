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
    $owner_email = isset($_POST['owner_email']) ? trim($_POST['owner_email']) : '';

    if (empty($booking_id) || empty($owner_email)) {
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

    // Get owner ID
    $stmt = $pdo->prepare("SELECT user_id FROM users WHERE email = ? AND role = 'owner'");
    $stmt->execute([$owner_email]);
    $owner = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$owner) {
        echo json_encode(['success' => false, 'error' => 'Owner not found']);
        exit;
    }

    $owner_id = $owner['user_id'];

    // Verify booking exists and belongs to this owner's dorm
    $stmt = $pdo->prepare("
        SELECT b.booking_id, b.status, b.owner_contract_copy,
               d.owner_id, d.name as dorm_name
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

    // Verify owner owns this dorm
    if ($booking['owner_id'] != $owner_id) {
        echo json_encode(['success' => false, 'error' => 'Unauthorized: This booking is not from your dorm']);
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

    // Validate file type (PDF, images)
    $allowed_types = ['application/pdf', 'image/jpeg', 'image/jpg', 'image/png'];
    $file_type = $_FILES['contract_document']['type'];
    
    if (!in_array($file_type, $allowed_types)) {
        echo json_encode([
            'success' => false, 
            'error' => 'Invalid file type. Please upload PDF, JPG, or PNG files only'
        ]);
        exit;
    }

    // Validate file size (max 5MB)
    $max_size = 5 * 1024 * 1024; // 5MB
    if ($_FILES['contract_document']['size'] > $max_size) {
        echo json_encode(['success' => false, 'error' => 'File too large. Maximum size is 5MB']);
        exit;
    }

    // Create upload directory if it doesn't exist
    $upload_dir = '../../../uploads/contracts/owner/';
    if (!file_exists($upload_dir)) {
        mkdir($upload_dir, 0755, true);
    }

    // Generate unique filename
    $file_extension = pathinfo($_FILES['contract_document']['name'], PATHINFO_EXTENSION);
    $new_filename = 'owner_contract_' . $booking_id . '_' . time() . '.' . $file_extension;
    $upload_path = $upload_dir . $new_filename;
    $db_path = 'uploads/contracts/owner/' . $new_filename;

    // Delete old contract file if exists
    if (!empty($booking['owner_contract_copy'])) {
        $old_file = '../../../' . $booking['owner_contract_copy'];
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
        SET owner_contract_copy = ?,
            owner_contract_uploaded_at = NOW(),
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
    error_log('Database error in upload_owner_contract.php: ' . $e->getMessage());
    error_log('Stack trace: ' . $e->getTraceAsString());
    echo json_encode(['success' => false, 'error' => 'Database error: ' . $e->getMessage()]);
} catch (Exception $e) {
    error_log('Error in upload_owner_contract.php: ' . $e->getMessage());
    error_log('Stack trace: ' . $e->getTraceAsString());
    echo json_encode(['success' => false, 'error' => 'Error: ' . $e->getMessage()]);
}
