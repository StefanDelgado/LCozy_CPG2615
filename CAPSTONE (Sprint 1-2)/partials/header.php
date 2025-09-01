<?php
require_once __DIR__ . '/../auth.php';
login_required();
$user = current_user();
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
        <a href="/CAPSTONE/modules/room_management.php">Dorm Room Management</a>
        <a href="/CAPSTONE/modules/booking_oversight.php">Booking & Reservation</a>
        <a href="/CAPSTONE/modules/payments.php">Payment Management</a>
        <a href="/CAPSTONE/modules/messaging.php">Messaging & Inquiry</a>
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
        <a href="/CAPSTONE/modules/student_messages.php">Messages</a>
        <a href="/CAPSTONE/modules/student_announcements.php">Announcements</a>
        <a href="/CAPSTONE/modules/download.php">Mobile Download</a>

      <?php elseif ($user['role'] === 'owner'): ?>
        <a href="/CAPSTONE/owner_dashboard.php">My Dashboard</a>
        <a href="/CAPSTONE/modules/owner_dorms.php">My Dorms</a>
        <a href="/CAPSTONE/modules/owner_bookings.php">Bookings</a>
        <a href="/CAPSTONE/modules/owner_payments.php">Payments</a>
        <a href="/CAPSTONE/modules/owner_messages.php">Messages</a>
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
        <button class="btn-icon"><i class="fa fa-bell"></i></button>
        <button class="btn-icon"><i class="fa fa-envelope"></i></button>
      </div>
    </header>