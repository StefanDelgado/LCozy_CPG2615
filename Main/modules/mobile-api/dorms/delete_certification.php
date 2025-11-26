<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once '../../../config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'DELETE' && $_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['success' => false, 'error' => 'Invalid request method']);
    exit;
}

try {
    // Get request data
    $input = json_decode(file_get_contents('php://input'), true);
    
    // Also support POST with parameters for compatibility
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $certification_id = isset($_POST['certification_id']) ? intval($_POST['certification_id']) : 0;
        $owner_email = isset($_POST['owner_email']) ? trim($_POST['owner_email']) : '';
    } else {
        $certification_id = isset($input['certification_id']) ? intval($input['certification_id']) : 0;
        $owner_email = isset($input['owner_email']) ? trim($input['owner_email']) : '';
    }

    if (empty($certification_id) || empty($owner_email)) {
        echo json_encode(['success' => false, 'error' => 'Missing required fields']);
        exit;
    }

    // Verify owner owns this certification's dorm
    $stmt = $pdo->prepare("
        SELECT dc.file_path
        FROM dorm_certifications dc
        JOIN dormitories d ON dc.dorm_id = d.dorm_id
        JOIN users u ON d.owner_id = u.user_id
        WHERE dc.certification_id = ? AND u.email = ? AND u.role = 'owner'
    ");
    $stmt->execute([$certification_id, $owner_email]);
    $certification = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$certification) {
        echo json_encode(['success' => false, 'error' => 'Unauthorized or certification not found']);
        exit;
    }

    // Delete file from server
    $file_path = '../../../' . $certification['file_path'];
    if (file_exists($file_path)) {
        unlink($file_path);
    }

    // Delete from database
    $stmt = $pdo->prepare("DELETE FROM dorm_certifications WHERE certification_id = ?");
    $stmt->execute([$certification_id]);

    echo json_encode([
        'success' => true,
        'message' => 'Certification deleted successfully'
    ]);

} catch (PDOException $e) {
    error_log('Database error in delete_certification.php: ' . $e->getMessage());
    echo json_encode(['success' => false, 'error' => 'Database error occurred']);
} catch (Exception $e) {
    error_log('Error in delete_certification.php: ' . $e->getMessage());
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
