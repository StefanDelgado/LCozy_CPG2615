<?php 
require_once __DIR__ . '/partials/header.php'; 
require_role('student');
?>

<div class="page-header">
  <h1>Student Dashboard</h1>
  <p>Welcome back, <?= htmlspecialchars(current_user()['name']) ?>! Here’s your activity overview.</p>
</div>

<div class="stats-grid">
  <div class="stat-card">
    <h3>2</h3>
    <p>Active Reservations</p>
  </div>
  <div class="stat-card">
    <h3>₱15,000</h3>
    <p>Payments Due</p>
  </div>
  <div class="stat-card">
    <h3>3</h3>
    <p>Unread Messages</p>
  </div>
  <div class="stat-card">
    <h3>1</h3>
    <p>Announcements</p>
  </div>
</div>

<div class="section">
  <h2>Quick Actions</h2>
  <div class="actions">
    <a href="/CAPSTONE/modules/student_reservations.php" class="btn-primary">My Reservations</a>
    <a href="/CAPSTONE/modules/student_payments.php" class="btn-secondary">Payments</a>
    <a href="/CAPSTONE/modules/student_messages.php" class="btn-secondary">Messages</a>
    <a href="/CAPSTONE/modules/student_announcements.php" class="btn-secondary">Announcements</a>
  </div>
</div>

<div class="section">
  <h2>Recent Reservations</h2>
  <table class="data-table">
    <thead>
      <tr>
        <th>Dorm</th>
        <th>Owner</th>
        <th>Status</th>
        <th>Check-in</th>
        <th>Check-out</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>Modern Shared Dorm</td>
        <td>Sarah Johnson</td>
        <td><span class="status active">Active</span></td>
        <td>2024-02-01</td>
        <td>2024-07-01</td>
      </tr>
      <tr>
        <td>Private Single Room</td>
        <td>Michael Chen</td>
        <td><span class="status completed">Completed</span></td>
        <td>2023-09-01</td>
        <td>2024-01-01</td>
      </tr>
    </tbody>
  </table>
</div>

<?php require_once __DIR__ . '/partials/footer.php'; ?>