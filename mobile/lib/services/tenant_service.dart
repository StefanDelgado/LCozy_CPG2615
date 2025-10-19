import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

/// Service class for managing tenant-related API operations
/// Handles tenant data fetching for owners
class TenantService {
  /// Fetches tenant data for an owner
  /// 
  /// Parameters:
  /// - [ownerEmail]: The email of the owner
  /// 
  /// Returns:
  /// - Map with keys:
  ///   - success: boolean indicating if the request was successful
  ///   - data: Map containing stats and tenants list if successful
  ///   - error: Error message if request failed
  Future<Map<String, dynamic>> getOwnerTenants(String ownerEmail) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/modules/mobile-api/owner/owner_tenants_api.php'
      ).replace(queryParameters: {
        'owner_email': ownerEmail,
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          return {
            'success': true,
            'data': {
              'current_tenants': data['current_tenants'] ?? [],
              'past_tenants': data['past_tenants'] ?? [],
            },
          };
        } else {
          return {
            'success': false,
            'error': data['error'] ?? 'Failed to fetch tenants',
          };
        }
      } else {
        return {
          'success': false,
          'error': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }
}
