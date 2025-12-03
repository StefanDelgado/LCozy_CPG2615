<?php
/**
 * Reject Cancellation Request API
 * 
 * Allows dorm owners to reject/cancel a cancellation request
 * and revert the booking back to its previous status (typically 'pending' or 'approved')
 * 
 * Request format:
 * {
 *   "booking_id": 123,
 *   "owner_email": "owner@example.com"
 * }
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once '../../config/database.php';

// Only allow POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'error' => 'Method not allowed']);
    exit();
}

try {
    // Get JSON input
    $input = json_decode(file_get_contents('php://input'), true);
    
    // Validate required fields
    if (!isset($input['booking_id']) || !isset($input['owner_email'])) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'error' => 'Missing required fields: booking_id and owner_email'
        ]);
        exit();
    }
    
    $booking_id = intval($input['booking_id']);
    $owner_email = trim($input['owner_email']);
    
    // Get database connection
    $database = new Database();
    $pdo = $database->getConnection();
    
    // Verify owner exists and get owner_id
    $stmt = $pdo->prepare("
        SELECT user_id, name 
        FROM users 
        WHERE email = ? AND role = 'owner'
    ");
    $stmt->execute([$owner_email]);
    $owner = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$owner) {
        http_response_code(403);
        echo json_encode([
            'success' => false,
            'error' => 'Owner not found or invalid credentials'
        ]);
        exit();
    }
    
    // Verify booking exists and belongs to owner's dorm
    $stmt = $pdo->prepare("
        SELECT 
            b.booking_id,
            b.status,
            b.student_id,
            d.owner_id,
            d.name as dorm_name
        FROM bookings b
        JOIN rooms r ON b.room_id = r.room_id
        JOIN dormitories d ON r.dorm_id = d.dorm_id
        WHERE b.booking_id = ?
    ");
    $stmt->execute([$booking_id]);
    $booking = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$booking) {
        http_response_code(404);
        echo json_encode([
            'success' => false,
            'error' => 'Booking not found'
        ]);
        exit();
    }
    
    // Verify owner owns this dorm
    if ($booking['owner_id'] != $owner['user_id']) {
        http_response_code(403);
        echo json_encode([
            'success' => false,
            'error' => 'You do not have permission to manage this booking'
        ]);
        exit();
    }
    
    // Check if booking status is cancellation_requested
    if (strtolower($booking['status']) !== 'cancellation_requested') {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'error' => 'Can only reject cancellation requests. Current status: ' . $booking['status']
        ]);
        exit();
    }
    
    // Begin transaction
    $pdo->beginTransaction();
    
    try {
        // Update booking status back to approved (owner is rejecting the cancellation)
        $stmt = $pdo->prepare("
            UPDATE bookings 
            SET status = 'approved',
                notes = CONCAT(
                    COALESCE(notes, ''),
                    IF(COALESCE(notes, '') != '', '\n', ''),
                    'Cancellation request rejected by owner on ', DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s')
                ),
                updated_at = NOW()
            WHERE booking_id = ?
        ");
        $stmt->execute([$booking_id]);
        
        $pdo->commit();
        
        http_response_code(200);
        echo json_encode([
            'success' => true,
            'message' => 'Cancellation request rejected successfully. Booking has been reverted to approved status.',
            'status' => 'approved'
        ]);
        
    } catch (Exception $e) {
        $pdo->rollBack();
        error_log("Transaction error: " . $e->getMessage());
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'error' => 'Failed to reject cancellation request: ' . $e->getMessage()
        ]);
    }
    
} catch (Exception $e) {
    error_log("Error in reject_cancellation_request.php: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Server error: ' . $e->getMessage()
    ]);
}
