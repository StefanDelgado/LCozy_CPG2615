<?php 
require_once __DIR__ . '/../partials/header.php'; 
require_once __DIR__ . '/../config.php';

$role = $_SESSION['user']['role'];
$user_id = $_SESSION['user']['user_id'];

if ($role === 'owner') {
    // --- OWNER: Upload documents ---
    $msg = null;
    $allowedTypes = ['image/jpeg', 'image/png', 'application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'];
    $maxSize = 5 * 1024 * 1024; // 5 MB

    if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['upload_docs'])) {
        $uploadDir = __DIR__ . '/../uploads/';
        if (!is_dir($uploadDir)) mkdir($uploadDir, 0777, true);

        $updates = [];

        // --- Profile Picture ---
        if (!empty($_FILES['profile_pic']['name'])) {
            if ($_FILES['profile_pic']['size'] > $maxSize) {
                $msg = "Profile picture exceeds 5MB limit.";
            } elseif (!in_array($_FILES['profile_pic']['type'], $allowedTypes)) {
                $msg = "Invalid file type for Profile Picture.";
            } else {
                $fileName = time() . '_selfie_' . basename($_FILES['profile_pic']['name']);
                $targetPath = $uploadDir . $fileName;
                if (move_uploaded_file($_FILES['profile_pic']['tmp_name'], $targetPath)) {
                    $updates['profile_pic'] = $fileName;
                }
            }
        }

        // --- ID Document ---
        if (!empty($_FILES['id_document']['name'])) {
            if ($_FILES['id_document']['size'] > $maxSize) {
                $msg = "ID document exceeds 5MB limit.";
            } elseif (!in_array($_FILES['id_document']['type'], $allowedTypes)) {
                $msg = "Invalid file type for ID Document.";
            } else {
                $fileName = time() . '_id_' . basename($_FILES['id_document']['name']);
                $targetPath = $uploadDir . $fileName;
                if (move_uploaded_file($_FILES['id_document']['tmp_name'], $targetPath)) {
                    $updates['id_document'] = $fileName;
                }
            }
        }

        // --- License Number ---
        if (!empty($_POST['license_no'])) {
            $updates['license_no'] = trim($_POST['license_no']);
        }

        // --- Save to DB ---
        if ($updates) {
            $set = implode(', ', array_map(fn($k) => "$k=?", array_keys($updates)));
            $stmt = $pdo->prepare("UPDATE users SET $set, verified=0 WHERE user_id=?");
            $stmt->execute([...array_values($updates), $user_id]);
            if (!$msg) $msg = "Documents uploaded. Awaiting admin approval.";
        }
    }

    // Fetch owner’s docs
    $stmt = $pdo->prepare("SELECT profile_pic, id_document, license_no, verified FROM users WHERE user_id=?");
    $stmt->execute([$user_id]);
    $me = $stmt->fetch(PDO::FETCH_ASSOC);
    ?>
    
    <h1>Owner Verification</h1>
    <?php if ($msg): ?><p class="success"><?=$msg?></p><?php endif; ?>

    <form method="POST" enctype="multipart/form-data">
        <label>Profile Picture (JPG/PNG):</label>
        <input type="file" name="profile_pic" accept=".jpg,.jpeg,.png,.pdf,.doc,.docx">

        <label>ID Document (JPG/PNG/PDF/DOC):</label>
        <input type="file" name="id_document" accept=".jpg,.jpeg,.png,.pdf,.doc,.docx">

        <label>Business License Number:</label>
        <input type="text" name="license_no" value="<?=htmlspecialchars($me['license_no'] ?? '')?>">

        <button type="submit" name="upload_docs">Submit</button>
    </form>

    <h2>Current Status</h2>
    <p>
      <?php if ($me['verified']==1): ?>
        <span class="badge success">Verified</span>
      <?php elseif ($me['verified']==-1): ?>
        <span class="badge error">Rejected</span>
      <?php else: ?>
        <span class="badge warning">Pending</span>
      <?php endif; ?>
    </p>

    <?php
    
} elseif ($role === 'admin') {
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $owner_id = intval($_POST['user_id']);
        $action = $_POST['action'];

        if ($action === 'approve') {
            // Approve owner account
            $pdo->prepare("UPDATE users SET verified = 1 WHERE user_id = ? AND role = 'owner'")
                ->execute([$owner_id]);

            // Also approve all dorms owned by this user
            $pdo->prepare("UPDATE dormitories SET verified = 1 WHERE owner_id = ?")
                ->execute([$owner_id]);

        } elseif ($action === 'reject') {
            // Reject owner account
            $pdo->prepare("UPDATE users SET verified = -1 WHERE user_id = ? AND role = 'owner'")
                ->execute([$owner_id]);

            // Also mark dorms as rejected
            $pdo->prepare("UPDATE dormitories SET verified = -1 WHERE owner_id = ?")
                ->execute([$owner_id]);
        }
    }

    $status = $_GET['status'] ?? 'pending';
    switch ($status) {
        case 'verified':
            $owners = $pdo->query("SELECT * FROM users WHERE role='owner' AND verified=1")->fetchAll();
            break;
        case 'rejected':
            $owners = $pdo->query("SELECT * FROM users WHERE role='owner' AND verified=-1")->fetchAll();
            break;
        default:
            $owners = $pdo->query("SELECT * FROM users WHERE role='owner' AND verified=0")->fetchAll();
            break;
    }
    ?>

    <h1>Dorm Owner Verification</h1>
    <div class="filter-actions">
        <a href="?status=pending" class="btn <?=$status==='pending'?'active':''?>">Pending</a>
        <a href="?status=verified" class="btn <?=$status==='verified'?'active':''?>">Verified</a>
        <a href="?status=rejected" class="btn <?=$status==='rejected'?'active':''?>">Rejected</a>
    </div>

    <table class="data-table">
      <thead>
        <tr>
          <th>ID</th><th>Name</th><th>Email</th>
          <th>Phone</th><th>License</th>
          <th>Selfie</th><th>ID Document</th>
          <th>Status</th><th>Actions</th>
        </tr>
      </thead>
      <tbody>
        <?php foreach ($owners as $o): ?>
        <tr>
          <td><?=$o['user_id']?></td>
          <td><?=htmlspecialchars($o['name'])?></td>
          <td><?=htmlspecialchars($o['email'])?></td>
          <td><?=htmlspecialchars($o['phone'] ?? 'N/A')?></td>
          <td><?=htmlspecialchars($o['license_no'] ?? 'N/A')?></td>
          <td>
            <?php if ($o['profile_pic']): ?>
              <img src="../uploads/<?=htmlspecialchars($o['profile_pic'])?>" 
                   alt="Selfie" class="thumb" onclick="openModal('../uploads/<?=htmlspecialchars($o['profile_pic'])?>')">
            <?php else: ?><em>No selfie</em><?php endif; ?>
          </td>
          <td>
            <?php if ($o['id_document']): ?>
              <img src="../uploads/<?=htmlspecialchars($o['id_document'])?>" 
                   alt="ID" class="thumb" onclick="openModal('../uploads/<?=htmlspecialchars($o['id_document'])?>')">
            <?php else: ?><em>No ID</em><?php endif; ?>
          </td>
          <td>
            <?php if ($o['verified']==1): ?>
              <span class="badge success">Verified</span>
            <?php elseif ($o['verified']==-1): ?>
              <span class="badge error">Rejected</span>
            <?php else: ?>
              <span class="badge warning">Pending</span>
            <?php endif; ?>
          </td>
          <td>
            <?php if ($o['verified']==0): ?>
              <form method="post" style="display:inline">
                <input type="hidden" name="user_id" value="<?=$o['user_id']?>">
                <button class="btn-primary" name="action" value="approve">Approve</button>
                <button class="btn-secondary" name="action" value="reject">Reject</button>
              </form>
            <?php else: ?>
              <em>No actions</em>
            <?php endif; ?>
          </td>
        </tr>
        <?php endforeach; ?>
      </tbody>
    </table>

    <div id="imgModal" class="modal" style="display:none;">
      <span class="close" onclick="closeModal()">&times;</span>
      <img class="modal-content" id="imgPreview">
    </div>

    <style>
    .thumb { width:60px; height:60px; object-fit:cover; border-radius:6px; cursor:pointer; border:1px solid #ccc; }
    .modal { position:fixed; top:0; left:0; right:0; bottom:0; background:rgba(0,0,0,0.8); display:flex; align-items:center; justify-content:center; z-index:10000; }
    .modal-content { max-width:90%; max-height:90%; border-radius:10px; }
    .close { position:absolute; top:20px; right:40px; font-size:40px; color:#fff; cursor:pointer; }
    </style>
    <script>
    function openModal(src) {
      document.getElementById('imgPreview').src = src;
      document.getElementById('imgModal').style.display = 'flex';
    }
    function closeModal() {
      document.getElementById('imgModal').style.display = 'none';
    }
    </script>

    <?php
} else {
    echo "<p>Access denied</p>";
}

require_once __DIR__ . '/../partials/footer.php'; 
?>
