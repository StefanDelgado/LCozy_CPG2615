<?php
/**
 * Mobile API: Get Owner's Checkout Requests
 * GET /mobile-api/checkout/get_owner_requests.php?owner_id=123
 * 
 * Returns all checkout requests for owner's properties
 */

header('Content-Type: application/json');
require_once __DIR__ . '/../../../config.php';

// Get owner_id from query parameter
$owner_id = isset($_GET['owner_id']) ? (int)$_GET['owner_id'] : 0;

if (!$owner_id) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'Missing owner_id parameter']);
    exit;
}

try {
    // Fetch checkout requests
    $stmt = $pdo->prepare("
        SELECT 
            cr.id AS request_id,
            cr.booking_id,
            cr.tenant_id,
            cr.owner_id,
            cr.request_reason,
            cr.status,
            cr.processed_by,
            cr.created_at,
            cr.updated_at,
            cr.processed_at,
            b.start_date,
            b.end_date,
            b.booking_type,
            b.status AS booking_status,
            u.name AS tenant_name,
            u.email AS tenant_email,
            d.dorm_id,
            d.name AS dorm_name,
            d.address AS dorm_address,
            r.room_id,
            r.room_type,
            r.price
        FROM checkout_requests cr
        JOIN bookings b ON cr.booking_id = b.booking_id
        JOIN users u ON cr.tenant_id = u.user_id
        JOIN rooms r ON b.room_id = r.room_id
        JOIN dormitories d ON r.dorm_id = d.dorm_id
        WHERE cr.owner_id = ?
        ORDER BY 
            CASE cr.status
                WHEN 'requested' THEN 1
                WHEN 'approved' THEN 2
                WHEN 'disapproved' THEN 3
                WHEN 'completed' THEN 4
            END,
            cr.created_at DESC
    ");
    $stmt->execute([$owner_id]);
    $requests = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Format the response
    $formatted_requests = array_map(function($req) {
        return [
            'request_id' => (int)$req['request_id'],
            'booking_id' => (int)$req['booking_id'],
            'tenant_id' => (int)$req['tenant_id'],
            'tenant_name' => $req['tenant_name'],
            'tenant_email' => $req['tenant_email'],
            'dorm_id' => (int)$req['dorm_id'],
            'dorm_name' => $req['dorm_name'],
            'dorm_address' => $req['dorm_address'],
            'room_id' => (int)$req['room_id'],
            'room_type' => $req['room_type'],
            'price' => (float)$req['price'],
            'booking_type' => $req['booking_type'],
            'start_date' => $req['start_date'],
            'end_date' => $req['end_date'],
            'request_reason' => $req['request_reason'],
            'status' => $req['status'],
            'booking_status' => $req['booking_status'],
            'created_at' => $req['created_at'],
            'updated_at' => $req['updated_at'],
            'processed_at' => $req['processed_at'],
            'processed_by' => $req['processed_by'] ? (int)$req['processed_by'] : null,
            'can_approve' => $req['status'] === 'requested',
            'can_complete' => $req['status'] === 'approved'
        ];
    }, $requests);

    // Group by status for easier UI handling
    $grouped = [
        'pending' => array_filter($formatted_requests, fn($r) => $r['status'] === 'requested'),
        'approved' => array_filter($formatted_requests, fn($r) => $r['status'] === 'approved'),
        'completed' => array_filter($formatted_requests, fn($r) => $r['status'] === 'completed'),
        'disapproved' => array_filter($formatted_requests, fn($r) => $r['status'] === 'disapproved')
    ];

    echo json_encode([
        'success' => true,
        'data' => [
            'all' => array_values($formatted_requests),
            'grouped' => [
                'pending' => array_values($grouped['pending']),
                'approved' => array_values($grouped['approved']),
                'completed' => array_values($grouped['completed']),
                'disapproved' => array_values($grouped['disapproved'])
            ]
        ],
        'count' => [
            'total' => count($formatted_requests),
            'pending' => count($grouped['pending']),
            'approved' => count($grouped['approved']),
            'completed' => count($grouped['completed']),
            'disapproved' => count($grouped['disapproved'])
        ]
    ]);

} catch (Exception $e) {
    error_log('Get owner checkout requests error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'An error occurred while fetching checkout requests']);
}
