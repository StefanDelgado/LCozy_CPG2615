<?php
require_once __DIR__ . '/../config.php';

try {
    echo "=== Booking Maintenance Script ===\n";

    $stmt = $pdo->prepare("
        SELECT booking_id, room_id 
        FROM bookings 
        WHERE status = 'pending' 
          AND expires_at IS NOT NULL 
          AND expires_at < NOW()
    ");
    $stmt->execute();
    $expired = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if ($expired) {
        $cancelStmt = $pdo->prepare("UPDATE bookings SET status = 'cancelled' WHERE booking_id = ?");
        foreach ($expired as $b) {
            $cancelStmt->execute([$b['booking_id']]);
            echo "Cancelled expired booking ID #{$b['booking_id']} (Room #{$b['room_id']})\n";
        }
    } else {
        echo "No expired bookings found.\n";
    }

    $rooms = $pdo->query("
        SELECT r.room_id, r.capacity,
               COUNT(CASE WHEN b.status IN ('pending','approved') THEN 1 END) AS active_bookings
        FROM rooms r
        LEFT JOIN bookings b ON b.room_id = r.room_id
        GROUP BY r.room_id, r.capacity
    ")->fetchAll(PDO::FETCH_ASSOC);

    $updateRoom = $pdo->prepare("UPDATE rooms SET status = ? WHERE room_id = ?");

    foreach ($rooms as $room) {
        if ($room['active_bookings'] >= $room['capacity']) {
            $updateRoom->execute(['occupied', $room['room_id']]);
            echo "Room #{$room['room_id']} marked as OCCUPIED (Full capacity)\n";
        } else {
            $updateRoom->execute(['vacant', $room['room_id']]);
            echo "Room #{$room['room_id']} marked as VACANT ({$room['active_bookings']}/{$room['capacity']} occupied)\n";
        }
    }

    echo "=== Maintenance Complete ===\n";

} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}