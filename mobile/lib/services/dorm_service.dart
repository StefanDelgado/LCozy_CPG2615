import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

/// Service class for managing dormitory-related API calls
/// 
/// Provides centralized methods for all dorm operations including:
/// - Fetching dorms (owner-specific and all dorms)
/// - Getting dorm details
/// - Creating new dorms
/// - Deleting dorms
class DormService {
  static const String _baseUrl = ApiConstants.baseUrl;

  /// Fetches all dorms owned by a specific owner
  /// 
  /// [ownerEmail] - Email of the owner
  /// 
  /// Returns a Map with:
  /// - success: true if successful, false otherwise
  /// - data: List of dorms or null
  /// - message: Success or error message
  Future<Map<String, dynamic>> getOwnerDorms(String ownerEmail) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/modules/mobile-api/owner/owner_dorms_api.php?owner_email=$ownerEmail',
      );
      
      print('🌐 Calling API: $uri');
      final response = await http.get(uri);
      print('🌐 Response status: ${response.statusCode}');
      print('🌐 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('🌐 Decoded data type: ${data.runtimeType}');
        print('🌐 Decoded data: $data');
        
        if (data is List) {
          print('✅ Data is List with ${data.length} items');
          return {
            'success': true,
            'data': data,
            'message': 'Dorms loaded successfully',
          };
        } else if (data is Map && data['dorms'] != null) {
          // Handle {ok: true, dorms: [...]} format
          final dormsList = data['dorms'] as List;
          print('✅ Data has dorms array with ${dormsList.length} items');
          return {
            'success': true,
            'data': dormsList,
            'message': 'Dorms loaded successfully',
          };
        } else if (data is Map && data['error'] != null) {
          print('❌ Data has error: ${data['error']}');
          return {
            'success': false,
            'error': data['error'],
            'message': data['error'],
          };
        } else {
          print('⚠️ Data is neither List nor error Map, returning empty');
          return {
            'success': true,
            'data': [],
            'message': 'No dorms found',
          };
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        return {
          'success': false,
          'error': 'HTTP Error',
          'message': 'Failed to load dorms. Status: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Exception: $e');
      return {
        'success': false,
        'error': 'Exception',
        'message': 'Error loading dorms: ${e.toString()}',
      };
    }
  }

  /// Fetches all available dorms for students
  /// 
  /// Parameters:
  /// - [studentEmail]: Email of the student (optional, but recommended)
  /// 
  /// Returns a Map with:
  /// - success: true if successful, false otherwise
  /// - data: List of dorms or null
  /// - message: Success or error message
  Future<Map<String, dynamic>> getAllDorms({String? studentEmail}) async {
    try {
      // Use student_home_api.php which returns all available dorms
      final uri = Uri.parse('${ApiConstants.baseUrl}/modules/mobile-api/student/student_home_api.php');
      
      print('🌐 API Call: $uri');
      
      final response = await http.get(uri).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Request timeout - Please check your internet connection');
        },
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📦 Response Body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        print('📊 Decoded data type: ${data.runtimeType}');
        
        // student_home_api.php returns {ok: true, dorms: [...]}
        if (data is Map && data['dorms'] != null) {
          final dormsList = data['dorms'] as List;
          print('✅ Found dorms in Map: ${dormsList.length} dorms');
          if (dormsList.isNotEmpty) {
            print('   First dorm: ${dormsList[0]}');
          }
          return {
            'success': true,
            'data': dormsList,
            'message': 'Dorms loaded successfully',
          };
        } else if (data is List) {
          print('✅ Found dorms as List: ${data.length} dorms');
          return {
            'success': true,
            'data': data,
            'message': 'Dorms loaded successfully',
          };
        } else if (data is Map && data['ok'] == true && data['dorms'] == null) {
          print('⚠️ Response OK but no dorms array');
          return {
            'success': true,
            'data': [],
            'message': 'No dorms available',
          };
        } else if (data is Map) {
          print('⚠️ Map without dorms key. Keys: ${data.keys}');
          return {
            'success': true,
            'data': [],
            'message': 'No dorms available',
          };
        } else {
          print('⚠️ Unknown data format');
          return {
            'success': true,
            'data': [],
            'message': 'No dorms available',
          };
        }
      } else {
        return {
          'success': false,
          'error': 'HTTP Error ${response.statusCode}',
          'message': 'Failed to load dorms. Status: ${response.statusCode}\nResponse: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}',
        };
      }
    } catch (e) {
      // Provide more specific error messages
      String errorMessage = 'Error loading dorms: ${e.toString()}';
      
      if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
        errorMessage = 'Network error: Cannot connect to server. Please check your internet connection.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Request timeout: Server is taking too long to respond.';
      } else if (e.toString().contains('FormatException')) {
        errorMessage = 'Data format error: Invalid response from server.';
      }
      
      return {
        'success': false,
        'error': 'Exception',
        'message': errorMessage,
      };
    }
  }

  /// Fetches detailed information for a specific dorm
  /// 
  /// [dormId] - ID of the dorm to fetch
  /// 
  /// Returns a Map with:
  /// - success: true if successful, false otherwise
  /// - data: Dorm details or null
  /// - message: Success or error message
  Future<Map<String, dynamic>> getDormDetails(String dormId) async {
    print('🏠 [DormService] Fetching dorm details for ID: $dormId');
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/modules/mobile-api/dorms/dorm_details_api.php?dorm_id=$dormId',
      );
      
      print('🏠 [DormService] Request URL: $uri');
      final response = await http.get(uri);
      print('🏠 [DormService] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('🏠 [DormService] Response body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');
        final data = json.decode(response.body);
        
        if (data is Map) {
          // Check if API returns {ok: true, dorm: {...}}
          if (data['ok'] == true && data['dorm'] != null) {
            print('🏠 [DormService] ✅ Success! Dorm details loaded');
            return {
              'success': true,
              'data': data['dorm'], // Use 'dorm' field from API
              'rooms': data['rooms'], // Also include rooms
              'reviews': data['reviews'], // And reviews
              'message': 'Dorm details loaded successfully',
            };
          }
          // Or direct dorm data (fallback)
          else if (data['dorm_id'] != null) {
            print('🏠 [DormService] ✅ Success! Dorm details loaded (direct format)');
            return {
              'success': true,
              'data': data,
              'message': 'Dorm details loaded successfully',
            };
          }
          // Error response
          else if (data['ok'] == false) {
            print('🏠 [DormService] ❌ API error: ${data['error']}');
            return {
              'success': false,
              'error': data['error'] ?? 'Unknown error',
              'message': data['message'] ?? data['error'] ?? 'Failed to load dorm details',
            };
          }
        }
        
        print('🏠 [DormService] ❌ Invalid data format');
        return {
          'success': false,
          'error': 'Invalid data format',
          'message': 'Unexpected response format',
        };
      } else {
        print('🏠 [DormService] ❌ HTTP ${response.statusCode}: ${response.body}');
        return {
          'success': false,
          'error': 'HTTP Error',
          'message': 'Failed to load dorm details. Status: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('🏠 [DormService] ❌ Exception: $e');
      return {
        'success': false,
        'error': 'Exception',
        'message': 'Error loading dorm details: ${e.toString()}',
      };
    }
  }

  /// Adds a new dorm
  /// 
  /// [dormData] - Map containing dorm information:
  ///   - dorm_name: String
  ///   - address: String
  ///   - owner_email: String
  ///   - description: String (optional)
  ///   - amenities: String (optional)
  /// 
  /// Returns a Map with:
  /// - success: true if successful, false otherwise
  /// - data: Created dorm data or null
  /// - message: Success or error message
  Future<Map<String, dynamic>> addDorm(Map<String, dynamic> dormData) async {
    try {
      final uri = Uri.parse('$_baseUrl/modules/mobile-api/dorms/add_dorm_api.php');
      
      final response = await http.post(
        uri,
        body: dormData,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          return {
            'success': true,
            'data': data,
            'message': data['message'] ?? 'Dorm added successfully',
          };
        } else {
          return {
            'success': false,
            'error': data['error'] ?? 'Unknown error',
            'message': data['message'] ?? 'Failed to add dorm',
          };
        }
      } else {
        return {
          'success': false,
          'error': 'HTTP Error',
          'message': 'Failed to add dorm. Status: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Exception',
        'message': 'Error adding dorm: ${e.toString()}',
      };
    }
  }

  /// Deletes a dorm
  /// 
  /// [dormId] - ID of the dorm to delete
  /// 
  /// Returns a Map with:
  /// - success: true if successful, false otherwise
  /// - message: Success or error message
  Future<Map<String, dynamic>> deleteDorm(String dormId) async {
    try {
      final uri = Uri.parse('$_baseUrl/modules/mobile-api/dorms/delete_dorm_api.php');
      
      final response = await http.post(
        uri,
        body: {'dorm_id': dormId},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          return {
            'success': true,
            'message': data['message'] ?? 'Dorm deleted successfully',
          };
        } else {
          return {
            'success': false,
            'error': data['error'] ?? 'Unknown error',
            'message': data['message'] ?? 'Failed to delete dorm',
          };
        }
      } else {
        return {
          'success': false,
          'error': 'HTTP Error',
          'message': 'Failed to delete dorm. Status: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Exception',
        'message': 'Error deleting dorm: ${e.toString()}',
      };
    }
  }

  /// Updates an existing dorm
  /// 
  /// [dormId] - ID of the dorm to update
  /// [dormData] - Map containing updated dorm information:
  ///   - name: String
  ///   - address: String
  ///   - description: String (optional)
  ///   - features: String (optional)
  ///   - latitude: String (optional)
  ///   - longitude: String (optional)
  /// 
  /// Returns a Map with:
  /// - success: true if successful, false otherwise
  /// - data: Updated dorm data or null
  /// - message: Success or error message
  Future<Map<String, dynamic>> updateDorm(
    String dormId,
    Map<String, dynamic> dormData,
  ) async {
    try {
      final uri = Uri.parse('$_baseUrl/modules/mobile-api/dorms/update_dorm_api.php');
      
      final body = {
        'dorm_id': dormId,
        ...dormData,
      };
      
      final response = await http.post(
        uri,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          return {
            'success': true,
            'data': data,
            'message': data['message'] ?? 'Dorm updated successfully',
          };
        } else {
          return {
            'success': false,
            'error': data['error'] ?? 'Unknown error',
            'message': data['message'] ?? 'Failed to update dorm',
          };
        }
      } else {
        return {
          'success': false,
          'error': 'HTTP Error',
          'message': 'Failed to update dorm. Status: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Exception',
        'message': 'Error updating dorm: ${e.toString()}',
      };
    }
  }
}
