import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../services/location_service.dart';
import '../../../utils/map_helpers.dart';

/// Location tab showing dorm location on map with distance and directions.
/// 
/// Features:
/// - Display dorm location on static/interactive map
/// - Show distance from user's current location
/// - "Get Directions" button to open Google Maps
/// - Formatted address display
/// - Loading and error states for location
class LocationTab extends StatefulWidget {
  final Map<String, dynamic> dorm;

  const LocationTab({
    super.key,
    required this.dorm,
  });

  @override
  State<LocationTab> createState() => _LocationTabState();
}

class _LocationTabState extends State<LocationTab> {
  final LocationService _locationService = LocationService();
  GoogleMapController? _mapController;
  
  bool _isLoadingLocation = false;
  String? _locationError;
  double? _distanceInKm;

  @override
  void initState() {
    super.initState();
    _calculateDistance();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  /// Calculate distance from user location to dorm
  Future<void> _calculateDistance() async {
    final dormLat = double.tryParse(widget.dorm['latitude']?.toString() ?? '');
    final dormLng = double.tryParse(widget.dorm['longitude']?.toString() ?? '');

    if (dormLat == null || dormLng == null) {
      return;
    }

    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      final userPosition = await _locationService.getCurrentLocation();
      final userLatLng = LatLng(userPosition.latitude, userPosition.longitude);
      final dormLatLng = LatLng(dormLat, dormLng);
      
      final distance = _locationService.calculateDistance(
        userLatLng,
        dormLatLng,
      );

      setState(() {
        _distanceInKm = distance;
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _locationError = 'Could not get your location';
        _isLoadingLocation = false;
      });
    }
  }

  /// Open Google Maps for directions
  Future<void> _openDirections() async {
    final dormLat = double.tryParse(widget.dorm['latitude']?.toString() ?? '');
    final dormLng = double.tryParse(widget.dorm['longitude']?.toString() ?? '');

    if (dormLat == null || dormLng == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dorm location not available')),
        );
      }
      return;
    }

    final dormLocation = LatLng(dormLat, dormLng);
    final dormName = widget.dorm['name']?.toString() ?? 'Dorm';

    try {
      await MapHelpers.openGoogleMapsDirections(
        dormLocation,
        destinationLabel: dormName,
      );
    } catch (e) {
      // Fallback: just open the dorm location
      await MapHelpers.openGoogleMapsLocation(dormLocation, label: dormName);
    }
  }

  /// Open dorm location in Google Maps
  Future<void> _openLocation() async {
    final dormLat = double.tryParse(widget.dorm['latitude']?.toString() ?? '');
    final dormLng = double.tryParse(widget.dorm['longitude']?.toString() ?? '');

    if (dormLat == null || dormLng == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dorm location not available')),
        );
      }
      return;
    }

    final dormLocation = LatLng(dormLat, dormLng);
    final dormName = widget.dorm['name']?.toString() ?? 'Dorm';

    await MapHelpers.openGoogleMapsLocation(dormLocation, label: dormName);
  }

  @override
  Widget build(BuildContext context) {
    final dormLat = double.tryParse(widget.dorm['latitude']?.toString() ?? '');
    final dormLng = double.tryParse(widget.dorm['longitude']?.toString() ?? '');
    final address = widget.dorm['address']?.toString() ?? 'Address not available';
    final dormName = widget.dorm['name']?.toString() ?? 'Dorm';

    // Check if coordinates are valid
    if (dormLat == null || dormLng == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_off,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'Location Not Available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                address,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final dormLocation = LatLng(dormLat, dormLng);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Map
          SizedBox(
            height: 300,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: dormLocation,
                zoom: 15.0,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('dorm_location'),
                  position: dormLocation,
                  icon: MapHelpers.createColoredMarker(hue: 30.0), // Orange
                  infoWindow: InfoWindow(
                    title: dormName,
                    snippet: address,
                  ),
                ),
              },
              zoomControlsEnabled: true,
              mapToolbarEnabled: false,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              compassEnabled: true,
              onMapCreated: (controller) {
                _mapController = controller;
              },
              onTap: (_) => _openLocation(),
            ),
          ),

          // Location Info Card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Address
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Color(0xFFFF9800),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Address',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                address,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Distance
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.directions_walk,
                          color: Color(0xFF8B5CF6),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Distance from you',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              _isLoadingLocation
                                  ? const Row(
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text('Calculating...'),
                                      ],
                                    )
                                  : _locationError != null
                                      ? Text(
                                          _locationError!,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.orange,
                                          ),
                                        )
                                      : _distanceInKm != null
                                          ? Text(
                                              MapHelpers.formatDistance(_distanceInKm!),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black87,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            )
                                          : const Text(
                                              'Unknown',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey,
                                              ),
                                            ),
                            ],
                          ),
                        ),
                        // Refresh button
                        if (_locationError != null)
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            color: const Color(0xFF8B5CF6),
                            onPressed: _calculateDistance,
                            tooltip: 'Retry',
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Coordinates
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.gps_fixed,
                          color: Colors.grey,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Coordinates',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${dormLat.toStringAsFixed(6)}, ${dormLng.toStringAsFixed(6)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                // Get Directions Button
                ElevatedButton.icon(
                  onPressed: _openDirections,
                  icon: const Icon(Icons.directions),
                  label: const Text('Get Directions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Open in Maps Button
                OutlinedButton.icon(
                  onPressed: _openLocation,
                  icon: const Icon(Icons.map),
                  label: const Text('Open in Google Maps'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF8B5CF6),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    minimumSize: const Size(double.infinity, 50),
                    side: const BorderSide(color: Color(0xFF8B5CF6)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
