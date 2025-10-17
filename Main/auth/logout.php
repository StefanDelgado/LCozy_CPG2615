<?php
require_once __DIR__ . '/../config.php';
session_destroy();
header('Location: /public/anchorpage.php');
exit;