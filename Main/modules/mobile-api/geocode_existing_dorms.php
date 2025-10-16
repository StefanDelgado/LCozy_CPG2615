<?php
/**
 * Script to auto-geocode existing dorms that have addresses but no coordinates
 * Run this once to update all old dorms
 */

require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/geocoding_helper.php';

header('Content-Type: application/json');

try {
    // Find dorms without coordinates but with addresses
    $stmt = $pdo->prepare("
        SELECT dorm_id, name, address 
        FROM dormitories 
        WHERE (latitude IS NULL OR longitude IS NULL OR latitude = 0 OR longitude = 0)
        AND address IS NOT NULL 
        AND address != ''
    ");
    
    $stmt->execute();
    $dorms = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    $results = [
        'total_found' => count($dorms),
        'geocoded' => 0,
        'failed' => 0,
        'details' => []
    ];
    
    foreach ($dorms as $dorm) {
        $geocoded = basicGeocodePhilippines($dorm['address']);
        
        if ($geocoded) {
            // Update the dorm with coordinates
            $updateStmt = $pdo->prepare("
                UPDATE dormitories 
                SET latitude = ?, longitude = ?, updated_at = NOW()
                WHERE dorm_id = ?
            ");
            
            $updateStmt->execute([
                $geocoded['latitude'],
                $geocoded['longitude'],
                $dorm['dorm_id']
            ]);
            
            $results['geocoded']++;
            $results['details'][] = [
                'dorm_id' => $dorm['dorm_id'],
                'name' => $dorm['name'],
                'address' => $dorm['address'],
                'latitude' => $geocoded['latitude'],
                'longitude' => $geocoded['longitude'],
                'status' => 'success'
            ];
            
        } else {
            $results['failed']++;
            $results['details'][] = [
                'dorm_id' => $dorm['dorm_id'],
                'name' => $dorm['name'],
                'address' => $dorm['address'],
                'status' => 'failed',
                'reason' => 'Could not geocode address'
            ];
        }
    }
    
    echo json_encode([
        'success' => true,
        'message' => "Geocoded {$results['geocoded']} out of {$results['total_found']} dorms",
        'results' => $results
    ], JSON_PRETTY_PRINT);
    
} catch (Exception $e) {
    error_log('Geocode script error: ' . $e->getMessage());
    echo json_encode([
        'success' => false,
        'error' => 'Server error',
        'message' => $e->getMessage()
    ]);
}
