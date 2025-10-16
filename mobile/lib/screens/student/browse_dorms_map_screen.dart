import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/dorm_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/location_service.dart';
import '../../utils/map_helpers.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_display_widget.dart';
import '../student/view_details_screen.dart';

/// Browse dorms on an interactive map.
/// 
/// Features:
/// - Display all dorms as markers
/// - Custom orange markers for dorms
/// - Tap marker to view dorm details
/// - Current location button
/// - Center map on all dorms
/// - Loading and error states
class BrowseDormsMapScreen extends StatefulWidget {
  const BrowseDormsMapScreen({super.key});

  @override
  State<BrowseDormsMapScreen> createState() => _BrowseDormsMapScreenState();
}

class _BrowseDormsMapScreenState extends State<BrowseDormsMapScreen> {
  final LocationService _locationService = LocationService();
  GoogleMapController? _mapController;
  
  bool _isLoadingLocation = false;
  String? _locationError;
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _loadDorms();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  /// Load all dorms from provider
  Future<void> _loadDorms() async {
    final dormProvider = context.read<DormProvider>();
    final authProvider = context.read<AuthProvider>();
    
    if (dormProvider.allDorms.isEmpty) {
      await dormProvider.fetchAllDorms(studentEmail: authProvider.userEmail);
    }
  }

  /// Get user's current location
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      final position = await _locationService.getCurrentLocation();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _locationError = e.toString();
        _isLoadingLocation = false;
      });
    }
  }

  /// Create markers from dorm data
  Set<Marker> _createMarkers(List<Map<String, dynamic>> dorms) {
    print('📍 [Map] Creating markers from ${dorms.length} dorms');
    
    final markers = dorms.where((dorm) {
      // Only include dorms with valid coordinates
      final lat = double.tryParse(dorm['latitude']?.toString() ?? '');
      final lng = double.tryParse(dorm['longitude']?.toString() ?? '');
      return lat != null && lng != null && lat != 0.0 && lng != 0.0;
    }).map((dorm) {
      final lat = double.parse(dorm['latitude'].toString());
      final lng = double.parse(dorm['longitude'].toString());

      print('   ✅ Creating marker for: ${dorm['title']} at ($lat, $lng)');

      return Marker(
        markerId: MarkerId(dorm['dorm_id'].toString()),
        position: LatLng(lat, lng),
        icon: MapHelpers.createColoredMarker(hue: 30.0), // Orange marker
        infoWindow: InfoWindow(
          title: dorm['title'] ?? dorm['name'] ?? 'Dorm',
          snippet: dorm['min_price']?.toString() ?? '₱0/month',
          onTap: () => _navigateToDormDetails(dorm),
        ),
        onTap: () => _onMarkerTap(dorm),
      );
    }).toSet();
    
    print('📍 [Map] Created ${markers.length} markers');
    return markers;
  }

  /// Handle marker tap
  void _onMarkerTap(Map<String, dynamic> dorm) {
    // The info window will show automatically
    // Additional custom behavior can be added here
  }

  /// Navigate to dorm details screen
  void _navigateToDormDetails(Map<String, dynamic> dorm) {
    final dormId = dorm['dorm_id']?.toString() ?? '';
    final dormName = dorm['name']?.toString() ?? 'Dorm';
    final authProvider = context.read<AuthProvider>();
    
    // Create property map compatible with ViewDetailsScreen
    final property = {
      'dorm_id': dormId,
      'name': dormName,
      'address': dorm['address']?.toString() ?? '',
      'price_per_month': dorm['price_per_month']?.toString() ?? dorm['price']?.toString() ?? '0',
      'image_url': dorm['image_url']?.toString() ?? dorm['images']?.toString() ?? '',
    };
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewDetailsScreen(
          property: property,
          userEmail: authProvider.userEmail ?? '',
        ),
      ),
    );
  }

  /// Center camera on all dorm markers
  void _centerOnDorms(List<Map<String, dynamic>> dorms) {
    if (_mapController == null || dorms.isEmpty) return;

    final positions = dorms
        .where((d) => d['latitude'] != null && d['longitude'] != null)
        .map((d) {
      final lat = double.tryParse(d['latitude'].toString());
      final lng = double.tryParse(d['longitude'].toString());
      if (lat != null && lng != null) {
        return LatLng(lat, lng);
      }
      return null;
    }).whereType<LatLng>().toList();

    if (positions.isEmpty) return;

    try {
      final bounds = MapHelpers.calculateBounds(positions);
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 50),
      );
    } catch (e) {
      // If bounds calculation fails, center on first position
      if (positions.isNotEmpty) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(positions.first),
        );
      }
    }
  }

  /// Move camera to user's current location
  void _goToCurrentLocation() {
    if (_mapController == null || _currentLocation == null) {
      _getCurrentLocation();
      return;
    }

    _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(_currentLocation!, 15.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dorms on Map'),
        actions: [
          // Recenter button
          IconButton(
            icon: const Icon(Icons.center_focus_strong),
            tooltip: 'Center on dorms',
            onPressed: () {
              final dorms = context.read<DormProvider>().allDorms;
              _centerOnDorms(dorms);
            },
          ),
        ],
      ),
      body: Consumer<DormProvider>(
        builder: (context, dormProvider, child) {
          if (dormProvider.isLoading && dormProvider.allDorms.isEmpty) {
            return const LoadingWidget(message: 'Loading dorms...');
          }

          if (dormProvider.error != null && dormProvider.allDorms.isEmpty) {
            final authProvider = context.read<AuthProvider>();
            return ErrorDisplayWidget(
              message: dormProvider.error!,
              onRetry: () => dormProvider.fetchAllDorms(studentEmail: authProvider.userEmail),
            );
          }

          final dorms = dormProvider.allDorms;
          final markers = _createMarkers(dorms);

          // Find first dorm with valid coordinates, or default to Manila
          LatLng initialPosition = MapHelpers.defaultManilaPosition.target;
          
          for (var dorm in dorms) {
            final lat = double.tryParse(dorm['latitude']?.toString() ?? '');
            final lng = double.tryParse(dorm['longitude']?.toString() ?? '');
            
            if (lat != null && lng != null && lat != 0.0 && lng != 0.0) {
              initialPosition = LatLng(lat, lng);
              print('📍 [Map] Using initial position from dorm: ${dorm['title']} ($lat, $lng)');
              break;
            }
          }
          
          if (initialPosition == MapHelpers.defaultManilaPosition.target) {
            print('⚠️ [Map] No valid dorm locations, using default Manila position');
          }

          return Stack(
            children: [
              // Map
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: initialPosition,
                  zoom: 12.0,
                ),
                markers: markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false, // We'll use custom button
                zoomControlsEnabled: true,
                mapToolbarEnabled: false,
                compassEnabled: true,
                onMapCreated: (controller) {
                  _mapController = controller;
                  // Center on all dorms after map is created
                  Future.delayed(const Duration(milliseconds: 500), () {
                    _centerOnDorms(dorms);
                  });
                },
              ),

              // Dorm count badge
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Color(0xFFFF9800),
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${markers.length} ${markers.length == 1 ? 'Dorm' : 'Dorms'}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8B5CF6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Current location button
              Positioned(
                bottom: 80,
                right: 16,
                child: FloatingActionButton(
                  heroTag: 'currentLocation',
                  onPressed: _goToCurrentLocation,
                  backgroundColor: Colors.white,
                  child: _isLoadingLocation
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF8B5CF6),
                          ),
                        )
                      : const Icon(
                          Icons.my_location,
                          color: Color(0xFF8B5CF6),
                        ),
                ),
              ),

              // Location error snackbar
              if (_locationError != null)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Material(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Location unavailable',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              setState(() => _locationError = null);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.list),
        label: const Text('List View'),
      ),
    );
  }
}
