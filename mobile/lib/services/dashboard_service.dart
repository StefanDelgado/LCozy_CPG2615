import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

/// Service class for handling dashboard-related API operations.
/// 
/// This service provides methods for:
/// - Fetching owner dashboard statistics and activity data
/// 
/// All methods return a standardized response map with the following structure:
/// - {success: true, data: Map, message: String} on success
/// - {success: false, error: String} on failure
class DashboardService {
  /// Fetches owner dashboard data including stats and recent activity.
  /// 
  /// Makes a GET request to: /modules/mobile-api/owner_dashboard_api.php
  /// 
  /// Parameters:
  /// - [ownerEmail]: Email of the dorm owner
  /// 
  /// Returns a map containing:
  /// - success: true if the request was successful
  /// - data: Dashboard data including:
  ///   - stats: Statistical information (total_dorms, total_rooms, occupancy_rate, etc.)
  ///   - recent_activities: List of recent activities
  ///   - upcoming_payments: List of upcoming payments
  ///   - pending_approvals: List of pending booking approvals
  /// - message: Success message
  /// 
  /// On error, returns:
  /// - success: false
  /// - error: Error description
  /// 
  /// Example:
  /// ```dart
  /// final result = await dashboardService.getOwnerDashboard('owner@example.com');
  /// if (result['success']) {
  ///   final stats = result['data']['stats'];
  ///   final activities = result['data']['recent_activities'];
  /// }
  /// ```
  Future<Map<String, dynamic>> getOwnerDashboard(String ownerEmail) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/modules/mobile-api/owner/owner_dashboard_api.php'
      ).replace(queryParameters: {
        'owner_email': ownerEmail,
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          final data = responseData['data'];
          return {
            'success': true,
            'data': {
              'stats': data['stats'] ?? {},
              'recent_activities': data['stats']?['recent_activities'] ?? [],
              'recent_bookings': data['recent_bookings'] ?? [],
              'recent_payments': data['recent_payments'] ?? [],
              'recent_messages': data['recent_messages'] ?? [],
            },
            'message': 'Dashboard data loaded successfully',
          };
        } else {
          return {
            'success': false,
            'error': responseData['error'] ?? 'Failed to load dashboard data',
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
