<?php
require_once 'config.php'; // your DB connection file

// ✅ Handle Approve / Reject actions
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['booking_id'])) {
        $booking_id = $_POST['booking_id'];
        $new_status = isset($_POST['approve_booking']) ? 'approved' : 'rejected';

        $stmt = $pdo->prepare("UPDATE bookings SET status = ?, updated_at = NOW() WHERE booking_id = ?");
        $stmt->execute([$new_status, $booking_id]);
    }

    // Refresh page to show updated data
    header("Location: bookings.php");
    exit;
}

// ✅ Fetch all bookings
$stmt = $pdo->query("
    SELECT b.*, 
           s.full_name AS student_name, 
           s.email, 
           s.phone,
           d.dorm_name,
           r.room_type,
           r.price,
           r.capacity
    FROM bookings b
    JOIN students s ON b.student_id = s.student_id
    JOIN dorms d ON b.dorm_id = d.dorm_id
    JOIN rooms r ON b.room_id = r.room_id
    ORDER BY b.created_at DESC
");
$bookings = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Bookings Management</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background-color: #f8f9fa; }
        .badge.approved { background-color: #28a745; }
        .badge.rejected { background-color: #dc3545; }
        .badge.pending { background-color: #ffc107; color: black; }
        .badge.cancelled { background-color: #6c757d; }
        .badge.completed { background-color: #0d6efd; }
        .badge.unknown { background-color: #adb5bd; }
    </style>
</head>
<body class="p-4">
<div class="container bg-white p-4 rounded shadow-sm">
    <h4 class="mb-4 fw-bold">Dorm Booking Management</h4>

    <table class="table table-bordered align-middle">
        <thead class="table-light">
            <tr>
                <th>Student</th>
                <th>Email</th>
                <th>Phone</th>
                <th>Dorm</th>
                <th>Room Type</th>
                <th>Price</th>
                <th>Capacity</th>
                <th>Booking Period</th>
                <th>Status</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
        <?php foreach ($bookings as $b): ?>
            <?php 
                $status = strtolower(trim($b['status']));
                $valid_statuses = ['pending','approved','rejected','cancelled','completed'];
                if (!in_array($status, $valid_statuses)) {
                    $status = 'unknown';
                }
            ?>
            <tr>
                <td><?= htmlspecialchars($b['student_name']) ?></td>
                <td><?= htmlspecialchars($b['email']) ?></td>
                <td><?= htmlspecialchars($b['phone']) ?></td>
                <td><?= htmlspecialchars($b['dorm_name']) ?></td>
                <td><?= htmlspecialchars($b['room_type']) ?></td>
                <td>₱<?= number_format($b['price'], 2) ?></td>
                <td><?= htmlspecialchars($b['capacity']) ?></td>
                <td><?= htmlspecialchars($b['start_date']) ?> → <?= htmlspecialchars($b['end_date']) ?></td>
                <td>
                    <span class="badge <?= $status ?>"><?= ucfirst($status) ?></span>
                </td>
                <td>
                    <?php if ($status === 'pending'): ?>
                        <form method="POST" style="display:inline-block;">
                            <input type="hidden" name="booking_id" value="<?= $b['booking_id'] ?>">
                            <button type="submit" name="approve_booking" class="btn btn-success btn-sm">Approve</button>
                        </form>
                        <form method="POST" style="display:inline-block;">
                            <input type="hidden" name="booking_id" value="<?= $b['booking_id'] ?>">
                            <button type="submit" name="reject_booking" class="btn btn-danger btn-sm">Reject</button>
                        </form>
                    <?php else: ?>
                        <button class="btn btn-primary btn-sm">Contact</button>
                    <?php endif; ?>
                </td>
            </tr>
        <?php endforeach; ?>
        </tbody>
    </table>
</div>
</body>
</html>
