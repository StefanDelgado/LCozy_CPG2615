<?php
require_once __DIR__ . '/../../../config.php';
require_once __DIR__ . '/../shared/cors.php';

header('Content-Type: application/json');

try {
    // Fetch featured/available dorms with their details
    $stmt = $pdo->prepare("
        SELECT 
            d.dorm_id,
            d.name as title,
            d.address as location,
            d.description as `desc`,
            d.cover_image as image,
            d.features,
            d.verified,
            d.latitude,
            d.longitude,
            u.email as owner_email,
            u.name as owner_name,
            (
                SELECT COUNT(*) 
                FROM rooms r 
                WHERE r.dorm_id = d.dorm_id 
                AND r.status = 'vacant'
            ) as available_rooms,
            MIN(r.price) as min_price
        FROM dormitories d
        JOIN users u ON d.owner_id = u.user_id
        LEFT JOIN rooms r ON d.dorm_id = r.dorm_id
        WHERE d.verified = 1
        GROUP BY d.dorm_id
        ORDER BY d.created_at DESC
    ");
    
    $stmt->execute();
    $dorms = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Format the response
    $formatted_dorms = array_map(function($dorm) {
        return [
            'dorm_id' => $dorm['dorm_id'],
            'image' => $dorm['image'] ? SITE_URL . "/uploads/dorms/{$dorm['image']}" : null,
            'location' => $dorm['location'],
            'title' => $dorm['title'],
            'desc' => $dorm['desc'],
            'features' => $dorm['features'],
            'latitude' => $dorm['latitude'],
            'longitude' => $dorm['longitude'],
            'owner_email' => $dorm['owner_email'],
            'owner_name' => $dorm['owner_name'],
            'available_rooms' => (int)$dorm['available_rooms'],
            'min_price' => $dorm['min_price'] ? "₱" . number_format($dorm['min_price'], 2) : null,
            'type' => determineType($dorm['location'], $dorm['min_price'])
        ];
    }, $dorms);

    echo json_encode([
        'ok' => true,
        'dorms' => $formatted_dorms
    ]);

} catch (Exception $e) {
    error_log('Student home API error: ' . $e->getMessage());
    echo json_encode(['error' => 'Server error']);
}

function determineType($location, $price) {
    if (stripos($location, 'campus') !== false) return 'Near Campus';
    if (stripos($location, 'city') !== false) return 'City Center';
    if ($price < 3000) return 'Budget';
    return 'Premium';
}