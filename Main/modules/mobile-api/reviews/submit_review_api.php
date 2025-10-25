<?php
require_once __DIR__ . '/../../../config.php';
require_once __DIR__ . '/../shared/cors.php';
header('Content-Type: application/json');

try {
    $json = file_get_contents('php://input');
    error_log('SubmitReviewAPI RAW: ' . $json);
    $data = json_decode($json, true);
    error_log('SubmitReviewAPI DECODED: ' . print_r($data, true));

    // Validate required fields
    if (!isset($data['booking_id'], $data['rating'], $data['comment'], $data['student_id'])) {
        echo json_encode([
            'success' => false,
            'error' => 'Missing required fields',
            'received' => $data
        ]);
        exit;
    }
    $booking_id = intval($data['booking_id']);
    $rating = intval($data['rating']);
    $comment = trim($data['comment']);
    $student_id = intval($data['student_id']);
    error_log("SubmitReviewAPI booking_id=$booking_id rating=$rating comment=$comment student_id=$student_id");

    // Check if booking is completed and belongs to student
    $stmt = $pdo->prepare("SELECT b.booking_id, r.dorm_id FROM bookings b JOIN rooms r ON b.room_id = r.room_id WHERE b.booking_id = ? AND b.student_id = ? AND b.status = 'completed'");
    $stmt->execute([$booking_id, $student_id]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$row) {
        echo json_encode(['success' => false, 'error' => 'Booking not eligible for review']);
        exit;
    }
    $dorm_id = $row['dorm_id'];

    // Insert review (status = pending)
    $stmt = $pdo->prepare("INSERT INTO reviews (booking_id, student_id, dorm_id, rating, comment, status) VALUES (?, ?, ?, ?, ?, 'approved')");
    $stmt->execute([$booking_id, $student_id, $dorm_id, $rating, $comment]);

    echo json_encode(['success' => true, 'message' => 'Review submitted and approved']);
} catch (Exception $e) {
    error_log('Submit review API error: ' . $e->getMessage());
    echo json_encode(['success' => false, 'error' => 'Server error']);
}
