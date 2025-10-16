import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

/// Service class for managing room-related API operations
/// Handles all room CRUD operations and interactions with the backend
class RoomService {
  /// Fetches all rooms for a specific dorm
  /// 
  /// Parameters:
  /// - [dormId]: The ID of the dorm to fetch rooms for
  /// 
  /// Returns:
  /// - Map with keys:
  ///   - success: boolean indicating if the request was successful
  ///   - data: List of room objects if successful
  ///   - error: Error message if request failed
  Future<Map<String, dynamic>> getRoomsByDorm(int dormId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/modules/mobile-api/fetch_rooms.php?dorm_id=$dormId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return {
            'success': true,
            'data': data['rooms'] ?? [],
          };
        } else {
          return {
            'success': false,
            'error': data['message'] ?? 'Failed to fetch rooms',
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

  /// Adds a new room to a dorm
  /// 
  /// Parameters:
  /// - [roomData]: Map containing room information
  ///   Required fields:
  ///   - dorm_id: ID of the dorm
  ///   - room_number: Room number/identifier
  ///   - room_type: Type of room (Single, Double, etc.)
  ///   - capacity: Maximum occupancy
  ///   - price: Monthly rental price
  ///   - status: Room status (Available, Occupied, etc.)
  /// 
  /// Returns:
  /// - Map with keys:
  ///   - success: boolean indicating if the room was added
  ///   - message: Success or error message
  ///   - data: Created room data if successful
  Future<Map<String, dynamic>> addRoom(Map<String, dynamic> roomData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/modules/mobile-api/add_room_api.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(roomData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return {
            'success': true,
            'message': data['message'] ?? 'Room added successfully',
            'data': data['room'],
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Failed to add room',
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

  /// Updates an existing room's information
  /// 
  /// Parameters:
  /// - [roomId]: The ID of the room to update
  /// - [roomData]: Map containing updated room information
  ///   Possible fields:
  ///   - room_number: Updated room number
  ///   - room_type: Updated room type
  ///   - capacity: Updated capacity
  ///   - price: Updated price
  ///   - status: Updated status
  /// 
  /// Returns:
  /// - Map with keys:
  ///   - success: boolean indicating if the room was updated
  ///   - message: Success or error message
  ///   - data: Updated room data if successful
  Future<Map<String, dynamic>> updateRoom(
    int roomId,
    Map<String, dynamic> roomData,
  ) async {
    try {
      final updateData = {
        'room_id': roomId,
        ...roomData,
      };

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/modules/mobile-api/edit_room_api.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return {
            'success': true,
            'message': data['message'] ?? 'Room updated successfully',
            'data': data['room'],
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Failed to update room',
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

  /// Deletes a room from a dorm
  /// 
  /// Parameters:
  /// - [roomId]: The ID of the room to delete
  /// 
  /// Returns:
  /// - Map with keys:
  ///   - success: boolean indicating if the room was deleted
  ///   - message: Success or error message
  Future<Map<String, dynamic>> deleteRoom(int roomId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/modules/mobile-api/delete_room_api.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'room_id': roomId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return {
            'success': true,
            'message': data['message'] ?? 'Room deleted successfully',
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Failed to delete room',
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
