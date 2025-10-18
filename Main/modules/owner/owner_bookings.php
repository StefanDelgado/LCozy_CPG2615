<?php
require_once __DIR__ . '/../../auth/auth.php';
require_role('owner');
require_once __DIR__ . '/../../config.php';

// ---- DEBUG MODE ----
if (isset($pdo) && $pdo instanceof PDO) {
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
}
define('APP_DEBUG', true);
if (APP_DEBUG) {
    ini_set('display_errors', '1');
    ini_set('display_startup_errors', '1');
    error_reporting(E_ALL);
}

$page_title = "Bookings";
include __DIR__ . '/../../partials/header.php';

$owner_id = $_SESSION['user']['user_id'] ?? 0;

// ─── Handle Approve/Reject ───
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['booking_id'])) {
    $booking_id = (int)$_POST['booking_id'];
    
    // Validate action and set status
    if (isset($_POST['approve_booking'])) {
        $new_status = 'approved';
    } elseif (isset($_POST['reject_booking'])) {
        $new_status = 'rejected';
    } else {
        $_SESSION['flash'] = ['type' => 'error', 'msg' => 'Invalid action specified'];
        header('Location: owner_bookings.php');
        exit;
    }

    // Replace the check_stmt query with this updated version
    $check_stmt = $pdo->prepare("
        SELECT 
            b.booking_id,
            b.status,
            b.room_id,
            b.student_id,
            b.start_date,
            r.price,
            d.owner_id
        FROM bookings b
        JOIN rooms r ON b.room_id = r.room_id
        JOIN dormitories d ON r.dorm_id = d.dorm_id
        WHERE b.booking_id = ? 
        AND d.owner_id = ?
        AND b.status = 'pending'
        LIMIT 1
    ");

    // Add debug logging to track the update
    try {
        $pdo->beginTransaction();

        // Check booking exists and is valid
        $check_stmt->execute([$booking_id, $owner_id]);
        $booking = $check_stmt->fetch(PDO::FETCH_ASSOC);

        if (!$booking) {
            throw new Exception('Booking not found or already processed');
        }

        // Debug log before update
        error_log("Attempting update - Booking ID: {$booking_id}, New Status: {$new_status}, Room ID: {$booking['room_id']}");

        // First, fix the update query to ensure proper status setting
        $update = $pdo->prepare("
            UPDATE bookings 
            SET status = ?
            WHERE booking_id = ? 
            AND (status = 'pending' OR status IS NULL OR status = '')
        ");

        // Execute update with just status and booking_id
        $update->execute([
            $new_status,
            $booking_id
        ]);

        $affected = $update->rowCount();
        error_log("Update affected rows: {$affected}");

        if ($affected === 0) {
            throw new Exception('Booking status could not be updated');
        }

        // Handle approved bookings
        if ($new_status === 'approved') {
            // Check for existing payment
            $check = $pdo->prepare("SELECT COUNT(*) FROM payments WHERE booking_id = ?");
            $check->execute([$booking_id]);
            
            if ($check->fetchColumn() == 0) {
                // Create payment record
                $insert = $pdo->prepare("
                    INSERT INTO payments (
                        booking_id, 
                        student_id, 
                        amount, 
                        status, 
                        due_date, 
                        created_at
                    ) VALUES (?, ?, ?, 'pending', ?, NOW())
                ");
                $insert->execute([
                    $booking_id,
                    $booking['student_id'],
                    $booking['price'],
                    $booking['start_date'] ?? date('Y-m-d', strtotime('+7 days'))
                ]);
            }

            $_SESSION['flash'] = ['type' => 'success', 'msg' => 'Booking approved and payment reminder created.'];
        } else {
            $_SESSION['flash'] = ['type' => 'success', 'msg' => 'Booking rejected successfully.'];
        }

        $pdo->commit();

    } catch (Exception $e) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        error_log('owner_bookings error: ' . $e->getMessage());
        $_SESSION['flash'] = [
            'type' => 'error', 
            'msg' => APP_DEBUG ? 'Internal error: ' . $e->getMessage() : 'An error occurred.'
        ];
    }

    header('Location: owner_bookings.php');
    exit;
}

// ─── Fetch All Bookings for Owner ───
$sql = "
    SELECT 
        b.booking_id,
        COALESCE(NULLIF(LOWER(TRIM(b.status)), ''), 'pending') AS status,
        b.booking_type,
        b.start_date,
        b.end_date,
        u.user_id AS student_id,
        u.name AS student_name,
        u.email,
        u.phone,
        r.room_type,
        r.price,
        r.capacity,
        d.name AS dorm_name,
        d.dorm_id
    FROM bookings b
    JOIN users u ON b.student_id = u.user_id
    JOIN rooms r ON b.room_id = r.room_id
    JOIN dormitories d ON r.dorm_id = d.dorm_id
    WHERE d.owner_id = ?
    ORDER BY FIELD(COALESCE(b.status, 'pending'),'pending','approved','rejected','cancelled','completed'), 
             b.start_date DESC
";
$stmt = $pdo->prepare($sql);
$stmt->execute([$owner_id]);
$bookings = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Calculate statistics
$stats = [
    'total' => count($bookings),
    'pending' => 0,
    'approved' => 0,
    'rejected' => 0,
    'active' => 0,
    'completed' => 0
];

foreach ($bookings as $b) {
    $status = strtolower(trim($b['status'] ?? 'pending'));
    if (isset($stats[$status])) {
        $stats[$status]++;
    }
}

$flash = $_SESSION['flash'] ?? null;
unset($_SESSION['flash']);
?>

<div class="page-header">
  <div>
    <h1>Booking Management</h1>
    <p>Review and manage student booking requests for your dormitories</p>
  </div>
</div>

<?php if ($flash): ?>
<div class="alert alert-<?= htmlspecialchars($flash['type']) ?>">
  <?= htmlspecialchars($flash['msg']) ?>
</div>
<?php endif; ?>

<!-- Statistics Cards -->
<div class="stats-grid">
  <div class="stat-card">
    <div class="stat-icon" style="background: #6f42c1;">📊</div>
    <div class="stat-details">
      <h3><?= $stats['total'] ?></h3>
      <p>Total Bookings</p>
    </div>
  </div>
  
  <div class="stat-card">
    <div class="stat-icon" style="background: #ffc107;">⏳</div>
    <div class="stat-details">
      <h3><?= $stats['pending'] ?></h3>
      <p>Pending Review</p>
    </div>
  </div>
  
  <div class="stat-card">
    <div class="stat-icon" style="background: #28a745;">✓</div>
    <div class="stat-details">
      <h3><?= $stats['approved'] ?></h3>
      <p>Approved</p>
    </div>
  </div>
  
  <div class="stat-card">
    <div class="stat-icon" style="background: #17a2b8;">🏠</div>
    <div class="stat-details">
      <h3><?= $stats['active'] ?></h3>
      <p>Active</p>
    </div>
  </div>
</div>

<!-- Status Legend -->
<div class="status-legend">
  <strong>Status:</strong>
  <span class="status-badge pending">Pending</span>
  <span class="status-badge approved">Approved</span>
  <span class="status-badge rejected">Rejected</span>
  <span class="status-badge cancelled">Cancelled</span>
  <span class="status-badge completed">Completed</span>
</div>

<!-- Bookings List -->
<div class="bookings-container">
  <?php if (empty($bookings)): ?>
    <div class="empty-state">
      <div class="empty-icon">📭</div>
      <h3>No Bookings Yet</h3>
      <p>When students book your dormitories, they will appear here for your review.</p>
    </div>
  <?php else: ?>
    <?php foreach ($bookings as $b): 
      $status = strtolower(trim($b['status'] ?? 'pending'));
      if ($status === '' || $status === null) $status = 'pending';
      $booking_type = strtolower($b['booking_type'] ?? 'shared');
    ?>
    
    <div class="booking-card <?= $status ?>">
      <!-- Card Header -->
      <div class="booking-header">
        <div class="student-info">
          <div class="student-avatar">
            <?= strtoupper(substr($b['student_name'], 0, 2)) ?>
          </div>
          <div class="student-details">
            <h3><?= htmlspecialchars($b['student_name']) ?></h3>
            <p>📧 <?= htmlspecialchars($b['email']) ?></p>
            <p>📱 <?= htmlspecialchars($b['phone'] ?? 'N/A') ?></p>
          </div>
        </div>
        <div class="booking-status">
          <span class="status-badge <?= $status ?>"><?= ucfirst($status) ?></span>
        </div>
      </div>
      
      <!-- Card Body -->
      <div class="booking-body">
        <!-- Dorm & Room Info -->
        <div class="info-section">
          <div class="info-row">
            <span class="info-label">🏢 Dormitory:</span>
            <span class="info-value"><strong><?= htmlspecialchars($b['dorm_name']) ?></strong></span>
          </div>
          <div class="info-row">
            <span class="info-label">🚪 Room Type:</span>
            <span class="info-value"><?= htmlspecialchars($b['room_type']) ?></span>
          </div>
          <div class="info-row">
            <span class="info-label">🏷️ Booking Type:</span>
            <span class="booking-type-badge <?= $booking_type ?>">
              <?php if ($booking_type === 'whole'): ?>
                🏠 Whole Room
              <?php else: ?>
                👥 Shared Room
              <?php endif; ?>
            </span>
          </div>
          <div class="info-row">
            <span class="info-label">👥 Capacity:</span>
            <span class="info-value"><?= htmlspecialchars($b['capacity']) ?> person(s)</span>
          </div>
          <div class="info-row">
            <span class="info-label">💰 Price:</span>
            <span class="info-value price">₱<?= number_format($b['price'], 2) ?>/month</span>
          </div>
        </div>
        
        <!-- Booking Period -->
        <div class="booking-period">
          <div class="period-item">
            <span class="period-label">Check-in</span>
            <span class="period-date"><?= $b['start_date'] ? date('M d, Y', strtotime($b['start_date'])) : '—' ?></span>
          </div>
          <div class="period-arrow">→</div>
          <div class="period-item">
            <span class="period-label">Check-out</span>
            <span class="period-date"><?= $b['end_date'] ? date('M d, Y', strtotime($b['end_date'])) : 'Ongoing' ?></span>
          </div>
        </div>
      </div>
      
      <!-- Card Footer / Actions -->
      <div class="booking-actions">
        <?php if ($status === 'pending'): ?>
          <form method="post" style="display: inline;">
            <input type="hidden" name="booking_id" value="<?= $b['booking_id'] ?>">
            <button type="submit" name="approve_booking" value="1" class="btn btn-approve">
              <span>✓</span> Approve
            </button>
          </form>
          <form method="post" style="display: inline;">
            <input type="hidden" name="booking_id" value="<?= $b['booking_id'] ?>">
            <button type="submit" name="reject_booking" value="1" class="btn btn-reject">
              <span>✗</span> Reject
            </button>
          </form>
        <?php else: ?>
          <a href="owner_messages.php?recipient_id=<?= $b['student_id'] ?>" class="btn btn-contact">
            <span>💬</span> Contact Student
          </a>
        <?php endif; ?>
        
        <a href="owner_dorms.php?dorm_id=<?= $b['dorm_id'] ?>" class="btn btn-view">
          <span>🏠</span> View Dorm
        </a>
      </div>
    </div>
    
    <?php endforeach; ?>
  <?php endif; ?>
</div>

<style>
/* ===== Page Layout ===== */
.page-header {
  margin-bottom: 30px;
}

.page-header h1 {
  margin: 0 0 8px 0;
  font-size: 2rem;
  color: #2c3e50;
}

.page-header p {
  margin: 0;
  color: #6c757d;
  font-size: 1rem;
}

/* ===== Alert Messages ===== */
.alert {
  padding: 15px 20px;
  border-radius: 8px;
  margin-bottom: 20px;
  font-weight: 500;
  display: flex;
  align-items: center;
  gap: 10px;
}

.alert-success {
  background: #d4edda;
  color: #155724;
  border-left: 4px solid #28a745;
}

.alert-error {
  background: #f8d7da;
  color: #721c24;
  border-left: 4px solid #dc3545;
}

.alert::before {
  font-size: 1.2rem;
}

.alert-success::before {
  content: "✓";
}

.alert-error::before {
  content: "⚠";
}

/* ===== Statistics Grid ===== */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.stat-card {
  background: white;
  padding: 20px;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
  display: flex;
  align-items: center;
  gap: 15px;
  transition: transform 0.2s, box-shadow 0.2s;
}

.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0,0,0,0.12);
}

.stat-icon {
  width: 50px;
  height: 50px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.5rem;
  flex-shrink: 0;
}

.stat-details h3 {
  margin: 0;
  font-size: 1.8rem;
  color: #2c3e50;
}

.stat-details p {
  margin: 4px 0 0 0;
  color: #6c757d;
  font-size: 0.9rem;
}

/* ===== Status Legend ===== */
.status-legend {
  background: white;
  padding: 15px 20px;
  border-radius: 12px;
  margin-bottom: 25px;
  display: flex;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
}

.status-legend strong {
  color: #2c3e50;
  margin-right: 5px;
}

/* ===== Status Badges ===== */
.status-badge {
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 600;
  text-transform: capitalize;
  display: inline-block;
}

.status-badge.pending {
  background: #fff3cd;
  color: #856404;
  border: 1px solid #ffeaa7;
}

.status-badge.approved {
  background: #d4edda;
  color: #155724;
  border: 1px solid #c3e6cb;
}

.status-badge.active {
  background: #d1ecf1;
  color: #0c5460;
  border: 1px solid #bee5eb;
}

.status-badge.rejected {
  background: #f8d7da;
  color: #721c24;
  border: 1px solid #f5c6cb;
}

.status-badge.cancelled {
  background: #e2e3e5;
  color: #383d41;
  border: 1px solid #d6d8db;
}

.status-badge.completed {
  background: #d1ecf1;
  color: #0c5460;
  border: 1px solid #bee5eb;
}

/* ===== Booking Type Badge ===== */
.booking-type-badge {
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 600;
  display: inline-block;
}

.booking-type-badge.whole {
  background: #e7f3ff;
  color: #0066cc;
  border: 1px solid #b3d9ff;
}

.booking-type-badge.shared {
  background: #f3e7ff;
  color: #6f42c1;
  border: 1px solid #d7b3ff;
}

/* ===== Bookings Container ===== */
.bookings-container {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

/* ===== Booking Card ===== */
.booking-card {
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
  overflow: hidden;
  transition: transform 0.2s, box-shadow 0.2s;
  border-left: 4px solid #6c757d;
}

.booking-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 16px rgba(0,0,0,0.12);
}

.booking-card.pending {
  border-left-color: #ffc107;
}

.booking-card.approved {
  border-left-color: #28a745;
}

.booking-card.active {
  border-left-color: #17a2b8;
}

.booking-card.rejected {
  border-left-color: #dc3545;
}

.booking-card.cancelled {
  border-left-color: #6c757d;
}

.booking-card.completed {
  border-left-color: #17a2b8;
}

/* ===== Card Header ===== */
.booking-header {
  padding: 20px;
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 20px;
  flex-wrap: wrap;
}

.student-info {
  display: flex;
  align-items: center;
  gap: 15px;
  flex: 1;
}

.student-avatar {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  background: linear-gradient(135deg, #6f42c1, #a06cd5);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.3rem;
  font-weight: bold;
  flex-shrink: 0;
  box-shadow: 0 3px 10px rgba(111, 66, 193, 0.3);
}

.student-details h3 {
  margin: 0 0 6px 0;
  font-size: 1.3rem;
  color: #2c3e50;
}

.student-details p {
  margin: 3px 0;
  font-size: 0.9rem;
  color: #6c757d;
}

.booking-status {
  flex-shrink: 0;
}

/* ===== Card Body ===== */
.booking-body {
  padding: 20px;
}

.info-section {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 12px;
  margin-bottom: 20px;
}

.info-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 0;
}

.info-label {
  color: #6c757d;
  font-size: 0.9rem;
  font-weight: 500;
}

.info-value {
  color: #2c3e50;
  font-weight: 600;
  text-align: right;
}

.info-value.price {
  color: #28a745;
  font-size: 1.1rem;
}

/* ===== Booking Period ===== */
.booking-period {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 20px;
  padding: 15px;
  background: #f8f9fa;
  border-radius: 8px;
  margin-top: 15px;
}

.period-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 5px;
}

.period-label {
  font-size: 0.8rem;
  color: #6c757d;
  text-transform: uppercase;
  font-weight: 600;
  letter-spacing: 0.5px;
}

.period-date {
  font-size: 1rem;
  color: #2c3e50;
  font-weight: 600;
}

.period-arrow {
  font-size: 1.5rem;
  color: #6f42c1;
  font-weight: bold;
}

/* ===== Card Footer / Actions ===== */
.booking-actions {
  padding: 15px 20px;
  background: #f8f9fa;
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
  border-top: 1px solid #e9ecef;
}

.btn {
  padding: 10px 20px;
  border: none;
  border-radius: 8px;
  font-size: 0.9rem;
  font-weight: 600;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  gap: 8px;
  transition: all 0.2s;
  text-decoration: none;
}

.btn span {
  font-size: 1.1rem;
}

.btn-approve {
  background: #28a745;
  color: white;
}

.btn-approve:hover {
  background: #218838;
  transform: translateY(-1px);
  box-shadow: 0 3px 8px rgba(40, 167, 69, 0.3);
}

.btn-reject {
  background: #dc3545;
  color: white;
}

.btn-reject:hover {
  background: #c82333;
  transform: translateY(-1px);
  box-shadow: 0 3px 8px rgba(220, 53, 69, 0.3);
}

.btn-contact {
  background: #6f42c1;
  color: white;
}

.btn-contact:hover {
  background: #5a32a3;
  transform: translateY(-1px);
  box-shadow: 0 3px 8px rgba(111, 66, 193, 0.3);
}

.btn-view {
  background: #17a2b8;
  color: white;
}

.btn-view:hover {
  background: #138496;
  transform: translateY(-1px);
  box-shadow: 0 3px 8px rgba(23, 162, 184, 0.3);
}

/* ===== Empty State ===== */
.empty-state {
  text-align: center;
  padding: 60px 20px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
}

.empty-icon {
  font-size: 4rem;
  margin-bottom: 20px;
}

.empty-state h3 {
  margin: 0 0 10px 0;
  color: #2c3e50;
  font-size: 1.5rem;
}

.empty-state p {
  margin: 0;
  color: #6c757d;
  font-size: 1rem;
}

/* ===== Responsive Design ===== */
@media (max-width: 768px) {
  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .booking-header {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .student-info {
    width: 100%;
  }
  
  .info-section {
    grid-template-columns: 1fr;
  }
  
  .booking-period {
    flex-direction: column;
    gap: 10px;
  }
  
  .period-arrow {
    transform: rotate(90deg);
  }
  
  .booking-actions {
    flex-direction: column;
  }
  
  .btn {
    width: 100%;
    justify-content: center;
  }
}

@media (max-width: 480px) {
  .stats-grid {
    grid-template-columns: 1fr;
  }
  
  .page-header h1 {
    font-size: 1.5rem;
  }
  
  .student-avatar {
    width: 50px;
    height: 50px;
    font-size: 1.1rem;
  }
  
  .student-details h3 {
    font-size: 1.1rem;
  }
}
</style>

<?php require_once __DIR__ . '/../../partials/footer.php'; ?>
