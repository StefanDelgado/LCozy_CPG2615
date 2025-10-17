<?php
/**
 * Geocoding helper for converting addresses to coordinates
 * Uses Google Geocoding API
 */

/**
 * Get coordinates (latitude, longitude) from an address
 * 
 * @param string $address The address to geocode
 * @return array|null ['latitude' => float, 'longitude' => float] or null if failed
 */
function geocodeAddress($address) {
    // Google Maps API key - Replace with your actual key
    $apiKey = 'YOUR_GOOGLE_MAPS_API_KEY'; // TODO: Add your API key in config
    
    // For now, use a basic geocoding approach
    // In production, you should use Google Geocoding API with proper API key
    
    // Clean and prepare address
    $cleanAddress = trim($address);
    
    if (empty($cleanAddress)) {
        return null;
    }
    
    // Try Google Geocoding API
    $url = 'https://maps.googleapis.com/maps/api/geocode/json?' . http_build_query([
        'address' => $cleanAddress . ', Philippines', // Add country for better results
        'key' => $apiKey,
    ]);
    
    try {
        $response = @file_get_contents($url);
        
        if ($response === false) {
            error_log("Geocoding failed for address: $cleanAddress");
            return null;
        }
        
        $data = json_decode($response, true);
        
        if ($data['status'] === 'OK' && !empty($data['results'])) {
            $location = $data['results'][0]['geometry']['location'];
            return [
                'latitude' => $location['lat'],
                'longitude' => $location['lng']
            ];
        }
        
        error_log("Geocoding returned status: " . $data['status']);
        return null;
        
    } catch (Exception $e) {
        error_log("Geocoding exception: " . $e->getMessage());
        return null;
    }
}

/**
 * Basic geocoding fallback using known Philippines cities
 * This is a backup when Google API is not available
 * 
 * @param string $address
 * @return array|null
 */
function basicGeocodePhilippines($address) {
    $address = strtolower($address);
    
    // Common Philippines locations with approximate coordinates
    $knownLocations = [
        'bacolod' => ['latitude' => 10.6917, 'longitude' => 122.9746],
        'bacolod city' => ['latitude' => 10.6917, 'longitude' => 122.9746],
        'lacson street, bacolod' => ['latitude' => 10.6765, 'longitude' => 122.9509],
        'araneta avenue, bacolod' => ['latitude' => 10.6635, 'longitude' => 122.9530],
        'burgos avenue, bacolod' => ['latitude' => 10.6762, 'longitude' => 122.9563],
        'p hernaez st' => ['latitude' => 10.6853, 'longitude' => 122.9567],
        'manila' => ['latitude' => 14.5995, 'longitude' => 120.9842],
        'quezon city' => ['latitude' => 14.6760, 'longitude' => 121.0437],
        'cebu' => ['latitude' => 10.3157, 'longitude' => 123.8854],
        'davao' => ['latitude' => 7.1907, 'longitude' => 125.4553],
    ];
    
    // Try exact match first
    foreach ($knownLocations as $location => $coords) {
        if (stripos($address, $location) !== false) {
            return $coords;
        }
    }
    
    // Default to Bacolod City center if address contains "bacolod"
    if (stripos($address, 'bacolod') !== false) {
        return ['latitude' => 10.6917, 'longitude' => 122.9746];
    }
    
    return null;
}
