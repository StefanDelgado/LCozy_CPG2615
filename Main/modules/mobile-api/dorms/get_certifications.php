<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

require_once '../../../config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    echo json_encode(['success' => false, 'error' => 'Invalid request method']);
    exit;
}

try {
    $dorm_id = isset($_GET['dorm_id']) ? intval($_GET['dorm_id']) : 0;

    if (empty($dorm_id)) {
        echo json_encode(['success' => false, 'error' => 'Missing dorm_id']);
        exit;
    }

    // Get all certifications for this dorm
    $stmt = $pdo->prepare("
        SELECT 
            certification_id,
            dorm_id,
            file_name,
            file_path,
            certification_type,
            uploaded_at
        FROM dorm_certifications
        WHERE dorm_id = ?
        ORDER BY uploaded_at DESC
    ");
    $stmt->execute([$dorm_id]);
    $certifications = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        'success' => true,
        'certifications' => $certifications,
        'count' => count($certifications)
    ]);

} catch (PDOException $e) {
    error_log('Database error in get_certifications.php: ' . $e->getMessage());
    echo json_encode(['success' => false, 'error' => 'Database error occurred']);
} catch (Exception $e) {
    error_log('Error in get_certifications.php: ' . $e->getMessage());
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
