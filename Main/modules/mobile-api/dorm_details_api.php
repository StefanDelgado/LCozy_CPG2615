<?php
require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/cors.php';

header('Content-Type: application/json');
error_reporting(E_ALL);
ini_set('display_errors', 1); // Show errors for debugging

// Check if PDO is initialized
if (!isset($pdo) || $pdo === null) {
    http_response_code(500);
    echo json_encode(['ok' => false, 'error' => 'Database connection not initialized']);
    exit;
}

if (!isset($_GET['dorm_id'])) {
    http_response_code(400);
    echo json_encode(['ok' => false, 'error' => 'Dorm ID required']);
    exit;
}

$dorm_id = intval($_GET['dorm_id']);

try {
    // Fetch dorm details with owner info and reviews
    $stmt = $pdo->prepare("
        SELECT 
            d.dorm_id,
            d.name,
            d.address,
            d.description,
            d.cover_image,
            d.features,
            d.verified,
            d.latitude,
            d.longitude,
            u.user_id as owner_id,
            u.name as owner_name,
            u.email as owner_email,
            u.phone as owner_phone,
            COALESCE(AVG(r.rating), 0) as avg_rating,
            COUNT(DISTINCT r.review_id) as total_reviews,
            COUNT(DISTINCT rooms.room_id) as total_rooms
        FROM dormitories d
        JOIN users u ON d.owner_id = u.user_id
        LEFT JOIN reviews r ON d.dorm_id = r.dorm_id AND r.status = 'approved'
        LEFT JOIN rooms ON d.dorm_id = rooms.dorm_id
        WHERE d.dorm_id = ?
        GROUP BY d.dorm_id
    ");
    $stmt->execute([$dorm_id]);
    $dorm = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$dorm) {
        http_response_code(404);
        echo json_encode(['ok' => false, 'error' => 'Dorm not found']);
        exit;
    }

    // Fetch all rooms for this dorm
    $roomsStmt = $pdo->prepare("
        SELECT 
            r.room_id,
            r.room_type,
            r.room_number,
            r.capacity,
            r.price,
            r.status,
            r.size,
            r.features as room_features,
            (SELECT COUNT(*) 
             FROM bookings b 
             WHERE b.room_id = r.room_id 
             AND b.status IN ('approved', 'pending')) as booked_count
        FROM rooms r
        WHERE r.dorm_id = ?
        ORDER BY r.price ASC
    ");
    $roomsStmt->execute([$dorm_id]);
    $rooms = $roomsStmt->fetchAll(PDO::FETCH_ASSOC);

    // Format rooms with availability
    $formatted_rooms = array_map(function($room) {
        $available_slots = (int)$room['capacity'] - (int)$room['booked_count'];
        return [
            'room_id' => (int)$room['room_id'],
            'room_type' => $room['room_type'],
            'room_number' => $room['room_number'],
            'capacity' => (int)$room['capacity'],
            'price' => (float)$room['price'],
            'status' => $room['status'],
            'size' => $room['size'] ? (float)$room['size'] : null,
            'features' => $room['room_features'],
            'available_slots' => $available_slots,
            'is_available' => $available_slots > 0
        ];
    }, $rooms);

    // Fetch approved reviews
    $reviewsStmt = $pdo->prepare("
        SELECT 
            r.review_id,
            r.rating,
            r.comment,
            r.created_at,
            u.name as student_name
        FROM reviews r
        JOIN users u ON r.student_id = u.user_id
        WHERE r.dorm_id = ? 
        AND r.status = 'approved'
        ORDER BY r.created_at DESC
        LIMIT 10
    ");
    $reviewsStmt->execute([$dorm_id]);
    $reviews = $reviewsStmt->fetchAll(PDO::FETCH_ASSOC);

    // Fetch dorm images
    $imagesStmt = $pdo->prepare("
        SELECT image_path 
        FROM room_images ri
        JOIN rooms r ON ri.room_id = r.room_id
        WHERE r.dorm_id = ?
        ORDER BY ri.uploaded_at DESC
        LIMIT 5
    ");
    $imagesStmt->execute([$dorm_id]);
    $roomImages = $imagesStmt->fetchAll(PDO::FETCH_COLUMN);

    // Build images array
    $images = [];
    if ($dorm['cover_image']) {
        $images[] = 'http://cozydorms.life/uploads/' . $dorm['cover_image'];
    }
    foreach ($roomImages as $img) {
        $images[] = 'http://cozydorms.life/uploads/' . $img;
    }

    // Parse features
    $features_list = [];
    if ($dorm['features']) {
        $features_list = array_map('trim', explode(',', $dorm['features']));
    }

    // Calculate min and max price
    $prices = array_column($formatted_rooms, 'price');
    $min_price = !empty($prices) ? min($prices) : 0;
    $max_price = !empty($prices) ? max($prices) : 0;

    // Return complete dorm details
    echo json_encode([
        'ok' => true,
        'dorm' => [
            'dorm_id' => (int)$dorm['dorm_id'],
            'name' => $dorm['name'],
            'address' => $dorm['address'],
            'description' => $dorm['description'],
            'verified' => (bool)$dorm['verified'],
            'features' => $features_list,
            'images' => $images,
            'latitude' => $dorm['latitude'] ? (float)$dorm['latitude'] : 10.6765,
            'longitude' => $dorm['longitude'] ? (float)$dorm['longitude'] : 122.9509,
            'owner' => [
                'owner_id' => (int)$dorm['owner_id'],
                'name' => $dorm['owner_name'],
                'email' => $dorm['owner_email'],
                'phone' => $dorm['owner_phone'] ?: 'Not provided'
            ],
            'stats' => [
                'avg_rating' => round((float)$dorm['avg_rating'], 1),
                'total_reviews' => (int)$dorm['total_reviews'],
                'total_rooms' => (int)$dorm['total_rooms'],
                'available_rooms' => count(array_filter($formatted_rooms, fn($r) => $r['is_available']))
            ],
            'pricing' => [
                'min_price' => $min_price,
                'max_price' => $max_price,
                'currency' => '₱'
            ]
        ],
        'rooms' => $formatted_rooms,
        'reviews' => array_map(function($review) {
            return [
                'review_id' => (int)$review['review_id'],
                'rating' => (int)$review['rating'],
                'review' => $review['comment'] ?? '',
                'comment' => $review['comment'] ?? '',
                'student_name' => $review['student_name'],
                'created_at' => $review['created_at'],
                'stars' => str_repeat('⭐', (int)$review['rating'])
            ];
        }, $reviews)
    ]);

} catch (PDOException $e) {
    error_log('Dorm details API PDO error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'ok' => false, 
        'error' => 'Database error', 
        'debug' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine()
    ]);
} catch (Exception $e) {
    error_log('Dorm details API error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'ok' => false, 
        'error' => 'Server error',
        'debug' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine()
    ]);
}
