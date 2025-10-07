<?php
require_once __DIR__ . '/../auth.php';
login_required();
$user = current_user();
require_once __DIR__ . '/../config.php';

$unread_count = 0;
if ($user && isset($user['user_id'])) {
    $stmt = $pdo->prepare("SELECT COUNT(*) FROM messages WHERE receiver_id = ? AND read_at IS NULL");
    $stmt->execute([$user['user_id']]);
    $unread_count = (int)$stmt->fetchColumn();
}

$unread_announcements = 0;
if ($user && isset($user['user_id'])) {
    $stmt = $pdo->prepare("
        SELECT COUNT(*)
        FROM announcements a
        LEFT JOIN announcement_reads ar
          ON a.id = ar.announcement_id AND ar.user_id = ?
        WHERE ar.read_at IS NULL
          AND (
            a.audience = 'All Hosts'
            OR (a.audience = 'Students' AND ? = 'student')
            OR (a.audience IN ('Verified Owners','Pending Owners','All Hosts') AND ? = 'owner')
          )
    ");
    $stmt->execute([$user['user_id'], $user['role'], $user['role']]);
    $unread_announcements = (int)$stmt->fetchColumn();
}

$message_page = "#";
$announcement_page = "#";

if ($user['role'] === 'student') {
    $message_page = "/CAPSTONE/modules/student_messages.php";
    $announcement_page = "/CAPSTONE/modules/student_announcements.php";
} elseif ($user['role'] === 'owner') {
    $message_page = "/CAPSTONE/modules/owner_messages.php";
    $announcement_page = "/CAPSTONE/modules/owner_announcements.php";
} elseif ($user['role'] === 'admin') {
    $message_page = "/CAPSTONE/modules/messaging.php";
    $announcement_page = "/CAPSTONE/modules/announcements.php";
}
?>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>CozyDorms — Dashboard</title>
  <meta name="viewport" content="width=device-width,initial-scale=1">

  <link rel="icon" href="/CAPSTONE/assets/favicon.png" type="image/png">
  <link rel="stylesheet" href="/CAPSTONE/assets/style.css">
  <link rel="stylesheet" href="/CAPSTONE/assets/modules.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  <style>
    .badge {
      display:inline-block;
      background:#e63946;
      color:#fff;
      border-radius:50%;
      font-size:0.7em;
      padding:2px 6px;
      margin-left:4px;
    }
    .btn-icon {
      position: relative;
      margin-left: 8px;
      color: inherit;
      text-decoration: none;
    }
    .btn-icon .badge {
      position: absolute;
      top: -5px;
      right: -5px;
    }
  </style>
</head>
<body>
  <aside class="sidebar">
    <div class="brand">CozyDorms Management</div>
    <nav>

      <?php if ($user['role'] === 'admin'): ?>
        <a href="/CAPSTONE/dashboard.php">Overview</a>
        <a href="/CAPSTONE/modules/user_management.php">User Management</a>
        <a href="/CAPSTONE/modules/reports.php">Reports & Analytics</a>
        <a href="/CAPSTONE/modules/owner_verification.php">Dorm Owner Verification</a>
        <a href="/CAPSTONE/modules/dorm_listings.php">Dorm Listings</a>
        <a href="/CAPSTONE/modules/booking_oversight.php">Booking & Reservation</a>
        <a href="/CAPSTONE/modules/admin_payments.php">Payment Management</a>
        <a href="/CAPSTONE/modules/announcements.php">Broadcast Announcements</a>
        <a href="/CAPSTONE/modules/system_config.php">System Configuration</a>
        <a href="/CAPSTONE/modules/map_radius.php">Map & Radius Management</a>
        <a href="/CAPSTONE/modules/post_reservation.php">Post-Reservation Management</a>
        <a href="/CAPSTONE/modules/download.php">Mobile Download</a>
      
      <?php elseif ($user['role'] === 'student'): ?>
        <a href="/CAPSTONE/student_dashboard.php">My Dashboard</a>
        <a href="/CAPSTONE/modules/available_dorms.php">Available Dorms</a>
        <a href="/CAPSTONE/modules/student_reservations.php">My Reservations</a>
        <a href="/CAPSTONE/modules/student_payments.php">Payments</a>
        <a href="/CAPSTONE/modules/student_messages.php">Messages
          <?php if ($unread_count > 0): ?>
            <span class="badge"><?= $unread_count ?></span>
          <?php endif; ?>
        </a>
        <a href="/CAPSTONE/modules/student_announcements.php">Announcements
          <?php if ($unread_announcements > 0): ?>
            <span class="badge"><?= $unread_announcements ?></span>
          <?php endif; ?>
        </a>
        <a href="/CAPSTONE/modules/download.php">Mobile Download</a>

      <?php elseif ($user['role'] === 'owner'): ?>
        <a href="/CAPSTONE/owner_dashboard.php">My Dashboard</a>
        <a href="/CAPSTONE/modules/owner_dorms.php">CozyDorms</a>
        <a href="/CAPSTONE/modules/room_management.php">Dorm Room Management</a>
        <a href="/CAPSTONE/modules/owner_bookings.php">Bookings</a>
        <a href="/CAPSTONE/modules/owner_payments.php">Payments</a>
        <a href="/CAPSTONE/modules/owner_messages.php">Messages
          <?php if ($unread_count > 0): ?>
            <span class="badge"><?= $unread_count ?></span>
          <?php endif; ?>
        </a>
        <a href="/CAPSTONE/modules/owner_announcements.php">Announcements
          <?php if ($unread_announcements > 0): ?>
            <span class="badge"><?= $unread_announcements ?></span>
          <?php endif; ?>
        </a>
        <a href="/CAPSTONE/modules/download.php">Mobile Download</a>
      <?php endif; ?>
    </nav>

    <div class="sidebar-foot">
      <div class="user">
        <div class="name"><?=htmlspecialchars($user['name'])?></div>
        <div class="role"><?=htmlspecialchars(ucfirst($user['role']))?></div>
      </div>
      <a class="logout" href="/CAPSTONE/logout.php"><i class="fa fa-sign-out-alt"></i> Logout</a>
    </div>
  </aside>

  <main class="main">
    <header class="topbar">
      <div class="page-title">
        <?php if (isset($page_title)): ?>
          <h1><?=htmlspecialchars($page_title)?></h1>
        <?php endif; ?>
      </div>
      <div class="header-actions">
        <a href="<?= $announcement_page ?>" class="btn-icon">
          <i class="fa fa-bell"></i>
          <?php if ($unread_announcements > 0): ?>
            <span class="badge"><?= $unread_announcements ?></span>
          <?php endif; ?>
        </a>
        <a href="<?= $message_page ?>" class="btn-icon">
          <i class="fa fa-envelope"></i>
          <?php if ($unread_count > 0): ?>
            <span class="badge"><?= $unread_count ?></span>
          <?php endif; ?>
        </a>
      </div>
    </header>