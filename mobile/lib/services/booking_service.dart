import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

/// Service class for managing booking-related API operations
/// Handles all booking operations including fetching, creating, and updating bookings
class BookingService {
  /// Fetches bookings for a student
  /// 
  /// Parameters:
  /// - [studentEmail]: The email of the student
  /// 
  /// Returns:
  /// - Map with keys:
  ///   - success: boolean indicating if the request was successful
  ///   - data: Map containing dashboard data (bookings, etc.) if successful
  ///   - error: Error message if request failed
  Future<Map<String, dynamic>> getStudentBookings(String studentEmail) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}/modules/mobile-api/student/student_dashboard_api.php?student_email=${Uri.encodeComponent(studentEmail)}'
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          return {
            'success': true,
            'data': data,
          };
        } else {
          return {
            'success': false,
            'error': data['error'] ?? 'Failed to fetch student bookings',
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

  /// Fetches bookings for an owner
  /// 
  /// Parameters:
  /// - [ownerEmail]: The email of the owner
  /// 
  /// Returns:
  /// - Map with keys:
  ///   - success: boolean indicating if the request was successful
  ///   - data: List of booking objects if successful
  ///   - error: Error message if request failed
  Future<Map<String, dynamic>> getOwnerBookings(String ownerEmail) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/modules/mobile-api/owner/owner_bookings_api.php'
      ).replace(queryParameters: {
        'owner_email': ownerEmail,
      });

      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          return {
            'success': true,
            'data': data['bookings'] ?? [],
          };
        } else {
          return {
            'success': false,
            'error': data['error'] ?? 'Failed to fetch owner bookings',
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

  /// Creates a new booking
  /// 
  /// Parameters:
  /// - [bookingData]: Map containing booking information
  ///   Required fields:
  ///   - student_email: Email of the student
  ///   - dorm_id: ID of the dorm
  ///   - room_id: ID of the room
  ///   - check_in_date: Check-in date
  ///   - check_out_date: Check-out date
  ///   Optional fields based on requirements
  /// 
  /// Returns:
  /// - Map with keys:
  ///   - success: boolean indicating if the booking was created
  ///   - message: Success or error message
  ///   - data: Created booking data if successful
  Future<Map<String, dynamic>> createBooking(Map<String, dynamic> bookingData) async {
    print('📝 [Booking] ========== CREATE BOOKING START ==========');
    print('📝 [Booking] Input data: $bookingData');
    print('📝 [Booking] Student email: ${bookingData['student_email']}');
    print('📝 [Booking] Dorm ID: ${bookingData['dorm_id']}');
    print('📝 [Booking] Room ID: ${bookingData['room_id']}');
    print('📝 [Booking] Booking type: ${bookingData['booking_type']}');
    print('📝 [Booking] Check-in date: ${bookingData['check_in_date']}');
    print('📝 [Booking] Check-out date: ${bookingData['check_out_date']}');
    
    try {
      final url = '${ApiConstants.baseUrl}/modules/mobile-api/bookings/create_booking_api.php';
      print('📝 [Booking] Request URL: $url');
      print('📝 [Booking] Request headers: Content-Type: application/json');
      print('📝 [Booking] Request body (JSON): ${jsonEncode(bookingData)}');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(bookingData),
      );

      print('📝 [Booking] Response status: ${response.statusCode}');
      print('📝 [Booking] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('📝 [Booking] Parsed response data: $data');
        print('📝 [Booking] OK flag: ${data['ok']}');
        
        // PHP API returns 'ok' not 'success'
        if (data['ok'] == true) {
          print('📝 [Booking] ✅ Booking created successfully!');
          return {
            'success': true,
            'message': data['message'] ?? 'Booking created successfully',
            'data': data['booking'],
          };
        } else {
          print('📝 [Booking] ❌ API returned ok=false');
          print('📝 [Booking] Error message: ${data['error'] ?? data['message']}');
          return {
            'success': false,
            'message': data['error'] ?? data['message'] ?? 'Failed to create booking',
          };
        }
      } else {
        print('📝 [Booking] ❌ Server error - HTTP ${response.statusCode}');
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e, stackTrace) {
      print('📝 [Booking] ❌ Exception caught: $e');
      print('📝 [Booking] ❌ Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Updates a booking status (approve/reject)
  /// 
  /// Parameters:
  /// - [bookingId]: The ID of the booking to update
  /// - [action]: The action to perform ('approve' or 'reject')
  /// - [ownerEmail]: The email of the owner performing the action
  /// 
  /// Returns:
  /// - Map with keys:
  ///   - success: boolean indicating if the booking was updated
  ///   - message: Success or error message
  Future<Map<String, dynamic>> updateBookingStatus({
    required String bookingId,
    required String action,
    required String ownerEmail,
  }) async {
    try {
      print('📋 [BookingService] Updating booking status...');
      print('📋 [BookingService] Booking ID: $bookingId');
      print('📋 [BookingService] Action: $action');
      print('📋 [BookingService] Owner Email: $ownerEmail');

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/modules/mobile-api/owner/owner_bookings_api.php'),
        body: {
          'action': action,
          'booking_id': bookingId,
          'owner_email': ownerEmail,
        },
      );

      print('📋 [BookingService] Response status: ${response.statusCode}');
      print('📋 [BookingService] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          print('📋 [BookingService] ✅ Booking updated successfully');
          return {
            'success': true,
            'message': data['message'] ?? 'Booking updated successfully',
          };
        } else {
          print('📋 [BookingService] ❌ Update failed: ${data['error']}');
          return {
            'success': false,
            'message': data['error'] ?? 'Failed to update booking',
          };
        }
      } else {
        print('📋 [BookingService] ❌ Server error: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('📋 [BookingService] ❌ Exception: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Cancels a booking (student cancellation)
  /// 
  /// Parameters:
  /// - [bookingId]: The ID of the booking to cancel
  /// - [studentEmail]: The email of the student canceling
  /// - [cancellationReason]: Optional reason for cancellation
  /// 
  /// Returns:
  /// - Map with keys:
  ///   - success: boolean indicating if the request was successful
  ///   - message: Success or error message
  Future<Map<String, dynamic>> cancelBooking({
    required int bookingId,
    required String studentEmail,
    String? cancellationReason,
  }) async {
    try {
      print('📋 [BookingService] Canceling booking...');
      print('📋 [BookingService] Booking ID: $bookingId');
      print('📋 [BookingService] Student Email: $studentEmail');
      print('📋 [BookingService] Reason: $cancellationReason');

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/modules/mobile-api/student/cancel_booking.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'booking_id': bookingId,
          'student_email': studentEmail,
          'cancellation_reason': cancellationReason ?? '',
        }),
      );

      print('📋 [BookingService] Response status: ${response.statusCode}');
      print('📋 [BookingService] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          print('📋 [BookingService] ✅ Booking cancelled successfully');
          return {
            'success': true,
            'message': data['message'] ?? 'Booking cancelled successfully',
          };
        } else {
          print('📋 [BookingService] ❌ Cancellation failed: ${data['error']}');
          return {
            'success': false,
            'message': data['error'] ?? 'Failed to cancel booking',
          };
        }
      } else {
        print('📋 [BookingService] ❌ Server error: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('📋 [BookingService] ❌ Exception: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Cancels a cancellation request and reverts booking to pending
  /// 
  /// Parameters:
  /// - [bookingId]: The ID of the booking
  /// - [studentEmail]: The email of the student requesting the cancellation
  /// 
  /// Returns:
  /// - Map with keys:
  ///   - success: boolean indicating if the request was successful
  ///   - message: Success or error message
  ///   - status: New status ('pending') if successful
  Future<Map<String, dynamic>> cancelCancellationRequest({
    required int bookingId,
    required String studentEmail,
  }) async {
    try {
      print('📋 [BookingService] Canceling cancellation request...');
      print('📋 [BookingService] Booking ID: $bookingId');
      print('📋 [BookingService] Student Email: $studentEmail');

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/modules/mobile-api/student/cancel_cancellation_request.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'booking_id': bookingId,
          'student_email': studentEmail,
        }),
      );

      print('📋 [BookingService] Response status: ${response.statusCode}');
      print('📋 [BookingService] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          print('📋 [BookingService] ✅ Cancellation request cancelled successfully');
          return {
            'success': true,
            'message': data['message'] ?? 'Cancellation request cancelled successfully',
            'status': data['status'] ?? 'pending',
          };
        } else {
          print('📋 [BookingService] ❌ Failed: ${data['error']}');
          return {
            'success': false,
            'error': data['error'] ?? 'Failed to cancel cancellation request',
          };
        }
      } else {
        print('📋 [BookingService] ❌ Server error: ${response.statusCode}');
        return {
          'success': false,
          'error': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('📋 [BookingService] ❌ Exception: $e');
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Acknowledges a cancelled booking
  Future<Map<String, dynamic>> acknowledgeCancellation({
    required int bookingId,
    required String ownerEmail,
  }) async {
    try {
      print('📋 [BookingService] Acknowledging cancellation...');
      print('📋 [BookingService] Booking ID: $bookingId');
      print('📋 [BookingService] Owner Email: $ownerEmail');

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/modules/mobile-api/owner/acknowledge_cancellation.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'booking_id': bookingId,
          'owner_email': ownerEmail,
        }),
      );

      print('📋 [BookingService] Response status: ${response.statusCode}');
      print('📋 [BookingService] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          print('📋 [BookingService] ✅ Cancellation acknowledged successfully');
          return {
            'success': true,
            'message': data['message'] ?? 'Cancellation acknowledged successfully',
          };
        } else {
          print('📋 [BookingService] ❌ Acknowledgement failed: ${data['error']}');
          return {
            'success': false,
            'message': data['error'] ?? 'Failed to acknowledge cancellation',
          };
        }
      } else {
        print('📋 [BookingService] ❌ Server error: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('📋 [BookingService] ❌ Exception: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Uploads student's copy of contract document
  Future<Map<String, dynamic>> uploadStudentContract({
    required int bookingId,
    required String studentEmail,
    required File contractFile,
  }) async {
    try {
      print('📋 [BookingService] Uploading student contract...');
      print('📋 [BookingService] Booking ID: $bookingId');
      print('📋 [BookingService] Student Email: $studentEmail');
      print('📋 [BookingService] File path: ${contractFile.path}');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}/modules/mobile-api/student/upload_student_contract.php'),
      );

      request.fields['booking_id'] = bookingId.toString();
      request.fields['student_email'] = studentEmail;

      request.files.add(await http.MultipartFile.fromPath(
        'contract_document',
        contractFile.path,
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('📋 [BookingService] Response status: ${response.statusCode}');
      print('📋 [BookingService] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          print('📋 [BookingService] ✅ Contract uploaded successfully');
          return {
            'success': true,
            'message': data['message'] ?? 'Contract uploaded successfully',
            'file_path': data['file_path'],
          };
        } else {
          print('📋 [BookingService] ❌ Upload failed: ${data['error']}');
          return {
            'success': false,
            'message': data['error'] ?? 'Failed to upload contract',
          };
        }
      } else {
        print('📋 [BookingService] ❌ Server error: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('📋 [BookingService] ❌ Exception: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}


