<?php
echo "<h1>Path Diagnostic</h1>";
echo "<p><strong>__FILE__:</strong> " . __FILE__ . "</p>";
echo "<p><strong>__DIR__:</strong> " . __DIR__ . "</p>";
echo "<p><strong>Current Working Directory:</strong> " . getcwd() . "</p>";

echo "<h2>Checking File Paths</h2>";

$paths_to_check = [
    '__DIR__ . "/../auth/auth.php"' => __DIR__ . '/../auth/auth.php',
    '__DIR__ . "/../../auth/auth.php"' => __DIR__ . '/../../auth/auth.php',
    '__DIR__ . "/../config.php"' => __DIR__ . '/../config.php',
    '__DIR__ . "/../../config.php"' => __DIR__ . '/../../config.php',
    '__DIR__ . "/../partials/header.php"' => __DIR__ . '/../partials/header.php',
    '__DIR__ . "/../../partials/header.php"' => __DIR__ . '/../../partials/header.php',
];

foreach ($paths_to_check as $label => $path) {
    $exists = file_exists($path);
    $realpath = realpath($path);
    $color = $exists ? 'green' : 'red';
    $status = $exists ? '✅ EXISTS' : '❌ NOT FOUND';
    
    echo "<div style='margin: 10px 0; padding: 10px; background: #f5f5f5; border-left: 4px solid $color;'>";
    echo "<strong>$label</strong><br>";
    echo "<span style='color: $color;'>$status</span><br>";
    if ($realpath) {
        echo "<small>Real path: $realpath</small>";
    }
    echo "</div>";
}

echo "<h2>Directory Contents</h2>";
echo "<h3>Parent Directory (../)</h3>";
$parent = __DIR__ . '/..';
if (is_dir($parent)) {
    $files = scandir($parent);
    echo "<pre>" . print_r($files, true) . "</pre>";
}

echo "<h3>Grandparent Directory (../../)</h3>";
$grandparent = __DIR__ . '/../..';
if (is_dir($grandparent)) {
    $files = scandir($grandparent);
    echo "<pre>" . print_r($files, true) . "</pre>";
}
?>
