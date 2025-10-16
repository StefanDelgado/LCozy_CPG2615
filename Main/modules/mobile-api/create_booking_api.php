<?php
// Prevent any output before headers
error_reporting(E_ALL);
ini_set('display_errors', 0); // Don't display errors in output
ini_set('log_errors', 1);

require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/cors.php';

header('Content-Type: application/json');

// Check if PDO is initialized
if (!isset($pdo) || $pdo === null) {
    http_response_code(500);
    echo json_encode(['ok' => false, 'error' => 'Database connection failed']);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['ok' => false, 'error' => 'Method not allowed']);
    exit;
}

try {
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);

    // Validate required fields
    if (!isset($data['student_email']) || !isset($data['room_id'])) {
        http_response_code(400);
        echo json_encode(['ok' => false, 'error' => 'Student email and room ID required']);
        exit;
    }

    $student_email = trim($data['student_email']);
    $room_id = intval($data['room_id']);
    $booking_type = $data['booking_type'] ?? 'shared'; // 'whole' or 'shared'
    $start_date = $data['start_date'] ?? date('Y-m-d');
    $end_date = $data['end_date'] ?? date('Y-m-d', strtotime('+6 months'));

    // Get student ID
    $stmt = $pdo->prepare("SELECT user_id FROM users WHERE email = ? AND role = 'student'");
    $stmt->execute([$student_email]);
    $student = $stmt->fetch();

    if (!$student) {
        http_response_code(404);
        echo json_encode(['ok' => false, 'error' => 'Student not found']);
        exit;
    }

    $student_id = $student['user_id'];

    // Check if student already has an active booking in this dorm
    $check_existing = $pdo->prepare("
        SELECT b.booking_id 
        FROM bookings b
        JOIN rooms r ON b.room_id = r.room_id
        WHERE b.student_id = ? 
          AND r.dorm_id = (SELECT dorm_id FROM rooms WHERE room_id = ?)
          AND b.status IN ('pending', 'approved')
    ");
    $check_existing->execute([$student_id, $room_id]);
    $already_booked = $check_existing->fetch();

    if ($already_booked) {
        echo json_encode([
            'ok' => false,
            'error' => 'You already have an active booking in this dormitory.'
        ]);
        exit;
    }

    // Check room availability
    $check = $pdo->prepare("
        SELECT r.capacity, r.status, r.dorm_id,
               COUNT(b.booking_id) AS total_booked
        FROM rooms r
        LEFT JOIN bookings b ON b.room_id = r.room_id AND b.status IN ('pending','approved')
        WHERE r.room_id = ?
        GROUP BY r.room_id
    ");
    $check->execute([$room_id]);
    $room_info = $check->fetch(PDO::FETCH_ASSOC);

    if (!$room_info) {
        echo json_encode(['ok' => false, 'error' => 'Room not found']);
        exit;
    }

    // Check if room has available slots
    $available_slots = $room_info['capacity'] - $room_info['total_booked'];
    
    if ($booking_type === 'whole' && $room_info['total_booked'] > 0) {
        echo json_encode([
            'ok' => false,
            'error' => 'This room is already partially booked. Whole room booking is not available.'
        ]);
        exit;
    }

    if ($available_slots <= 0) {
        echo json_encode([
            'ok' => false,
            'error' => 'No available slots in this room.'
        ]);
        exit;
    }

    // Create booking
    $expires_at = date('Y-m-d H:i:s', strtotime('+2 hours'));
    
    $stmt = $pdo->prepare("
        INSERT INTO bookings (
            room_id, student_id, start_date, end_date, 
            status, booking_type, expires_at, created_at
        ) VALUES (?, ?, ?, ?, 'pending', ?, ?, NOW())
    ");
    
    $stmt->execute([
        $room_id,
        $student_id,
        $start_date,
        $end_date,
        $booking_type,
        $expires_at
    ]);

    $booking_id = $pdo->lastInsertId();

    // Update room status if fully booked
    if ($booking_type === 'whole' || $available_slots <= 1) {
        $pdo->prepare("UPDATE rooms SET status = 'occupied' WHERE room_id = ?")->execute([$room_id]);
    }

    // Get booking details to return with calculated price
    $stmt = $pdo->prepare("
        SELECT 
            b.booking_id,
            b.status,
            b.start_date,
            b.end_date,
            b.booking_type,
            d.name as dorm_name,
            r.room_type,
            r.price as base_price,
            r.capacity
        FROM bookings b
        JOIN rooms r ON b.room_id = r.room_id
        JOIN dormitories d ON r.dorm_id = d.dorm_id
        WHERE b.booking_id = ?
    ");
    $stmt->execute([$booking_id]);
    $booking = $stmt->fetch(PDO::FETCH_ASSOC);

    // Calculate price based on booking type
    $base_price = (float)$booking['base_price'];
    $capacity = (int)$booking['capacity'];
    
    if ($booking_type === 'shared' && $capacity > 0) {
        // For shared booking, divide price by room capacity
        $calculated_price = $base_price / $capacity;
    } else {
        // For whole room booking, use full price
        $calculated_price = $base_price;
    }

    echo json_encode([
        'ok' => true,
        'message' => 'Booking request submitted successfully! Awaiting owner approval.',
        'booking' => [
            'booking_id' => (int)$booking['booking_id'],
            'status' => $booking['status'],
            'start_date' => $booking['start_date'],
            'end_date' => $booking['end_date'],
            'booking_type' => $booking['booking_type'],
            'dorm_name' => $booking['dorm_name'],
            'room_type' => $booking['room_type'],
            'base_price' => $base_price,
            'capacity' => $capacity,
            'price' => $calculated_price
        ]
    ]);

} catch (PDOException $e) {
    error_log('Booking API error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'ok' => false,
        'error' => 'Database error occurred'
    ]);
} catch (Exception $e) {
    error_log('Booking API error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'ok' => false,
        'error' => 'Server error occurred'
    ]);
}