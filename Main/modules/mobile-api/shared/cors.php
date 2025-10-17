<?php
// Enable JSON output and CORS access
header('Content-Type: application/json; charset=utf-8');

// Allow any domain (for testing); later restrict to your Flutter web origin
header('Access-Control-Allow-Origin: *');

// Allow the methods your API uses
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');

// Allow all headers your app might send
header('Access-Control-Allow-Headers: Content-Type, Accept, X-Requested-With');

// Handle preflight OPTIONS requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
  http_response_code(204);
  exit;
}
