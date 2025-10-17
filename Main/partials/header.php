<?php
require_once __DIR__ . '/../auth/auth.php';
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

// Dynamic branding title per role
$brand_title = "CozyDorms Management";
if ($user['role'] === 'admin') {
    $brand_title = "CozyAdmin";
} elseif ($user['role'] === 'owner') {
    $brand_title = "CozyOwner";
} elseif ($user['role'] === 'student') {
    $brand_title = "CozyTenant";
}

$message_page = "#";
$announcement_page = "#";

if ($user['role'] === 'student') {
    $message_page = "../modules/student/student_messages.php";
    $announcement_page = "../modules/student/student_announcements.php";
} elseif ($user['role'] === 'owner') {
    $message_page = "../modules/owner/owner_messages.php";
    $announcement_page = "../modules/owner/owner_announcements.php";
} elseif ($user['role'] === 'admin') {
    $message_page = "../modules/shared/messaging.php";
    $announcement_page = "../modules/admin/announcements.php";
}
?>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title><?= htmlspecialchars($brand_title) ?> — Dashboard</title>
  <meta name="viewport" content="width=device-width,initial-scale=1">

  <link rel="icon" href="../assets/favicon.png" type="image/png">
  <link rel="stylesheet" href="../assets/style.css">
  <link rel="stylesheet" href="../assets/modules.css">
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

    /* Sidebar header and user info styling */
    .brand {
      padding: 1.2rem;
      background: #e9d5ff;
      text-align: left;
      font-weight: 700;
      color: #1e1e2f;
    }

    .brand-title {
      font-size: 1.1rem;
      margin-bottom: 0.8rem;
    }

    .user-info {
      display: flex;
      align-items: center;
      gap: 0.8rem;
    }

    .user-info img {
      width: 40px;
      height: 40px;
      border-radius: 50%;
      object-fit: cover;
    }

    .user-details {
      display: flex;
      flex-direction: column;
      font-weight: normal;
      font-size: 0.9rem;
      color: #333;
      line-height: 1.2;
    }

    .user-details .name {
      font-weight: 600;
    }

    .user-details .role {
      font-size: 0.85rem;
      opacity: 0.8;
    }

    .sidebar-separator {
      border: none;
      border-top: 1px solid #d0bfff;
      margin: 0;
    }
  </style>
</head>
<body>
  <aside class="sidebar">
    <div class="brand">
      <div class="brand-title"><?= htmlspecialchars($brand_title) ?></div>
      <div class="user-info">
        <?php if (!empty($user['profile_pic'])): ?>
          <img src="<?= htmlspecialchars($user['profile_pic']) ?>" alt="profile">
        <?php else: ?>
          <img src="../assets/default_profile.jpg" alt="default">
        <?php endif; ?>
        <div class="user-details">
          <div class="name"><?= htmlspecialchars($user['name']) ?></div>
          <div class="role"><?= htmlspecialchars(ucfirst($user['role'])) ?></div>
        </div>
      </div>
    </div>
    <hr class="sidebar-separator">

    <nav>
      <?php if ($user['role'] === 'admin'): ?>
        <a href="../dashboards/admin_dashboard.php">Overview</a>
        <a href="../modules/admin/user_management.php">User Management</a>
        <a href="../modules/admin/reports.php">Reports & Analytics</a>
        <a href="../modules/admin/owner_verification.php">Dorm Owner Verification</a>
        <a href="../modules/shared/dorm_listings.php">Dorm Listings</a>
        <a href="../modules/admin/booking_oversight.php">Booking & Reservation</a>
        <a href="../modules/admin/admin_payments.php">Payment Management</a>
        <a href="../modules/admin/announcements.php">Broadcast Announcements</a>
      
      <?php elseif ($user['role'] === 'student'): ?>
        <a href="../dashboards/student_dashboard.php">My Dashboard</a>
        <a href="../modules/shared/available_dorms.php">Available Dorms</a>
        <a href="../modules/student/student_reservations.php">My Reservations</a>
        <a href="../modules/student/student_payments.php">Payment Management</a>


      <?php elseif ($user['role'] === 'owner'): ?>
        <a href="../dashboards/owner_dashboard.php">My Dashboard</a>
        <a href="../modules/owner/owner_dorms.php">CozyDorms</a>
        <a href="../modules/admin/room_management.php">Dorm Room Management</a>
        <a href="../modules/owner/owner_bookings.php">Bookings</a>
        <a href="../modules/owner/owner_payments.php">Payment Management</a>
      <?php endif; ?>
    </nav>

    <div class="sidebar-foot">
      <a class="logout" href="../auth/logout.php"><i class="fa fa-sign-out-alt"></i> Logout</a>
    </div>
  </aside>

  <main class="main">
    <header class="topbar">
      <div class="page-title">
        <?php if (isset($page_title)): ?>
          <h1><?= htmlspecialchars($page_title) ?></h1>
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