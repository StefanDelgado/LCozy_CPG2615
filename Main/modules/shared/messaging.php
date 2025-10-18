<?php 
require_once __DIR__ . '/../../partials/header.php'; 
require_role('admin');
?>

<div class="page-header">
  <h1>Messaging & Inquiry</h1>
  <p>Monitor messages between students and dorm owners</p>
</div>

<div class="stats-grid">
  <div class="stat-card"><h3>120</h3><p>Open Conversations</p></div>
  <div class="stat-card"><h3>45</h3><p>Unanswered Inquiries</p></div>
</div>

<div class="section">
  <h2>Recent Inquiries</h2>
  <ul class="log-list">
    <li><strong>John Doe</strong> asked <em>“Is WiFi included?”</em> — <small>Pending Reply</small></li>
    <li><strong>Maria Lopez</strong> asked <em>“Can I extend my stay?”</em> — <small>Answered</small></li>
    <li><strong>Michael Smith</strong> asked <em>“Are utilities separate?”</em> — <small>Pending Reply</small></li>
  </ul>
</div>

<?php require_once __DIR__ . '/../partials/footer.php'; ?>
