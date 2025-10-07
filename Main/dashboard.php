<?php
require_once __DIR__ . '/auth.php';
require_role('admin');

$totalDorms = (int)$pdo->query("SELECT COUNT(*) FROM dormitories")->fetchColumn();

$activeOwners = (int)$pdo->query("
  SELECT COUNT(DISTINCT u.user_id)
  FROM users u
  JOIN dormitories d ON d.owner_id = u.user_id
  WHERE u.role = 'owner'
")->fetchColumn();

$bookingsToday = (int)$pdo->query("
  SELECT COUNT(*) FROM bookings WHERE start_date = CURDATE()
")->fetchColumn();

$pendingBookings = (int)$pdo->query("
  SELECT COUNT(*) FROM bookings WHERE status='pending'
")->fetchColumn();

$pendingListings = (int)$pdo->query("
  SELECT COUNT(*) 
  FROM dormitories d
  LEFT JOIN rooms r ON r.dorm_id = d.dorm_id
  WHERE r.dorm_id IS NULL
")->fetchColumn();

$awaitingApproval = $pendingBookings;

$activeAnnouncements = 0;

$page_title = "Admin Dashboard";
include __DIR__ . '/partials/header.php';
?>

<div class="top-cards">
  <div class="card">
    <div class="card-title">Total Dorms</div>
    <div class="metric"><?=$totalDorms?></div>
  </div>
  <div class="card">
    <div class="card-title">Active Owners</div>
    <div class="metric"><?=$activeOwners?></div>
  </div>
  <div class="card">
    <div class="card-title">Bookings Today</div>
    <div class="metric"><?=$bookingsToday?></div>
  </div>
  <div class="card">
    <div class="card-title">Pending Bookings</div>
    <div class="metric"><?=$pendingBookings?></div>
  </div>
</div>

<section class="modules">
  <h2>Management Modules</h2>
  <p>Comprehensive management tools for admins</p>
  <div class="grid">
    <a class="module" href="modules/user_management.php"><span class="module-title">User Management</span></a>
    <a class="module" href="modules/reports.php"><span class="module-title">Reports & Analytics</span></a>
    <a class="module" href="modules/owner_verification.php"><span class="module-title">Owner Verification</span></a>
    <a class="module" href="modules/room_management.php"><span class="module-title">Room Management</span></a>
    <a class="module" href="modules/booking_oversight.php"><span class="module-title">Booking Oversight</span></a>
    <a class="module" href="modules/payments.php"><span class="module-title">Payment Management</span></a>
    <a class="module" href="modules/messaging.php"><span class="module-title">Messaging</span></a>
    <a class="module" href="modules/system_config.php"><span class="module-title">System Configuration</span></a>
  </div>
</section>

<div class="bottom-cards">
  <div class="big-card">
    <div class="metric"><?=$pendingListings?></div>
    <div class="label">Dorms w/o Rooms</div>
  </div>
  <div class="big-card">
    <div class="metric"><?=$awaitingApproval?></div>
    <div class="label">Awaiting Approval</div>
  </div>
  <div class="big-card">
    <div class="metric"><?=$activeAnnouncements?></div>
    <div class="label">Active Announcements</div>
  </div>
</div>

<?php include __DIR__ . '/partials/footer.php'; ?>