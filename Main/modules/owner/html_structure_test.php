<?php
require_once __DIR__ . '/../../auth/auth.php';
require_role('owner');
require_once __DIR__ . '/../../config.php';

$page_title = "HTML Structure Test";

// Start output buffering to capture the header output
ob_start();
include __DIR__ . '/../../partials/header.php';
$header_html = ob_get_clean();

// Output the header normally
echo $header_html;
?>

<div class="page-header">
    <h1>HTML Structure Validation</h1>
</div>

<div class="card" style="padding: 20px;">
    <h2>Checking Header HTML Structure:</h2>
    
    <h3>1. Count of opening tags:</h3>
    <ul>
        <li>&lt;aside&gt; tags: <?= substr_count($header_html, '<aside') ?></li>
        <li>&lt;nav&gt; tags: <?= substr_count($header_html, '<nav') ?></li>
        <li>&lt;main&gt; tags: <?= substr_count($header_html, '<main') ?></li>
    </ul>
    
    <h3>2. Count of closing tags:</h3>
    <ul>
        <li>&lt;/aside&gt; tags: <?= substr_count($header_html, '</aside') ?></li>
        <li>&lt;/nav&gt; tags: <?= substr_count($header_html, '</nav') ?></li>
    </ul>
    
    <h3>3. Check for "My Dashboard" location:</h3>
    <?php
    $pos = strpos($header_html, 'My Dashboard');
    $before_aside_close = strpos($header_html, '</aside');
    ?>
    <p>"My Dashboard" position: <?= $pos ?></p>
    <p>"&lt;/aside&gt;" position: <?= $before_aside_close ?></p>
    <p>Is "My Dashboard" BEFORE &lt;/aside&gt;? <?= ($pos < $before_aside_close) ? '✅ YES (Good!)' : '❌ NO (Problem!)' ?></p>
    
    <h3>4. Raw HTML around navigation (first 200 chars after &lt;nav&gt;):</h3>
    <pre style="background: #f4f4f4; padding: 10px; font-size: 11px; overflow-x: auto;"><?php
    $nav_pos = strpos($header_html, '<nav');
    if ($nav_pos !== false) {
        echo htmlspecialchars(substr($header_html, $nav_pos, 400));
    }
    ?></pre>
    
    <h3>5. View Page Source:</h3>
    <p>Right-click this page and select "View Page Source" to see the actual HTML structure.</p>
    <p>Look for where the navigation links appear - they should be INSIDE &lt;aside class="sidebar"&gt;</p>
</div>

<?php include __DIR__ . '/../../partials/footer.php'; ?>
