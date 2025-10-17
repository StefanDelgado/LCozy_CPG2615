<aside class="sidebar">
    <h2>CozyDorms Management</h2>
    <nav>
        <a href="../dashboards/admin_dashboard.php">Overview</a>
        <a href="../modules/admin/reports.php">Reports & Analytics</a>
        <a href="../modules/admin/owner_verification.php">Dorm Owner Verification</a>
        <a href="../modules/admin/room_management.php">Dorm Room Management</a>
        <a href="../modules/admin/booking_oversight.php">Booking & Reservation Oversight</a>
        <a href="../modules/admin/admin_payments.php">Payment Management</a>
        <a href="../modules/shared/messaging.php">Messaging & Inquiry Oversight</a>
        <a href="../modules/admin/announcements.php">Broadcast Announcements</a>
        <a href="../modules/admin/system_config.php">System Configuration</a>
        <a href="../modules/admin/map_radius.php">Map & Radius Management</a>
        <a href="../modules/admin/post_reservation.php">Post-Reservation Management</a>
    </nav>

    <div class="user-info">
        <span><?php echo $_SESSION['username'] ?? 'Admin'; ?></span>
        <a href="../auth/logout.php">Logout</a>
    </div>
</aside>