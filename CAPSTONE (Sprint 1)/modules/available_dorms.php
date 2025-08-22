<?php
require_once __DIR__ . '/../auth.php';
require_role('student');
require_once __DIR__ . '/../config.php';

$page_title = "Available Dorms";
include __DIR__ . '/../partials/header.php';

$search = trim($_GET['search'] ?? '');
$address = trim($_GET['address'] ?? '');
$min_price = $_GET['min_price'] ?? '';
$max_price = $_GET['max_price'] ?? '';
$availability = $_GET['availability'] ?? '';

$sql = "
    SELECT d.dorm_id, d.name AS dorm_name, d.address, d.description,
           u.name AS owner_name
    FROM dormitories d
    JOIN users u ON d.owner_id = u.user_id
    WHERE 1=1
";
$params = [];

if ($search) {
    $sql .= " AND (d.name LIKE ? OR d.address LIKE ?)";
    $params[] = "%$search%";
    $params[] = "%$search%";
}

if ($min_price !== '') {
    $sql .= " AND EXISTS (
        SELECT 1 FROM rooms r 
        WHERE r.dorm_id = d.dorm_id AND r.price >= ?
    )";
    $params[] = $min_price;
}

if ($max_price !== '') {
    $sql .= " AND EXISTS (
        SELECT 1 FROM rooms r 
        WHERE r.dorm_id = d.dorm_id AND r.price <= ?
    )";
    $params[] = $max_price;
}

if ($availability !== '') {
    $sql .= " AND EXISTS (
        SELECT 1 FROM rooms r 
        WHERE r.dorm_id = d.dorm_id AND r.availability = ?
    )";
    $params[] = $availability;
}

$stmt = $pdo->prepare($sql);
$stmt->execute($params);
$dorms = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

<div class="page-header">
  <h1>Available Dorms</h1>
  <p>Browse and filter dormitories with available rooms</p>
</div>

<div class="form-area">
  <form method="get" class="grid-4">
    <input type="text" name="search" placeholder="Search dorm name or address..." value="<?=htmlspecialchars($search)?>">
    <input type="text" name="location" placeholder="Address..." value="<?=htmlspecialchars($address)?>">
    <input type="number" step="0.01" name="min_price" placeholder="Min Price" value="<?=htmlspecialchars($min_price)?>">
    <input type="number" step="0.01" name="max_price" placeholder="Max Price" value="<?=htmlspecialchars($max_price)?>">
    <select name="availability">
      <option value="">Any Availability</option>
      <option value="1" <?= $availability==='1'?'selected':'' ?>>Available</option>
      <option value="0" <?= $availability==='0'?'selected':'' ?>>Unavailable</option>
    </select>
    <button type="submit" class="btn">Filter</button>
  </form>
</div>

<div class="grid-2">
<?php foreach ($dorms as $dorm): ?>
  <div class="card">
    <h2><?=htmlspecialchars($dorm['dorm_name'])?></h2>
    <p><strong>Address:</strong> <?=htmlspecialchars($dorm['address'])?></p>
    <p><strong>Owner:</strong> <?=htmlspecialchars($dorm['owner_name'])?></p>
    <p><?=nl2br(htmlspecialchars($dorm['description']))?></p>

    <h3>Rooms</h3>
    <table>
      <thead>
        <tr>
          <th>Room Name</th>
          <th>Capacity</th>
          <th>Price (₱)</th>
          <th>Status</th>
        </tr>
      </thead>
      <tbody>
        <?php
        $room_sql = "SELECT * FROM rooms WHERE dorm_id = ?";
        $room_params = [$dorm['dorm_id']];

        if ($min_price !== '') {
            $room_sql .= " AND price >= ?";
            $room_params[] = $min_price;
        }
        if ($max_price !== '') {
            $room_sql .= " AND price <= ?";
            $room_params[] = $max_price;
        }
        if ($availability !== '') {
            $room_sql .= " AND availability = ?";
            $room_params[] = $availability;
        }

        $rooms = $pdo->prepare($room_sql);
        $rooms->execute($room_params);
        $rooms = $rooms->fetchAll(PDO::FETCH_ASSOC);
        ?>
        <?php if ($rooms): ?>
          <?php foreach ($rooms as $room): ?>
          <tr>
            <td><?=htmlspecialchars($room['room_name'])?></td>
            <td><?=htmlspecialchars($room['capacity'])?></td>
            <td><?=number_format($room['price'], 2)?></td>
            <td>
              <?php if ($room['availability']): ?>
                <span class="badge success">Available</span>
              <?php else: ?>
                <span class="badge error">Unavailable</span>
              <?php endif; ?>
            </td>
          </tr>
          <?php endforeach; ?>
        <?php else: ?>
          <tr><td colspan="4"><em>No rooms match your filters</em></td></tr>
        <?php endif; ?>
      </tbody>
    </table>
  </div>
<?php endforeach; ?>
</div>

<?php include __DIR__ . '/../partials/footer.php'; ?>