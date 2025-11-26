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
    // Get POST data
    $dorm_id = isset($_POST['dorm_id']) ? intval($_POST['dorm_id']) : 0;
    $owner_email = isset($_POST['owner_email']) ? trim($_POST['owner_email']) : '';
    $certification_type = isset($_POST['certification_type']) ? trim($_POST['certification_type']) : '';

    if (empty($dorm_id) || empty($owner_email)) {
        echo json_encode(['success' => false, 'error' => 'Missing required fields']);
        exit;
    }

    // Verify owner owns this dorm
    $stmt = $pdo->prepare("
        SELECT d.dorm_id 
        FROM dormitories d
        JOIN users u ON d.owner_id = u.user_id
        WHERE d.dorm_id = ? AND u.email = ? AND u.role = 'owner'
    ");
    $stmt->execute([$dorm_id, $owner_email]);
    
    if (!$stmt->fetch()) {
        echo json_encode(['success' => false, 'error' => 'Unauthorized or dorm not found']);
        exit;
    }

    // Check if file was uploaded
    if (!isset($_FILES['certification_file']) || $_FILES['certification_file']['error'] !== UPLOAD_ERR_OK) {
        echo json_encode(['success' => false, 'error' => 'No file uploaded or upload error']);
        exit;
    }

    $file = $_FILES['certification_file'];
    $allowed_types = ['application/pdf', 'image/jpeg', 'image/jpg', 'image/png'];
    $max_size = 5 * 1024 * 1024; // 5MB

    // Validate file type
    if (!in_array($file['type'], $allowed_types)) {
        echo json_encode(['success' => false, 'error' => 'Invalid file type. Only PDF, JPG, JPEG, and PNG are allowed']);
        exit;
    }

    // Validate file size
    if ($file['size'] > $max_size) {
        echo json_encode(['success' => false, 'error' => 'File size exceeds 5MB limit']);
        exit;
    }

    // Create upload directory if it doesn't exist
    $upload_dir = '../../../uploads/certifications/';
    if (!file_exists($upload_dir)) {
        mkdir($upload_dir, 0755, true);
    }

    // Generate unique filename
    $file_extension = pathinfo($file['name'], PATHINFO_EXTENSION);
    $unique_filename = 'cert_' . $dorm_id . '_' . uniqid() . '.' . $file_extension;
    $upload_path = $upload_dir . $unique_filename;

    // Move uploaded file
    if (!move_uploaded_file($file['tmp_name'], $upload_path)) {
        echo json_encode(['success' => false, 'error' => 'Failed to upload file']);
        exit;
    }

    // Save to database
    $stmt = $pdo->prepare("
        INSERT INTO dorm_certifications (dorm_id, file_name, file_path, certification_type)
        VALUES (?, ?, ?, ?)
    ");
    $stmt->execute([
        $dorm_id,
        $file['name'],
        'uploads/certifications/' . $unique_filename,
        $certification_type
    ]);

    echo json_encode([
        'success' => true,
        'message' => 'Certification uploaded successfully',
        'certification_id' => $pdo->lastInsertId(),
        'file_path' => 'uploads/certifications/' . $unique_filename
    ]);

} catch (PDOException $e) {
    error_log('Database error in upload_certification.php: ' . $e->getMessage());
    echo json_encode(['success' => false, 'error' => 'Database error occurred']);
} catch (Exception $e) {
    error_log('Error in upload_certification.php: ' . $e->getMessage());
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
