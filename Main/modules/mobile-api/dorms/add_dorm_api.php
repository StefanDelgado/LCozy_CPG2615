<?php
require_once __DIR__ . '/../../../config.php';
require_once __DIR__ . '/../shared/cors.php';
require_once __DIR__ . '/../shared/geocoding_helper.php';

header('Content-Type: application/json');

try {
    // Handle both JSON and POST data
    $data = $_POST;
    if (empty($data)) {
        $json = file_get_contents('php://input');
        $data = json_decode($json, true);
    }

    if (!isset($data['owner_email'])) {
        echo json_encode([
            'success' => false,
            'error' => 'Owner email required',
            'message' => 'Owner email is required'
        ]);
        exit;
    }

    // Get owner ID
    $stmt = $pdo->prepare("SELECT user_id FROM users WHERE email = ? AND role = 'owner'");
    $stmt->execute([$data['owner_email']]);
    $owner = $stmt->fetch();

    if (!$owner) {
        echo json_encode([
            'success' => false,
            'error' => 'Owner not found',
            'message' => 'Owner account not found'
        ]);
        exit;
    }

    // Get coordinates from address if not provided
    $latitude = $data['latitude'] ?? null;
    $longitude = $data['longitude'] ?? null;
    
    // Auto-geocode if coordinates not provided but address exists
    if (empty($latitude) && empty($longitude) && !empty($data['address'])) {
        error_log("Auto-geocoding address: " . $data['address']);
        $geocoded = basicGeocodePhilippines($data['address']);
        
        if ($geocoded) {
            $latitude = $geocoded['latitude'];
            $longitude = $geocoded['longitude'];
            error_log("Geocoded to: $latitude, $longitude");
        } else {
            error_log("Geocoding failed, dorm will be saved without coordinates");
        }
    }

    // Insert new dorm with latitude/longitude and deposit fields
    $stmt = $pdo->prepare("
        INSERT INTO dormitories (
            owner_id, name, address, description, 
            features, latitude, longitude, verified, 
            deposit_required, deposit_months, created_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, 0, ?, ?, NOW())
    ");
    
    $deposit_required = isset($data['deposit_required']) ? (int)$data['deposit_required'] : 0;
    $deposit_months = isset($data['deposit_months']) ? (int)$data['deposit_months'] : 1;
    
    $stmt->execute([
        $owner['user_id'],
        $data['name'],
        $data['address'],
        $data['description'],
        $data['features'] ?? '',
        $latitude,
        $longitude,
        $deposit_required,
        $deposit_months
    ]);

    echo json_encode([
        'success' => true,
        'message' => 'Dorm added successfully',
        'dorm_id' => $pdo->lastInsertId(),
        'geocoded' => !empty($latitude) && !empty($longitude)
    ]);

} catch (Exception $e) {
    error_log('Add dorm API error: ' . $e->getMessage());
    echo json_encode([
        'success' => false,
        'error' => 'Server error',
        'message' => 'An error occurred while adding the dorm'
    ]);
}