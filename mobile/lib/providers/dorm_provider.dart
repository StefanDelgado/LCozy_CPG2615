import 'package:flutter/foundation.dart';
import '../services/dorm_service.dart';

/// Provider for managing dorm data state across the app.
/// 
/// Handles:
/// - Fetching all dorms (for students browsing)
/// - Fetching owner's dorms
/// - Creating, updating, deleting dorms
/// - Selected dorm details
/// - Loading and error states
/// 
/// Usage:
/// ```dart
/// // In widget
/// final dormProvider = context.watch<DormProvider>();
/// 
/// // Fetch all dorms
/// await context.read<DormProvider>().fetchAllDorms();
/// 
/// // Access dorms
/// final dorms = dormProvider.allDorms;
/// ```
class DormProvider with ChangeNotifier {
  final DormService _dormService = DormService();

  // State
  List<Map<String, dynamic>> _allDorms = [];
  List<Map<String, dynamic>> _ownerDorms = [];
  Map<String, dynamic>? _selectedDorm;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Map<String, dynamic>> get allDorms => _allDorms;
  List<Map<String, dynamic>> get ownerDorms => _ownerDorms;
  Map<String, dynamic>? get selectedDorm => _selectedDorm;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  int get allDormsCount => _allDorms.length;
  int get ownerDormsCount => _ownerDorms.length;
  bool get hasSelectedDorm => _selectedDorm != null;

  /// Fetch all available dorms (for student browsing).
  /// 
  /// Parameters:
  /// - [studentEmail]: Email of the student (optional)
  /// 
  /// Updates [allDorms] list with all dorms from the server.
  /// 
  /// Returns `true` if successful, `false` otherwise.
  Future<bool> fetchAllDorms({String? studentEmail}) async {
    print('🔵 [Provider] fetchAllDorms called with email: $studentEmail');
    _setLoading(true);
    _error = null;

    try {
      print('🔵 [Provider] Calling dormService.getAllDorms...');
      final result = await _dormService.getAllDorms(studentEmail: studentEmail);
      print('🔵 [Provider] Service returned: ${result.keys}');

      if (result['success'] == true) {
        final dormsList = List<Map<String, dynamic>>.from(result['data'] ?? []);
        print('✅ [Provider] Success! Got ${dormsList.length} dorms');
        if (dormsList.isNotEmpty) {
          print('   First dorm: ${dormsList[0]['name']} (ID: ${dormsList[0]['dorm_id']})');
        }
        _allDorms = dormsList;
        _error = null;
        _setLoading(false);
        return true;
      } else {
        // Include more detailed error information
        final errorMsg = result['message'] ?? result['error'] ?? 'Failed to load dorms';
        print('❌ [Provider] Failed: $errorMsg');
        _error = errorMsg;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      print('❌ [Provider] Exception: $e');
      _error = 'Error loading dorms: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  /// Fetch dorms owned by specific owner.
  /// 
  /// Parameters:
  /// - [ownerEmail]: Email of the dorm owner
  /// 
  /// Updates [ownerDorms] list with owner's dorms.
  /// 
  /// Returns `true` if successful, `false` otherwise.
  Future<bool> fetchOwnerDorms(String ownerEmail) async {
    _setLoading(true);
    _error = null;

    try {
      final result = await _dormService.getOwnerDorms(ownerEmail);

      if (result['success'] == true) {
        _ownerDorms = List<Map<String, dynamic>>.from(result['data'] ?? []);
        _error = null;
        _setLoading(false);
        return true;
      } else {
        _error = result['error'] ?? 'Failed to load owner dorms';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error loading owner dorms: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  /// Fetch detailed information for a specific dorm.
  /// 
  /// Parameters:
  /// - [dormId]: ID of the dorm to fetch
  /// 
  /// Updates [selectedDorm] with dorm details.
  /// 
  /// Returns `true` if successful, `false` otherwise.
  Future<bool> fetchDormDetails(String dormId) async {
    _setLoading(true);
    _error = null;

    try {
      final result = await _dormService.getDormDetails(dormId);

      if (result['success'] == true) {
        _selectedDorm = result['data'];
        _error = null;
        _setLoading(false);
        return true;
      } else {
        _error = result['error'] ?? 'Failed to load dorm details';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error loading dorm details: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  /// Add a new dorm.
  /// 
  /// Parameters:
  /// - [dormData]: Map containing dorm information:
  ///   - name: string
  ///   - address: string
  ///   - owner_email: string
  ///   - description: string (optional)
  ///   - image: string (base64, optional)
  ///   - latitude: double (optional)
  ///   - longitude: double (optional)
  /// 
  /// Automatically refreshes owner dorms list after successful addition.
  /// 
  /// Returns `true` if successful, `false` otherwise.
  Future<bool> addDorm(Map<String, dynamic> dormData) async {
    _setLoading(true);
    _error = null;

    try {
      final result = await _dormService.addDorm(dormData);

      if (result['success'] == true) {
        // Refresh owner dorms list
        final ownerEmail = dormData['owner_email'] as String;
        await fetchOwnerDorms(ownerEmail);
        _error = null;
        return true;
      } else {
        _error = result['error'] ?? 'Failed to add dorm';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error adding dorm: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  /// Delete a dorm.
  /// 
  /// Parameters:
  /// - [dormId]: ID of the dorm to delete
  /// - [ownerEmail]: Email of the owner (for refreshing list)
  /// 
  /// Automatically refreshes owner dorms list after successful deletion.
  /// 
  /// Returns `true` if successful, `false` otherwise.
  Future<bool> deleteDorm(String dormId, String ownerEmail) async {
    _setLoading(true);
    _error = null;

    try {
      final result = await _dormService.deleteDorm(dormId);

      if (result['success'] == true) {
        // Refresh owner dorms list
        await fetchOwnerDorms(ownerEmail);
        _error = null;
        return true;
      } else {
        _error = result['error'] ?? 'Failed to delete dorm';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error deleting dorm: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  /// Update an existing dorm.
  /// 
  /// Parameters:
  /// - [dormId]: ID of the dorm to update
  /// - [dormData]: Map containing updated dorm information
  /// - [ownerEmail]: Email of the owner (for refreshing list)
  /// 
  /// Automatically refreshes owner dorms list after successful update.
  /// 
  /// Returns `true` if successful, `false` otherwise.
  Future<bool> updateDorm(
    String dormId,
    Map<String, dynamic> dormData,
    String ownerEmail,
  ) async {
    _setLoading(true);
    _error = null;

    try {
      final result = await _dormService.updateDorm(dormId, dormData);

      if (result['success'] == true) {
        // Refresh owner dorms list
        await fetchOwnerDorms(ownerEmail);
        _error = null;
        return true;
      } else {
        _error = result['error'] ?? 'Failed to update dorm';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error updating dorm: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  /// Select a dorm for detailed viewing.
  /// 
  /// Parameters:
  /// - [dorm]: Dorm data map
  /// 
  /// Sets [selectedDorm] without fetching from server.
  /// Use [fetchDormDetails] for fresh data.
  void selectDorm(Map<String, dynamic> dorm) {
    _selectedDorm = dorm;
    notifyListeners();
  }

  /// Clear the currently selected dorm.
  void clearSelectedDorm() {
    _selectedDorm = null;
    notifyListeners();
  }

  /// Clear any error messages.
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Filter dorms by search query.
  /// 
  /// Searches in dorm name, address, and description.
  /// 
  /// Parameters:
  /// - [query]: Search string
  /// 
  /// Returns filtered list of dorms.
  List<Map<String, dynamic>> searchDorms(String query) {
    if (query.isEmpty) return _allDorms;

    final lowerQuery = query.toLowerCase();
    return _allDorms.where((dorm) {
      final name = (dorm['name'] ?? '').toString().toLowerCase();
      final address = (dorm['address'] ?? '').toString().toLowerCase();
      final description = (dorm['description'] ?? '').toString().toLowerCase();

      return name.contains(lowerQuery) ||
          address.contains(lowerQuery) ||
          description.contains(lowerQuery);
    }).toList();
  }

  /// Filter dorms within a radius of a location.
  /// 
  /// Parameters:
  /// - [centerLat]: Center latitude
  /// - [centerLng]: Center longitude
  /// - [radiusInKm]: Radius in kilometers
  /// 
  /// Returns list of dorms within the specified radius.
  /// 
  /// Note: Requires dorms to have latitude and longitude data.
  List<Map<String, dynamic>> filterDormsByRadius(
    double centerLat,
    double centerLng,
    double radiusInKm,
  ) {
    return _allDorms.where((dorm) {
      final lat = dorm['latitude'];
      final lng = dorm['longitude'];

      if (lat == null || lng == null) return false;

      final distance = _calculateDistance(
        centerLat,
        centerLng,
        double.parse(lat.toString()),
        double.parse(lng.toString()),
      );

      return distance <= radiusInKm;
    }).toList();
  }

  /// Calculate distance between two coordinates using Haversine formula.
  /// 
  /// Returns distance in kilometers.
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth radius in km
    const double pi = 3.141592653589793;
    
    final dLat = (lat2 - lat1) * pi / 180;
    final dLon = (lon2 - lon1) * pi / 180;

    final lat1Rad = lat1 * pi / 180;
    final lat2Rad = lat2 * pi / 180;

    final a = (dLat / 2).abs() * (dLat / 2).abs() +
        lat1Rad.abs() * lat2Rad.abs() * (dLon / 2).abs() * (dLon / 2).abs();

    final c = 2 * a.abs();

    return earthRadius * c;
  }

  /// Set loading state and notify listeners.
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Refresh all data.
  /// 
  /// Fetches both all dorms and owner dorms (if owner email is provided).
  Future<void> refreshAll({String? ownerEmail}) async {
    await fetchAllDorms();
    if (ownerEmail != null) {
      await fetchOwnerDorms(ownerEmail);
    }
  }
}
