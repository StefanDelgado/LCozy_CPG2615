<?php
class ReviewHelper
{
    // Fetch approved reviews for a dorm (limit optional)
    public static function fetchApprovedReviews(PDO $pdo, int $dorm_id, int $limit = 10): array
    {
        $stmt = $pdo->prepare("
            SELECT r.review_id, r.rating, r.comment, r.created_at, u.name
            FROM reviews r
            JOIN users u ON r.student_id = u.user_id
            WHERE r.dorm_id = ? AND r.status = 'approved'
            ORDER BY r.created_at DESC
            LIMIT ?
        ");
            // bind parameters (limit must be bound as integer)
            $stmt->bindValue(1, $dorm_id, PDO::PARAM_INT);
            $stmt->bindValue(2, (int)$limit, PDO::PARAM_INT);
            $stmt->execute();
        $rows = $stmt->fetchAll(PDO::FETCH_NUM);
        $out = [];
        foreach ($rows as $r) {
            // map numeric columns to normalized keys: review_id, rating, comment, created_at, name
            $out[] = [
                'review_id' => isset($r[0]) ? (int)$r[0] : null,
                'rating' => isset($r[1]) ? (int)$r[1] : null,
                'comment' => isset($r[2]) && $r[2] !== null ? $r[2] : '',
                'created_at' => $r[3] ?? null,
                'name' => $r[4] ?? null,
            ];
        }
        return $out;
    }

    // Compute average rating and total reviews for a dorm
    public static function getRatingStats(PDO $pdo, int $dorm_id): array
    {
        $stmt = $pdo->prepare("
            SELECT AVG(rating), COUNT(*)
            FROM reviews
            WHERE dorm_id = ? AND status = 'approved'
        ");
        $stmt->execute([$dorm_id]);
        $row = $stmt->fetch(PDO::FETCH_NUM);
        $avg = isset($row[0]) && $row[0] !== null ? (float)$row[0] : 0.0;
        $count = isset($row[1]) ? (int)$row[1] : 0;
        return [
            'avg_rating' => round($avg, 1),
            'total_reviews' => $count
        ];
    }

    // Check if student can submit a review (simple booking-based check)
    public static function canSubmitReview(PDO $pdo, int $student_id, int $dorm_id): bool
    {
        // The schema uses booking.status values: pending, approved, rejected, cancelled
        // Consider a booking eligible for review only when it is 'approved'
        $stmt = $pdo->prepare("SELECT 1 FROM bookings b
            JOIN rooms r ON b.room_id = r.room_id
            WHERE b.student_id = ? AND r.dorm_id = ? AND b.status = 'approved'
            LIMIT 1");
        $stmt->execute([$student_id, $dorm_id]);
        return (bool)$stmt->fetchColumn();
    }

    // Submit a review (inserts as 'pending' by default)
    public static function submitReview(PDO $pdo, int $booking_id, int $student_id, int $dorm_id, int $rating, string $comment): bool
    {
        // Basic validation
        $rating = max(1, min(5, intval($rating)));
        $comment = trim($comment);

        $stmt = $pdo->prepare("
            INSERT INTO reviews (booking_id, student_id, dorm_id, rating, comment, status, created_at)
            VALUES (?, ?, ?, ?, ?, 'pending', NOW())
        ");
        return $stmt->execute([$booking_id, $student_id, $dorm_id, $rating, $comment]);
    }

    // Approve or reject a review (admin action)
    public static function setReviewStatus(PDO $pdo, int $review_id, string $status): bool
    {
        $allowed = ['approved', 'rejected', 'pending'];
        if (!in_array($status, $allowed, true)) return false;

        $stmt = $pdo->prepare("UPDATE reviews SET status = ? WHERE review_id = ?");
        return $stmt->execute([$status, $review_id]);
    }

    // Delete a review (admin or owner moderation)
    public static function deleteReview(PDO $pdo, int $review_id): bool
    {
        // Optional: confirm review exists before deleting
        $check = $pdo->prepare("SELECT review_id FROM reviews WHERE review_id = :id LIMIT 1");
        $check->execute([':id' => $review_id]);
        if (!$check->fetchColumn()) {
            return false; // No review found
        }

        // Proceed with deletion
        $stmt = $pdo->prepare("DELETE FROM reviews WHERE review_id = :id LIMIT 1");
        return $stmt->execute([':id' => $review_id]);
    }

    // Helper to render stars (returns HTML string)
    public static function renderStars(float $rating, int $max = 5): string
    {
        $full = floor($rating);
        $half = ($rating - $full) >= 0.5 ? 1 : 0;
        $empty = $max - $full - $half;
        $out = str_repeat('★', $full);
        if ($half) $out .= '½';
        $out .= str_repeat('☆', $empty);
        // Return safe HTML/plain text. Caller can echo directly.
        return htmlspecialchars($out . ' ' . number_format($rating, 1) . '/5');
    }
}