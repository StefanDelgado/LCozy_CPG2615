<?php 
require_once __DIR__ . '/../partials/header.php'; 
?>

<div class="page-header">
  <h1>System Configuration</h1>
  <p>Set platform-wide rules, booking limits, notification templates, and content policies</p>
</div>

<div class="stats-grid">
  <div class="stat-card">
    <h3>98.5%</h3>
    <p>System Uptime</p>
  </div>
  <div class="stat-card">
    <h3>47</h3>
    <p>Blocked Apartments</p>
  </div>
  <div class="stat-card">
    <h3>5–10 km</h3>
    <p>Search Radius</p>
  </div>
  <div class="stat-card">
    <h3>12</h3>
    <p>Active Templates</p>
  </div>
</div>

<div class="section">
  <h2>Booking Policies</h2>
  <form class="form-area">
    <label>Maximum Booking Duration</label>
    <select>
      <option>12 months</option>
      <option>6 months</option>
    </select>

    <label>Minimum Advance Payment</label>
    <select>
      <option>1 month</option>
      <option>2 weeks</option>
    </select>

    <label>Payment Deadline</label>
    <select>
      <option>5th of each month</option>
      <option>10th of each month</option>
    </select>

    <label>Cancellation Window</label>
    <select>
      <option>48 hours</option>
      <option>72 hours</option>
    </select>
  </form>
</div>

<div class="section">
  <h2>Content Restrictions</h2>
  <div class="form-area">
    <label><input type="checkbox" checked> Block Apartment Listings</label>
    <label><input type="checkbox"> Hide Promotional Links</label>
    <label><input type="checkbox" checked> Require Gender Restriction</label>
    <label><input type="checkbox" checked> Auto-Hide Full Dorms</label>
  </div>
</div>

<div class="section">
  <h2>Notifications</h2>
  <div class="form-area">
    <label>Payment Confirmations</label>
    <select>
      <option>Auto-send</option>
      <option>Manual</option>
    </select>

    <label>Booking Approvals</label>
    <select>
      <option>Instant</option>
      <option>Daily</option>
    </select>

    <label>Listing Rejections</label>
    <select>
      <option>With Feedback</option>
      <option>Without Feedback</option>
    </select>

    <label><input type="checkbox" checked> System Alerts</label>
  </div>
</div>

<div class="section">
  <h2>Notification Templates</h2>
  <ul class="history-list">
    <li><strong>Payment Confirmation</strong> <small>Last modified: 2024-01-15</small></li>
    <li><strong>Booking Approval</strong> <small>Last modified: 2024-01-12</small></li>
    <li><strong>Listing Rejection</strong> <small>Last modified: 2024-01-10</small></li>
    <li><strong>System Maintenance</strong> <small>Last modified: 2024-01-08</small></li>
  </ul>
</div>

<?php require_once __DIR__ . '/../partials/footer.php'; ?>
