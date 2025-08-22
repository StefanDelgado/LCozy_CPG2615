<?php
require_once __DIR__ . '/../auth.php';
require_role('admin');

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['create_user'])) {
    $name  = trim($_POST['name']);
    $email = trim($_POST['email']);
    $pass  = $_POST['password'];
    $role  = $_POST['role'];

    if ($name && $email && $pass && $role) {
        $hash = password_hash($pass, PASSWORD_DEFAULT);
        $stmt = $pdo->prepare("INSERT INTO users (name, email, password, role) VALUES (?,?,?,?)");
        $stmt->execute([$name, $email, $hash, $role]);
        header("Location: user_management.php?msg=User+created");
        exit;
    }
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['edit_user'])) {
    $id    = $_POST['user_id'];
    $name  = trim($_POST['name']);
    $email = trim($_POST['email']);
    $role  = $_POST['role'];

    $stmt = $pdo->prepare("UPDATE users SET name=?, email=?, role=? WHERE user_id=?");
    $stmt->execute([$name, $email, $role, $id]);
    header("Location: user_management.php?msg=User+updated");
    exit;
}

if (isset($_GET['delete'])) {
    $userId = (int) $_GET['delete'];
    $stmt = $pdo->prepare("DELETE FROM users WHERE user_id = ?");
    $stmt->execute([$userId]);
    header("Location: user_management.php?msg=User+deleted");
    exit;
}

$users = $pdo->query("SELECT user_id, name, email, role, created_at FROM users ORDER BY created_at DESC")->fetchAll();
$page_title = "User Management";
require_once __DIR__ . '/../partials/header.php';
?>

<div class="page-header">
  <div>
  </div>
</div>

<?php if (isset($_GET['msg'])): ?>
  <div class="alert success"><?=htmlspecialchars($_GET['msg'])?></div>
<?php endif; ?>

<div class="card">
  <h2>Create New User</h2>
  <form method="post">
    <label>Name
      <input type="text" name="name" required>
    </label>
    <label>Email
      <input type="email" name="email" required>
    </label>
    <label>Password
      <input type="password" name="password" required>
    </label>
    <label>Role
      <select name="role" required>
        <option value="student">Student</option>
        <option value="owner">Owner</option>
        <option value="admin">Admin</option>
      </select>
    </label>
    <button type="submit" name="create_user">Create User</button>
  </form>
</div>

<div class="card">
  <h2>All Users</h2>
  <table>
    <thead>
      <tr>
        <th>ID</th>
        <th>Name</th>
        <th>Email</th>
        <th>Role</th>
        <th>Created</th>
        <th>Actions</th>
      </tr>
    </thead>
    <tbody>
      <?php foreach ($users as $u): ?>
        <tr>
          <td><?=$u['user_id']?></td>
          <td><?=$u['name']?></td>
          <td><?=$u['email']?></td>
          <td><span class="badge"><?=$u['role']?></span></td>
          <td><?=$u['created_at']?></td>
          <td class="actions">
            <button class="btn-secondary" 
              onclick="openEdit(<?=$u['user_id']?>,'<?=htmlspecialchars($u['name'],ENT_QUOTES)?>','<?=htmlspecialchars($u['email'],ENT_QUOTES)?>','<?=$u['role']?>')">
              Edit
            </button>
            <a class="btn" style="background:#dc3545" href="?delete=<?=$u['user_id']?>" onclick="return confirm('Delete this user?')">Delete</a>
          </td>
        </tr>
      <?php endforeach; ?>
    </tbody>
  </table>
</div>

<div id="editModal" class="modal" style="display:none;">
  <div class="modal-content">
    <h2>Edit User</h2>
    <form method="post">
      <input type="hidden" name="user_id" id="edit_user_id">
      <label>Name
        <input type="text" name="name" id="edit_name" required>
      </label>
      <label>Email
        <input type="email" name="email" id="edit_email" required>
      </label>
      <label>Role
        <select name="role" id="edit_role" required>
          <option value="student">Student</option>
          <option value="owner">Owner</option>
          <option value="admin">Admin</option>
        </select>
      </label>
      <button type="submit" name="edit_user">Save Changes</button>
      <button type="button" class="btn-secondary" onclick="closeEdit()">Cancel</button>
    </form>
  </div>
</div>

<script>
function openEdit(id, name, email, role) {
  document.getElementById('edit_user_id').value = id;
  document.getElementById('edit_name').value = name;
  document.getElementById('edit_email').value = email;
  document.getElementById('edit_role').value = role;
  document.getElementById('editModal').style.display = 'flex';
}
function closeEdit() {
  document.getElementById('editModal').style.display = 'none';
}
</script>

<?php require_once __DIR__ . '/../partials/footer.php'; ?>