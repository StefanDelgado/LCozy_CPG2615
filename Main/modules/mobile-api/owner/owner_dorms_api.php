<?php
require_once __DIR__ . '/../../../config.php';
require_once __DIR__ . '/../shared/cors.php';

header('Content-Type: application/json');

if (!isset($_GET['owner_email'])) {
    echo json_encode(['error' => 'Owner email required']);
    exit;
}

$owner_email = $_GET['owner_email'];

try {
    // Get owner ID
    $stmt = $pdo->prepare("SELECT user_id FROM users WHERE email = ? AND role = 'owner'");
    $stmt->execute([$owner_email]);
    $owner = $stmt->fetch();

    if (!$owner) {
        echo json_encode(['error' => 'Owner not found']);
        exit;
    }

    // Fetch owner's dorms with room counts
    $stmt = $pdo->prepare("
        SELECT 
            d.dorm_id,
            d.name,
            d.address,
            d.description,
            d.verified,
            d.cover_image,
            d.features,
            COUNT(r.room_id) as room_count,
            (SELECT COUNT(*) 
             FROM bookings b 
             JOIN rooms r2 ON b.room_id = r2.room_id 
             WHERE r2.dorm_id = d.dorm_id AND b.status = 'approved') as active_bookings,
            (SELECT ROUND(AVG(r.rating),1) FROM reviews r WHERE r.dorm_id = d.dorm_id AND r.status = 'approved') as avg_rating,
            (SELECT COUNT(*) FROM reviews r WHERE r.dorm_id = d.dorm_id AND r.status = 'approved') as total_reviews
        FROM dormitories d
        LEFT JOIN rooms r ON d.dorm_id = r.dorm_id
        WHERE d.owner_id = ?
        GROUP BY d.dorm_id
    ");
    $stmt->execute([$owner['user_id']]);
    
    // Return dorms as direct array (expected by mobile app)
    echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));

} catch (Exception $e) {
    error_log('Owner dorms API error: ' . $e->getMessage());
    echo json_encode(['error' => 'Server error']);
}