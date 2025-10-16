import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../providers/dorm_provider.dart';
import '../../services/location_service.dart';
import '../../utils/map_helpers.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../student/view_details_screen.dart';

/// Screen for browsing and searching available dorms
class BrowseDormsScreen extends StatefulWidget {
  final String? searchQuery;
  final String userEmail;
  
  const BrowseDormsScreen({
    super.key, 
    this.searchQuery,
    required this.userEmail,
  });

  @override
  State<BrowseDormsScreen> createState() => _BrowseDormsScreenState();
}

class _BrowseDormsScreenState extends State<BrowseDormsScreen> {
  final LocationService _locationService = LocationService();
  
  List<Map<String, dynamic>> dorms = [];
  List<Map<String, dynamic>> allDorms = []; // Keep original list
  
  // Near Me filter state
  bool _nearMeFilterActive = false;
  double _radiusKm = 5.0; // Default 5km
  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    // Load dorms from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchDorms();
    });
  }

  Future<void> fetchDorms() async {
    print('🔵 [Browse] Starting fetchDorms for user: ${widget.userEmail}');
    
    final dormProvider = context.read<DormProvider>();
    
    // Fetch all dorms with student email
    print('🔵 [Browse] Calling provider.fetchAllDorms...');
    await dormProvider.fetchAllDorms(studentEmail: widget.userEmail);
    
    if (!mounted) return;
    
    // Get dorms from provider
    var items = List<Map<String, dynamic>>.from(dormProvider.allDorms);
    
    // Debug: Print dorm count and first dorm if available
    print('📊 [Browse] Fetched ${items.length} dorms from provider');
    if (items.isNotEmpty) {
      print('📍 [Browse] First dorm details:');
      print('   - ID: ${items[0]['dorm_id']}');
      print('   - Name: ${items[0]['name']}');
      print('   - Address: ${items[0]['address']}');
      print('   - Latitude: ${items[0]['latitude']}');
      print('   - Longitude: ${items[0]['longitude']}');
      print('   - Full data: ${items[0]}');
    } else {
      print('⚠️ [Browse] No dorms returned from provider!');
      print('   - Provider error: ${dormProvider.error}');
      print('   - Provider loading: ${dormProvider.isLoading}');
    }
    
    // Apply search filter if query provided
    if (widget.searchQuery != null && widget.searchQuery!.trim().isNotEmpty) {
      final q = widget.searchQuery!.toLowerCase();
      print('🔍 [Browse] Applying search filter: "$q"');
      items = items.where((p) {
        final t = (p['title'] ?? p['name'] ?? '').toString().toLowerCase();
        final l = (p['location'] ?? p['address'] ?? '').toString().toLowerCase();
        return t.contains(q) || l.contains(q);
      }).toList();
      print('🔍 [Browse] After search filter: ${items.length} dorms');
    }
    
    setState(() {
      allDorms = items; // Store original list
      dorms = items;
    });
    
    print('✅ [Browse] Set state with ${dorms.length} dorms');
    
    // Apply Near Me filter if active
    if (_nearMeFilterActive) {
      print('📍 [Browse] Applying Near Me filter...');
      _applyNearMeFilter();
    }
  }

  /// Get user's current location
  Future<void> _getUserLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not get location: ${e.toString()}')),
        );
      }
    }
  }

  /// Apply Near Me filter
  Future<void> _applyNearMeFilter() async {
    print('📍 [Filter] Starting Near Me filter...');
    print('📍 [Filter] User location: $_userLocation');
    print('📍 [Filter] Radius: $_radiusKm km');
    print('📍 [Filter] Total dorms to filter: ${allDorms.length}');
    
    if (_userLocation == null) {
      print('📍 [Filter] No user location, fetching...');
      await _getUserLocation();
    }

    if (_userLocation == null) {
      print('❌ [Filter] Could not get user location, disabling filter');
      setState(() {
        _nearMeFilterActive = false;
      });
      return;
    }

    setState(() {
      _nearMeFilterActive = true;
    });

    // Filter dorms within radius
    int validLocationCount = 0;
    int invalidLocationCount = 0;
    
    final filteredDorms = allDorms.where((dorm) {
      final latStr = dorm['latitude']?.toString() ?? '';
      final lngStr = dorm['longitude']?.toString() ?? '';
      final lat = double.tryParse(latStr);
      final lng = double.tryParse(lngStr);

      if (lat == null || lng == null || lat == 0.0 || lng == 0.0) {
        invalidLocationCount++;
        print('   ⚠️ Dorm "${dorm['name']}" has no valid location (lat: $latStr, lng: $lngStr)');
        return false;
      }

      validLocationCount++;
      final dormLocation = LatLng(lat, lng);
      final distance = _locationService.calculateDistance(_userLocation!, dormLocation);

      // Add distance to dorm data for display
      dorm['_distance'] = distance;
      
      final withinRadius = distance <= _radiusKm;
      if (withinRadius) {
        print('   ✅ Dorm "${dorm['name']}" is ${distance.toStringAsFixed(2)} km away (within radius)');
      }

      return withinRadius;
    }).toList();

    print('📊 [Filter] Results:');
    print('   - Valid locations: $validLocationCount');
    print('   - Invalid locations: $invalidLocationCount');
    print('   - Within radius: ${filteredDorms.length}');

    // Sort by distance
    filteredDorms.sort((a, b) {
      final distA = a['_distance'] as double? ?? 999999;
      final distB = b['_distance'] as double? ?? 999999;
      return distA.compareTo(distB);
    });

    setState(() {
      dorms = filteredDorms;
    });
    
    print('✅ [Filter] Applied Near Me filter, showing ${dorms.length} dorms');
  }

  /// Clear Near Me filter
  void _clearNearMeFilter() {
    setState(() {
      _nearMeFilterActive = false;
      dorms = allDorms;
      // Remove distance data
      for (var dorm in dorms) {
        dorm.remove('_distance');
      }
    });
  }

  /// Show radius picker dialog
  void _showRadiusPickerDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Search Radius'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${_radiusKm.toStringAsFixed(1)} km',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(height: 16),
              Slider(
                value: _radiusKm,
                min: 1.0,
                max: 20.0,
                divisions: 19,
                label: '${_radiusKm.toStringAsFixed(1)} km',
                activeColor: const Color(0xFF8B5CF6),
                onChanged: (value) {
                  setDialogState(() {
                    _radiusKm = value;
                  });
                  setState(() {
                    _radiusKm = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              const Text(
                'Show dorms within this radius',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _applyNearMeFilter();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
              ),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.searchQuery == null || widget.searchQuery!.isEmpty 
            ? 'Browse Dorms' 
            : 'Search: ${widget.searchQuery}'
        ),
        backgroundColor: Colors.orange,
        actions: [
          // Near Me filter button
          IconButton(
            icon: Icon(
              _nearMeFilterActive ? Icons.location_on : Icons.location_searching,
            ),
            tooltip: 'Near Me',
            onPressed: () {
              if (_nearMeFilterActive) {
                _clearNearMeFilter();
              } else {
                _showRadiusPickerDialog();
              }
            },
          ),
          // Map view toggle button
          IconButton(
            icon: const Icon(Icons.map),
            tooltip: 'Map View',
            onPressed: () {
              Navigator.pushNamed(context, '/browse_dorms_map');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Near Me Filter Indicator
          if (_nearMeFilterActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: const Color(0xFF8B5CF6).withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Color(0xFF8B5CF6),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Showing dorms within ${_radiusKm.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        color: Color(0xFF8B5CF6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _showRadiusPickerDialog,
                    icon: const Icon(Icons.tune, size: 16),
                    label: const Text('Adjust'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF8B5CF6),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    color: const Color(0xFF8B5CF6),
                    onPressed: _clearNearMeFilter,
                    tooltip: 'Clear filter',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          // Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: fetchDorms,
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Consumer<DormProvider>(
      builder: (context, dormProvider, child) {
        if (dormProvider.isLoading && dorms.isEmpty) {
          return const LoadingWidget();
        }
        
        if (dormProvider.error != null && dorms.isEmpty) {
          return ErrorDisplayWidget(
            error: dormProvider.error!,
            onRetry: fetchDorms,
          );
        }
        
        if (dorms.isEmpty) {
          return _buildEmptyState();
        }
        
        return _buildDormList();
      },
    );
  }

  Widget _buildEmptyState() {
    if (dorms.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text(
                'No dorms found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildDormList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: dorms.length,
      itemBuilder: (context, i) => _buildDormCard(dorms[i]),
    );
  }

  Widget _buildDormCard(Map<String, dynamic> dorm) {
    final image = dorm['image'] ?? '';
    final title = dorm['title'] ?? 'Unnamed Dorm';
    final location = dorm['location'] ?? '';
    final minPrice = dorm['min_price'] ?? '';
    final available = dorm['available_rooms']?.toString() ?? '0';
    final distance = dorm['_distance'] as double?;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToDetails(dorm),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            // Distance Badge (if Near Me filter active)
            if (distance != null)
              Container(
                width: 60,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.near_me,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      MapHelpers.formatDistance(distance),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            _buildDormImage(image),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.black54),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: const TextStyle(color: Colors.black54, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (minPrice != null && minPrice != '') 
                          Text(
                            minPrice,
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$available rooms',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDormImage(String? image) {
    return Container(
      width: 110,
      height: 90,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomLeft: Radius.circular(12),
        ),
        color: Colors.grey[200],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomLeft: Radius.circular(12),
        ),
        child: (image != null && image.isNotEmpty)
            ? Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.home,
                  size: 40,
                  color: Colors.grey,
                ),
              )
            : const Icon(
                Icons.home,
                size: 40,
                color: Colors.grey,
              ),
      ),
    );
  }

  void _navigateToDetails(Map<String, dynamic> dorm) {
    // Convert to format expected by ViewDetailsScreen
    final property = <String, String>{
      'dorm_id': dorm['dorm_id']?.toString() ?? '',
      'title': dorm['title']?.toString() ?? '',
      'location': dorm['location']?.toString() ?? '',
      'desc': dorm['desc']?.toString() ?? '',
      'image': dorm['image']?.toString() ?? '',
      'owner_email': dorm['owner_email']?.toString() ?? '',
      'owner_name': dorm['owner_name']?.toString() ?? '',
      'min_price': dorm['min_price']?.toString() ?? '',
      'available_rooms': dorm['available_rooms']?.toString() ?? '',
    };
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ViewDetailsScreen(
          property: property,
          userEmail: widget.userEmail,
        ),
      ),
    );
  }
}
