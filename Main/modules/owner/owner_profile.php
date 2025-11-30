<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

require_once __DIR__ . '/../../auth/auth.php';
require_role(['admin', 'superadmin']);

require_once __DIR__ . '/../../config.php';

$owner_id = $_GET['id'] ?? null;

if (!$owner_id) {
    die("Invalid owner ID.");
}

// Fetch owner account info
$stmt = $pdo->prepare("
    SELECT u.user_id, u.name, u.email, u.role, u.created_at,
           r.status AS request_status, r.submitted_at, r.processed_at,
           r.document_path
    FROM users u
    LEFT JOIN owner_verification_requests r ON r.user_id = u.user_id
    WHERE u.user_id = ?
");
$stmt->execute([$owner_id]);
$owner = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$owner) {
    die("Owner not found.");
}

// Format role display
$roleDisplay = ucfirst($owner['role']);
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Owner Profile — CozyDorms</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <style>
        body {
            margin: 0;
            font-family: 'Segoe UI', sans-serif;
            background: #f7f7fb;
            padding: 30px;
        }

        .container {
            max-width: 750px;
            margin: auto;
        }

        .card {
            background: white;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0px 6px 18px rgba(0,0,0,0.08);
            margin-bottom: 25px;
        }

        h1 {
            margin-bottom: 20px;
            color: #3a3a3a;
        }

        .info-row {
            margin-bottom: 12px;
        }

        .label {
            font-weight: 600;
            color: #555;
        }

        .value {
            color: #111;
        }

        .actions {
            margin-top: 25px;
        }

        .btn {
            padding: 10px 16px;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 600;
            margin-right: 10px;
            display: inline-block;
        }
        .approve {
            background: #2e7d32;
            color: white;
        }
        .disapprove {
            background: #c62828;
            color: white;
        }
        .back {
            background: #555;
            color: white;
        }

        .doc-preview {
            margin-top: 15px;
        }

        .doc-preview a {
            color: #4c3bcf;
            font-weight: bold;
        }
    </style>
</head>
<body>

<div class="container">

    <h1>Owner Profile</h1>

    <div class="card">
        <div class="info-row">
            <span class="label">Full Name:</span>
            <span class="value"><?= htmlspecialchars($owner['name']) ?></span>
        </div>

        <div class="info-row">
            <span class="label">Email:</span>
            <span class="value"><?= htmlspecialchars($owner['email']) ?></span>
        </div>

        <div class="info-row">
            <span class="label">Current Role:</span>
            <span class="value"><?= $roleDisplay ?></span>
        </div>

        <div class="info-row">
            <span class="label">Account Created:</span>
            <span class="value"><?= $owner['created_at'] ?></span>
        </div>
    </div>

    <div class="card">
        <h2>Verification Details</h2>

        <div class="info-row">
            <span class="label">Request Status:</span>
            <span class="value"><?= ucfirst($owner['request_status'] ?? "N/A") ?></span>
        </div>

        <div class="info-row">
            <span class="label">Submitted At:</span>
            <span class="value"><?= $owner['submitted_at'] ?? "N/A" ?></span>
        </div>

        <div class="info-row">
            <span class="label">Processed At:</span>
            <span class="value"><?= $owner['processed_at'] ?? "Not processed" ?></span>
        </div>

        <?php if (!empty($owner['document_path'])): ?>
        <div class="doc-preview">
            <span class="label">Uploaded Document:</span><br>
            <a href="/uploads/owner_docs/<?= htmlspecialchars($owner['document_path']) ?>" target="_blank">
                View Document
            </a>
        </div>
        <?php endif; ?>
    </div>

    <div class="actions">

        <a href="owner_management.php" class="btn back">← Back</a>

        <?php if ($owner['request_status'] === 'pending'): ?>
            <a href="process_owner_request.php?action=approve&request_id=<?= $owner['request_id'] ?>&user_id=<?= $owner['user_id'] ?>"
               class="btn approve">
               Approve
            </a>

            <a href="process_owner_request.php?action=disapprove&request_id=<?= $owner['request_id'] ?>&user_id=<?= $owner['user_id'] ?>"
               class="btn disapprove">
               Disapprove
            </a>
        <?php endif; ?>

    </div>

</div>

</body>
</html>