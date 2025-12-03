<?php
require_once __DIR__ . '/../../../config.php';
require_once __DIR__ . '/../shared/cors.php';

header('Content-Type: application/json');

// Handle POST requests for booking actions (approve/reject)
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';
    $booking_id = $_POST['booking_id'] ?? '';
    $owner_email = $_POST['owner_email'] ?? '';

    error_log("POST request - action: $action, booking_id: $booking_id, owner_email: $owner_email");

    if (!$owner_email) {
        http_response_code(400);
        echo json_encode([
            'ok' => false,
            'success' => false,
            'error' => 'Owner email required'
        ]);
        exit;
    }

    if (!$booking_id) {
        http_response_code(400);
        echo json_encode([
            'ok' => false,
            'success' => false,
            'error' => 'Booking ID required'
        ]);
        exit;
    }

    if (!in_array($action, ['approve', 'reject'])) {
        http_response_code(400);
        echo json_encode([
            'ok' => false,
            'success' => false,
            'error' => 'Invalid action'
        ]);
        exit;
    }

    try {
        // Verify owner exists
        $stmt = $pdo->prepare("SELECT user_id FROM users WHERE email = ? AND role = 'owner'");
        $stmt->execute([$owner_email]);
        $owner = $stmt->fetch();

        if (!$owner) {
            http_response_code(404);
            echo json_encode(['ok' => false, 'error' => 'Owner not found']);
            exit;
        }

        // Verify booking belongs to owner's dorm
        $stmt = $pdo->prepare("
            SELECT b.booking_id, b.status, d.owner_id, b.room_id
            FROM bookings b
            JOIN rooms r ON b.room_id = r.room_id
            JOIN dormitories d ON r.dorm_id = d.dorm_id
            WHERE b.booking_id = ? AND d.owner_id = ?
        ");
        $stmt->execute([$booking_id, $owner['user_id']]);
        $booking = $stmt->fetch();

        if (!$booking) {
            http_response_code(403);
            echo json_encode([
                'ok' => false,
                'success' => false,
                'error' => 'Booking not found or access denied'
            ]);
            exit;
        }

        // Update booking status
        $new_status = $action === 'approve' ? 'approved' : 'rejected';
        $stmt = $pdo->prepare("UPDATE bookings SET status = ? WHERE booking_id = ?");
        $stmt->execute([$new_status, $booking_id]);

        // If approved, mark room as occupied AND create payment
        if ($action === 'approve') {
            $stmt = $pdo->prepare("UPDATE rooms SET status = 'occupied' WHERE room_id = ?");
            $stmt->execute([$booking['room_id']]);
            
            // Get booking details to create payment
            $stmt = $pdo->prepare("
                SELECT 
                    b.student_id,
                    b.booking_type,
                    b.start_date,
                    r.price as base_price,
                    r.capacity
                FROM bookings b
                JOIN rooms r ON b.room_id = r.room_id
                WHERE b.booking_id = ?
            ");
            $stmt->execute([$booking_id]);
            $booking_details = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if ($booking_details) {
                // Calculate payment amount based on booking type
                $base_price = (float)$booking_details['base_price'];
                $capacity = (int)$booking_details['capacity'];
                $booking_type = strtolower($booking_details['booking_type']);
                
                if ($booking_type === 'shared' && $capacity > 0) {
                    $payment_amount = $base_price / $capacity;
                } else {
                    $payment_amount = $base_price;
                }
                
                // Set due date (first payment due 7 days from start date or today, whichever is later)
                $start_date = $booking_details['start_date'];
                $today = date('Y-m-d');
                $due_date = max($start_date, date('Y-m-d', strtotime($today . ' +7 days')));
                
                // Create payment record
                $stmt = $pdo->prepare("
                    INSERT INTO payments (
                        student_id, 
                        booking_id, 
                        owner_id,
                        amount, 
                        status, 
                        payment_date, 
                        due_date,
                        created_at
                    ) VALUES (?, ?, ?, ?, 'pending', NOW(), ?, NOW())
                ");
                $stmt->execute([
                    $booking_details['student_id'],
                    $booking_id,
                    $owner['user_id'],
                    $payment_amount,
                    $due_date
                ]);
                
                $payment_id = $pdo->lastInsertId();
                error_log("Payment $payment_id created for booking $booking_id - Amount: $payment_amount, Due: $due_date");
            } else {
                error_log("WARNING: Could not create payment - booking details not found for booking $booking_id");
            }
        }

        error_log("Booking $booking_id $new_status successfully");

        http_response_code(200);
        echo json_encode([
            'ok' => true,
            'success' => true,
            'message' => 'Booking ' . $new_status . ' successfully'
        ]);
        exit;

    } catch (Exception $e) {
        error_log('Booking action error: ' . $e->getMessage());
        http_response_code(500);
        echo json_encode([
            'ok' => false,
            'success' => false,
            'error' => 'Server error: ' . $e->getMessage()
        ]);
        exit;
    }
}

// Handle GET requests for fetching bookings
$owner_email = $_GET['owner_email'] ?? '';

if (!$owner_email) {
    http_response_code(400);
    echo json_encode([
        'ok' => false,
        'success' => false,
        'error' => 'Owner email required'
    ]);
    exit;
}

try {
    // Get owner details
    $stmt = $pdo->prepare("SELECT user_id FROM users WHERE email = ? AND role = 'owner'");
    $stmt->execute([$owner_email]);
    $owner = $stmt->fetch();

    if (!$owner) {
        http_response_code(404);
        echo json_encode([
            'ok' => false,
            'success' => false,
            'error' => 'Owner not found'
        ]);
        exit;
    }

    // Debug owner
    error_log("Found owner ID: " . $owner['user_id']);

    // Fetch bookings for owner's dorms
    $stmt = $pdo->prepare("
        SELECT 
            b.booking_id as id,
            u.email as student_email,
            u.name as student_name,
            b.created_at as requested_at,
            COALESCE(b.status, 'pending') as status, -- Default to pending if NULL
            d.dorm_id,
            d.name as dorm,
            r.room_type,
            r.price as base_price,
            r.capacity,
            b.booking_type,
            b.start_date,
            b.end_date,
            b.notes as message,
            b.cancellation_acknowledged,
            b.cancellation_acknowledged_at,
            b.cancellation_acknowledged_by,
            b.student_id
        FROM bookings b
        JOIN rooms r ON b.room_id = r.room_id
        JOIN dormitories d ON r.dorm_id = d.dorm_id
        JOIN users u ON b.student_id = u.user_id
        WHERE d.owner_id = ?
        ORDER BY b.created_at DESC
    ");
    
    $stmt->execute([$owner['user_id']]);
    $bookings = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Debug bookings
    error_log("Found " . count($bookings) . " bookings");

    // Format data for mobile app
    $formatted = array_map(function($b) {
        // Calculate duration from start_date and end_date
        $duration = 'Not specified';
        if (!empty($b['start_date']) && !empty($b['end_date'])) {
            $start = new DateTime($b['start_date']);
            $end = new DateTime($b['end_date']);
            $interval = $start->diff($end);
            
            $months = $interval->m + ($interval->y * 12);
            $days = $interval->d;
            
            if ($months > 0) {
                $duration = $months . ' month' . ($months > 1 ? 's' : '');
                if ($days > 0) {
                    $duration .= ' ' . $days . ' day' . ($days > 1 ? 's' : '');
                }
            } else if ($days > 0) {
                $duration = $days . ' day' . ($days > 1 ? 's' : '');
            }
        }
        
        // Calculate price based on booking type
        $base_price = (float)$b['base_price'];
        $capacity = (int)$b['capacity'];
        $booking_type = strtolower($b['booking_type'] ?? 'shared');
        
        if ($booking_type === 'shared' && $capacity > 0) {
            // For shared booking, divide price by room capacity
            $calculated_price = $base_price / $capacity;
        } else {
            // For whole room booking, use full price
            $calculated_price = $base_price;
        }
        
        // Extract cancellation reason from notes (for both cancelled and cancellation_requested)
        $cancellation_reason = '';
        $status_lower = strtolower($b['status']);
        if (($status_lower === 'cancelled' || $status_lower === 'cancellation_requested') && !empty($b['message'])) {
            // Look for "Reason: " in the notes
            if (preg_match('/Reason:\s*(.+?)(?:\n|$)/s', $b['message'], $matches)) {
                $cancellation_reason = trim($matches[1]);
            }
        }
        
        // Format status for display (handle underscore in cancellation_requested)
        $status_formatted = ucfirst(strtolower($b['status']));
        if (strtolower($b['status']) === 'cancellation_requested') {
            $status_formatted = 'Cancellation Requested';
        }
        
        return [
            'id' => $b['id'],
            'booking_id' => $b['id'], // Add booking_id for consistency
            'student_id' => $b['student_id'], // Add student_id for messaging
            'student_email' => $b['student_email'],
            'student_name' => $b['student_name'],
            'requested_at' => timeAgo($b['requested_at']),
            'status' => $status_formatted,
            'dorm_id' => $b['dorm_id'], // Add dorm_id for messaging
            'dorm' => $b['dorm'], // Keep for backward compatibility
            'dorm_name' => $b['dorm'], // Add dorm_name for consistency with widget
            'room_type' => $b['room_type'],
            'booking_type' => ucfirst($booking_type), // 'Whole' or 'Shared'
            'duration' => $duration,
            'start_date' => $b['start_date'],
            'end_date' => $b['end_date'] ?? null,
            'base_price' => $base_price,
            'capacity' => $capacity,
            'price' => '₱' . number_format($calculated_price, 2),
            'message' => $b['message'] ?? 'No additional message',
            'cancellation_reason' => $cancellation_reason,
            'cancellation_acknowledged' => $b['cancellation_acknowledged'] ?? 0,
            'cancellation_acknowledged_at' => $b['cancellation_acknowledged_at'] ?? null,
            'cancellation_acknowledged_by' => $b['cancellation_acknowledged_by'] ?? null
        ];
    }, $bookings);

    error_log("Formatted " . count($formatted) . " bookings for response");
    http_response_code(200);
    echo json_encode([
        'ok' => true,
        'success' => true,
        'bookings' => $formatted
    ]);

} catch (Exception $e) {
    error_log('Owner bookings API error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'ok' => false,
        'success' => false,
        'error' => 'Server error: ' . $e->getMessage()
    ]);
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