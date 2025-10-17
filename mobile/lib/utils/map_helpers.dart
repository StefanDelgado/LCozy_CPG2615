import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/services.dart';

/// Helper utilities for Google Maps functionality.
/// 
/// Provides static methods for:
/// - Creating custom map markers
/// - Formatting distances
/// - Calculating map bounds
/// - Opening external map applications
class MapHelpers {
  /// Format distance in meters to human-readable string.
  /// 
  /// - Less than 1000m: Returns "X m"
  /// - 1000m or more: Returns "X.X km"
  /// 
  /// Examples:
  /// - 0.5 → "500 m"
  /// - 1.5 → "1.5 km"
  /// - 12.3 → "12.3 km"
  static String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      final meters = (distanceInKm * 1000).toStringAsFixed(0);
      return '$meters m';
    } else {
      return '${distanceInKm.toStringAsFixed(1)} km';
    }
  }

  /// Calculate the bounding box that contains all given positions.
  /// 
  /// Useful for centering map to show all markers.
  /// 
  /// Parameters:
  /// - [positions]: List of LatLng coordinates to bound
  /// 
  /// Returns [LatLngBounds] that encompasses all positions.
  /// 
  /// Throws exception if positions list is empty.
  /// 
  /// Example:
  /// ```dart
  /// final bounds = MapHelpers.calculateBounds(dormLocations);
  /// mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  /// ```
  static LatLngBounds calculateBounds(List<LatLng> positions) {
    if (positions.isEmpty) {
      throw Exception('Cannot calculate bounds for empty position list');
    }

    if (positions.length == 1) {
      // For single position, create small bounds around it
      final pos = positions[0];
      return LatLngBounds(
        southwest: LatLng(pos.latitude - 0.01, pos.longitude - 0.01),
        northeast: LatLng(pos.latitude + 0.01, pos.longitude + 0.01),
      );
    }

    double minLat = positions[0].latitude;
    double maxLat = positions[0].latitude;
    double minLng = positions[0].longitude;
    double maxLng = positions[0].longitude;

    for (final position in positions) {
      if (position.latitude < minLat) minLat = position.latitude;
      if (position.latitude > maxLat) maxLat = position.latitude;
      if (position.longitude < minLng) minLng = position.longitude;
      if (position.longitude > maxLng) maxLng = position.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  /// Create a custom marker icon from an asset image.
  /// 
  /// Parameters:
  /// - [assetPath]: Path to the asset image (e.g., 'assets/images/marker.png')
  /// - [width]: Desired width in pixels (optional, default 100)
  /// 
  /// Returns [BitmapDescriptor] for use in Marker objects.
  /// 
  /// Note: Asset must be declared in pubspec.yaml
  /// 
  /// Example:
  /// ```dart
  /// final icon = await MapHelpers.createCustomMarkerFromAsset(
  ///   'assets/images/dorm_marker.png',
  ///   width: 80,
  /// );
  /// final marker = Marker(
  ///   markerId: MarkerId('dorm1'),
  ///   position: LatLng(14.5995, 120.9842),
  ///   icon: icon,
  /// );
  /// ```
  static Future<BitmapDescriptor> createCustomMarkerFromAsset(
    String assetPath, {
    int width = 100,
  }) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final ui.Codec codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
        targetWidth: width,
      );
      final ui.FrameInfo fi = await codec.getNextFrame();
      final ByteData? byteData = await fi.image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData != null) {
        return BitmapDescriptor.fromBytes(byteData.buffer.asUint8List());
      }
    } catch (e) {
      // Fallback to default marker if custom marker fails
      return BitmapDescriptor.defaultMarkerWithHue(270.0);
    }

    return BitmapDescriptor.defaultMarkerWithHue(270.0);
  }

  /// Create a default custom marker with specified color.
  /// 
  /// Parameters:
  /// - [hue]: Hue value (0-360). Common values:
  ///   - 0: Red
  ///   - 270: Purple (default for CozyDorm)
  ///   - 120: Green
  ///   - 240: Blue
  /// 
  /// Returns [BitmapDescriptor] for use in Marker objects.
  static BitmapDescriptor createColoredMarker({double hue = 270.0}) {
    return BitmapDescriptor.defaultMarkerWithHue(hue);
  }

  /// Open Google Maps with directions to a destination.
  /// 
  /// Opens the native Google Maps app (or web) with directions from
  /// user's current location to the specified destination.
  /// 
  /// Parameters:
  /// - [destination]: Target location coordinates
  /// - [destinationLabel]: Optional label for destination (e.g., "CozyDorm Manila")
  /// 
  /// Returns `true` if Maps was opened successfully, `false` otherwise.
  /// 
  /// Example:
  /// ```dart
  /// final opened = await MapHelpers.openGoogleMapsDirections(
  ///   LatLng(14.5995, 120.9842),
  ///   destinationLabel: 'CozyDorm Manila Branch',
  /// );
  /// if (!opened) {
  ///   // Show error message
  /// }
  /// ```
  static Future<bool> openGoogleMapsDirections(
    LatLng destination, {
    String? destinationLabel,
  }) async {
    final lat = destination.latitude;
    final lng = destination.longitude;
    final label = destinationLabel ?? 'Destination';

    // Try different URL schemes for better compatibility
    final urls = [
      // Google Maps app URL (Android/iOS)
      'google.navigation:q=$lat,$lng',
      // Google Maps web URL (fallback)
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&destination_place_id=$label',
      // Generic geo URL (last resort)
      'geo:$lat,$lng?q=$lat,$lng($label)',
    ];

    for (final urlString in urls) {
      final uri = Uri.parse(urlString);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
    }

    return false;
  }

  /// Open Google Maps showing a specific location.
  /// 
  /// Opens Google Maps centered on the specified location without directions.
  /// 
  /// Parameters:
  /// - [location]: Location coordinates to show
  /// - [label]: Optional label for the location
  /// - [zoom]: Zoom level (1-20, default 15)
  /// 
  /// Returns `true` if Maps was opened successfully, `false` otherwise.
  static Future<bool> openGoogleMapsLocation(
    LatLng location, {
    String? label,
    int zoom = 15,
  }) async {
    final lat = location.latitude;
    final lng = location.longitude;
    final markerLabel = label ?? 'Location';

    final urlString = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng&query_place_id=$markerLabel&zoom=$zoom';

    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return true;
    }

    return false;
  }

  /// Get the center point of multiple locations.
  /// 
  /// Calculates the geographic center (centroid) of given positions.
  /// 
  /// Parameters:
  /// - [positions]: List of LatLng coordinates
  /// 
  /// Returns [LatLng] representing the center point.
  /// 
  /// Throws exception if positions list is empty.
  static LatLng getCenterPoint(List<LatLng> positions) {
    if (positions.isEmpty) {
      throw Exception('Cannot calculate center of empty position list');
    }

    if (positions.length == 1) {
      return positions[0];
    }

    double totalLat = 0;
    double totalLng = 0;

    for (final position in positions) {
      totalLat += position.latitude;
      totalLng += position.longitude;
    }

    return LatLng(
      totalLat / positions.length,
      totalLng / positions.length,
    );
  }

  /// Calculate appropriate zoom level for given distance.
  /// 
  /// Suggests zoom level based on the maximum distance to show.
  /// 
  /// Parameters:
  /// - [distanceInMeters]: Maximum distance to display
  /// 
  /// Returns suggested zoom level (1-20).
  /// 
  /// Rough guide:
  /// - 20: Building level
  /// - 15: Street level
  /// - 10: City level
  /// - 5: Country level
  /// - 1: World level
  static double calculateZoomLevel(double distanceInMeters) {
    if (distanceInMeters < 100) return 18.0;
    if (distanceInMeters < 500) return 16.0;
    if (distanceInMeters < 1000) return 15.0;
    if (distanceInMeters < 5000) return 13.0;
    if (distanceInMeters < 10000) return 12.0;
    if (distanceInMeters < 50000) return 10.0;
    if (distanceInMeters < 100000) return 8.0;
    return 6.0;
  }

  /// Default map camera position for Metro Manila, Philippines.
  /// 
  /// Centered on Manila with zoom level 12.
  static const CameraPosition defaultManilaPosition = CameraPosition(
    target: LatLng(14.5995, 120.9842), // Manila coordinates
    zoom: 12.0,
  );

  /// Default map camera position for Quezon City, Philippines.
  static const CameraPosition defaultQuezonCityPosition = CameraPosition(
    target: LatLng(14.6760, 121.0437), // Quezon City coordinates
    zoom: 13.0,
  );
}
