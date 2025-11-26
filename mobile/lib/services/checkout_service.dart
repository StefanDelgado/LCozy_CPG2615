import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_constants.dart';

class CheckoutService {
  /// Request checkout for a booking (Student)
  static Future<Map<String, dynamic>> requestCheckout({
    required int studentId,
    required int bookingId,
    String? reason,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/modules/mobile-api/checkout/request_checkout.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'student_id': studentId,
          'booking_id': bookingId,
          'reason': reason ?? '',
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Failed to submit checkout request'
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Connection error: $e'};
    }
  }

  /// Get student's active bookings (Student)
  static Future<Map<String, dynamic>> getStudentBookings({
    required int studentId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${ApiConstants.baseUrl}/modules/mobile-api/checkout/get_student_bookings.php?student_id=$studentId'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'error': 'Failed to fetch bookings'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Connection error: $e'};
    }
  }

  /// Get owner's checkout requests (Owner)
  static Future<Map<String, dynamic>> getOwnerRequests({
    required int ownerId,
  }) async {
    try {
      final url = '${ApiConstants.baseUrl}/modules/mobile-api/checkout/get_owner_requests.php?owner_id=$ownerId';
      print('[DEBUG] Fetching checkout requests from: $url');
      
      final response = await http.get(Uri.parse(url));
      
      print('[DEBUG] Response status: ${response.statusCode}');
      print('[DEBUG] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded;
      } else {
        return {'success': false, 'error': 'Failed to fetch checkout requests'};
      }
    } catch (e) {
      print('[ERROR] getOwnerRequests exception: $e');
      return {'success': false, 'error': 'Connection error: $e'};
    }
  }

  /// Approve checkout request (Owner)
  static Future<Map<String, dynamic>> approveCheckout({
    required int requestId,
    required int ownerId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/modules/mobile-api/checkout/approve_checkout.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'request_id': requestId,
          'owner_id': ownerId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Failed to approve checkout'
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Connection error: $e'};
    }
  }

  /// Disapprove checkout request (Owner)
  static Future<Map<String, dynamic>> disapproveCheckout({
    required int requestId,
    required int ownerId,
    String? reason,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/modules/mobile-api/checkout/disapprove_checkout.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'request_id': requestId,
          'owner_id': ownerId,
          'reason': reason ?? '',
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Failed to disapprove checkout'
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Connection error: $e'};
    }
  }

  /// Complete checkout request (Owner)
  static Future<Map<String, dynamic>> completeCheckout({
    required int requestId,
    required int ownerId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/modules/mobile-api/checkout/complete_checkout.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'request_id': requestId,
          'owner_id': ownerId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Failed to complete checkout'
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Connection error: $e'};
    }
  }

  /// Get past tenants (Owner)
  static Future<Map<String, dynamic>> getPastTenants({
    required int ownerId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${ApiConstants.baseUrl}/modules/mobile-api/checkout/get_past_tenants.php?owner_id=$ownerId'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'error': 'Failed to fetch past tenants'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Connection error: $e'};
    }
  }
}
