<?php
require_once __DIR__ . '/../../auth/auth.php';
require_role('owner');
require_once __DIR__ . '/../../config.php';

$page_title = "Tenant Management";
include __DIR__ . '/../../partials/header.php';

$owner_id = $_SESSION['user']['user_id'];
$active_tab = $_GET['tab'] ?? 'current';
$flash = null;

// Fetch payment history for AJAX request
if (isset($_GET['ajax']) && $_GET['ajax'] === 'payment_history' && isset($_GET['tenant_id'])) {
    $tenant_id = (int)$_GET['tenant_id'];
    
    // First, verify the tenant belongs to this owner
    $verify = $pdo->prepare("
        SELECT t.booking_id, t.student_id 
        FROM tenants t
        JOIN dormitories d ON t.dorm_id = d.dorm_id
        WHERE t.tenant_id = ? AND d.owner_id = ?
    ");
    $verify->execute([$tenant_id, $owner_id]);
    $tenant_info = $verify->fetch(PDO::FETCH_ASSOC);
    
    if ($tenant_info) {
        // Fetch payments for this tenant's booking
        $stmt = $pdo->prepare("
            SELECT 
                p.payment_id,
                p.amount,
                p.payment_date,
                p.due_date,
                p.status,
                p.payment_method,
                p.reference_number,
                p.payment_type,
                p.created_at
            FROM payments p
            WHERE p.booking_id = ?
            ORDER BY p.created_at DESC
        ");
        $stmt->execute([$tenant_info['booking_id']]);
        $payments = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        header('Content-Type: application/json');
        echo json_encode($payments);
    } else {
        // Tenant not found or doesn't belong to this owner
        header('Content-Type: application/json');
        echo json_encode(['error' => 'Tenant not found or access denied']);
    }
    exit();
}

// Handle Send Message
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['send_message'])) {
    $student_id = (int)$_POST['student_id'];
    $dorm_id = (int)$_POST['dorm_id'];
    $message_body = trim($_POST['message_body']);
    
    if (!empty($message_body)) {
        $stmt = $pdo->prepare("
            INSERT INTO messages (sender_id, receiver_id, dorm_id, body, created_at)
            VALUES (?, ?, ?, ?, NOW())
        ");
        $stmt->execute([$owner_id, $student_id, $dorm_id, $message_body]);
        $flash = ['type' => 'success', 'msg' => 'Message sent successfully!'];
    }
}

// Handle Add Payment Reminder
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['add_payment_reminder'])) {
    $booking_id = (int)$_POST['booking_id'];
    $amount = (float)$_POST['amount'];
    $due_date = $_POST['due_date'];
    $student_id = (int)$_POST['student_id'];
    
    $stmt = $pdo->prepare("
        INSERT INTO payments (booking_id, student_id, owner_id, amount, due_date, status, created_at)
        VALUES (?, ?, ?, ?, ?, 'pending', NOW())
    ");
    $stmt->execute([$booking_id, $student_id, $owner_id, $amount, $due_date]);
    $flash = ['type' => 'success', 'msg' => 'Payment reminder added successfully!'];
}

// Fetch tenants
$stmt = $pdo->prepare("
    SELECT 
        t.tenant_id,
        t.booking_id,
        t.student_id,
        t.dorm_id,
        u.name AS tenant_name,
        u.email AS tenant_email,
        u.phone AS tenant_phone,
        d.name AS dorm_name,
        r.room_type,
        t.check_in_date,
        t.expected_checkout,
        DATEDIFF(t.expected_checkout, CURDATE()) AS days_remaining,
        t.total_paid,
        t.outstanding_balance,
        t.status AS tenant_status
    FROM tenants t
    JOIN users u ON t.student_id = u.user_id
    JOIN dormitories d ON t.dorm_id = d.dorm_id AND d.owner_id = ?
    JOIN rooms r ON t.room_id = r.room_id
    WHERE t.status IN ('active', 'pending')
    ORDER BY t.check_in_date DESC
");
$stmt->execute([$owner_id]);
$current_tenants = $stmt->fetchAll(PDO::FETCH_ASSOC);

$total_current = count($current_tenants);
$total_revenue = array_sum(array_column($current_tenants, 'total_paid'));
?>

<div class="page-header">
    <div>
        <h1>Tenant Management</h1>
        <p>Track and manage your current and past tenants</p>
    </div>
</div>

<?php if ($flash): ?>
<div class="alert alert-<?= $flash['type'] ?>" style="margin: 20px 0; padding: 15px; border-radius: 8px; background: <?= $flash['type'] === 'success' ? '#d4edda' : '#f8d7da' ?>; color: <?= $flash['type'] === 'success' ? '#155724' : '#721c24' ?>;">
    <?= htmlspecialchars($flash['msg']) ?>
</div>
<?php endif; ?>

<!-- Statistics -->
<div class="stats-grid">
    <div class="stat-card">
        <h3><?= $total_current ?></h3>
        <p>Current Tenants</p>
    </div>
    <div class="stat-card">
        <h3>₱<?= number_format($total_revenue, 2) ?></h3>
        <p>Total Revenue</p>
    </div>
</div>

<div class="section">
    <h2>Current Tenants (<?= $total_current ?>)</h2>
    
    <?php if (empty($current_tenants)): ?>
        <div class="card" style="text-align: center; padding: 60px 20px;">
            <h3 style="color: #666;">No Current Tenants</h3>
            <p style="color: #999;">You don't have any active tenants at the moment.</p>
        </div>
    <?php else: ?>
        <?php foreach ($current_tenants as $tenant): 
            $days_left = (int)$tenant['days_remaining'];
            $is_overdue = $days_left < 0;
        ?>
            <div class="card" style="margin-bottom: 15px;">
                <div style="display: flex; justify-content: space-between; align-items: start; margin-bottom: 15px;">
                    <div>
                        <h3 style="margin: 0 0 5px 0; font-size: 18px;"><?= htmlspecialchars($tenant['tenant_name']) ?></h3>
                        <div style="color: #666; font-size: 14px;">
                            <?= htmlspecialchars($tenant['dorm_name']) ?> • <?= htmlspecialchars($tenant['room_type']) ?> Room
                        </div>
                    </div>
                    <div>
                        <span class="badge success"><?= ucfirst($tenant['tenant_status']) ?></span>
                    </div>
                </div>

                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 12px; padding: 12px; background: #f8f9fa; border-radius: 8px;">
                    <div>
                        <label style="font-size: 11px; color: #666; margin-bottom: 3px; text-transform: uppercase; font-weight: 600; display: block;">Email</label>
                        <span style="font-size: 14px; color: #333;"><?= htmlspecialchars($tenant['tenant_email']) ?></span>
                    </div>
                    <div>
                        <label style="font-size: 11px; color: #666; margin-bottom: 3px; text-transform: uppercase; font-weight: 600; display: block;">Phone</label>
                        <span style="font-size: 14px; color: #333;"><?= htmlspecialchars($tenant['tenant_phone'] ?: 'Not provided') ?></span>
                    </div>
                    <div>
                        <label style="font-size: 11px; color: #666; margin-bottom: 3px; text-transform: uppercase; font-weight: 600; display: block;">Check-in Date</label>
                        <span style="font-size: 14px; color: #333;"><?= date('M d, Y', strtotime($tenant['check_in_date'])) ?></span>
                    </div>
                    <div>
                        <label style="font-size: 11px; color: #666; margin-bottom: 3px; text-transform: uppercase; font-weight: 600; display: block;">Expected Checkout</label>
                        <span style="font-size: 14px; color: #333;"><?= date('M d, Y', strtotime($tenant['expected_checkout'])) ?></span>
                    </div>
                    <div>
                        <label style="font-size: 11px; color: #666; margin-bottom: 3px; text-transform: uppercase; font-weight: 600; display: block;">Days Remaining</label>
                        <span style="font-size: 14px; color: <?= $is_overdue ? '#d9534f' : '#333' ?>;"><?= $days_left ?> days</span>
                    </div>
                    <div>
                        <label style="font-size: 11px; color: #666; margin-bottom: 3px; text-transform: uppercase; font-weight: 600; display: block;">Total Paid</label>
                        <span style="font-size: 14px; color: #333;">₱<?= number_format($tenant['total_paid'], 2) ?></span>
                    </div>
                </div>

                <!-- Action Buttons -->
                <div style="display: flex; gap: 10px; margin-top: 15px; padding-top: 15px; border-top: 1px solid #e0e0e0;">
                    <button onclick="openMessageModal(<?= $tenant['student_id'] ?>, <?= $tenant['dorm_id'] ?>, '<?= htmlspecialchars($tenant['tenant_name']) ?>')" 
                            class="btn btn-primary" style="flex: 1;">
                        <i class="fa fa-envelope"></i> Send Message
                    </button>
                    <button onclick="openPaymentModal(<?= $tenant['booking_id'] ?>, <?= $tenant['student_id'] ?>, '<?= htmlspecialchars($tenant['tenant_name']) ?>')" 
                            class="btn btn-secondary" style="flex: 1;">
                        <i class="fa fa-dollar-sign"></i> Add Payment
                    </button>
                    <button onclick="openPaymentHistoryModal(<?= $tenant['tenant_id'] ?>, '<?= htmlspecialchars($tenant['tenant_name']) ?>')" 
                            class="btn btn-outline" style="flex: 1;">
                        <i class="fa fa-history"></i> View History
                    </button>
                </div>
            </div>
        <?php endforeach; ?>
    <?php endif; ?>
</div>

<!-- Send Message Modal -->
<div id="messageModal" class="modal" style="display: none;">
    <div class="modal-content" style="max-width: 500px;">
        <div class="modal-header">
            <h2>Send Message to <span id="messageTenantName"></span></h2>
            <button onclick="closeModal('messageModal')" class="close-btn">&times;</button>
        </div>
        <form method="POST">
            <input type="hidden" name="student_id" id="messageStudentId">
            <input type="hidden" name="dorm_id" id="messageDormId">
            
            <div class="form-group">
                <label>Message:</label>
                <textarea name="message_body" required rows="5" placeholder="Type your message here..." style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 6px; font-family: inherit;"></textarea>
            </div>
            
            <div style="display: flex; gap: 10px; margin-top: 20px;">
                <button type="submit" name="send_message" class="btn btn-primary" style="flex: 1;">
                    <i class="fa fa-paper-plane"></i> Send Message
                </button>
                <button type="button" onclick="closeModal('messageModal')" class="btn btn-secondary" style="flex: 1;">
                    Cancel
                </button>
            </div>
        </form>
    </div>
</div>

<!-- Add Payment Modal -->
<div id="paymentModal" class="modal" style="display: none;">
    <div class="modal-content" style="max-width: 500px;">
        <div class="modal-header">
            <h2>Add Payment Reminder for <span id="paymentTenantName"></span></h2>
            <button onclick="closeModal('paymentModal')" class="close-btn">&times;</button>
        </div>
        <form method="POST">
            <input type="hidden" name="booking_id" id="paymentBookingId">
            <input type="hidden" name="student_id" id="paymentStudentId">
            
            <div class="form-group">
                <label>Amount (₱):</label>
                <input type="number" name="amount" required step="0.01" min="0" placeholder="0.00" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 6px;">
            </div>
            
            <div class="form-group">
                <label>Due Date:</label>
                <input type="date" name="due_date" required style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 6px;">
            </div>
            
            <div style="display: flex; gap: 10px; margin-top: 20px;">
                <button type="submit" name="add_payment_reminder" class="btn btn-primary" style="flex: 1;">
                    <i class="fa fa-plus"></i> Add Reminder
                </button>
                <button type="button" onclick="closeModal('paymentModal')" class="btn btn-secondary" style="flex: 1;">
                    Cancel
                </button>
            </div>
        </form>
    </div>
</div>

<!-- Payment History Modal -->
<div id="paymentHistoryModal" class="modal" style="display: none;">
    <div class="modal-content" style="max-width: 800px; max-height: 90vh; overflow-y: auto;">
        <div class="modal-header">
            <h2>Payment History - <span id="historyTenantName"></span></h2>
            <button onclick="closeModal('paymentHistoryModal')" class="close-btn">&times;</button>
        </div>
        
        <div id="paymentHistoryContent">
            <div style="text-align: center; padding: 40px;">
                <div class="spinner"></div>
                <p>Loading payment history...</p>
            </div>
        </div>
        
        <div style="margin-top: 20px; text-align: right;">
            <button type="button" onclick="closeModal('paymentHistoryModal')" class="btn btn-secondary">
                Close
            </button>
        </div>
    </div>
</div>

<style>
    .modal {
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: rgba(0, 0, 0, 0.5);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 9999;
    }
    
    .modal-content {
        background: white;
        padding: 30px;
        border-radius: 12px;
        box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
        width: 90%;
        max-width: 600px;
    }
    
    .modal-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 20px;
    }
    
    .modal-header h2 {
        margin: 0;
        font-size: 20px;
    }
    
    .close-btn {
        background: none;
        border: none;
        font-size: 28px;
        cursor: pointer;
        color: #999;
        line-height: 1;
        padding: 0;
        width: 30px;
        height: 30px;
    }
    
    .close-btn:hover {
        color: #333;
    }
    
    .form-group {
        margin-bottom: 15px;
    }
    
    .form-group label {
        display: block;
        margin-bottom: 5px;
        font-weight: 600;
        color: #333;
    }
    
    .btn {
        padding: 10px 20px;
        border: none;
        border-radius: 6px;
        cursor: pointer;
        font-size: 14px;
        font-weight: 600;
        transition: all 0.2s;
    }
    
    .btn-primary {
        background: #8b5cf6;
        color: white;
    }
    
    .btn-primary:hover {
        background: #7c3aed;
    }
    
    .btn-secondary {
        background: #6c757d;
        color: white;
    }
    
    .btn-secondary:hover {
        background: #5a6268;
    }
    
    .btn-outline {
        background: white;
        color: #8b5cf6;
        border: 2px solid #8b5cf6;
        text-decoration: none;
        display: inline-block;
    }
    
    .btn-outline:hover {
        background: #8b5cf6;
        color: white;
    }
    
    .payment-history-table {
        width: 100%;
        border-collapse: collapse;
        margin-top: 15px;
    }
    
    .payment-history-table thead {
        background: #f8f9fa;
    }
    
    .payment-history-table th {
        padding: 12px;
        text-align: left;
        font-weight: 600;
        color: #333;
        border-bottom: 2px solid #dee2e6;
        font-size: 13px;
    }
    
    .payment-history-table td {
        padding: 12px;
        border-bottom: 1px solid #e9ecef;
        font-size: 14px;
    }
    
    .payment-history-table tr:hover {
        background: #f8f9fa;
    }
    
    .status-badge {
        padding: 4px 10px;
        border-radius: 12px;
        font-size: 12px;
        font-weight: 600;
        text-transform: uppercase;
    }
    
    .status-badge.paid {
        background: #d4edda;
        color: #155724;
    }
    
    .status-badge.pending {
        background: #fff3cd;
        color: #856404;
    }
    
    .status-badge.overdue {
        background: #f8d7da;
        color: #721c24;
    }
    
    .no-payments {
        text-align: center;
        padding: 40px;
        color: #666;
    }
    
    .no-payments i {
        font-size: 48px;
        color: #ccc;
        margin-bottom: 15px;
    }
    
    .spinner {
        border: 4px solid #f3f3f3;
        border-top: 4px solid #8b5cf6;
        border-radius: 50%;
        width: 40px;
        height: 40px;
        animation: spin 1s linear infinite;
        margin: 0 auto;
    }
    
    @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
    }
    
    .payment-summary {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 15px;
        margin-bottom: 20px;
        padding: 20px;
        background: #f8f9fa;
        border-radius: 8px;
    }
    
    .summary-item {
        text-align: center;
    }
    
    .summary-item h3 {
        margin: 0 0 5px 0;
        font-size: 24px;
        color: #8b5cf6;
    }
    
    .summary-item p {
        margin: 0;
        font-size: 12px;
        color: #666;
        text-transform: uppercase;
        font-weight: 600;
    }
</style>

<script>
    function openMessageModal(studentId, dormId, tenantName) {
        document.getElementById('messageStudentId').value = studentId;
        document.getElementById('messageDormId').value = dormId;
        document.getElementById('messageTenantName').textContent = tenantName;
        document.getElementById('messageModal').style.display = 'flex';
    }
    
    function openPaymentModal(bookingId, studentId, tenantName) {
        document.getElementById('paymentBookingId').value = bookingId;
        document.getElementById('paymentStudentId').value = studentId;
        document.getElementById('paymentTenantName').textContent = tenantName;
        document.getElementById('paymentModal').style.display = 'flex';
    }
    
    function closeModal(modalId) {
        document.getElementById(modalId).style.display = 'none';
    }
    
    function openPaymentHistoryModal(tenantId, tenantName) {
        document.getElementById('historyTenantName').textContent = tenantName;
        document.getElementById('paymentHistoryModal').style.display = 'flex';
        
        // Show loading state
        document.getElementById('paymentHistoryContent').innerHTML = `
            <div style="text-align: center; padding: 40px;">
                <div class="spinner"></div>
                <p>Loading payment history...</p>
            </div>
        `;
        
        // Fetch payment history via AJAX
        fetch(`?ajax=payment_history&tenant_id=${tenantId}`)
            .then(response => {
                if (!response.ok) {
                    throw new Error('Network response was not ok');
                }
                return response.json();
            })
            .then(data => {
                // Check if error response
                if (data.error) {
                    throw new Error(data.error);
                }
                displayPaymentHistory(data);
            })
            .catch(error => {
                console.error('Error fetching payment history:', error);
                document.getElementById('paymentHistoryContent').innerHTML = `
                    <div class="no-payments">
                        <i class="fa fa-exclamation-triangle"></i>
                        <h3>Error Loading Payment History</h3>
                        <p>${error.message || 'Unable to fetch payment history. Please try again.'}</p>
                    </div>
                `;
            });
    }
    
    function displayPaymentHistory(payments) {
        // Check for error or empty array
        if (!payments || payments.length === 0) {
            document.getElementById('paymentHistoryContent').innerHTML = `
                <div class="no-payments">
                    <i class="fa fa-receipt"></i>
                    <h3>No Payment History</h3>
                    <p>This tenant hasn't made any payments yet.</p>
                </div>
            `;
            return;
        }
        
        // Calculate summary
        const totalPaid = payments.filter(p => p.status === 'paid').reduce((sum, p) => sum + parseFloat(p.amount), 0);
        const totalPending = payments.filter(p => p.status === 'pending').reduce((sum, p) => sum + parseFloat(p.amount), 0);
        const totalPayments = payments.length;
        
        let html = `
            <div class="payment-summary">
                <div class="summary-item">
                    <h3>₱${totalPaid.toLocaleString('en-PH', {minimumFractionDigits: 2, maximumFractionDigits: 2})}</h3>
                    <p>Total Paid</p>
                </div>
                <div class="summary-item">
                    <h3>₱${totalPending.toLocaleString('en-PH', {minimumFractionDigits: 2, maximumFractionDigits: 2})}</h3>
                    <p>Pending</p>
                </div>
                <div class="summary-item">
                    <h3>${totalPayments}</h3>
                    <p>Total Payments</p>
                </div>
            </div>
            
            <table class="payment-history-table">
                <thead>
                    <tr>
                        <th>Date</th>
                        <th>Amount</th>
                        <th>Due Date</th>
                        <th>Status</th>
                        <th>Method</th>
                        <th>Reference</th>
                    </tr>
                </thead>
                <tbody>
        `;
        
        payments.forEach(payment => {
            const paymentDate = payment.payment_date ? formatDate(payment.payment_date) : 'Not paid';
            const dueDate = formatDate(payment.due_date);
            const amount = parseFloat(payment.amount).toLocaleString('en-PH', {minimumFractionDigits: 2, maximumFractionDigits: 2});
            const status = payment.status || 'pending';
            const method = payment.payment_method || '-';
            const reference = payment.reference_number || '-';
            
            html += `
                <tr>
                    <td>${paymentDate}</td>
                    <td style="font-weight: 600;">₱${amount}</td>
                    <td>${dueDate}</td>
                    <td><span class="status-badge ${status}">${status.toUpperCase()}</span></td>
                    <td>${method}</td>
                    <td style="font-family: monospace; font-size: 12px;">${reference}</td>
                </tr>
            `;
        });
        
        html += `
                </tbody>
            </table>
        `;
        
        document.getElementById('paymentHistoryContent').innerHTML = html;
    }
    
    function formatDate(dateString) {
        const date = new Date(dateString);
        const options = { year: 'numeric', month: 'short', day: 'numeric' };
        return date.toLocaleDateString('en-US', options);
    }
    
    // Close modal when clicking outside
    window.onclick = function(event) {
        if (event.target.classList.contains('modal')) {
            event.target.style.display = 'none';
        }
    }
</script>

<?php include __DIR__ . '/../../partials/footer.php'; ?>
