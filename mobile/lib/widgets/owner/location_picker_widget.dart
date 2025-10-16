import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/location_service.dart';
import '../../utils/map_helpers.dart';

/// Interactive location picker for selecting dorm coordinates.
/// 
/// Features:
/// - Interactive Google Maps
/// - Draggable marker for location selection
/// - Current location button
/// - Address search (optional)
/// - Display selected coordinates
/// - Return LatLng on selection
class LocationPickerWidget extends StatefulWidget {
  /// Initial location (if editing existing dorm)
  final LatLng? initialLocation;
  
  /// Callback when location is selected
  final Function(LatLng location, String? address) onLocationSelected;
  
  /// Show address search field
  final bool showAddressSearch;
  
  /// Initial address (if editing existing dorm)
  final String? initialAddress;

  const LocationPickerWidget({
    super.key,
    this.initialLocation,
    required this.onLocationSelected,
    this.showAddressSearch = true,
    this.initialAddress,
  });

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  final LocationService _locationService = LocationService();
  final TextEditingController _addressController = TextEditingController();
  
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  String? _selectedAddress;
  bool _isLoadingLocation = false;
  bool _isSearchingAddress = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    _selectedAddress = widget.initialAddress;
    if (widget.initialAddress != null) {
      _addressController.text = widget.initialAddress!;
    }
    
    // If no initial location, use current location
    if (_selectedLocation == null) {
      _getCurrentLocation();
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _addressController.dispose();
    super.dispose();
  }

  /// Get user's current location
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _error = null;
    });

    try {
      final position = await _locationService.getCurrentLocation();
      final location = LatLng(position.latitude, position.longitude);
      
      setState(() {
        _selectedLocation = location;
        _isLoadingLocation = false;
      });

      // Move camera to current location
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(location, 15.0),
      );

      // Get address for current location
      _getAddressFromLocation(location);
    } catch (e) {
      setState(() {
        _error = 'Could not get your location';
        _isLoadingLocation = false;
        // Use Manila as fallback
        _selectedLocation = MapHelpers.defaultManilaPosition.target;
      });
    }
  }

  /// Get address from coordinates (reverse geocoding)
  Future<void> _getAddressFromLocation(LatLng location) async {
    try {
      final address = await _locationService.getAddressFromCoordinates(location);
      
      setState(() {
        _selectedAddress = address;
        _addressController.text = address;
      });
      
      // Notify parent
      widget.onLocationSelected(location, address);
    } catch (e) {
      setState(() {
        _selectedAddress = null;
      });
      
      // Still notify parent with location (without address)
      widget.onLocationSelected(location, null);
    }
  }

  /// Search address and get coordinates (forward geocoding)
  Future<void> _searchAddress() async {
    final query = _addressController.text.trim();
    
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an address')),
      );
      return;
    }

    setState(() {
      _isSearchingAddress = true;
      _error = null;
    });

    try {
      final location = await _locationService.getCoordinatesFromAddress(query);
      
      if (!mounted) return;
      
      if (location == null) {
        setState(() {
          _error = 'Address not found';
          _isSearchingAddress = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Address not found. Please try a different address.')),
          );
        }
        return;
      }
      
      setState(() {
        _selectedLocation = location;
        _selectedAddress = query;
        _isSearchingAddress = false;
      });

      // Move camera to searched location
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(location, 15.0),
      );

      // Notify parent
      widget.onLocationSelected(location, query);

      // Hide keyboard
      FocusScope.of(context).unfocus();
    } catch (e) {
      setState(() {
        _error = 'Address not found';
        _isSearchingAddress = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Address not found: ${e.toString()}')),
        );
      }
    }
  }

  /// Handle map tap (update marker position)
  void _onMapTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
    
    // Get address for tapped location
    _getAddressFromLocation(location);
  }

  @override
  Widget build(BuildContext context) {
    final currentLocation = _selectedLocation ?? MapHelpers.defaultManilaPosition.target;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Address Search Field
        if (widget.showAddressSearch) ...[
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Search Address',
                    hintText: 'Enter address or landmark',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: _addressController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _addressController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                  onSubmitted: (_) => _searchAddress(),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isSearchingAddress ? null : _searchAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSearchingAddress
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.search),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],

        // Error Message
        if (_error != null)
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.orange.shade900, fontSize: 12),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => setState(() => _error = null),
                ),
              ],
            ),
          ),

        // Instructions
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Tap on the map to select dorm location',
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Map
        Container(
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          clipBehavior: Clip.antiAlias,
          child: _isLoadingLocation
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Getting your location...'),
                    ],
                  ),
                )
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: currentLocation,
                    zoom: 15.0,
                  ),
                  markers: _selectedLocation != null
                      ? {
                          Marker(
                            markerId: const MarkerId('selected_location'),
                            position: _selectedLocation!,
                            icon: MapHelpers.createColoredMarker(hue: 270.0), // Purple
                            draggable: true,
                            onDragEnd: (newPosition) {
                              _onMapTap(newPosition);
                            },
                          ),
                        }
                      : {},
                  onTap: _onMapTap,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: true,
                  mapToolbarEnabled: false,
                  compassEnabled: true,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                ),
        ),
        const SizedBox(height: 12),

        // Selected Location Info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Coordinates
              Row(
                children: [
                  const Icon(Icons.gps_fixed, size: 16, color: Color(0xFF8B5CF6)),
                  const SizedBox(width: 8),
                  Text(
                    'Coordinates',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (_selectedLocation != null)
                SelectableText(
                  '${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'monospace',
                    color: Colors.black87,
                  ),
                )
              else
                const Text(
                  'No location selected',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),

              // Address
              if (_selectedAddress != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Color(0xFFFF9800)),
                    const SizedBox(width: 8),
                    Text(
                      'Address',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedAddress!,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Action Buttons
        Row(
          children: [
            // Current Location Button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                icon: _isLoadingLocation
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
                label: const Text('Use Current Location'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF8B5CF6),
                  side: const BorderSide(color: Color(0xFF8B5CF6)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
