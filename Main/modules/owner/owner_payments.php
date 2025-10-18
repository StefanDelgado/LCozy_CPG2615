<?php
require_once __DIR__ . '/../../auth/auth.php';
require_role('owner');
require_once __DIR__ . '/../../config.php';

$page_title = "Payment Management";
include __DIR__ . '/../../partials/header.php';

$owner_id = $_SESSION['user']['user_id'];
$flash = null;

// --- Add Payment Reminder ---
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['add_reminder'])) {
    $booking_id = intval($_POST['booking_id']);
    $amount = floatval($_POST['amount']);
    $due_date = $_POST['due_date'];

    $stmt = $pdo->prepare("
        INSERT INTO payments (booking_id, student_id, owner_id, amount, due_date, status, created_at)
        SELECT b.booking_id, b.student_id, ?, ?, ?, 'pending', NOW()
        FROM bookings b
        JOIN rooms r ON b.room_id = r.room_id
        JOIN dormitories d ON r.dorm_id = d.dorm_id
        WHERE b.booking_id = ? AND d.owner_id = ?
    ");
    $stmt->execute([$owner_id, $amount, $due_date, $booking_id, $owner_id]);
    $flash = ['type' => 'success', 'msg' => 'Payment reminder added successfully.'];
}

// --- Manual Status Updates (Confirm/Reject) ---
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['update_status'])) {
    $payment_id = intval($_POST['payment_id']);
    $status = $_POST['status'];

    // Authorize via booking->room->dorm (owner relationship) so we don't rely on payments.owner_id
    $stmt = $pdo->prepare("
        UPDATE payments p
        JOIN bookings b ON p.booking_id = b.booking_id
        JOIN rooms r ON b.room_id = r.room_id
        JOIN dormitories d ON r.dorm_id = d.dorm_id
        SET p.status = ?, p.updated_at = NOW()
        WHERE p.payment_id = ? AND d.owner_id = ?
    ");
    $stmt->execute([$status, $payment_id, $owner_id]);
    $flash = ['type' => 'success', 'msg' => 'Payment status updated successfully.'];
}
 
// --- Delete a Payment ---
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['delete_payment'])) {
    $payment_id = intval($_POST['payment_id']);
    // Ensure owner owns the related dorm via booking -> room -> dorm
    $stmt = $pdo->prepare("
        DELETE p FROM payments p
        JOIN bookings b ON p.booking_id = b.booking_id
        JOIN rooms r ON b.room_id = r.room_id
        JOIN dormitories d ON r.dorm_id = d.dorm_id
        WHERE p.payment_id = ? AND d.owner_id = ?
    ");
    $stmt->execute([$payment_id, $owner_id]);
    $flash = ['type' => 'error', 'msg' => 'Payment record deleted successfully.'];
}

// --- Fetch Bookings for Dropdown ---
$bookings = $pdo->prepare("
    SELECT b.booking_id, u.name AS student_name, d.name AS dorm_name
    FROM bookings b
    JOIN users u ON b.student_id = u.user_id
    JOIN rooms r ON b.room_id = r.room_id
    JOIN dormitories d ON r.dorm_id = d.dorm_id
    WHERE d.owner_id = ? AND b.status = 'approved'
");
$bookings->execute([$owner_id]);
$bookings = $bookings->fetchAll(PDO::FETCH_ASSOC);

// --- Fetch Payment Statistics ---
$stats_query = $pdo->prepare("
    SELECT 
        COUNT(*) as total_payments,
        SUM(CASE WHEN p.status = 'pending' THEN 1 ELSE 0 END) as pending_count,
        SUM(CASE WHEN p.status = 'submitted' THEN 1 ELSE 0 END) as submitted_count,
        SUM(CASE WHEN p.status = 'paid' THEN 1 ELSE 0 END) as paid_count,
        SUM(CASE WHEN p.status = 'expired' THEN 1 ELSE 0 END) as expired_count,
        SUM(CASE WHEN p.status = 'paid' THEN p.amount ELSE 0 END) as total_revenue
    FROM payments p
    JOIN bookings b ON p.booking_id = b.booking_id
    JOIN rooms r ON b.room_id = r.room_id
    JOIN dormitories d ON r.dorm_id = d.dorm_id
    WHERE d.owner_id = ?
");
$stats_query->execute([$owner_id]);
$stats = $stats_query->fetch(PDO::FETCH_ASSOC);
?>

<div class="page-header">
  <div class="header-content">
    <div>
      <h1>💰 Payment Management</h1>
      <p>Track payments, confirm receipts, and manage student billing efficiently.</p>
    </div>
    <button class="btn-add" onclick="document.getElementById('addPaymentModal').style.display='flex'">
      ➕ Add Payment Reminder
    </button>
  </div>
</div>

<?php if ($flash): ?>
  <div class="alert alert-<?= $flash['type'] ?>"><?= htmlspecialchars($flash['msg']) ?></div>
<?php endif; ?>

<!-- Statistics Dashboard -->
<div class="stats-grid">
  <div class="stat-card">
    <div class="stat-icon" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);">
      📊
    </div>
    <div class="stat-details">
      <h3><?= $stats['total_payments'] ?? 0 ?></h3>
      <p>Total Payments</p>
    </div>
  </div>
  
  <div class="stat-card">
    <div class="stat-icon" style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);">
      ⏳
    </div>
    <div class="stat-details">
      <h3><?= $stats['pending_count'] ?? 0 ?></h3>
      <p>Pending</p>
    </div>
  </div>
  
  <div class="stat-card">
    <div class="stat-icon" style="background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);">
      📤
    </div>
    <div class="stat-details">
      <h3><?= $stats['submitted_count'] ?? 0 ?></h3>
      <p>Submitted</p>
    </div>
  </div>
  
  <div class="stat-card">
    <div class="stat-icon" style="background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);">
      ✓
    </div>
    <div class="stat-details">
      <h3><?= $stats['paid_count'] ?? 0 ?></h3>
      <p>Paid</p>
    </div>
  </div>
  
  <div class="stat-card">
    <div class="stat-icon" style="background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);">
      💵
    </div>
    <div class="stat-details">
      <h3>₱<?= number_format($stats['total_revenue'] ?? 0, 2) ?></h3>
      <p>Total Revenue</p>
    </div>
  </div>
</div>

<!-- Filter Tabs -->
<div class="filter-tabs">
  <button class="filter-tab active" data-filter="all">All Payments</button>
  <button class="filter-tab" data-filter="pending">Pending</button>
  <button class="filter-tab" data-filter="submitted">Submitted</button>
  <button class="filter-tab" data-filter="paid">Paid</button>
  <button class="filter-tab" data-filter="expired">Expired</button>
</div>

<!-- Payments Grid -->
<div class="payments-grid" id="paymentsGrid">
  <!-- Loaded by JavaScript -->
  <div class="loading-state">
    <div class="spinner"></div>
    <p>Loading payments...</p>
  </div>
</div>

<!-- Add Payment Modal -->
<div id="addPaymentModal" class="modal">
  <div class="modal-content">
    <div class="modal-header">
      <h2>➕ Add Payment Reminder</h2>
      <button class="modal-close" onclick="document.getElementById('addPaymentModal').style.display='none'">&times;</button>
    </div>
    <form method="post">
      <div class="form-group">
        <label>📋 Booking</label>
        <select name="booking_id" required>
          <option value="">Select Booking</option>
          <?php foreach ($bookings as $b): ?>
            <option value="<?= $b['booking_id'] ?>">
              <?= htmlspecialchars($b['student_name']) ?> — <?= htmlspecialchars($b['dorm_name']) ?>
            </option>
          <?php endforeach; ?>
        </select>
      </div>
      <div class="form-group">
        <label>💵 Amount (₱)</label>
        <input type="number" step="0.01" name="amount" placeholder="Enter amount" required>
      </div>
      <div class="form-group">
        <label>📅 Due Date</label>
        <input type="date" name="due_date" required>
      </div>
      <div class="modal-actions">
        <button type="button" class="btn-secondary" onclick="document.getElementById('addPaymentModal').style.display='none'">Cancel</button>
        <button type="submit" name="add_reminder" class="btn-primary">Add Reminder</button>
      </div>
    </form>
  </div>
</div>

<script>
let currentFilter = 'all';
let allPayments = [];

// Filter Tabs
document.querySelectorAll('.filter-tab').forEach(tab => {
  tab.addEventListener('click', function() {
    document.querySelectorAll('.filter-tab').forEach(t => t.classList.remove('active'));
    this.classList.add('active');
    currentFilter = this.dataset.filter;
    renderPayments();
  });
});

async function fetchPayments() {
  try {
    const res = await fetch('fetch_payments.php');
    const data = await res.json();
    allPayments = data;
    renderPayments();
  } catch (err) {
    console.error('Error fetching payments:', err);
    document.getElementById('paymentsGrid').innerHTML = `
      <div class="empty-state">
        <div class="empty-icon">⚠️</div>
        <h3>Error Loading Payments</h3>
        <p>Unable to fetch payment data. Please refresh the page.</p>
      </div>
    `;
  }
}

function renderPayments() {
  const grid = document.getElementById('paymentsGrid');
  
  // Filter payments
  let filtered = allPayments;
  if (currentFilter !== 'all') {
    filtered = allPayments.filter(p => {
      const createdAt = new Date(p.created_at);
      const now = new Date();
      const hoursElapsed = Math.floor((now - createdAt) / (1000 * 60 * 60));
      const expired = hoursElapsed >= 48 && p.status === 'pending';
      
      if (currentFilter === 'expired') {
        return expired;
      }
      return p.status === currentFilter && !expired;
    });
  }
  
  if (filtered.length === 0) {
    grid.innerHTML = `
      <div class="empty-state">
        <div class="empty-icon">📭</div>
        <h3>No ${currentFilter === 'all' ? '' : currentFilter.charAt(0).toUpperCase() + currentFilter.slice(1)} Payments</h3>
        <p>${currentFilter === 'all' ? 'Add payment reminders to track student payments.' : 'No payments found with this status.'}</p>
      </div>
    `;
    return;
  }
  
  grid.innerHTML = '';
  
  filtered.forEach(p => {
    const createdAt = new Date(p.created_at);
    const now = new Date();
    const hoursElapsed = Math.floor((now - createdAt) / (1000 * 60 * 60));
    const hoursLeft = 48 - hoursElapsed;
    const expired = hoursElapsed >= 48 && p.status === 'pending';
    
    const statusDisplay = expired ? 'expired' : p.status;
    const statusText = expired ? 'Expired' : p.status.charAt(0).toUpperCase() + p.status.slice(1);
    
    // Status badge colors
    const statusColors = {
      'pending': 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)',
      'submitted': 'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)',
      'paid': 'linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)',
      'expired': 'linear-gradient(135deg, #fc4a1a 0%, #f7b733 100%)'
    };
    
    const card = document.createElement('div');
    card.className = 'payment-card';
    card.innerHTML = `
      <div class="payment-card-header">
        <div class="payment-student">
          <div class="student-avatar">${p.student_name.charAt(0).toUpperCase()}</div>
          <div>
            <h3>${p.student_name}</h3>
            <p>🏠 ${p.dorm_name} • ${p.room_type}</p>
          </div>
        </div>
        <div class="payment-status" style="background: ${statusColors[statusDisplay]}">
          ${statusText}
        </div>
      </div>
      
      <div class="payment-card-body">
        <div class="payment-info-grid">
          <div class="info-item">
            <span class="info-label">💵 Amount</span>
            <span class="info-value">₱${parseFloat(p.amount).toFixed(2)}</span>
          </div>
          <div class="info-item">
            <span class="info-label">📅 Due Date</span>
            <span class="info-value">${p.due_date}</span>
          </div>
          ${p.status === 'pending' && !expired ? `
            <div class="info-item">
              <span class="info-label">⏳ Time Left</span>
              <span class="info-value">${hoursLeft}h remaining</span>
            </div>
          ` : ''}
          <div class="info-item">
            <span class="info-label">📎 Receipt</span>
            <span class="info-value">
              ${p.receipt_image 
                ? `<a href="../uploads/receipts/${p.receipt_image}" target="_blank" class="receipt-link">View Receipt</a>` 
                : '<span style="color: #999;">No receipt</span>'}
            </span>
          </div>
        </div>
      </div>
      
      <div class="payment-card-actions">
        <form method="post" style="display:inline-block; flex: 1;">
          <input type="hidden" name="payment_id" value="${p.payment_id}">
          <select name="status" class="status-select" onchange="this.form.submit()">
            ${['pending', 'submitted', 'paid', 'expired'].map(s =>
              `<option value="${s}" ${p.status === s ? 'selected' : ''}>${s.charAt(0).toUpperCase() + s.slice(1)}</option>`
            ).join('')}
          </select>
          <input type="hidden" name="update_status" value="1">
        </form>
        <form method="post" style="display:inline-block;" onsubmit="return confirm('Are you sure you want to delete this payment record?')">
          <input type="hidden" name="payment_id" value="${p.payment_id}">
          <button type="submit" name="delete_payment" class="btn-delete">🗑️ Delete</button>
        </form>
      </div>
    `;
    
    grid.appendChild(card);
  });
}

document.addEventListener('DOMContentLoaded', fetchPayments);
setInterval(fetchPayments, 10000);

// Close modal on outside click
window.onclick = function(event) {
  const modal = document.getElementById('addPaymentModal');
  if (event.target === modal) {
    modal.style.display = 'none';
  }
}
</script>

<style>
/* ===== Global Styles ===== */
* {
  box-sizing: border-box;
}

body {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  min-height: 100vh;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

/* ===== Page Header ===== */
.page-header {
  margin-bottom: 30px;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 20px;
  flex-wrap: wrap;
}

.page-header h1 {
  margin: 0 0 8px 0;
  font-size: 2.2rem;
  color: #2c3e50;
  display: flex;
  align-items: center;
  gap: 10px;
}

.page-header p {
  margin: 0;
  color: #6c757d;
  font-size: 1rem;
}

.btn-add {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
  transition: all 0.3s ease;
}

.btn-add:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
}

/* ===== Alert Messages ===== */
.alert {
  padding: 15px 20px;
  border-radius: 10px;
  margin-bottom: 20px;
  font-weight: 500;
  display: flex;
  align-items: center;
  gap: 10px;
  animation: slideDown 0.3s ease;
}

.alert-success {
  background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
  color: white;
  box-shadow: 0 4px 12px rgba(67, 233, 123, 0.3);
}

.alert-error {
  background: linear-gradient(135deg, #fc4a1a 0%, #f7b733 100%);
  color: white;
  box-shadow: 0 4px 12px rgba(252, 74, 26, 0.3);
}

@keyframes slideDown {
  from {
    opacity: 0;
    transform: translateY(-20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* ===== Statistics Grid ===== */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.stat-card {
  background: white;
  padding: 20px;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.08);
  display: flex;
  align-items: center;
  gap: 15px;
  transition: all 0.3s ease;
  animation: fadeIn 0.5s ease;
}

.stat-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 20px rgba(0,0,0,0.12);
}

.stat-icon {
  width: 55px;
  height: 55px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.6rem;
  flex-shrink: 0;
  color: white;
}

.stat-details h3 {
  margin: 0 0 4px 0;
  font-size: 1.8rem;
  color: #2c3e50;
  font-weight: 700;
}

.stat-details p {
  margin: 0;
  color: #6c757d;
  font-size: 0.9rem;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: scale(0.9);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}

/* ===== Filter Tabs ===== */
.filter-tabs {
  display: flex;
  gap: 10px;
  margin-bottom: 25px;
  flex-wrap: wrap;
}

.filter-tab {
  padding: 10px 20px;
  background: white;
  border: 2px solid #e9ecef;
  border-radius: 8px;
  font-size: 0.95rem;
  font-weight: 600;
  color: #495057;
  cursor: pointer;
  transition: all 0.3s ease;
}

.filter-tab:hover {
  background: #f8f9fa;
  border-color: #667eea;
  color: #667eea;
}

.filter-tab.active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-color: #667eea;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

/* ===== Payments Grid ===== */
.payments-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  gap: 20px;
  animation: fadeIn 0.5s ease;
}

.payment-card {
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.08);
  overflow: hidden;
  transition: all 0.3s ease;
  animation: slideUp 0.4s ease;
}

.payment-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 24px rgba(0,0,0,0.15);
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* ===== Payment Card Header ===== */
.payment-card-header {
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  padding: 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 15px;
  border-bottom: 1px solid #dee2e6;
}

.payment-student {
  display: flex;
  align-items: center;
  gap: 12px;
  flex: 1;
  min-width: 0;
}

.student-avatar {
  width: 45px;
  height: 45px;
  border-radius: 50%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.2rem;
  font-weight: 700;
  flex-shrink: 0;
}

.payment-student h3 {
  margin: 0 0 4px 0;
  font-size: 1.1rem;
  color: #2c3e50;
  font-weight: 600;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.payment-student p {
  margin: 0;
  font-size: 0.85rem;
  color: #6c757d;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.payment-status {
  padding: 8px 16px;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 700;
  color: white;
  white-space: nowrap;
  box-shadow: 0 2px 8px rgba(0,0,0,0.15);
}

/* ===== Payment Card Body ===== */
.payment-card-body {
  padding: 20px;
}

.payment-info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
  gap: 15px;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.info-label {
  font-size: 0.85rem;
  color: #6c757d;
  font-weight: 500;
}

.info-value {
  font-size: 1rem;
  color: #2c3e50;
  font-weight: 600;
}

.receipt-link {
  color: #667eea;
  text-decoration: none;
  font-weight: 600;
  transition: color 0.2s;
}

.receipt-link:hover {
  color: #764ba2;
  text-decoration: underline;
}

/* ===== Payment Card Actions ===== */
.payment-card-actions {
  padding: 15px 20px;
  background: #f8f9fa;
  border-top: 1px solid #e9ecef;
  display: flex;
  gap: 10px;
  align-items: center;
}

.status-select {
  flex: 1;
  padding: 10px 14px;
  border: 2px solid #e9ecef;
  border-radius: 8px;
  font-size: 0.95rem;
  font-weight: 500;
  color: #495057;
  background: white;
  cursor: pointer;
  transition: all 0.2s;
}

.status-select:hover {
  border-color: #667eea;
}

.status-select:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.btn-delete {
  padding: 10px 16px;
  background: linear-gradient(135deg, #fc4a1a 0%, #f7b733 100%);
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 0.9rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  white-space: nowrap;
}

.btn-delete:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(252, 74, 26, 0.3);
}

/* ===== Empty State ===== */
.empty-state {
  grid-column: 1 / -1;
  text-align: center;
  padding: 60px 20px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.08);
}

.empty-icon {
  font-size: 4rem;
  margin-bottom: 20px;
  opacity: 0.5;
}

.empty-state h3 {
  margin: 0 0 10px 0;
  color: #2c3e50;
  font-size: 1.4rem;
}

.empty-state p {
  margin: 0;
  color: #6c757d;
  font-size: 1rem;
}

/* ===== Loading State ===== */
.loading-state {
  grid-column: 1 / -1;
  text-align: center;
  padding: 60px 20px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.08);
}

.spinner {
  width: 50px;
  height: 50px;
  border: 4px solid #e9ecef;
  border-top: 4px solid #667eea;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 20px;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

.loading-state p {
  margin: 0;
  color: #6c757d;
  font-size: 1rem;
}

/* ===== Modal Styles ===== */
.modal {
  display: none;
  position: fixed;
  z-index: 1000;
  left: 0;
  top: 0;
  width: 100%;
  height: 100%;
  background: rgba(0,0,0,0.6);
  align-items: center;
  justify-content: center;
  animation: fadeIn 0.3s ease;
}

.modal-content {
  background: white;
  border-radius: 16px;
  width: 90%;
  max-width: 500px;
  box-shadow: 0 20px 60px rgba(0,0,0,0.3);
  animation: scaleIn 0.3s ease;
}

@keyframes scaleIn {
  from {
    transform: scale(0.9);
    opacity: 0;
  }
  to {
    transform: scale(1);
    opacity: 1;
  }
}

.modal-header {
  padding: 25px 30px;
  border-bottom: 1px solid #e9ecef;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.modal-header h2 {
  margin: 0;
  font-size: 1.5rem;
  color: #2c3e50;
}

.modal-close {
  background: none;
  border: none;
  font-size: 2rem;
  color: #6c757d;
  cursor: pointer;
  width: 35px;
  height: 35px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  transition: all 0.2s;
}

.modal-close:hover {
  background: #f8f9fa;
  color: #2c3e50;
}

.modal-content form {
  padding: 30px;
}

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  margin-bottom: 8px;
  font-weight: 600;
  color: #2c3e50;
  font-size: 0.95rem;
}

.form-group input,
.form-group select {
  width: 100%;
  padding: 12px 14px;
  border: 2px solid #e9ecef;
  border-radius: 8px;
  font-size: 1rem;
  color: #495057;
  transition: all 0.2s;
}

.form-group input:focus,
.form-group select:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.modal-actions {
  display: flex;
  gap: 10px;
  margin-top: 30px;
}

.btn-primary {
  flex: 1;
  padding: 12px 24px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
}

.btn-secondary {
  flex: 1;
  padding: 12px 24px;
  background: white;
  color: #495057;
  border: 2px solid #e9ecef;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.btn-secondary:hover {
  background: #f8f9fa;
  border-color: #ced4da;
}

/* ===== Responsive Design ===== */
@media (max-width: 768px) {
  .header-content {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .btn-add {
    width: 100%;
  }
  
  .stats-grid {
    grid-template-columns: 1fr;
  }
  
  .payments-grid {
    grid-template-columns: 1fr;
  }
  
  .payment-card-header {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .payment-status {
    align-self: flex-start;
  }
  
  .filter-tabs {
    overflow-x: auto;
    flex-wrap: nowrap;
  }
  
  .modal-content {
    width: 95%;
    margin: 20px;
  }
}

@media (max-width: 480px) {
  .page-header h1 {
    font-size: 1.6rem;
  }
  
  .stat-details h3 {
    font-size: 1.4rem;
  }
  
  .payment-info-grid {
    grid-template-columns: 1fr;
  }
  
  .payment-card-actions {
    flex-direction: column;
  }
  
  .status-select,
  .btn-delete {
    width: 100%;
  }
}
</style>

<?php require_once __DIR__ . '/../partials/footer.php'; ?>
