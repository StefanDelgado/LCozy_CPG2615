<?php
// Simple test to ensure API works
header('Content-Type: application/json');

echo json_encode([
    'ok' => true,
    'message' => 'API endpoint is working',
    'timestamp' => date('Y-m-d H:i:s')
]);
