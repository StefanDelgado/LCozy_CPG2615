<?php 
require_once __DIR__ . '/../../partials/header.php'; 
require_role('owner');
require_once __DIR__ . '/../../config.php';

$owner_id = $_SESSION['user']['user_id'];
$flash = null;

// Get dorm_id from URL if provided
$filter_dorm_id = isset($_GET['dorm_id']) ? (int)$_GET['dorm_id'] : null;

// ───── Handle Form Submissions ─────
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Add Room
    if (isset($_POST['add_room'])) {
        $dorm_id = (int)$_POST['dorm_id'];
        $room_type = $_POST['room_type_select'] === 'Custom' ? trim($_POST['room_type']) : $_POST['room_type_select'];
        $size = !empty($_POST['size']) ? (float)$_POST['size'] : null;
        $capacity = (int)$_POST['capacity'];
        $price = (float)$_POST['price'];
        $status = $_POST['status'];

        $stmt = $pdo->prepare("SELECT COUNT(*) FROM dormitories WHERE dorm_id=? AND owner_id=?");
        $stmt->execute([$dorm_id, $owner_id]);
        if ($stmt->fetchColumn() > 0) {
            // Handle multiple image uploads
            $room_images = [];
            if (!empty($_FILES['room_images']['name'][0])) {
                $upload_dir = __DIR__ . '/../../uploads/';
                if (!is_dir($upload_dir)) mkdir($upload_dir, 0755, true);
                
                foreach ($_FILES['room_images']['tmp_name'] as $key => $tmp_name) {
                    if (!empty($tmp_name)) {
                        $file_name = uniqid('room_') . '_' . basename($_FILES['room_images']['name'][$key]);
                        $target_path = $upload_dir . $file_name;
                        if (move_uploaded_file($tmp_name, $target_path)) {
                            $room_images[] = $file_name;
                        }
                    }
                }
            }

            $stmt = $pdo->prepare("INSERT INTO rooms (dorm_id, room_type, size, capacity, price, status, created_at)
                                   VALUES (?, ?, ?, ?, ?, ?, NOW())");
            $stmt->execute([$dorm_id, $room_type, $size, $capacity, $price, $status]);
            $room_id = $pdo->lastInsertId();

            // Insert room images
            if (!empty($room_images)) {
                $img_stmt = $pdo->prepare("INSERT INTO room_images (room_id, image_path) VALUES (?, ?)");
                foreach ($room_images as $img) {
                    $img_stmt->execute([$room_id, $img]);
                }
            }

            $_SESSION['flash'] = ['type'=>'success','msg'=>'Room added successfully!'];
            // Redirect to prevent form resubmission
            $redirect_url = $filter_dorm_id ? "?dorm_id=$filter_dorm_id" : "";
            header("Location: " . $_SERVER['PHP_SELF'] . $redirect_url);
            exit();
        }
    }

    // Edit Room
    if (isset($_POST['edit_room'])) {
        $id = (int)$_POST['room_id'];
        $room_type = trim($_POST['room_type']);
        $size = !empty($_POST['size']) ? (float)$_POST['size'] : null;
        $capacity = (int)$_POST['capacity'];
        $price = (float)$_POST['price'];
        $status = $_POST['status'];

        // Handle room image uploads
        if (!empty($_FILES['room_images']['name'][0])) {
            $upload_dir = __DIR__ . '/../../uploads/rooms/';
            if (!is_dir($upload_dir)) mkdir($upload_dir, 0755, true);
            
            foreach ($_FILES['room_images']['tmp_name'] as $key => $tmp_name) {
                if (!empty($tmp_name)) {
                    $file_name = uniqid('room_') . '_' . basename($_FILES['room_images']['name'][$key]);
                    $target_path = $upload_dir . $file_name;
                    if (move_uploaded_file($tmp_name, $target_path)) {
                        // Insert new room image
                        $img_stmt = $pdo->prepare("INSERT INTO room_images (room_id, image_path) VALUES (?, ?)");
                        $img_stmt->execute([$id, $file_name]);
                    }
                }
            }
        }

        $stmt = $pdo->prepare("
            UPDATE rooms r
            JOIN dormitories d ON r.dorm_id = d.dorm_id
            SET r.room_type=?, r.size=?, r.capacity=?, r.price=?, r.status=?
            WHERE r.room_id=? AND d.owner_id=?
        ");
        $stmt->execute([$room_type, $size, $capacity, $price, $status, $id, $owner_id]);
        $_SESSION['flash'] = ['type'=>'success','msg'=>'Room updated successfully!'];
        // Redirect to prevent form resubmission
        $redirect_url = $filter_dorm_id ? "?dorm_id=$filter_dorm_id" : "";
        header("Location: " . $_SERVER['PHP_SELF'] . $redirect_url);
        exit();
    }

    // Delete Room
    if (isset($_POST['delete_room'])) {
        $id = (int)$_POST['room_id'];
        $stmt = $pdo->prepare("
            DELETE r FROM rooms r
            JOIN dormitories d ON r.dorm_id = d.dorm_id
            WHERE r.room_id=? AND d.owner_id=?
        ");
        $stmt->execute([$id, $owner_id]);
        $_SESSION['flash'] = ['type'=>'error','msg'=>'Room deleted successfully!'];
        // Redirect to prevent form resubmission
        $redirect_url = $filter_dorm_id ? "?dorm_id=$filter_dorm_id" : "";
        header("Location: " . $_SERVER['PHP_SELF'] . $redirect_url);
        exit();
    }

    // Delete Room Image
    if (isset($_POST['delete_room_image'])) {
        $image_path = $_POST['image_path'];
        $room_id = (int)$_POST['room_id'];
        
        // Verify ownership before deleting
        $stmt = $pdo->prepare("
            SELECT ri.image_path 
            FROM room_images ri
            JOIN rooms r ON ri.room_id = r.room_id
            JOIN dormitories d ON r.dorm_id = d.dorm_id
            WHERE ri.image_path = ? AND r.room_id = ? AND d.owner_id = ?
        ");
        $stmt->execute([$image_path, $room_id, $owner_id]);
        $image = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($image) {
            // Delete file from server
            $file_path = __DIR__ . '/../../uploads/rooms/' . $image['image_path'];
            if (file_exists($file_path)) {
                unlink($file_path);
            }
            
            // Delete from database
            $stmt = $pdo->prepare("DELETE FROM room_images WHERE image_path = ? AND room_id = ?");
            $stmt->execute([$image_path, $room_id]);
            
            $_SESSION['flash'] = ['type'=>'success','msg'=>'Image deleted successfully!'];
        }
        
        $redirect_url = $filter_dorm_id ? "?dorm_id=$filter_dorm_id" : "";
        header("Location: " . $_SERVER['PHP_SELF'] . $redirect_url);
        exit();
    }
}

// Check for flash message from session
if (isset($_SESSION['flash'])) {
    $flash = $_SESSION['flash'];
    unset($_SESSION['flash']);
}

// ───── Fetch Data ─────
$query = "
    SELECT r.room_id, r.room_type, r.size, r.capacity, r.price, r.status, 
           d.name AS dorm_name, r.dorm_id,
           (SELECT COUNT(*) FROM bookings b WHERE b.room_id = r.room_id AND b.status IN ('approved','active')) AS occupants,
           (SELECT image_path FROM room_images WHERE room_id = r.room_id LIMIT 1) AS cover_image
    FROM rooms r
    JOIN dormitories d ON r.dorm_id = d.dorm_id
    WHERE d.owner_id = ?
";
$params = [$owner_id];

if ($filter_dorm_id) {
    $query .= " AND r.dorm_id = ?";
    $params[] = $filter_dorm_id;
}

$query .= " ORDER BY d.name, r.room_type";

$stmt = $pdo->prepare($query);
$stmt->execute($params);
$rooms = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Get dorm info if filtering
$current_dorm = null;
if ($filter_dorm_id) {
    $stmt = $pdo->prepare("SELECT * FROM dormitories WHERE dorm_id = ? AND owner_id = ?");
    $stmt->execute([$filter_dorm_id, $owner_id]);
    $current_dorm = $stmt->fetch(PDO::FETCH_ASSOC);
}

$dorms = $pdo->prepare("SELECT dorm_id, name FROM dormitories WHERE owner_id=? ORDER BY name");
$dorms->execute([$owner_id]);
$dorms = $dorms->fetchAll(PDO::FETCH_ASSOC);
?>

<div class="page-header">
  <div>
    <h1>Room Management</h1>
    <?php if ($current_dorm): ?>
      <p class="breadcrumb">
        <a href="/modules/owner/owner_dorms.php">← Back to Dorm Management</a> / 
        <strong><?= htmlspecialchars($current_dorm['name']) ?></strong>
      </p>
    <?php endif; ?>
  </div>
  <button class="btn" onclick="openAddModal()">+ Add Room</button>
</div>

<?php if ($flash): ?>
  <div class="alert <?=$flash['type']?>"><?= htmlspecialchars($flash['msg']) ?></div>
<?php endif; ?>

<!-- Room Cards -->
<?php if (!empty($rooms)): ?>
  <div class="rooms-grid">
    <?php 
    $grouped_rooms = [];
    foreach ($rooms as $room) {
      $grouped_rooms[$room['dorm_name']][] = $room;
    }
    
    foreach ($grouped_rooms as $dorm_name => $dorm_rooms): 
    ?>
      <?php if (!$filter_dorm_id): ?>
        <div class="dorm-group-header">
          <h2>📍 <?= htmlspecialchars($dorm_name) ?></h2>
          <span class="room-count"><?= count($dorm_rooms) ?> room<?= count($dorm_rooms) !== 1 ? 's' : '' ?></span>
        </div>
      <?php endif; ?>
      
      <div class="room-cards-container">
        <?php foreach ($dorm_rooms as $r): ?>
          <div class="room-card">
            <?php if (!empty($r['cover_image'])): ?>
              <div class="room-card-image">
                <img src="../../uploads/rooms/<?= htmlspecialchars($r['cover_image']) ?>" alt="<?= htmlspecialchars($r['room_type']) ?>">
                <div class="room-status-overlay status-<?= $r['status'] ?>">
                  <?= ucfirst($r['status']) ?>
                </div>
              </div>
            <?php else: ?>
              <div class="room-card-image no-image">
                <div class="no-image-placeholder">
                  <span>🏠</span>
                  <p>No Image</p>
                </div>
                <div class="room-status-overlay status-<?= $r['status'] ?>">
                  <?= ucfirst($r['status']) ?>
                </div>
              </div>
            <?php endif; ?>
            
            <div class="room-card-content">
              <div class="room-card-header">
                <h3><?= htmlspecialchars($r['room_type']) ?></h3>
                <div class="room-price">₱<?= number_format($r['price'], 2) ?><span>/month</span></div>
              </div>
              
              <div class="room-details">
                <?php if ($r['size']): ?>
                  <div class="detail-item">
                    <span class="icon">📐</span>
                    <span><?= $r['size'] ?> m²</span>
                  </div>
                <?php endif; ?>
                <div class="detail-item">
                  <span class="icon">👥</span>
                  <span><?= $r['capacity'] ?> <?= $r['capacity'] > 1 ? 'persons' : 'person' ?></span>
                </div>
                <div class="detail-item">
                  <span class="icon">🛏️</span>
                  <span><?= $r['occupants'] ?>/<?= $r['capacity'] ?> occupied</span>
                </div>
              </div>
              
              <div class="room-card-actions">
                <button class="btn-edit" 
                        data-room-id="<?= $r['room_id'] ?>"
                        data-room-type="<?= htmlspecialchars($r['room_type']) ?>"
                        data-size="<?= $r['size'] ?>"
                        data-capacity="<?= $r['capacity'] ?>"
                        data-price="<?= $r['price'] ?>"
                        data-status="<?= $r['status'] ?>"
                        onclick="openEditModal(this)">
                  ✏️ Edit
                </button>
                <form method="post" style="display:inline-block" onsubmit="return confirm('Are you sure you want to delete this room? This action cannot be undone.')">
                  <input type="hidden" name="room_id" value="<?= $r['room_id'] ?>">
                  <button type="submit" name="delete_room" class="btn-delete">🗑️ Delete</button>
                </form>
              </div>
            </div>
          </div>
        <?php endforeach; ?>
      </div>
    <?php endforeach; ?>
  </div>
<?php else: ?>
  <div class="empty-state">
    <div class="empty-icon">🏠</div>
    <h2>No Rooms Yet</h2>
    <p>Start by adding your first room to <?= $current_dorm ? htmlspecialchars($current_dorm['name']) : 'your dormitories' ?>.</p>
    <button class="btn" onclick="openAddModal()">+ Add Your First Room</button>
  </div>
<?php endif; ?>

<!-- ADD ROOM MODAL -->
<div id="addModal" class="modal">
  <div class="modal-content">
    <h2>Add New Room</h2>
    <form method="post" enctype="multipart/form-data" class="form-area">
      <div class="form-group">
        <label for="dorm_id">Dormitory *</label>
        <select name="dorm_id" id="dorm_id" required>
          <option value="">-- Select Dormitory --</option>
          <?php foreach ($dorms as $d): ?>
            <option value="<?= $d['dorm_id'] ?>" <?= ($filter_dorm_id && $filter_dorm_id == $d['dorm_id']) ? 'selected' : '' ?>>
              <?= htmlspecialchars($d['name']) ?>
            </option>
          <?php endforeach; ?>
        </select>
      </div>

      <div class="form-group">
        <label for="room_type_select">Room Type *</label>
        <select name="room_type_select" id="room_type_select" onchange="toggleCustomRoomType(this, 'customRoomTypeAdd')" required>
          <option value="">Select Room Type</option>
          <option value="Single">Single</option>
          <option value="Double">Double</option>
          <option value="Twin">Twin</option>
          <option value="Suite">Suite</option>
          <option value="Custom">Custom</option>
        </select>
        <input type="text" id="customRoomTypeAdd" name="room_type" placeholder="Enter custom room type" style="display:none;">
      </div>

      <div class="form-group">
        <label for="size">Room Size (m²)</label>
        <input type="number" id="size" name="size" step="0.1" placeholder="e.g. 15.5">
      </div>

      <div class="form-group">
        <label for="capacity">Capacity *</label>
        <input type="number" id="capacity" name="capacity" min="1" required placeholder="Number of persons">
      </div>

      <div class="form-group">
        <label for="price">Price (₱/month) *</label>
        <input type="number" id="price" name="price" step="0.01" required placeholder="e.g. 5000.00">
      </div>

      <div class="form-group">
        <label for="status">Status</label>
        <select name="status" id="status">
          <option value="vacant">Vacant</option>
          <option value="occupied">Occupied</option>
        </select>
      </div>

      <div class="form-group">
        <label for="room_images">Room Images (multiple)</label>
        <input type="file" name="room_images[]" id="room_images" accept=".jpg,.jpeg,.png" multiple>
        <small>You can select multiple images</small>
      </div>

      <div class="modal-actions">
        <button type="submit" name="add_room" class="btn">Add Room</button>
        <button type="button" class="btn-secondary" onclick="closeAddModal()">Cancel</button>
      </div>
    </form>
  </div>
</div>


<!-- EDIT ROOM MODAL -->
<div id="editModal" class="modal">
  <div class="modal-content">
    <h2>Edit Room</h2>
    <form method="post" enctype="multipart/form-data" class="form-area">
      <input type="hidden" name="room_id" id="edit_room_id">

      <div class="form-group">
        <label for="edit_room_type_select">Room Type *</label>
        <select id="edit_room_type_select" onchange="toggleCustomRoomType(this, 'customRoomTypeEdit')" required>
          <option value="">Select Room Type</option>
          <option value="Single">Single</option>
          <option value="Double">Double</option>
          <option value="Twin">Twin</option>
          <option value="Suite">Suite</option>
          <option value="Custom">Custom</option>
        </select>
        <input type="text" id="customRoomTypeEdit" name="room_type" placeholder="Enter custom room type" style="display:none;">
      </div>

      <div class="form-group">
        <label for="edit_size">Room Size (m²)</label>
        <input type="number" id="edit_size" name="size" step="0.1" placeholder="e.g. 15.5">
      </div>

      <div class="form-group">
        <label for="edit_capacity">Capacity *</label>
        <input type="number" id="edit_capacity" name="capacity" min="1" required>
      </div>

      <div class="form-group">
        <label for="edit_price">Price (₱/month) *</label>
        <input type="number" id="edit_price" name="price" step="0.01" required>
      </div>

      <div class="form-group">
        <label for="edit_status">Status</label>
        <select id="edit_status" name="status">
          <option value="vacant">Vacant</option>
          <option value="occupied">Occupied</option>
        </select>
      </div>

      <div class="form-group">
        <label>Current Room Images</label>
        <div id="current_room_images" class="current-images-grid">
          <!-- Images will be loaded dynamically -->
        </div>
      </div>

      <div class="form-group">
        <label for="edit_room_images">Add New Room Images (Multiple)</label>
        <input type="file" id="edit_room_images" name="room_images[]" accept="image/*" multiple>
        <small style="color: #666;">Upload new images to add to this room's gallery</small>
      </div>

      <div class="modal-actions">
        <button type="submit" name="edit_room" class="btn">Save Changes</button>
        <button type="button" class="btn-secondary" onclick="closeEditModal()">Cancel</button>
      </div>
    </form>
  </div>
</div>

<!-- Hidden form for deleting images -->
<form id="deleteImageForm" method="post" style="display:none;">
  <input type="hidden" name="delete_room_image" value="1">
  <input type="hidden" name="image_path" id="delete_image_path">
  <input type="hidden" name="room_id" id="delete_room_id">
</form>

<script>
function openAddModal() {
  document.getElementById('addModal').style.display = 'flex';
}
function closeAddModal() {
  document.getElementById('addModal').style.display = 'none';
}

function openEditModal(button) {
  const roomId = button.getAttribute('data-room-id');
  const roomType = button.getAttribute('data-room-type');
  const size = button.getAttribute('data-size');
  const capacity = button.getAttribute('data-capacity');
  const price = button.getAttribute('data-price');
  const status = button.getAttribute('data-status');
  
  // Set basic fields
  document.getElementById('edit_room_id').value = roomId;
  document.getElementById('edit_size').value = size || '';
  document.getElementById('edit_capacity').value = capacity;
  document.getElementById('edit_price').value = price;
  document.getElementById('edit_status').value = status;
  
  // Handle room type dropdown
  const roomTypeSelect = document.getElementById('edit_room_type_select');
  const customRoomTypeInput = document.getElementById('customRoomTypeEdit');
  
  // Check if room type matches standard options
  const standardTypes = ['Single', 'Double', 'Twin', 'Suite'];
  if (standardTypes.includes(roomType)) {
    roomTypeSelect.value = roomType;
    customRoomTypeInput.style.display = 'none';
    customRoomTypeInput.value = roomType;
  } else {
    // Custom room type
    roomTypeSelect.value = 'Custom';
    customRoomTypeInput.style.display = 'block';
    customRoomTypeInput.value = roomType;
  }
  
  // Load room images
  loadRoomImages(roomId);
  
  document.getElementById('editModal').style.display = 'flex';
}

function loadRoomImages(roomId) {
  // Fetch room images via AJAX
  const container = document.getElementById('current_room_images');
  container.innerHTML = '<p style="color: #999;">Loading images...</p>';
  
  fetch(`/modules/admin/get_room_images.php?room_id=${roomId}`)
    .then(response => {
      console.log('Response status:', response.status);
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      return response.json();
    })
    .then(data => {
      console.log('Images data:', data);
      if (data.images && data.images.length > 0) {
        container.innerHTML = data.images.map(img => `
          <div class="image-item">
            <img src="../../uploads/rooms/${img.image_path}" alt="Room Image">
            <button type="button" class="btn-delete-image" onclick="deleteRoomImage('${img.image_path}', ${roomId})" title="Delete Image">
              ✕
            </button>
          </div>
        `).join('');
      } else {
        container.innerHTML = '<p style="color: #999; font-style: italic;">No images uploaded yet</p>';
      }
    })
    .catch(err => {
      console.error('Error loading images:', err);
      container.innerHTML = '<p style="color: #dc3545;">Could not load images: ' + err.message + '</p>';
    });
}

function deleteRoomImage(imagePath, roomId) {
  if (!confirm('Are you sure you want to delete this image?')) return;
  
  document.getElementById('delete_image_path').value = imagePath;
  document.getElementById('delete_room_id').value = roomId;
  document.getElementById('deleteImageForm').submit();
}

function closeEditModal() {
  document.getElementById('editModal').style.display = 'none';
}

function toggleCustomRoomType(select, inputId) {
  const input = document.getElementById(inputId);
  input.style.display = (select.value === 'Custom') ? 'block' : 'none';
  if(select.value !== 'Custom') input.value = select.value;
}

// Close modal when clicking outside
window.onclick = function(event) {
  if (event.target.classList.contains('modal')) {
    event.target.style.display = 'none';
  }
}
</script>

<style>
/* Modern Room Management Styles */
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
  padding-bottom: 20px;
  border-bottom: 2px solid #e9ecef;
}

.page-header h1 {
  margin: 0 0 5px 0;
  color: #2c3e50;
}

.breadcrumb {
  margin: 5px 0 0 0;
  color: #6c757d;
  font-size: 14px;
}

.breadcrumb a {
  color: #6f42c1;
  text-decoration: none;
  transition: color 0.3s ease;
}

.breadcrumb a:hover {
  color: #5a32a3;
  text-decoration: underline;
}

.dorm-group-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin: 30px 0 15px 0;
  padding: 15px 20px;
  background: linear-gradient(135deg, #6f42c1 0%, #5a32a3 100%);
  border-radius: 12px;
  color: white;
}

.dorm-group-header h2 {
  margin: 0;
  font-size: 20px;
  font-weight: 600;
}

.room-count {
  background: rgba(255, 255, 255, 0.2);
  padding: 5px 15px;
  border-radius: 20px;
  font-size: 13px;
  font-weight: 600;
}

.rooms-grid {
  margin-bottom: 30px;
}

.room-cards-container {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.room-card {
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  transition: all 0.3s ease;
  border: 1px solid #e9ecef;
}

.room-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 20px rgba(111, 66, 193, 0.15);
}

.room-card-image {
  width: 100%;
  height: 200px;
  position: relative;
  overflow: hidden;
}

.room-card-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.room-card-image.no-image {
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  display: flex;
  align-items: center;
  justify-content: center;
}

.no-image-placeholder {
  text-align: center;
  color: #6c757d;
}

.no-image-placeholder span {
  font-size: 48px;
  display: block;
  margin-bottom: 10px;
}

.no-image-placeholder p {
  margin: 0;
  font-size: 14px;
  font-weight: 600;
}

.room-status-overlay {
  position: absolute;
  top: 10px;
  right: 10px;
  padding: 6px 12px;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 700;
  text-transform: uppercase;
  backdrop-filter: blur(10px);
}

.room-status-overlay.status-vacant {
  background: rgba(40, 167, 69, 0.9);
  color: white;
}

.room-status-overlay.status-occupied {
  background: rgba(220, 53, 69, 0.9);
  color: white;
}

.room-card-content {
  padding: 20px;
}

.room-card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 15px;
  padding-bottom: 15px;
  border-bottom: 2px solid #f8f9fa;
}

.room-card-header h3 {
  margin: 0;
  font-size: 20px;
  color: #2c3e50;
  font-weight: 700;
}

.room-price {
  font-size: 24px;
  font-weight: 700;
  color: #6f42c1;
  text-align: right;
}

.room-price span {
  font-size: 12px;
  color: #6c757d;
  font-weight: 400;
  display: block;
}

.room-details {
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-bottom: 15px;
}

.detail-item {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #495057;
  font-size: 14px;
}

.detail-item .icon {
  font-size: 16px;
}

.room-card-actions {
  display: flex;
  gap: 10px;
  margin-top: 15px;
  padding-top: 15px;
  border-top: 2px solid #f8f9fa;
}

.btn-edit {
  flex: 1;
  background: #17a2b8;
  color: white;
  border: none;
  padding: 10px 16px;
  border-radius: 6px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.btn-edit:hover {
  background: #138496;
  transform: translateY(-1px);
  box-shadow: 0 3px 8px rgba(23, 162, 184, 0.3);
}

.btn-delete {
  flex: 1;
  background: #dc3545;
  color: white;
  border: none;
  padding: 10px 16px;
  border-radius: 6px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.btn-delete:hover {
  background: #c82333;
  transform: translateY(-1px);
  box-shadow: 0 3px 8px rgba(220, 53, 69, 0.3);
}

.empty-state {
  text-align: center;
  padding: 80px 20px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.empty-icon {
  font-size: 80px;
  margin-bottom: 20px;
  opacity: 0.5;
}

.empty-state h2 {
  color: #2c3e50;
  margin-bottom: 10px;
}

.empty-state p {
  color: #6c757d;
  margin-bottom: 30px;
  font-size: 16px;
}

/* Room Images Grid */
.current-images-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
  gap: 15px;
  margin-top: 10px;
}

.image-item {
  position: relative;
  border-radius: 8px;
  overflow: hidden;
  border: 2px solid #e9ecef;
  aspect-ratio: 1;
}

.image-item img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.btn-delete-image {
  position: absolute;
  top: 5px;
  right: 5px;
  background: rgba(220, 53, 69, 0.9);
  color: white;
  border: none;
  border-radius: 50%;
  width: 28px;
  height: 28px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  font-size: 16px;
  font-weight: bold;
  transition: all 0.2s;
  padding: 0;
  line-height: 1;
}

.btn-delete-image:hover {
  background: #dc3545;
  transform: scale(1.1);
}

/* Responsive Design */
@media (max-width: 768px) {
  .page-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 15px;
  }
  
  .room-cards-container {
    grid-template-columns: 1fr;
  }
  
  .dorm-group-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 10px;
  }
  
  .current-images-grid {
    grid-template-columns: repeat(auto-fill, minmax(100px, 1fr));
  }
}
</style>

<?php require_once __DIR__ . '/../../partials/footer.php'; ?>
