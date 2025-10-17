<!DOCTYPE html>
<html>
<head>
    <title>CSS Diagnostic</title>
</head>
<body>
    <h1>CSS File Diagnostic</h1>
    
    <h2>1. Check if CSS files exist:</h2>
    <p>style.css exists: <?= file_exists(__DIR__ . '/../../assets/style.css') ? '✅ YES' : '❌ NO' ?></p>
    <p>modules.css exists: <?= file_exists(__DIR__ . '/../../assets/modules.css') ? '✅ YES' : '❌ NO' ?></p>
    
    <h2>2. CSS File Paths:</h2>
    <p>Expected style.css path: <?= __DIR__ . '/../../assets/style.css' ?></p>
    <p>Actual path: <?= realpath(__DIR__ . '/../../assets/style.css') ?: 'FILE NOT FOUND' ?></p>
    
    <h2>3. First 500 characters of style.css:</h2>
    <pre style="background: #f4f4f4; padding: 15px; overflow-x: auto;"><?php
    $cssPath = __DIR__ . '/../../assets/style.css';
    if (file_exists($cssPath)) {
        echo htmlspecialchars(substr(file_get_contents($cssPath), 0, 500));
    } else {
        echo "FILE NOT FOUND!";
    }
    ?></pre>
    
    <h2>4. Test if CSS loads in browser:</h2>
    <p>Open browser console and check for 404 errors on:</p>
    <ul>
        <li><a href="../assets/style.css" target="_blank">../assets/style.css</a></li>
        <li><a href="../assets/modules.css" target="_blank">../assets/modules.css</a></li>
    </ul>
    
    <h2>5. CSS Load Test:</h2>
    <link rel="stylesheet" href="../assets/style.css">
    <div class="sidebar" style="position: relative; width: 200px; padding: 10px; margin: 20px 0;">
        <div class="brand">TEST BRAND</div>
        <nav>
            <a href="#">Link 1</a>
            <a href="#">Link 2</a>
        </nav>
    </div>
    <p>If the box above has purple background and styled links, CSS is loading!</p>
    
    <h2>6. Upload/Sync Info:</h2>
    <p><strong>IMPORTANT:</strong> After making changes locally, you need to:</p>
    <ol>
        <li>Save all files</li>
        <li>Upload to GoDaddy server (if using FTP/cPanel File Manager)</li>
        <li>Clear browser cache (Ctrl+F5)</li>
        <li>Check file permissions on server (should be 644 for files)</li>
    </ol>
</body>
</html>
