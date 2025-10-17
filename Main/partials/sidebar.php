<aside class="sidebar">
    <h2>CozyDorms Management</h2>
    <nav>
        <a href="../dashboards/admin_dashboard.php">Overview</a>
        <a href="../modules/reports.php">Reports & Analytics</a>
        <a href="../modules/owner_verification.php">Dorm Owner Verification</a>
        <a href="../modules/room_management.php">Dorm Room Management</a>
        <a href="../modules/booking_oversight.php">Booking & Reservation Oversight</a>
        <a href="../modules/admin_payments.php">Payment Management</a>
        <a href="../modules/messaging.php">Messaging & Inquiry Oversight</a>
        <a href="../modules/announcements.php">Broadcast Announcements</a>
        <a href="../modules/system_config.php">System Configuration</a>
        <a href="../modules/map_radius.php">Map & Radius Management</a>
        <a href="../modules/post_reservation.php">Post-Reservation Management</a>
    </nav>

    <div class="user-info">
        <span><?php echo $_SESSION['username'] ?? 'Admin'; ?></span>
        <a href="../auth/logout.php">Logout</a>
    </div>
</aside>