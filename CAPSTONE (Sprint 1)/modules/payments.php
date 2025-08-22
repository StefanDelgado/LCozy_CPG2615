<?php 
require_once __DIR__ . '/../partials/header.php'; 
require_role('admin');
?>

<div class="page-header">
  <h1>Payment Management</h1>
  <p>Track and verify transactions from students and owners</p>
</div>

<div class="stats-grid">
  <div class="stat-card"><h3>₱120,000</h3><p>Total Collected</p></div>
  <div class="stat-card"><h3>₱15,000</h3><p>Pending</p></div>
  <div class="stat-card"><h3>12</h3><p>Overdue Payments</p></div>
</div>

<div class="section">
  <h2>Recent Transactions</h2>
  <table class="data-table">
    <thead>
      <tr>
        <th>ID</th><th>User</th><th>Amount</th><th>Status</th><th>Date</th>
      </tr>
    </thead>
    <tbody>
      <tr><td>1</td><td>Alice Chen</td><td>₱5,000</td><td><span class="status active">Paid</span></td><td>2024-02-12</td></tr>
      <tr><td>2</td><td>David Park</td><td>₱3,500</td><td><span class="status suspended">Overdue</span></td><td>2024-02-08</td></tr>
      <tr><td>3</td><td>Emma Wilson</td><td>₱6,000</td><td><span class="status pending">Pending</span></td><td>2024-02-10</td></tr>
    </tbody>
  </table>
</div>

<?php require_once __DIR__ . '/../partials/footer.php'; ?>