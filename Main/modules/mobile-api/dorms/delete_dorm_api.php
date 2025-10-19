<?php
require_once __DIR__ . '/../../../config.php';
require_once __DIR__ . '/../shared/cors.php';

header('Content-Type: application/json');

try {
    // Handle both JSON and POST data
    $data = $_POST;
    if (empty($data)) {
        $json = file_get_contents('php://input');
        $data = json_decode($json, true);
    }

    // Validate required fields
    if (!isset($data['dorm_id'])) {
        echo json_encode([
            'success' => false,
            'error' => 'Dorm ID required',
            'message' => 'Dorm ID is required'
        ]);
        exit;
    }

    $dormId = $data['dorm_id'];

    // First check if dorm exists and get owner info
    $stmt = $pdo->prepare("SELECT dorm_id, name, owner_id FROM dormitories WHERE dorm_id = ?");
    $stmt->execute([$dormId]);
    $dorm = $stmt->fetch();

    if (!$dorm) {
        echo json_encode([
            'success' => false,
            'error' => 'Dorm not found',
            'message' => 'The specified dorm does not exist'
        ]);
        exit;
    }

    // Delete associated rooms first (foreign key constraint)
    $stmt = $pdo->prepare("DELETE FROM rooms WHERE dorm_id = ?");
    $stmt->execute([$dormId]);

    // Delete associated bookings
    $stmt = $pdo->prepare("DELETE FROM reservations WHERE dorm_id = ?");
    $stmt->execute([$dormId]);

    // Delete the dorm
    $stmt = $pdo->prepare("DELETE FROM dormitories WHERE dorm_id = ?");
    $stmt->execute([$dormId]);

    if ($stmt->rowCount() > 0) {
        echo json_encode([
            'success' => true,
            'message' => 'Dorm and associated data deleted successfully'
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'error' => 'Delete failed',
            'message' => 'Failed to delete the dorm'
        ]);
    }

} catch (Exception $e) {
    error_log('Delete dorm API error: ' . $e->getMessage());
    echo json_encode([
        'success' => false,
        'error' => 'Server error',
        'message' => 'An error occurred while deleting the dorm: ' . $e->getMessage()
    ]);
}
