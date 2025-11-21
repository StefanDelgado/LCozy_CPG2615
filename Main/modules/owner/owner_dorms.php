<?php
require_once __DIR__ . '/../../auth/auth.php';
require_role('owner');
require_once __DIR__ . '/../../config.php';

include __DIR__ . '/../../partials/header.php';

$owner_id = $_SESSION['user']['user_id'];
$flash = null;

// ─── Add Dormitory ───
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['add_dorm'])) {
    $name = trim($_POST['name']);
    $address = trim($_POST['address']);
    $description = trim($_POST['description']);
    $features = trim($_POST['features']);
    $deposit_required = isset($_POST['deposit_required']) ? 1 : 0;
    $deposit_months = $deposit_required ? (int)$_POST['deposit_months'] : 0;
    $cover_image = null;

    if (!empty($_FILES['cover_image']['name'])) {
        $upload_dir = __DIR__ . '/../uploads/';
        if (!file_exists($upload_dir)) mkdir($upload_dir, 0777, true);

        $ext = strtolower(pathinfo($_FILES['cover_image']['name'], PATHINFO_EXTENSION));
        $allowed = ['jpg', 'jpeg', 'png'];
        if (in_array($ext, $allowed)) {
            $cover_image = uniqid('dorm_') . '.' . $ext;
            move_uploaded_file($_FILES['cover_image']['tmp_name'], $upload_dir . $cover_image);
        }
    }

    $stmt = $pdo->prepare("INSERT INTO dormitories (owner_id, name, address, description, features, cover_image, deposit_required, deposit_months, verified, created_at)
                           VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0, NOW())");
    $stmt->execute([$owner_id, $name, $address, $description, $features, $cover_image, $deposit_required, $deposit_months]);
    $_SESSION['flash'] = ['type' => 'success', 'msg' => 'Dorm added successfully! Pending admin verification.'];
    header("Location: " . $_SERVER['PHP_SELF']);
    exit();
}

// ─── Edit Dormitory ───
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['edit_dorm'])) {
    $dorm_id = (int)$_POST['dorm_id'];
    $name = trim($_POST['name']);
    $address = trim($_POST['address']);
    $description = trim($_POST['description']);
    $features = trim($_POST['features']);
    $deposit_required = isset($_POST['deposit_required']) ? 1 : 0;
    $deposit_months = $deposit_required ? (int)$_POST['deposit_months'] : 0;
    
    // Check if owner owns this dorm
    $check = $pdo->prepare("SELECT dorm_id FROM dormitories WHERE dorm_id = ? AND owner_id = ?");
    $check->execute([$dorm_id, $owner_id]);
    
    if ($check->fetch()) {
        $cover_image = null;
        
        // Handle new image upload
        if (!empty($_FILES['cover_image']['name'])) {
            $upload_dir = __DIR__ . '/../uploads/';
            if (!file_exists($upload_dir)) mkdir($upload_dir, 0777, true);

            $ext = strtolower(pathinfo($_FILES['cover_image']['name'], PATHINFO_EXTENSION));
            $allowed = ['jpg', 'jpeg', 'png'];
            if (in_array($ext, $allowed)) {
                $cover_image = uniqid('dorm_') . '.' . $ext;
                move_uploaded_file($_FILES['cover_image']['tmp_name'], $upload_dir . $cover_image);
                
                // Update with new image
                $stmt = $pdo->prepare("UPDATE dormitories SET name=?, address=?, description=?, features=?, cover_image=?, deposit_required=?, deposit_months=? WHERE dorm_id=? AND owner_id=?");
                $stmt->execute([$name, $address, $description, $features, $cover_image, $deposit_required, $deposit_months, $dorm_id, $owner_id]);
            }
        } else {
            // Update without changing image
            $stmt = $pdo->prepare("UPDATE dormitories SET name=?, address=?, description=?, features=?, deposit_required=?, deposit_months=? WHERE dorm_id=? AND owner_id=?");
            $stmt->execute([$name, $address, $description, $features, $deposit_required, $deposit_months, $dorm_id, $owner_id]);
        }
        
        $_SESSION['flash'] = ['type' => 'success', 'msg' => 'Dorm updated successfully!'];
    } else {
        $_SESSION['flash'] = ['type' => 'error', 'msg' => 'Unauthorized action.'];
    }
    header("Location: " . $_SERVER['PHP_SELF']);
    exit();
}

// ─── Add Room ───
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['add_room'])) {
    $dorm_id = (int)$_POST['dorm_id'];
    $room_type = $_POST['room_type_select'] === 'Custom' ? trim($_POST['room_type']) : $_POST['room_type_select'];
    $capacity = (int)$_POST['capacity'];
    $size = trim($_POST['size']);
    $price = (float)$_POST['price'];
    $status = $_POST['status'];

    $stmt = $pdo->prepare("INSERT INTO rooms (dorm_id, room_type, capacity, size, price, status, created_at)
                           VALUES (?, ?, ?, ?, ?, ?, NOW())");
    $stmt->execute([$dorm_id, $room_type, $capacity, $size, $price, $status]);
    $room_id = $pdo->lastInsertId();

    // multiple images
    if (!empty($_FILES['room_images']['name'][0])) {
        $upload_dir = __DIR__ . '/../uploads/';
        if (!file_exists($upload_dir)) mkdir($upload_dir, 0777, true);
        foreach ($_FILES['room_images']['tmp_name'] as $i => $tmp) {
            $ext = strtolower(pathinfo($_FILES['room_images']['name'][$i], PATHINFO_EXTENSION));
            if (in_array($ext, ['jpg','jpeg','png'])) {
                $filename = uniqid('room_') . '.' . $ext;
                move_uploaded_file($tmp, $upload_dir . $filename);
                $pdo->prepare("INSERT INTO room_images (room_id, image_path, uploaded_at) VALUES (?, ?, NOW())")
                    ->execute([$room_id, $filename]);
            }
        }
    }

    $_SESSION['flash'] = ['type'=>'success','msg'=>'Room added successfully!'];
    header("Location: " . $_SERVER['PHP_SELF']);
    exit();
}

// Check for flash message from session
if (isset($_SESSION['flash'])) {
    $flash = $_SESSION['flash'];
    unset($_SESSION['flash']);
}

// ─── Fetch Dorms ───
$stmt = $pdo->prepare("
    SELECT d.dorm_id, d.name, d.address, d.description, d.verified, d.cover_image, d.features, d.deposit_required, d.deposit_months,
      (SELECT ROUND(AVG(r.rating),1) FROM reviews r WHERE r.dorm_id = d.dorm_id AND r.status = 'approved') as avg_rating,
      (SELECT COUNT(*) FROM reviews r WHERE r.dorm_id = d.dorm_id AND r.status = 'approved') as total_reviews
    FROM dormitories d
    WHERE d.owner_id = ?
    ORDER BY d.created_at DESC
");
$stmt->execute([$owner_id]);
$dorms = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

<div class="page-header">
  <div>
    <h1>My Dormitories</h1>
    <p>Manage your dorm listings and rooms here.</p>
  </div>
  <button class="btn" onclick="openModal('addDormModal')">+ Add Dormitory</button>
</div>

<?php if ($flash): ?>
<div class="alert <?= $flash['type'] ?>"><?= htmlspecialchars($flash['msg']) ?></div>
<?php endif; ?>

<?php if ($dorms): ?>
  <?php foreach ($dorms as $dorm): ?>
  <div class="dorm-card">
    <!-- Header Section -->
    <div class="dorm-header">
      <div class="dorm-info">
        <div class="dorm-title-row">
          <h2><?= htmlspecialchars($dorm['name']) ?></h2>
          <div class="dorm-actions">
            <button class="btn-edit-dorm" 
                    data-dorm-id="<?= $dorm['dorm_id'] ?>"
                    data-dorm-name="<?= htmlspecialchars($dorm['name']) ?>"
                    data-dorm-address="<?= htmlspecialchars($dorm['address']) ?>"
                    data-dorm-description="<?= htmlspecialchars($dorm['description']) ?>"
                    data-dorm-features="<?= htmlspecialchars($dorm['features']) ?>"
                    data-deposit-required="<?= $dorm['deposit_required'] ?>"
                    data-deposit-months="<?= $dorm['deposit_months'] ?>"
                    onclick="openEditDormModal(this)">
              ✏️ Edit
            </button>
            <a href="/modules/admin/room_management.php?dorm_id=<?= $dorm['dorm_id'] ?>" class="btn-manage-rooms">
              🏠 Manage Rooms
            </a>
          </div>
        </div>
        <p class="dorm-address">📍 <?= htmlspecialchars($dorm['address']) ?></p>
        <div class="dorm-status">
          <?php if ($dorm['verified'] == 1): ?>
            <span class="status-badge approved">✓ Approved</span>
          <?php elseif ($dorm['verified'] == -1): ?>
            <span class="status-badge rejected">✗ Rejected</span>
          <?php else: ?>
            <span class="status-badge pending">⏳ Pending Verification</span>
          <?php endif; ?>
        </div>
      </div>
      
      <?php if (!empty($dorm['cover_image'])): ?>
        <div class="dorm-image">
          <img src="../uploads/<?= htmlspecialchars($dorm['cover_image']) ?>" 
               alt="<?= htmlspecialchars($dorm['name']) ?>">
        </div>
      <?php endif; ?>
    </div>

    <!-- Details Section -->
    <div class="dorm-details">
      <div class="detail-section">
        <h4>Description</h4>
        <p><?= nl2br(htmlspecialchars($dorm['description'])) ?></p>
      </div>

      <!-- Review & Rating Section -->
      <div class="detail-section">
        <h4>Reviews & Ratings</h4>
        <div class="review-rating-row">
          <span style="color: #FFC107; font-size: 1.2em;">★</span>
          <span style="font-weight: bold; font-size: 1.1em;">
            <?= $dorm['avg_rating'] !== null ? $dorm['avg_rating'] : '-' ?>
          </span>
          <span style="color: #888; margin-left: 8px;">
            (<?= $dorm['total_reviews'] ?> reviews)
          </span>
          <a href="owner_reviews.php?dorm_id=<?= $dorm['dorm_id'] ?>" class="btn btn-sm btn-primary" style="margin-left:16px;">View All Reviews</a>
        </div>
      </div>

      <?php if ($dorm['features']): ?>
      <div class="detail-section">
        <h4>Features & Amenities</h4>
        <div class="features-tags">
          <?php 
          $features = explode(',', $dorm['features']);
          foreach ($features as $feature): 
            $feature = trim($feature);
            if ($feature):
          ?>
            <span class="feature-tag"><?= htmlspecialchars($feature) ?></span>
          <?php 
            endif;
          endforeach; 
          ?>
        </div>
      </div>
      <?php endif; ?>
      
      <div class="detail-section">
        <h4>Deposit/Advance Payment Policy</h4>
        <?php if ($dorm['deposit_required']): ?>
          <div style="background: #f8f9fa; padding: 12px; border-radius: 8px; border-left: 4px solid #6f42c1;">
            <p style="margin: 0; color: #495057;">
              <strong style="color: #6f42c1;">✓ Deposit Required:</strong> 
              <?= $dorm['deposit_months'] ?> month(s) advance payment
            </p>
            <p style="margin: 8px 0 0 0; color: #6c757d; font-size: 0.9rem;">
              <em>Example: If room rent is ₱1,000/month, deposit will be ₱<?= number_format($dorm['deposit_months'] * 1000) ?></em>
            </p>
          </div>
        <?php else: ?>
          <p style="color: #28a745; margin: 0;">
            <strong>✓ No Deposit Required</strong> - Students can book without advance payment
          </p>
        <?php endif; ?>
      </div>
    </div>

    <!-- Rooms Section -->
    <div class="rooms-section">
      <div class="section-header">
        <h3>Rooms</h3>
      </div>
      
      <?php
      $room_stmt = $pdo->prepare("
        SELECT r.*, 
               (SELECT COUNT(*) FROM bookings b WHERE b.room_id = r.room_id AND b.status IN ('approved','active')) AS occupants
        FROM rooms r 
        WHERE r.dorm_id = ?
        ORDER BY r.room_type, r.capacity
      ");
      $room_stmt->execute([$dorm['dorm_id']]);
      $rooms = $room_stmt->fetchAll(PDO::FETCH_ASSOC);
      ?>
      
      <?php if ($rooms): ?>
        <div class="rooms-grid">
          <?php foreach ($rooms as $r): ?>
            <?php
              $img_stmt = $pdo->prepare("SELECT image_path FROM room_images WHERE room_id=? LIMIT 1");
              $img_stmt->execute([$r['room_id']]);
              $room_img = $img_stmt->fetchColumn();
              $is_full = $r['occupants'] >= $r['capacity'];
            ?>
            
            <div class="room-card <?= $is_full ? 'room-full' : '' ?>">
              <div class="room-image">
                <?php if ($room_img): ?>
                  <img src="../../uploads/rooms/<?= htmlspecialchars($room_img) ?>" alt="Room">
                <?php else: ?>
                  <div class="no-image">No Image</div>
                <?php endif; ?>
                
                <div class="room-status-overlay">
                  <?php if ($is_full): ?>
                    <span class="status-tag full">Full</span>
                  <?php elseif ($r['status']==='vacant'): ?>
                    <span class="status-tag vacant">Vacant</span>
                  <?php else: ?>
                    <span class="status-tag occupied">Occupied</span>
                  <?php endif; ?>
                </div>
              </div>
              
              <div class="room-info">
                <h4><?= htmlspecialchars($r['room_type']) ?></h4>
                <div class="room-details-grid">
                  <div class="detail-item">
                    <span class="label">Size</span>
                    <span class="value"><?= !empty($r['size']) ? htmlspecialchars($r['size']).' m²' : 'N/A' ?></span>
                  </div>
                  <div class="detail-item">
                    <span class="label">Occupancy</span>
                    <span class="value <?= $is_full ? 'full-occupancy' : '' ?>">
                      <?= intval($r['occupants']) ?> / <?= intval($r['capacity']) ?>
                    </span>
                  </div>
                </div>
                <div class="room-price">₱<?= number_format($r['price'], 2) ?><span>/month</span></div>
              </div>
            </div>
          <?php endforeach; ?>
        </div>
      <?php else: ?>
        <div class="no-rooms">
          <p>No rooms have been added yet. Click "Manage Rooms" to add rooms to this dormitory.</p>
        </div>
      <?php endif; ?>
    </div>
  </div>
  <?php endforeach; ?>
<?php else: ?>
  <div class="empty-state">
    <div class="empty-icon">🏠</div>
    <h3>No Dormitories Yet</h3>
    <p>Start by adding your first dormitory to manage rooms and tenants.</p>
    <button class="btn" onclick="openModal('addDormModal')">+ Add Your First Dormitory</button>
  </div>
<?php endif; ?>

<!-- ADD DORM MODAL -->
<div id="addDormModal" class="modal">
  <div class="modal-content">
    <h2>Add New Dormitory</h2>
    <form method="post" enctype="multipart/form-data" class="form-area">
      <div class="form-group">
        <label>Dorm Name</label>
        <input type="text" name="name" required>
      </div>
      <div class="form-group">
        <label>Address</label>
        <input type="text" name="address" required>
      </div>
      <div class="form-group">
        <label>Description</label>
        <textarea name="description" rows="3" required></textarea>
      </div>
      <div class="form-group">
        <label>Features (comma separated)</label>
        <input type="text" name="features" placeholder="Wi-Fi, Study Lounge, CCTV Security, Air-conditioned Rooms, Laundry Area">
      </div>
      <div class="form-group">
        <label>Cover Image</label>
        <input type="file" name="cover_image" accept=".jpg,.jpeg,.png">
      </div>
      <div class="form-group">
        <label style="display: flex; align-items: center; gap: 8px;">
          <input type="checkbox" name="deposit_required" id="add_deposit_required" checked onchange="toggleDepositMonths('add')">
          <span>Require Deposit/Advance Payment</span>
        </label>
      </div>
      <div class="form-group" id="add_deposit_months_group">
        <label>Number of Months Deposit</label>
        <input type="number" name="deposit_months" id="add_deposit_months" min="1" max="12" value="1" required>
        <small style="color: #6c757d; font-size: 0.85rem;">
          Students will pay this many months' rent in advance (e.g., 3 months = ₱3,000 if room is ₱1,000/month)
        </small>
      </div>
      <div class="modal-actions">
        <button type="submit" name="add_dorm" class="btn">Add Dormitory</button>
        <button type="button" class="btn-secondary" onclick="closeModal('addDormModal')">Cancel</button>
      </div>
    </form>
  </div>
</div>

<!-- EDIT DORM MODAL -->
<div id="editDormModal" class="modal">
  <div class="modal-content">
    <h2>Edit Dormitory</h2>
    <form method="post" enctype="multipart/form-data" class="form-area">
      <input type="hidden" name="dorm_id" id="edit_dorm_id">
      
      <div class="form-group">
        <label>Dorm Name</label>
        <input type="text" name="name" id="edit_dorm_name" required>
      </div>
      <div class="form-group">
        <label>Address</label>
        <input type="text" name="address" id="edit_dorm_address" required>
      </div>
      <div class="form-group">
        <label>Description</label>
        <textarea name="description" id="edit_dorm_description" rows="3" required></textarea>
      </div>
      <div class="form-group">
        <label>Features (comma separated)</label>
        <input type="text" name="features" id="edit_dorm_features" placeholder="Wi-Fi, Study Lounge, CCTV Security, Air-conditioned Rooms, Laundry Area">
      </div>
      <div class="form-group">
        <label>Cover Image (leave empty to keep current)</label>
        <input type="file" name="cover_image" accept=".jpg,.jpeg,.png">
      </div>
      <div class="form-group">
        <label style="display: flex; align-items: center; gap: 8px;">
          <input type="checkbox" name="deposit_required" id="edit_deposit_required" onchange="toggleDepositMonths('edit')">
          <span>Require Deposit/Advance Payment</span>
        </label>
      </div>
      <div class="form-group" id="edit_deposit_months_group">
        <label>Number of Months Deposit</label>
        <input type="number" name="deposit_months" id="edit_deposit_months" min="1" max="12" value="1" required>
        <small style="color: #6c757d; font-size: 0.85rem;">
          Students will pay this many months' rent in advance (e.g., 3 months = ₱3,000 if room is ₱1,000/month)
        </small>
      </div>
      <div class="modal-actions">
        <button type="submit" name="edit_dorm" class="btn">Update Dormitory</button>
        <button type="button" class="btn-secondary" onclick="closeModal('editDormModal')">Cancel</button>
      </div>
    </form>
  </div>
</div>

<script>
function openModal(id) {
  document.getElementById(id).style.display = 'flex';
}

function closeModal(id) {
  document.getElementById(id).style.display = 'none';
}

function openEditDormModal(button) {
  console.log('openEditDormModal called');
  
  const modal = document.getElementById('editDormModal');
  if (!modal) {
    console.error('Edit dorm modal not found');
    alert('Error: Modal not found. Please refresh the page.');
    return;
  }
  
  // Get data from button attributes
  const dormId = button.getAttribute('data-dorm-id');
  const name = button.getAttribute('data-dorm-name');
  const address = button.getAttribute('data-dorm-address');
  const description = button.getAttribute('data-dorm-description');
  const features = button.getAttribute('data-dorm-features');
  const depositRequired = button.getAttribute('data-deposit-required');
  const depositMonths = button.getAttribute('data-deposit-months');
  
  console.log('Edit dorm data:', { dormId, name, address, depositRequired, depositMonths });
  
  // Populate form fields
  const fields = {
    'edit_dorm_id': dormId,
    'edit_dorm_name': name,
    'edit_dorm_address': address,
    'edit_dorm_description': description,
    'edit_dorm_features': features
  };
  
  for (const [fieldId, value] of Object.entries(fields)) {
    const field = document.getElementById(fieldId);
    if (field) {
      field.value = value || '';
    } else {
      console.error(`Field not found: ${fieldId}`);
    }
  }
  
  // Set deposit fields
  const depositCheckbox = document.getElementById('edit_deposit_required');
  const depositMonthsInput = document.getElementById('edit_deposit_months');
  if (depositCheckbox) {
    depositCheckbox.checked = depositRequired === '1';
  }
  if (depositMonthsInput) {
    depositMonthsInput.value = depositMonths || 1;
  }
  toggleDepositMonths('edit');
  
  // Show modal
  modal.style.display = 'flex';
  console.log('Edit modal opened');
}

function toggleCustomRoomType(select, id) {
  const custom = document.getElementById(id);
  if (custom) {
    custom.style.display = select.value === 'Custom' ? 'block' : 'none';
  }
}

function toggleDepositMonths(mode) {
  const checkbox = document.getElementById(mode + '_deposit_required');
  const monthsGroup = document.getElementById(mode + '_deposit_months_group');
  const monthsInput = document.getElementById(mode + '_deposit_months');
  
  if (checkbox.checked) {
    monthsGroup.style.display = 'block';
    monthsInput.required = true;
  } else {
    monthsGroup.style.display = 'none';
    monthsInput.required = false;
  }
}

// Close modal when clicking outside
window.onclick = function(event) {
  if (event.target.classList.contains('modal')) {
    event.target.style.display = 'none';
  }
}

// Debug: Log when page loads
document.addEventListener('DOMContentLoaded', function() {
  console.log('Dorm management page loaded');
  console.log('Modals found:', {
    addDorm: !!document.getElementById('addDormModal'),
    editDorm: !!document.getElementById('editDormModal'),
    addRoom: !!document.getElementById('addRoomModal')
  });
});
</script>

<style>
/* ========== Professional Dorm Management Styling ========== */

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 30px;
  padding-bottom: 20px;
  border-bottom: 2px solid #e0e0e0;
}

.page-header h1 {
  font-size: 32px;
  color: #2c3e50;
  margin: 0 0 8px 0;
}

.page-header p {
  color: #7f8c8d;
  margin: 0;
  font-size: 15px;
}

/* Dorm Card */
.dorm-card {
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
  margin-bottom: 30px;
  overflow: hidden;
  border: 1px solid #e8e8e8;
  transition: box-shadow 0.3s ease;
}

.dorm-card:hover {
  box-shadow: 0 4px 16px rgba(0,0,0,0.12);
}

/* Dorm Header */
.dorm-header {
  display: grid;
  grid-template-columns: 1fr auto;
  gap: 25px;
  padding: 25px;
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  border-bottom: 1px solid #dee2e6;
}

.dorm-info h2 {
  font-size: 28px;
  color: #2c3e50;
  margin: 0 0 10px 0;
  font-weight: 600;
}

.dorm-title-row {
  display: flex;
  align-items: center;
  gap: 15px;
  margin-bottom: 10px;
}

.dorm-title-row h2 {
  margin: 0;
  flex: 1;
}

.dorm-actions {
  display: flex;
  gap: 10px;
}

.btn-edit-dorm {
  background: #17a2b8;
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 6px;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  white-space: nowrap;
}

.btn-edit-dorm:hover {
  background: #138496;
  transform: translateY(-1px);
  box-shadow: 0 3px 8px rgba(23, 162, 184, 0.3);
}

.btn-manage-rooms {
  background: #6f42c1;
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 6px;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  white-space: nowrap;
  text-decoration: none;
  display: inline-flex;
  align-items: center;
}

.btn-manage-rooms:hover {
  background: #5a32a3;
  transform: translateY(-1px);
  box-shadow: 0 3px 8px rgba(111, 66, 193, 0.3);
}

.dorm-address {
  color: #6c757d;
  font-size: 15px;
  margin: 0 0 12px 0;
}

.dorm-image {
  width: 200px;
  height: 150px;
  border-radius: 10px;
  overflow: hidden;
  box-shadow: 0 4px 8px rgba(0,0,0,0.1);
}

.dorm-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

/* Status Badges */
.status-badge {
  display: inline-block;
  padding: 6px 14px;
  border-radius: 20px;
  font-size: 13px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.status-badge.approved {
  background: #d4edda;
  color: #155724;
}

.status-badge.rejected {
  background: #f8d7da;
  color: #721c24;
}

.status-badge.pending {
  background: #fff3cd;
  color: #856404;
}

/* Dorm Details */
.dorm-details {
  padding: 25px;
  border-bottom: 1px solid #e8e8e8;
}

.detail-section {
  margin-bottom: 20px;
}

.detail-section:last-child {
  margin-bottom: 0;
}

.detail-section h4 {
  font-size: 16px;
  color: #495057;
  margin: 0 0 10px 0;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  font-size: 13px;
}

.detail-section p {
  color: #6c757d;
  line-height: 1.6;
  margin: 0;
}

/* Feature Tags */
.features-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.feature-tag {
  background: #e7f3ff;
  color: #0066cc;
  padding: 6px 12px;
  border-radius: 16px;
  font-size: 13px;
  font-weight: 500;
  border: 1px solid #b3d9ff;
}

/* Rooms Section */
.rooms-section {
  padding: 25px;
  background: #fafbfc;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.section-header h3 {
  font-size: 20px;
  color: #2c3e50;
  margin: 0;
  font-weight: 600;
}

.btn-add-room {
  background: #6f42c1;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.btn-add-room:hover {
  background: #5a32a3;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(111, 66, 193, 0.3);
}

/* Rooms Grid */
.rooms-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 20px;
}

/* Room Card */
.room-card {
  background: white;
  border-radius: 10px;
  overflow: hidden;
  box-shadow: 0 2px 6px rgba(0,0,0,0.08);
  transition: all 0.3s ease;
  border: 1px solid #e8e8e8;
}

.room-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 6px 16px rgba(0,0,0,0.12);
}

.room-card.room-full {
  opacity: 0.8;
}

.room-image {
  position: relative;
  height: 180px;
  background: #f8f9fa;
}

.room-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.no-image {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #e9ecef 0%, #dee2e6 100%);
  color: #adb5bd;
  font-weight: 500;
  font-size: 14px;
}

.room-status-overlay {
  position: absolute;
  top: 10px;
  right: 10px;
}

.status-tag {
  padding: 5px 12px;
  border-radius: 15px;
  font-size: 12px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  box-shadow: 0 2px 6px rgba(0,0,0,0.15);
}

.status-tag.full {
  background: #dc3545;
  color: white;
}

.status-tag.vacant {
  background: #28a745;
  color: white;
}

.status-tag.occupied {
  background: #ffc107;
  color: #000;
}

.room-info {
  padding: 15px;
}

.room-info h4 {
  font-size: 18px;
  color: #2c3e50;
  margin: 0 0 12px 0;
  font-weight: 600;
}

.room-details-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
  margin-bottom: 12px;
  padding-bottom: 12px;
  border-bottom: 1px solid #e8e8e8;
}

.detail-item {
  display: flex;
  flex-direction: column;
}

.detail-item .label {
  font-size: 11px;
  color: #6c757d;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  margin-bottom: 4px;
  font-weight: 600;
}

.detail-item .value {
  font-size: 15px;
  color: #2c3e50;
  font-weight: 600;
}

.full-occupancy {
  color: #dc3545;
}

.room-price {
  font-size: 24px;
  color: #6f42c1;
  font-weight: 700;
}

.room-price span {
  font-size: 13px;
  color: #6c757d;
  font-weight: 400;
}

/* No Rooms State */
.no-rooms {
  background: white;
  border-radius: 10px;
  padding: 40px;
  text-align: center;
  border: 2px dashed #dee2e6;
}

.no-rooms p {
  color: #6c757d;
  margin: 0 0 15px 0;
}

/* Empty State */
.empty-state {
  background: white;
  border-radius: 12px;
  padding: 60px 40px;
  text-align: center;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
}

.empty-icon {
  font-size: 80px;
  margin-bottom: 20px;
}

.empty-state h3 {
  font-size: 24px;
  color: #2c3e50;
  margin: 0 0 10px 0;
}

.empty-state p {
  color: #6c757d;
  margin: 0 0 25px 0;
  font-size: 15px;
}

/* Modal Styling */
.modal { 
  display: none;
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.6);
  justify-content: center;
  align-items: center;
  z-index: 9999;
  backdrop-filter: blur(4px);
}

.modal-content { 
  background: #fff;
  padding: 30px;
  border-radius: 12px;
  width: 500px;
  max-width: 90%;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 10px 40px rgba(0,0,0,0.2);
}

.modal-content h2 {
  margin: 0 0 25px 0;
  color: #2c3e50;
  font-size: 24px;
}

.form-group { 
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  margin-bottom: 6px;
  color: #495057;
  font-weight: 600;
  font-size: 14px;
}

.form-group input,
.form-group select,
.form-group textarea {
  width: 100%;
  padding: 10px 12px;
  border: 1px solid #ced4da;
  border-radius: 6px;
  font-size: 14px;
  transition: border-color 0.3s ease;
}

.form-group input:focus,
.form-group select:focus,
.form-group textarea:focus {
  outline: none;
  border-color: #6f42c1;
  box-shadow: 0 0 0 3px rgba(111, 66, 193, 0.1);
}

.modal-actions { 
  text-align: right;
  margin-top: 25px;
  padding-top: 20px;
  border-top: 1px solid #e8e8e8;
  display: flex;
  gap: 10px;
  justify-content: flex-end;
}

/* Responsive Design */
@media (max-width: 768px) {
  .dorm-header {
    grid-template-columns: 1fr;
  }
  
  .dorm-image {
    width: 100%;
    height: 200px;
  }
  
  .rooms-grid {
    grid-template-columns: 1fr;
  }
  
  .page-header {
    flex-direction: column;
    gap: 15px;
  }
  
  .page-header .btn {
    width: 100%;
  }
}
</style>

<?php include __DIR__ . '/../../partials/footer.php'; ?>
