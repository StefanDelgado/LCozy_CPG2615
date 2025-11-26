<?php
/**
 * Mobile API: Get Past Tenants (Owner)
 * GET /mobile-api/checkout/get_past_tenants.php?owner_id=123
 * 
 * Returns completed checkouts / past tenants
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
    // Fetch completed checkouts
    $stmt = $pdo->prepare("
        SELECT 
            t.tenant_id,
            t.booking_id,
            t.dorm_id,
            t.room_id,
            t.check_in_date,
            t.checkout_date,
            t.total_paid,
            t.outstanding_balance,
            u.name AS tenant_name,
            u.email AS tenant_email,
            d.name AS dorm_name,
            d.address AS dorm_address,
            r.room_type,
            r.price,
            b.booking_type,
            b.start_date,
            b.end_date
        FROM tenants t
        JOIN bookings b ON t.booking_id = b.booking_id
        JOIN rooms r ON t.room_id = r.room_id
        JOIN dormitories d ON t.dorm_id = d.dorm_id
        JOIN users u ON t.student_id = u.user_id
        WHERE d.owner_id = ? AND t.status = 'completed'
        ORDER BY t.checkout_date DESC
    ");
    $stmt->execute([$owner_id]);
    $past_tenants = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Format the response
    $formatted_tenants = array_map(function($tenant) {
        // Calculate duration
        $check_in = new DateTime($tenant['check_in_date']);
        $check_out = new DateTime($tenant['checkout_date']);
        $duration_days = $check_in->diff($check_out)->days;
        
        return [
            'tenant_id' => (int)$tenant['tenant_id'],
            'booking_id' => (int)$tenant['booking_id'],
            'tenant_name' => $tenant['tenant_name'],
            'tenant_email' => $tenant['tenant_email'],
            'dorm_id' => (int)$tenant['dorm_id'],
            'dorm_name' => $tenant['dorm_name'],
            'dorm_address' => $tenant['dorm_address'],
            'room_id' => (int)$tenant['room_id'],
            'room_type' => $tenant['room_type'],
            'booking_type' => $tenant['booking_type'],
            'price' => (float)$tenant['price'],
            'check_in_date' => $tenant['check_in_date'],
            'checkout_date' => $tenant['checkout_date'],
            'duration_days' => $duration_days,
            'total_paid' => (float)$tenant['total_paid'],
            'outstanding_balance' => (float)$tenant['outstanding_balance'],
            'payment_status' => (float)$tenant['outstanding_balance'] > 0 ? 'incomplete' : 'complete'
        ];
    }, $past_tenants);

    echo json_encode([
        'success' => true,
        'data' => $formatted_tenants,
        'count' => count($formatted_tenants)
    ]);

} catch (Exception $e) {
    error_log('Get past tenants error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'An error occurred while fetching past tenants']);
}
