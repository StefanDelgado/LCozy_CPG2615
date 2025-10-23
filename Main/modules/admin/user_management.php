<?php
require_once __DIR__ . '/../../auth/auth.php';
require_role('admin');

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['create_user'])) {
    $name  = trim($_POST['name']);
    $email = trim($_POST['email']);
    $pass  = $_POST['password'];
    $role  = $_POST['role'];
    $address = trim($_POST['address'] ?? '');
    $phone = trim($_POST['phone'] ?? '');
    $license = ($role === 'owner') ? trim($_POST['license_no'] ?? '') : 'N/A';

    $uploads = ['profile_pic','id_image','selfie_image'];
    $paths = [];
    foreach ($uploads as $u) {
        if (!empty($_FILES[$u]['name'])) {
            $filename = time() . "_" . basename($_FILES[$u]['name']);
            $targetDir = __DIR__ . "/../uploads";
            if (!is_dir($targetDir)) mkdir($targetDir, 0777, true);
            $target = "$targetDir/$filename";
            move_uploaded_file($_FILES[$u]['tmp_name'], $target);
            $paths[$u] = "/,,/uploads/$filename";
        } else {
            $paths[$u] = null;
        }
    }

    if ($name && $email && $pass && $role) {
        $hash = password_hash($pass, PASSWORD_DEFAULT);
        $stmt = $pdo->prepare("
            INSERT INTO users 
            (name, email, password, role, address, phone, license_no, profile_pic, id_document, created_at) 
            VALUES (?,?,?,?,?,?,?,?,?,NOW())
        ");
        $stmt->execute([
            $name, $email, $hash, $role, $address, $phone, $license,
            $paths['profile_pic'], $paths['id_document']
        ]);
        header("Location: user_management.php?msg=User+created");
        exit;
    }
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['edit_user'])) {
    $id    = $_POST['user_id'];
    $name  = trim($_POST['name']);
    $email = trim($_POST['email']);
    $role  = $_POST['role'];
    $address = trim($_POST['address'] ?? '');
    $phone = trim($_POST['phone'] ?? '');
    $license = ($role === 'owner') ? trim($_POST['license_no'] ?? '') : 'N/A';

    $stmt = $pdo->prepare("UPDATE users SET name=?, email=?, role=?, address=?, phone=?, license_no=? WHERE user_id=?");
    $stmt->execute([$name, $email, $role, $address, $phone, $license, $id]);
    header("Location: user_management.php?msg=User+updated");
    exit;
}

  // Handle manual verification actions
  if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['verify_user'])) {
    $id = (int)$_POST['user_id'];
    $action = $_POST['verify_action'];
    $status = ($action === 'accept') ? 1 : (($action === 'reject') ? -1 : 0);
    $stmt = $pdo->prepare("UPDATE users SET verified=? WHERE user_id=?");
    $stmt->execute([$status, $id]);
    header("Location: user_management.php?msg=Verification+updated");
    exit;
  }

if (isset($_GET['delete'])) {
    $userId = (int) $_GET['delete'];
    $stmt = $pdo->prepare("DELETE FROM users WHERE user_id = ?");
    $stmt->execute([$userId]);
    header("Location: user_management.php?msg=User+deleted");
    exit;
}

$users = $pdo->query("
    SELECT user_id, name, email, role, address, phone, license_no, profile_pic, id_document, verified, created_at 
    FROM users 
    ORDER BY created_at DESC
")->fetchAll();

$page_title = "User Management";
require_once __DIR__ . '/../../partials/header.php';
?>

<div class="page-header">
</div>

<?php if (isset($_GET['msg'])): ?>
  <div class="alert success"><?=htmlspecialchars($_GET['msg'])?></div>
<?php endif; ?>

<div class="card">
  <div class="header-row">
    <h2>All Users</h2>
    <button class="btn-primary" onclick="openCreate()">➕ Add User</button>
  </div>
  <div class="user-card-list">
    <?php foreach ($users as $u): ?>
      <div class="user-card">
        <div class="user-card-header" onclick="toggleUserCard(<?=$u['user_id']?>)">
          <div class="user-card-profile">
            <?php if ($u['profile_pic']): ?>
              <img src="<?=$u['profile_pic']?>" alt="profile" style="width:40px;height:40px;border-radius:50%;">
            <?php else: ?>
              <img src="../assets/default_profile.jpg" alt="default" style="width:40px;height:40px;border-radius:50%;">
            <?php endif; ?>
          </div>
          <div class="user-card-main">
            <div><b><?=$u['name']?></b> <span class="badge" style="margin-left:8px;"><?=$u['role']?></span></div>
            <div><?=$u['email']?></div>
            <div><?=$u['phone']?></div>
          </div>
          <div class="user-card-status">
            <?php
              if ($u['verified'] == 1) echo '<span class="badge" style="background:#28a745">Verified</span>';
              elseif ($u['verified'] == -1) echo '<span class="badge" style="background:#dc3545">Rejected</span>';
              else echo '<span class="badge" style="background:#ffc107;color:#333">Pending Verification</span>';
            ?>
          </div>
          <div class="user-card-actions">
            <button class="btn-secondary" onclick="event.stopPropagation();openEdit(<?=$u['user_id']?>,'<?=htmlspecialchars($u['name'],ENT_QUOTES)?>','<?=htmlspecialchars($u['email'],ENT_QUOTES)?>','<?=$u['role']?>','<?=htmlspecialchars($u['address'],ENT_QUOTES)?>','<?=htmlspecialchars($u['license_no'],ENT_QUOTES)?>','<?=htmlspecialchars($u['phone'],ENT_QUOTES)?>')">Edit</button>
            <a class="btn" style="background:#dc3545" href="?delete=<?=$u['user_id']?>" onclick="event.stopPropagation();return confirm('Delete this user?')">Delete</a>
            <?php if ($u['verified'] == 0): ?>
              <button class="btn" style="background:#28a745;margin-left:4px;" onclick="verifyUser(<?=$u['user_id']?>, 'accept', event)">Accept</button>
              <button class="btn" style="background:#dc3545;margin-left:2px;" onclick="verifyUser(<?=$u['user_id']?>, 'reject', event)">Reject</button>
            <?php endif; ?>
          </div>
        </div>
        <div class="user-card-details" id="user-details-<?=$u['user_id']?>" style="display:none;">
          <div><b>Address:</b> <?=htmlspecialchars($u['address'])?></div>
          <div><b>License #:</b> <?=!empty($u['license_no']) ? htmlspecialchars($u['license_no']) : 'N/A'?></div>
          <div><b>Created:</b> <?=$u['created_at']?></div>
          <div><b>ID Document:</b> <?=!empty($u['id_document']) ? htmlspecialchars($u['id_document']) : 'N/A'?></div>
        </div>
      </div>
    <?php endforeach; ?>
  </div>

<!-- CREATE USER MODAL -->
<div id="createModal" class="modal" style="display:none;">
  <div class="modal-content">
    <h2>Add New User</h2>
    <form method="post" enctype="multipart/form-data">
      <label>Name <input type="text" name="name" required></label>
      <label>Email <input type="email" name="email" required></label>
      <label>Password <input type="password" name="password" required></label>
      <label>Phone <input type="text" name="phone"></label>
      <label>Role
        <select name="role" id="create_role" required onchange="toggleLicenseField('create')">
          <option value="">Select role</option>
          <option value="student">Student</option>
          <option value="owner">Owner</option>
          <option value="admin">Admin</option>
        </select>
      </label>
      <div id="create_license_field" style="display:none;">
        <label>License Number (for Owners) <input type="text" name="license_no"></label>
      </div>
      <label>Address <input type="text" name="address"></label>
      <label>Profile Image <input type="file" name="profile_pic" accept="image/*"></label>
      <label>ID Image <input type="file" name="id_image" accept="image/*"></label>
      <button type="submit" name="create_user" class="btn-primary">Create User</button>
      <button type="button" class="btn-secondary" onclick="closeCreate()">Cancel</button>
    </form>
  </div>
</div>

<!-- EDIT USER MODAL -->
<div id="editModal" class="modal" style="display:none;">
  <div class="modal-content">
    <h2>Edit User</h2>
    <form method="post">
      <input type="hidden" name="user_id" id="edit_user_id">
      <label>Name <input type="text" name="name" id="edit_name" required></label>
      <label>Email <input type="email" name="email" id="edit_email" required></label>
      <label>Phone <input type="text" name="phone" id="edit_phone"></label>
      <label>Role
        <select name="role" id="edit_role" required onchange="toggleLicenseField('edit')">
          <option value="student">Student</option>
          <option value="owner">Owner</option>
          <option value="admin">Admin</option>
        </select>
      </label>
      <div id="edit_license_field" style="display:none;">
        <label>License Number <input type="text" name="license_no" id="edit_license"></label>
      </div>
      <label>Address <input type="text" name="address" id="edit_address"></label>
      <button type="submit" name="edit_user" class="btn-primary">Save Changes</button>
      <button type="button" class="btn-secondary" onclick="closeEdit()">Cancel</button>
    </form>
  </div>
</div>

<script>
function toggleLicenseField(type) {
  const role = document.getElementById(type + '_role').value;
  const field = document.getElementById(type + '_license_field');
  field.style.display = (role === 'owner') ? 'block' : 'none';
}

function openCreate() {
  document.getElementById('createModal').style.display = 'flex';
}
function closeCreate() {
  document.getElementById('createModal').style.display = 'none';
}
function openEdit(id, name, email, role, address, license, phone) {
  document.getElementById('edit_user_id').value = id;
  document.getElementById('edit_name').value = name;
  document.getElementById('edit_email').value = email;
  document.getElementById('edit_role').value = role;
  document.getElementById('edit_address').value = address;
  document.getElementById('edit_license').value = license;
  document.getElementById('edit_phone').value = phone;
  toggleLicenseField('edit');
  document.getElementById('editModal').style.display = 'flex';
}
function closeEdit() {
  document.getElementById('editModal').style.display = 'none';
}
function toggleUserCard(id) {
  var details = document.getElementById('user-details-' + id);
  if (details.style.display === 'none') {
    details.style.display = 'block';
  } else {
    details.style.display = 'none';
  }
}
</script>

<style>
.header-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.user-card-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}
.user-card {
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
  padding: 1rem;
  transition: box-shadow 0.2s;
  cursor: pointer;
}
.user-card:hover {
  box-shadow: 0 4px 16px rgba(0,0,0,0.12);
}
.user-card-header {
  display: flex;
  align-items: center;
  gap: 1rem;
}
.user-card-profile img {
  width: 40px;
  height: 40px;
  border-radius: 50%;
}
.user-card-main {
  flex: 1;
}
.user-card-status {
  min-width: 90px;
  text-align: center;
}
.user-card-actions {
  display: flex;
  gap: 0.5rem;
  position: relative;
  z-index: 100;
  margin-top: 12px;
}
  position: relative;
  z-index: 101;
.user-card-details {
  margin-top: 1rem;
  background: #f8f8ff;
  border-radius: 8px;
  padding: 0.75rem;
  font-size: 0.98em;
}
}
.btn-primary {
  background: #6A5ACD;
  color: #fff;
  padding: 8px 14px;
  border: none;
  border-radius: 8px;
  cursor: pointer;
}
.btn-primary:hover { background: #5848c2; }
.modal {
  position: fixed;
  top: 0; left: 0;
  width: 100%; height: 100%;
  background: rgba(0,0,0,0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
}
.modal-content {
  background: #fff;
  padding: 2rem;
  border-radius: 12px;
  width: 400px;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 4px 15px rgba(0,0,0,0.2);
}
.modal-content label { display: block; margin-bottom: 0.5rem; font-weight: 500; }
.modal-content input, .modal-content select {
  width: 100%;
  padding: 0.6rem;
  border: 1px solid #ccc;
  border-radius: 8px;
  margin-bottom: 1rem;
}

/* Responsive table container */
.card > div[style*="overflow-x:auto"] {
  margin-bottom: 1rem;
}
}
.btn-secondary {
  background: #ddd;
  color: #333;
  padding: 8px 14px;
  border-radius: 8px;
  border: none;
  cursor: pointer;
}
.btn-secondary:hover { background: #ccc; }
</style>

<?php require_once __DIR__ . '/../../partials/footer.php'; ?>