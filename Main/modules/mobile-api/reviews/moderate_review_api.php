<?php
require_once __DIR__ . '/../../../config.php';
require_once __DIR__ . '/../shared/cors.php';
header('Content-Type: application/json');

try {
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);

    // Validate required fields
    if (!isset($data['review_id'], $data['action'])) {
        echo json_encode(['success' => false, 'error' => 'Missing required fields']);
        exit;
    }
    $review_id = intval($data['review_id']);
    $action = strtolower($data['action']);
    if (!in_array($action, ['approve', 'reject'])) {
        echo json_encode(['success' => false, 'error' => 'Invalid action']);
        exit;
    }
    $status = $action === 'approve' ? 'approved' : 'rejected';

    // Update review status
    $stmt = $pdo->prepare("UPDATE reviews SET status = ? WHERE review_id = ?");
    $stmt->execute([$status, $review_id]);

    echo json_encode(['success' => true, 'message' => 'Review ' . $status]);
} catch (Exception $e) {
    error_log('Moderate review API error: ' . $e->getMessage());
    echo json_encode(['success' => false, 'error' => 'Server error']);
}
