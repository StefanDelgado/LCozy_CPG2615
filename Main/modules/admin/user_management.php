<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

require_once __DIR__ . '/../../auth/auth.php';
require_role('admin');

// ✅ CREATE USER
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['create_user'])) {
    $name     = trim($_POST['name']);
    $email    = trim($_POST['email']);
    $pass     = $_POST['password'];
    $role     = $_POST['role'];
    $address  = trim($_POST['address'] ?? '');
    $phone    = trim($_POST['phone'] ?? '');
    $license  = ($role === 'owner') ? trim($_POST['license_no'] ?? '') : 'N/A';

    // Handle uploads safely
    $uploads = ['profile_pic', 'id_image', 'selfie_image'];
    $paths = [];
    foreach ($uploads as $u) {
        if (!empty($_FILES[$u]['name'])) {
            $filename = time() . "_" . basename($_FILES[$u]['name']);
            $targetDir = __DIR__ . "/../uploads";
            if (!is_dir($targetDir)) {
                mkdir($targetDir, 0777, true);
            }
            $target = "$targetDir/$filename";
            move_uploaded_file($_FILES[$u]['tmp_name'], $target);
            $paths[$u] = "/modules/uploads/$filename"; // ✅ Clean upload path
        } else {
            $paths[$u] = null;
        }
    }

    if ($name && $email && $pass && $role) {
        $hash = password_hash($pass, PASSWORD_DEFAULT);

        // ✅ Fixed placeholder count and column mapping
        $stmt = $pdo->prepare("
            INSERT INTO users 
            (name, email, password, role, address, phone, license_no, profile_pic, id_document, selfie_image, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())
        ");

        // ✅ Fixed array keys — matches table structure exactly
        $stmt->execute([
            $name,
            $email,
            $hash,
            $role,
            $address,
            $phone,
            $license,
            $paths['profile_pic'] ?? null,
            $paths['id_image'] ?? null,      // maps to id_document column
            $paths['selfie_image'] ?? null
        ]);

        header("Location: user_management.php?msg=User+created");
        exit;
    }
}

// ✅ EDIT USER
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['edit_user'])) {
    $id      = $_POST['user_id'];
    $name    = trim($_POST['name']);
    $email   = trim($_POST['email']);
    $role    = $_POST['role'];
    $address = trim($_POST['address'] ?? '');
    $phone   = trim($_POST['phone'] ?? '');
    $license = ($role === 'owner') ? trim($_POST['license_no'] ?? '') : 'N/A';

    $stmt = $pdo->prepare("
        UPDATE users 
        SET name = ?, email = ?, role = ?, address = ?, phone = ?, license_no = ?
        WHERE user_id = ?
    ");
    $stmt->execute([$name, $email, $role, $address, $phone, $license, $id]);

    header("Location: user_management.php?msg=User+updated");
    exit;
}

// ✅ DELETE USER
if (isset($_GET['delete'])) {
    $userId = (int) $_GET['delete'];
    $stmt = $pdo->prepare("DELETE FROM users WHERE user_id = ?");
    $stmt->execute([$userId]);
    header("Location: user_management.php?msg=User+deleted");
    exit;
}

// ✅ FETCH USERS
$users = $pdo->query("
    SELECT user_id, name, email, role, address, phone, license_no, profile_pic, id_document, verified, created_at 
    FROM users 
    ORDER BY created_at DESC
")->fetchAll();

$page_title = "User Management";
require_once __DIR__ . '/../../partials/header.php';
?>

<!-- HTML BELOW UNCHANGED -->
<div class="page-header"></div>

<?php if (isset($_GET['msg'])): ?>
  <div class="alert success"><?= htmlspecialchars($_GET['msg']) ?></div>
<?php endif; ?>

<div class="card">
  <div class="header-row">
    <h2>All Users</h2>
    <button class="btn-primary" onclick="openCreate()">➕ Add User</button>
  </div>
  <table>
    <thead>
      <tr>
        <th>ID</th>
        <th>Profile</th>
        <th>Name</th>
        <th>Email</th>
        <th>Phone</th>
        <th>Role</th>
        <th>Address</th>
        <th>License #</th>
        <th>Created</th>
        <th>Actions</th>
      </tr>
    </thead>
    <tbody>
      <?php foreach ($users as $u): ?>
        <tr>
          <td><?= $u['user_id'] ?></td>
          <td>
            <?php if ($u['profile_pic']): ?>
              <img src="<?= $u['profile_pic'] ?>" alt="profile" style="width:40px;height:40px;border-radius:50%;">
            <?php else: ?>
              <img src="../assets/default_profile.jpg" alt="default" style="width:40px;height:40px;border-radius:50%;">
            <?php endif; ?>
          </td>
          <td><?= htmlspecialchars($u['name']) ?></td>
          <td><?= htmlspecialchars($u['email']) ?></td>
          <td><?= htmlspecialchars($u['phone']) ?></td>
          <td><span class="badge"><?= htmlspecialchars($u['role']) ?></span></td>
          <td><?= htmlspecialchars($u['address']) ?></td>
          <td><?= !empty($u['license_no']) ? htmlspecialchars($u['license_no']) : 'N/A' ?></td>
          <td><?= htmlspecialchars($u['created_at']) ?></td>
          <td class="actions">
            <button class="btn-secondary" 
              onclick="openEdit(<?= $u['user_id'] ?>,'<?= htmlspecialchars($u['name'], ENT_QUOTES) ?>','<?= htmlspecialchars($u['email'], ENT_QUOTES) ?>','<?= $u['role'] ?>','<?= htmlspecialchars($u['address'], ENT_QUOTES) ?>','<?= htmlspecialchars($u['license_no'], ENT_QUOTES) ?>','<?= htmlspecialchars($u['phone'], ENT_QUOTES) ?>')">
              Edit
            </button>
            <a class="btn" style="background:#dc3545" href="?delete=<?= $u['user_id'] ?>" onclick="return confirm('Delete this user?')">Delete</a>
          </td>
        </tr>
      <?php endforeach; ?>
    </tbody>
  </table>
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
</script>

<style>
.header-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
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
