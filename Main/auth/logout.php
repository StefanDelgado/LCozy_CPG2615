<?php
require_once __DIR__ . '/../config.php';
session_destroy();
header('Location: /public/index.html');
exit;