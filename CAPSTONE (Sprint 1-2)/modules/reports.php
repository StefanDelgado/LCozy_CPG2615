<?php 
require_once __DIR__ . '/../partials/header.php'; 
require_role('admin');
?>

<div class="page-header">
  <h1>Reports & Analytics</h1>
  <p>View booking, revenue, and platform usage statistics</p>
</div>

<div class="stats-grid">
  <div class="stat-card"><h3>542</h3><p>Total Reservations</p></div>
  <div class="stat-card"><h3>₱120,000</h3><p>Total Revenue</p></div>
  <div class="stat-card"><h3>312</h3><p>Active Students</p></div>
  <div class="stat-card"><h3>43</h3><p>Verified Owners</p></div>
</div>

<div class="section">
  <h2>Monthly Reservations Trend</h2>
  <div class="form-area">
    <canvas id="reservationsChart" height="120"></canvas>
  </div>
</div>

<script>
const ctx = document.getElementById('reservationsChart').getContext('2d');
new Chart(ctx, {
  type: 'line',
  data: {
    labels: ["Jan","Feb","Mar","Apr","May","Jun","Jul"],
    datasets: [{
      label: "Reservations",
      data: [50, 65, 80, 70, 90, 120, 140],
      borderColor: "#4A3AFF",
      backgroundColor: "rgba(74,58,255,0.1)",
      fill: true,
      tension: 0.4
    }]
  },
  options: { responsive: true, plugins: { legend: { display: false } } }
});
</script>

<?php require_once __DIR__ . '/../partials/footer.php'; ?>