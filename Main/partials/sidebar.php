<aside class="sidebar">
    <h2>CozyDorms Management</h2>
    <nav>
        <a href="/CAPSTONE/dashboard.php">Overview</a>
        <a href="/CAPSTONE/modules/reports.php">Reports & Analytics</a>
        <a href="/CAPSTONE/modules/owner_verification.php">Dorm Owner Verification</a>
        <a href="/CAPSTONE/modules/room_management.php">Dorm Room Management</a>
        <a href="/CAPSTONE/modules/booking_oversight.php">Booking & Reservation Oversight</a>
        <a href="/CAPSTONE/modules/admin_payments.php">Payment Management</a>
        <a href="/CAPSTONE/modules/messaging.php">Messaging & Inquiry Oversight</a>
        <a href="/CAPSTONE/modules/announcements.php">Broadcast Announcements</a>
        <a href="/CAPSTONE/modules/system_config.php">System Configuration</a>
        <a href="/CAPSTONE/modules/map_radius.php">Map & Radius Management</a>
        <a href="/CAPSTONE/modules/post_reservation.php">Post-Reservation Management</a>
    </nav>

    <div class="user-info">
        <span><?php echo $_SESSION['username'] ?? 'Admin'; ?></span>
        <a href="/CAPSTONE/logout.php">Logout</a>
    </div>
</aside>