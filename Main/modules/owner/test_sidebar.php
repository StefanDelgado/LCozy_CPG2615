<?php
require_once __DIR__ . '/../../auth/auth.php';
require_role('owner');
require_once __DIR__ . '/../../config.php';

$page_title = "TEST - Sidebar Check";
include __DIR__ . '/../../partials/header.php';
?>

<div class="page-header">
    <div>
        <h1>Sidebar Test Page</h1>
        <p>If you see a sidebar on the left, the header is working correctly!</p>
    </div>
</div>

<div class="card" style="padding: 40px;">
    <h2>Testing Instructions:</h2>
    <ul style="line-height: 2;">
        <li>✅ You should see a PURPLE sidebar on the LEFT side</li>
        <li>✅ The sidebar should contain: CozyOwner, user profile, and navigation links</li>
        <li>✅ This content should be on the RIGHT side</li>
        <li>❌ You should NOT see horizontal navigation links at the top</li>
    </ul>
    
    <hr style="margin: 30px 0;">
    
    <h3>CSS Loading Test:</h3>
    <p>Check browser console for any 404 errors on CSS files.</p>
    <p>CSS files should load from: ../assets/style.css and ../assets/modules.css</p>
    
    <hr style="margin: 30px 0;">
    
    <h3>Header File Path:</h3>
    <code><?= __DIR__ . '/../../partials/header.php' ?></code>
    
    <hr style="margin: 30px 0;">
    
    <h3>Current Page Path:</h3>
    <code><?= __FILE__ ?></code>
</div>

<?php include __DIR__ . '/../../partials/footer.php'; ?>
