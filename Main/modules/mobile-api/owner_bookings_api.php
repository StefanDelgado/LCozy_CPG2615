<?php
require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/cors.php';

header('Content-Type: application/json');

$owner_email = $_GET['owner_email'] ?? '';

if (!$owner_email) {
    echo json_encode(['error' => 'Owner email required']);
    exit;
}

try {
    // Get owner details
    $stmt = $pdo->prepare("SELECT user_id FROM users WHERE email = ? AND role = 'owner'");
    $stmt->execute([$owner_email]);
    $owner = $stmt->fetch();

    if (!$owner) {
        echo json_encode(['error' => 'Owner not found']);
        exit;
    }

    // Fetch bookings for owner's dorms
    $stmt = $pdo->prepare("
        SELECT 
            b.booking_id as id,
            u.email as student_email,
            u.name as student_name,
            b.created_at as requested_at,
            b.status,
            d.name as dorm,
            r.room_type,
            r.price,
            b.booking_type as duration,
            b.start_date,
            b.notes as message
        FROM bookings b
        JOIN rooms r ON b.room_id = r.room_id
        JOIN dormitories d ON r.dorm_id = d.dorm_id
        JOIN users u ON b.student_id = u.user_id
        WHERE d.owner_id = ?
        ORDER BY b.created_at DESC
    ");
    $stmt->execute([$owner['user_id']]);
    $bookings = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Format data for mobile app
    $formatted = array_map(function($b) {
        return [
            'id' => $b['id'],
            'student_email' => $b['student_email'],
            'student_name' => $b['student_name'], 
            'requested_at' => timeAgo($b['requested_at']),
            'status' => ucfirst(strtolower($b['status'])),
            'dorm' => $b['dorm'],
            'room_type' => $b['room_type'],
            'duration' => $b['duration'],
            'start_date' => $b['start_date'],
            'price' => '₱' . number_format($b['price'], 2),
            'message' => $b['message'] ?? 'No additional message'
        ];
    }, $bookings);

    echo json_encode(['ok' => true, 'bookings' => $formatted]);

} catch (Exception $e) {
    error_log('Owner bookings API error: ' . $e->getMessage());
    echo json_encode(['error' => 'Server error']);
}

function timeAgo($datetime) {
    $now = new DateTime();
    $ago = new DateTime($datetime);
    $diff = $now->diff($ago);

    if ($diff->d > 0) return $diff->d . "d ago";
    if ($diff->h > 0) return $diff->h . "h ago";
    if ($diff->i > 0) return $diff->i . "m ago";
    return "Just now";
}