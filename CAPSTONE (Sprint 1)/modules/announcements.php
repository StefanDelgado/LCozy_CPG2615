<?php 
require_once __DIR__ . '/../partials/header.php'; 
?>

<div class="page-header">
  <h1>Broadcast Announcement System</h1>
  <p>Send announcements to hosts and manage communications</p>
</div>

<!-- Stats Overview -->
<div class="stats-grid">
  <div class="stat-card">
    <h3>52</h3>
    <p>Total Hosts</p>
  </div>
  <div class="stat-card">
    <h3>87%</h3>
    <p>Avg Open Rate</p>
  </div>
  <div class="stat-card">
    <h3>23</h3>
    <p>This Month</p>
  </div>
</div>

<!-- Create Announcement -->
<div class="form-area">
  <h2>Create Announcement</h2>
  <form method="POST" action="">
    <label for="title">Title</label>
    <input type="text" id="title" name="title" placeholder="Enter announcement title...">

    <label for="message">Message</label>
    <textarea id="message" name="message" rows="4" placeholder="Write your announcement message..."></textarea>

    <label for="audience">Target Audience</label>
    <select id="audience" name="audience">
      <option>All Hosts</option>
      <option>Verified Owners</option>
      <option>Pending Owners</option>
    </select>

    <label for="sendOption">Send Options</label>
    <select id="sendOption" name="sendOption">
      <option>Send Now</option>
      <option>Schedule</option>
    </select>

    <div class="actions">
      <button type="submit" class="btn-primary">Send</button>
      <button type="reset" class="btn-secondary">Clear</button>
    </div>
  </form>
</div>

<!-- History -->
<div class="section">
  <h2>Announcement History</h2>
  <ul class="history-list">
    <li>
      <strong>Maintenance Notice – Water Supply</strong> <small>(Sent)</small>
    </li>
    <li>
      <strong>New Platform Features Available</strong> <small>(Sent)</small>
    </li>
    <li>
      <strong>Holiday Booking Reminder</strong> <small>(Scheduled)</small>
    </li>
  </ul>
</div>

<?php require_once __DIR__ . '/../partials/footer.php'; ?>