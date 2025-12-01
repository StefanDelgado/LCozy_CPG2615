<?php
// Main/modules/owner/owner_requests.php

require_once __DIR__ . '/../../auth/auth.php';
require_role(['admin', 'superadmin']);

require_once __DIR__ . '/../../config.php';

$page_title = "Owner Verification Requests";
$current = current_user();
$is_superadmin = ($current['role'] === 'superadmin');

// Fetch pending requests from correct table: user_verifications
$sql = "
    SELECT r.request_id, r.user_id, r.status, r.created_at,
           u.name, u.email, u.phone, u.address, u.license_no
    FROM user_verifications r
    JOIN users u ON u.user_id = r.user_id
    WHERE r.status = 'pending'
    ORDER BY r.created_at ASC
";

$stmt = $pdo->query($sql);
$requests = $stmt->fetchAll(PDO::FETCH_ASSOC);

require_once __DIR__ . '/../../partials/header.php';
?>

<div class="page-header">
    <h1>Owner Verification Requests</h1>
    <p>Review and approve or disapprove owner verification submissions.</p>
</div>

<div class="card">

<?php if (empty($requests)): ?>
    <p>No pending requests.</p>

<?php else: ?>
    <table class="table">
        <thead>
            <tr>
                <th>Owner</th>
                <th>Email</th>
                <th>License #</th>
                <th>Submitted</th>
                <th>Actions</th>
            </tr>
        </thead>

        <tbody>
        <?php foreach ($requests as $req): ?>
            <tr>
                <td><?= htmlspecialchars($req['name']) ?></td>
                <td><?= htmlspecialchars($req['email']) ?></td>
                <td><?= htmlspecialchars($req['license_no'] ?? '') ?></td>
                <td><?= date('M d, Y h:i A', strtotime($req['created_at'])) ?></td>

                <td style="display:flex; gap:5px;">
                    <a class="btn btn-secondary" 
                       href="owner_profile.php?id=<?= (int)$req['user_id'] ?>">
                        View Profile
                    </a>

                    <!-- Approve -->
                    <a class="btn btn-primary"
                       href="process_owner_request.php?action=approve&request_id=<?= (int)$req['request_id'] ?>&user_id=<?= (int)$req['user_id'] ?>"
                       onclick="return confirm('Approve this owner verification?');">
                        Approve
                    </a>

                    <!-- Disapprove -->
                    <a class="btn btn-danger"
                       href="process_owner_request.php?action=disapprove&request_id=<?= (int)$req['request_id'] ?>&user_id=<?= (int)$req['user_id'] ?>"
                       onclick="return confirm('Disapprove this owner verification?');">
                        Disapprove
                    </a>
                </td>

            </tr>
        <?php endforeach; ?>
        </tbody>
    </table>

<?php endif; ?>

</div>

<?php require_once __DIR__ . '/../../partials/footer.php'; ?>