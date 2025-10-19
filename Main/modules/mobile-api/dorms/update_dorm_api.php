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

    // Validate required fields
    if (!isset($data['dorm_id'])) {
        echo json_encode([
            'success' => false,
            'error' => 'Dorm ID required',
            'message' => 'Dorm ID is required'
        ]);
        exit;
    }

    // Prepare update query
    $updateFields = [];
    $params = [];
    
    // Auto-geocode if address is being updated but no coordinates provided
    $shouldGeocode = false;
    if (isset($data['address']) && !isset($data['latitude']) && !isset($data['longitude'])) {
        $shouldGeocode = true;
    }

    // Check which fields to update
    if (isset($data['name'])) {
        $updateFields[] = 'name = ?';
        $params[] = $data['name'];
    }

    if (isset($data['address'])) {
        $updateFields[] = 'address = ?';
        $params[] = $data['address'];
        
        // Try to geocode the new address
        if ($shouldGeocode) {
            error_log("Auto-geocoding updated address: " . $data['address']);
            $geocoded = basicGeocodePhilippines($data['address']);
            
            if ($geocoded) {
                $data['latitude'] = $geocoded['latitude'];
                $data['longitude'] = $geocoded['longitude'];
                error_log("Geocoded to: {$data['latitude']}, {$data['longitude']}");
            }
        }
    }

    if (isset($data['description'])) {
        $updateFields[] = 'description = ?';
        $params[] = $data['description'];
    }

    if (isset($data['features'])) {
        $updateFields[] = 'features = ?';
        $params[] = $data['features'];
    }

    if (isset($data['latitude'])) {
        $updateFields[] = 'latitude = ?';
        $params[] = $data['latitude'];
    }

    if (isset($data['longitude'])) {
        $updateFields[] = 'longitude = ?';
        $params[] = $data['longitude'];
    }

    // Always update the updated_at timestamp
    $updateFields[] = 'updated_at = NOW()';

    if (empty($updateFields)) {
        echo json_encode([
            'success' => false,
            'error' => 'No fields to update',
            'message' => 'No fields provided for update'
        ]);
        exit;
    }

    // Add dorm_id to params for WHERE clause
    $params[] = $data['dorm_id'];

    // Build and execute update query
    $sql = "UPDATE dormitories SET " . implode(', ', $updateFields) . " WHERE dorm_id = ?";
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);

    if ($stmt->rowCount() > 0) {
        echo json_encode([
            'success' => true,
            'message' => 'Dorm updated successfully'
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'error' => 'No changes made',
            'message' => 'No changes were made to the dorm'
        ]);
    }

} catch (Exception $e) {
    error_log('Update dorm API error: ' . $e->getMessage());
    echo json_encode([
        'success' => false,
        'error' => 'Server error',
        'message' => 'An error occurred while updating the dorm'
    ]);
}
