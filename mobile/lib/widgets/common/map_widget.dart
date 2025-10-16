import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Reusable Google Maps widget component.
/// 
/// Provides a configurable map with support for:
/// - Custom markers
/// - Initial camera position
/// - Marker tap callbacks
/// - Map tap callbacks
/// - Current location display
/// - Map controller access
/// 
/// Usage:
/// ```dart
/// MapWidget(
///   initialPosition: LatLng(14.5995, 120.9842),
///   markers: myMarkers,
///   onMarkerTap: (markerId) {
///     print('Tapped marker: $markerId');
///   },
/// )
/// ```
class MapWidget extends StatefulWidget {
  /// Initial camera position for the map
  final LatLng initialPosition;
  
  /// Initial zoom level (1-20)
  final double initialZoom;
  
  /// Set of markers to display on the map
  final Set<Marker> markers;
  
  /// Whether to show the current location button
  final bool showCurrentLocationButton;
  
  /// Whether to show zoom controls
  final bool showZoomControls;
  
  /// Whether to show the map toolbar (directions, etc.)
  final bool showMapToolbar;
  
  /// Callback when a marker is tapped
  final Function(String markerId)? onMarkerTap;
  
  /// Callback when the map is tapped
  final Function(LatLng position)? onMapTap;
  
  /// Callback when the map is long-pressed
  final Function(LatLng position)? onMapLongPress;
  
  /// Callback when camera position changes
  final Function(CameraPosition position)? onCameraMove;
  
  /// Callback to get the map controller after map is created
  final Function(GoogleMapController controller)? onMapCreated;
  
  /// Map type (normal, satellite, terrain, hybrid)
  final MapType mapType;
  
  /// Whether map gestures are enabled
  final bool gesturesEnabled;

  const MapWidget({
    super.key,
    required this.initialPosition,
    this.initialZoom = 14.0,
    this.markers = const {},
    this.showCurrentLocationButton = true,
    this.showZoomControls = true,
    this.showMapToolbar = false,
    this.onMarkerTap,
    this.onMapTap,
    this.onMapLongPress,
    this.onCameraMove,
    this.onMapCreated,
    this.mapType = MapType.normal,
    this.gesturesEnabled = true,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    widget.onMapCreated?.call(controller);
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: widget.initialPosition,
        zoom: widget.initialZoom,
      ),
      markers: widget.markers,
      mapType: widget.mapType,
      myLocationEnabled: widget.showCurrentLocationButton,
      myLocationButtonEnabled: widget.showCurrentLocationButton,
      zoomControlsEnabled: widget.showZoomControls,
      mapToolbarEnabled: widget.showMapToolbar,
      compassEnabled: true,
      rotateGesturesEnabled: widget.gesturesEnabled,
      scrollGesturesEnabled: widget.gesturesEnabled,
      tiltGesturesEnabled: widget.gesturesEnabled,
      zoomGesturesEnabled: widget.gesturesEnabled,
      onMapCreated: _onMapCreated,
      onTap: widget.onMapTap,
      onLongPress: widget.onMapLongPress,
      onCameraMove: widget.onCameraMove,
    );
  }
}
