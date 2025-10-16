import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' show cos, sqrt, asin, sin;

/// Service class for handling location-related operations.
/// 
/// This service provides methods for:
/// - Getting current user location
/// - Checking and requesting location permissions
/// - Calculating distances between coordinates
/// - Geocoding (address ↔ coordinates conversion)
/// - Formatting location data
class LocationService {
  /// Get the user's current location.
  /// 
  /// Returns the current [Position] with latitude, longitude, and accuracy.
  /// 
  /// Throws an exception if:
  /// - Location permissions are denied
  /// - Location services are disabled
  /// - Unable to determine location
  /// 
  /// Example:
  /// ```dart
  /// try {
  ///   final position = await locationService.getCurrentLocation();
  ///   print('Lat: ${position.latitude}, Lng: ${position.longitude}');
  /// } catch (e) {
  ///   print('Error: $e');
  /// }
  /// ```
  Future<Position> getCurrentLocation() async {
    print('🌍 [LocationService] Starting getCurrentLocation...');
    
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print('🌍 [LocationService] Location services enabled: $serviceEnabled');
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable location in settings.');
    }

    // Check permission status
    LocationPermission permission = await Geolocator.checkPermission();
    print('🌍 [LocationService] Initial permission status: $permission');
    
    if (permission == LocationPermission.denied) {
      print('🌍 [LocationService] Requesting permission...');
      permission = await Geolocator.requestPermission();
      print('🌍 [LocationService] Permission after request: $permission');
      
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied. Please grant location access.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied. Please enable in app settings.'
      );
    }

    // Get current position
    print('🌍 [LocationService] Getting current position...');
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );
      print('🌍 [LocationService] ✅ Location obtained: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('🌍 [LocationService] ❌ Error getting position: $e');
      
      // Try with lower accuracy if high accuracy failed
      if (e.toString().contains('timeout') || e.toString().contains('time')) {
        print('🌍 [LocationService] Retrying with lower accuracy...');
        try {
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 5),
          );
          print('🌍 [LocationService] ✅ Location obtained (medium accuracy): ${position.latitude}, ${position.longitude}');
          return position;
        } catch (e2) {
          print('🌍 [LocationService] ❌ Retry also failed: $e2');
          rethrow;
        }
      }
      
      rethrow;
    }
  }

  /// Check if location permissions are granted.
  /// 
  /// Returns `true` if permissions are granted, `false` otherwise.
  Future<bool> checkPermissions() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Request location permissions from the user.
  /// 
  /// Returns `true` if permissions are granted, `false` if denied.
  /// 
  /// Shows system permission dialog if not previously answered.
  Future<bool> requestPermissions() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  /// Calculate the distance between two geographic points in meters.
  /// 
  /// Uses the Haversine formula for accurate distance calculation.
  /// 
  /// Parameters:
  /// - [point1]: First location (latitude, longitude)
  /// - [point2]: Second location (latitude, longitude)
  /// 
  /// Returns distance in meters as a double.
  /// 
  /// Example:
  /// ```dart
  /// final distance = locationService.calculateDistance(
  ///   LatLng(14.5995, 120.9842),  // Manila
  ///   LatLng(14.6091, 121.0223),  // Quezon City
  /// );
  /// print('Distance: ${distance / 1000} km');
  /// ```
  double calculateDistance(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  /// Calculate distance using Haversine formula (alternative method).
  /// 
  /// More precise for short distances. Returns distance in kilometers.
  double calculateDistanceHaversine(LatLng point1, LatLng point2) {
    const double earthRadius = 6371; // Earth radius in kilometers

    final lat1 = point1.latitude * (3.141592653589793 / 180);
    final lat2 = point2.latitude * (3.141592653589793 / 180);
    final lon1 = point1.longitude * (3.141592653589793 / 180);
    final lon2 = point2.longitude * (3.141592653589793 / 180);

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    final a = (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2));

    final c = 2 * asin(sqrt(a));

    return earthRadius * c; // Returns kilometers
  }

  /// Get a human-readable address from coordinates (reverse geocoding).
  /// 
  /// Parameters:
  /// - [position]: LatLng coordinates to convert
  /// 
  /// Returns formatted address string, or coordinates if geocoding fails.
  /// 
  /// Example:
  /// ```dart
  /// final address = await locationService.getAddressFromCoordinates(
  ///   LatLng(14.5995, 120.9842),
  /// );
  /// print(address); // "Manila, Metro Manila, Philippines"
  /// ```
  Future<String> getAddressFromCoordinates(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return _formatPlacemark(place);
      }
    } catch (e) {
      print('Geocoding error: $e');
    }

    // Fallback to coordinates if geocoding fails
    return '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
  }

  /// Get coordinates from a human-readable address (geocoding).
  /// 
  /// Parameters:
  /// - [address]: Address string to convert (e.g., "Manila, Philippines")
  /// 
  /// Returns [LatLng] coordinates, or null if address not found.
  /// 
  /// Example:
  /// ```dart
  /// final coords = await locationService.getCoordinatesFromAddress(
  ///   'Quezon City, Metro Manila',
  /// );
  /// if (coords != null) {
  ///   print('Lat: ${coords.latitude}, Lng: ${coords.longitude}');
  /// }
  /// ```
  Future<LatLng?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);

      if (locations.isNotEmpty) {
        final location = locations[0];
        return LatLng(location.latitude, location.longitude);
      }
    } catch (e) {
      print('Geocoding error: $e');
    }

    return null;
  }

  /// Format a Placemark into a readable address string.
  /// 
  /// Prioritizes: street, locality, subAdministrativeArea, country
  String _formatPlacemark(Placemark place) {
    List<String> parts = [];

    if (place.street != null && place.street!.isNotEmpty) {
      parts.add(place.street!);
    }
    if (place.locality != null && place.locality!.isNotEmpty) {
      parts.add(place.locality!);
    }
    if (place.subAdministrativeArea != null &&
        place.subAdministrativeArea!.isNotEmpty) {
      parts.add(place.subAdministrativeArea!);
    }
    if (place.country != null && place.country!.isNotEmpty) {
      parts.add(place.country!);
    }

    return parts.join(', ');
  }

  /// Check if location services are enabled on the device.
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Open device location settings.
  /// 
  /// Opens the system settings page where user can enable location services.
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Get location permission status.
  /// 
  /// Returns a [LocationPermission] enum value indicating current status.
  Future<LocationPermission> getPermissionStatus() async {
    return await Geolocator.checkPermission();
  }
}
