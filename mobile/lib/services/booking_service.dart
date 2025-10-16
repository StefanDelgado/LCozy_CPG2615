import 'dart:convert';
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
          'http://cozydorms.life/modules/mobile-api/student_dashboard_api.php?student_email=${Uri.encodeComponent(studentEmail)}'
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
        '${ApiConstants.baseUrl}/modules/mobile-api/owner_bookings_api.php'
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
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.createBookingEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(bookingData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return {
            'success': true,
            'message': data['message'] ?? 'Booking created successfully',
            'data': data['booking'],
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Failed to create booking',
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
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/modules/mobile-api/owner_bookings_api.php'),
        body: {
          'action': action,
          'booking_id': bookingId,
          'owner_email': ownerEmail,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          return {
            'success': true,
            'message': data['message'] ?? 'Booking updated successfully',
          };
        } else {
          return {
            'success': false,
            'message': data['error'] ?? 'Failed to update booking',
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
