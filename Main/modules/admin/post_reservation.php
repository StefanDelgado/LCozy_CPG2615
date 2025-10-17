<?php 
$page_title = "Post-Reservation Management";
include __DIR__ . '/../partials/header.php';
?>

<div class="card-grid">
  <div class="card metric">
    <h2>23</h2>
    <small>Pending Reviews</small>
  </div>
  <div class="card metric">
    <h2>156</h2>
    <small>Reviews This Month</small>
  </div>
  <div class="card metric">
    <h2>4.2 ★</h2>
    <small>Average Rating</small>
  </div>
  <div class="card metric">
    <h2>89</h2>
    <small>Tenant Histories Updated</small>
  </div>
</div>

<div class="card-grid">
  <div class="card">
    <h3>Review Requests</h3>
    <label>Auto-send review requests after
      <select><option>3 days</option><option>7 days</option></select>
    </label>
    <label>Review reminder frequency
      <select><option>Weekly</option><option>Monthly</option></select>
    </label>
    <button class="btn">📩 Send Pending Requests</button>
  </div>

  <div class="card">
    <h3>Tenant History</h3>
    <p><strong>347</strong> Active tenants tracked</p>
    <p><strong>89</strong> Histories completed</p>
    <p><strong>5.2 months</strong> Avg stay duration</p>
    <button class="btn">📜 View Full History Log</button>
  </div>

  <div class="card">
    <h3>Actions Overview</h3>
    <p>✔ <strong>89</strong> Review submissions this week</p>
    <p>⏳ <strong>23</strong> Feedback requests pending</p>
    <p>⚠️ <strong>3</strong> Complaint investigations active</p>
    <button class="btn">🔍 View All Actions</button>
  </div>
</div>

<div class="card">
  <input type="text" class="input" placeholder="Search by student name, dorm, or owner...">
  <div class="row">
    <select class="input"><option>Status</option></select>
    <select class="input"><option>Rating</option></select>
    <button class="btn">🔎 More Filters</button>
  </div>
</div>

<div class="card">
  <h3>Post-Reservation Activity Log</h3>
  <table class="table">
    <thead>
      <tr>
        <th>Reservation</th>
        <th>Student & Dorm</th>
        <th>Rating & Review</th>
        <th>Tenant History</th>
        <th>Status</th>
        <th>Actions</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>RES001 <br><small>Checkout: 2024-01-15</small></td>
        <td>Alice Chen <br><small>Modern Shared Dorm Room</small></td>
        <td>⭐ 4.5 <br><small>“Great dorm experience!”</small></td>
        <td>6 months, no issues</td>
        <td><span class="badge success">Review Submitted</span></td>
        <td><button class="btn-sm">👁</button></td>
      </tr>
      <tr>
        <td>RES002 <br><small>Checkout: 2024-01-10</small></td>
        <td>David Park <br><small>Private Single Room</small></td>
        <td>No rating</td>
        <td>3 months, good tenant</td>
        <td><span class="badge warning">Pending Review</span></td>
        <td><button class="btn-sm">📩</button></td>
      </tr>
      <tr>
        <td>RES003 <br><small>Checkout: 2024-01-08</small></td>
        <td>Emma Wilson <br><small>Women’s Shared Dormitory</small></td>
        <td>⭐ 5.0 <br><small>“Excellent tenant!”</small></td>
        <td>8 months, excellent tenant</td>
        <td><span class="badge info">History Updated</span></td>
        <td><button class="btn-sm">👁</button></td>
      </tr>
      <tr>
        <td>RES004 <br><small>Checkout: 2024-01-05</small></td>
        <td>John Santos <br><small>Budget Shared Room</small></td>
        <td>⭐ 2.0 <br><small>“Issues with cleanliness”</small></td>
        <td>2 months, multiple complaints</td>
        <td><span class="badge danger">Complaint Filed</span></td>
        <td><button class="btn-sm danger">⚠ Investigate</button></td>
      </tr>
    </tbody>
  </table>
</div>

<?php include __DIR__ . '/../partials/footer.php'; ?>
