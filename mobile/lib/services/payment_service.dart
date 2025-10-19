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
      print('📡 [PaymentService] Fetching payments for: $studentEmail');
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}/modules/mobile-api/student/student_payments_api.php?student_email=$studentEmail'
        ),
      );

      print('📡 [PaymentService] Response status: ${response.statusCode}');
      print('📡 [PaymentService] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('📡 [PaymentService] Decoded data ok: ${data['ok']}');
        
        if (data['ok'] == true) {
          return {
            'success': true,
            'data': {
              'statistics': data['statistics'] ?? {},
              'payments': data['payments'] ?? [],
            },
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
      print('📡 [PaymentService] ❌ Exception: $e');
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
        '${ApiConstants.baseUrl}/modules/mobile-api/owner/owner_payments_api.php'
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
        Uri.parse('${ApiConstants.baseUrl}/modules/mobile-api/payments/upload_receipt_api.php'),
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

  /// Completes a payment (marks as paid)
  /// 
  /// Parameters:
  /// - [paymentId]: ID of the payment
  /// - [ownerEmail]: Email of the owner
  /// 
  /// Returns:
  /// - Map with keys:
  ///   - success: boolean indicating if the payment was completed
  ///   - message: Success or error message
  Future<Map<String, dynamic>> completePayment(int paymentId, String ownerEmail) async {
    try {
      print('📡 [PaymentService] Completing payment: $paymentId');
      
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/modules/mobile-api/owner/owner_payments_api.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'complete',
          'payment_id': paymentId,
          'owner_email': ownerEmail,
        }),
      );

      print('📡 [PaymentService] Complete response status: ${response.statusCode}');
      print('📡 [PaymentService] Complete response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          return {
            'success': true,
            'message': data['message'] ?? 'Payment completed successfully',
          };
        } else {
          return {
            'success': false,
            'message': data['error'] ?? 'Failed to complete payment',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('📡 [PaymentService] ❌ Exception: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Rejects a payment
  /// 
  /// Parameters:
  /// - [paymentId]: ID of the payment
  /// - [ownerEmail]: Email of the owner
  /// 
  /// Returns:
  /// - Map with keys:
  ///   - success: boolean indicating if the payment was rejected
  ///   - message: Success or error message
  Future<Map<String, dynamic>> rejectPayment(int paymentId, String ownerEmail) async {
    try {
      print('📡 [PaymentService] Rejecting payment: $paymentId');
      
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/modules/mobile-api/owner/owner_payments_api.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'reject',
          'payment_id': paymentId,
          'owner_email': ownerEmail,
        }),
      );

      print('📡 [PaymentService] Reject response status: ${response.statusCode}');
      print('📡 [PaymentService] Reject response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          return {
            'success': true,
            'message': data['message'] ?? 'Payment rejected successfully',
          };
        } else {
          return {
            'success': false,
            'message': data['error'] ?? 'Failed to reject payment',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('📡 [PaymentService] ❌ Exception: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Resets a rejected payment to pending so student can upload again
  /// 
  /// Parameters:
  /// - [paymentId]: ID of the payment
  /// - [studentEmail]: Email of the student
  /// 
  /// Returns:
  /// - Map with keys:
  ///   - success: boolean indicating if the payment status was reset
  ///   - message: Success or error message
  Future<Map<String, dynamic>> resetPaymentStatus(int paymentId, String studentEmail) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/modules/mobile-api/payments/reset_payment_status_api.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'payment_id': paymentId,
          'student_email': studentEmail,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        return {
          'ok': false,
          'error': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'ok': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }
}

