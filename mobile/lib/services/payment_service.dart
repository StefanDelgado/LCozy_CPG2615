import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

/// Service class for managing payment-related API operations
/// Handles all payment operations including fetching payments and uploading receipts
class PaymentService {
  /// Fetches payment data for a student
  /// 
  /// Parameters:
  /// - [studentEmail]: The email of the student
  /// 
  /// Returns:
  /// - Map with keys:
  ///   - success: boolean indicating if the request was successful
  ///   - data: Map containing payments list if successful
  ///   - error: Error message if request failed
  Future<Map<String, dynamic>> getStudentPayments(String studentEmail) async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://cozydorms.life/modules/mobile-api/student_payments_api.php?student_email=$studentEmail'
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          return {
            'success': true,
            'data': data['payments'] ?? [],
          };
        } else {
          return {
            'success': false,
            'error': data['error'] ?? 'Failed to fetch student payments',
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

  /// Fetches payment data for an owner
  /// 
  /// Parameters:
  /// - [ownerEmail]: The email of the owner
  /// 
  /// Returns:
  /// - Map with keys:
  ///   - success: boolean indicating if the request was successful
  ///   - data: Map containing stats and payments list if successful
  ///   - error: Error message if request failed
  Future<Map<String, dynamic>> getOwnerPayments(String ownerEmail) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/modules/mobile-api/owner_payments_api.php'
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
              'stats': data['stats'] ?? {},
              'payments': data['payments'] ?? [],
            },
          };
        } else {
          return {
            'success': false,
            'error': data['error'] ?? 'Failed to fetch owner payments',
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

  /// Uploads a payment receipt/proof
  /// 
  /// Parameters:
  /// - [paymentData]: Map containing payment receipt information
  ///   Required fields:
  ///   - booking_id: ID of the booking
  ///   - student_email: Email of the student
  ///   - receipt_image: Base64 encoded image or file path
  ///   Optional fields based on requirements
  /// 
  /// Returns:
  /// - Map with keys:
  ///   - success: boolean indicating if the receipt was uploaded
  ///   - message: Success or error message
  ///   - data: Upload response data if successful
  Future<Map<String, dynamic>> uploadPaymentProof(Map<String, dynamic> paymentData) async {
    try {
      final response = await http.post(
        Uri.parse('http://cozydorms.life/modules/mobile-api/upload_receipt_api.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(paymentData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          return {
            'success': true,
            'message': data['message'] ?? 'Receipt uploaded successfully',
            'data': data,
          };
        } else {
          return {
            'success': false,
            'message': data['error'] ?? 'Failed to upload receipt',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}
