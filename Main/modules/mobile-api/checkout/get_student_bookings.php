<?php
/**
 * Mobile API: Get Student's Active Bookings (for checkout request)
 * GET /mobile-api/checkout/get_student_bookings.php?student_id=123
 * 
 * Returns bookings that can be checked out
 */

header('Content-Type: application/json');
require_once __DIR__ . '/../../../config.php';

// Get student_id from query parameter
$student_id = isset($_GET['student_id']) ? (int)$_GET['student_id'] : 0;

if (!$student_id) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'Missing student_id parameter']);
    exit;
}

try {
    // Fetch active bookings for this student
    $stmt = $pdo->prepare("
        SELECT 
            b.booking_id,
            b.room_id,
            b.booking_type,
            b.start_date,
            b.end_date,
            b.status,
            b.created_at,
            d.dorm_id,
            d.name AS dorm_name,
            d.address AS dorm_address,
            r.room_type,
            r.price,
            cr.id AS checkout_request_id,
            cr.status AS checkout_status,
            cr.created_at AS checkout_requested_at
        FROM bookings b
        JOIN rooms r ON b.room_id = r.room_id
        JOIN dormitories d ON r.dorm_id = d.dorm_id
        LEFT JOIN checkout_requests cr ON b.booking_id = cr.booking_id 
            AND cr.status IN ('requested', 'approved')
        WHERE b.student_id = ? 
            AND b.status IN ('active', 'approved', 'checkout_requested', 'checkout_approved')
        ORDER BY b.start_date DESC
    ");
    $stmt->execute([$student_id]);
    $bookings = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Format the response
    $formatted_bookings = array_map(function($booking) {
        return [
            'booking_id' => (int)$booking['booking_id'],
            'room_id' => (int)$booking['room_id'],
            'dorm_id' => (int)$booking['dorm_id'],
            'dorm_name' => $booking['dorm_name'],
            'dorm_address' => $booking['dorm_address'],
            'room_type' => $booking['room_type'],
            'booking_type' => $booking['booking_type'],
            'price' => (float)$booking['price'],
            'start_date' => $booking['start_date'],
            'end_date' => $booking['end_date'],
            'status' => $booking['status'],
            'created_at' => $booking['created_at'],
            'can_request_checkout' => in_array($booking['status'], ['active', 'approved']) && !$booking['checkout_request_id'],
            'checkout_status' => $booking['checkout_status'],
            'checkout_requested_at' => $booking['checkout_requested_at']
        ];
    }, $bookings);

    echo json_encode([
        'success' => true,
        'data' => $formatted_bookings,
        'count' => count($formatted_bookings)
    ]);

} catch (Exception $e) {
    error_log('Get student bookings error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'An error occurred while fetching bookings']);
}
