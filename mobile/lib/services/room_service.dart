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
      final uri = Uri.parse('${ApiConstants.baseUrl}/modules/mobile-api/fetch_rooms.php?dorm_id=$dormId');
      print('🏠 Fetching rooms for dorm_id: $dormId');
      print('🏠 API URL: $uri');
      
      final response = await http.get(uri);
      print('🏠 Response status: ${response.statusCode}');
      print('🏠 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('🏠 Decoded data: $data');
        
        // Handle both {success: true} and {ok: true} formats
        final isSuccess = data['success'] == true || data['ok'] == true;
        
        if (isSuccess) {
          final rooms = data['rooms'] ?? [];
          print('✅ Rooms fetched successfully: ${rooms.length} rooms');
          return {
            'success': true,
            'data': rooms,
          };
        } else if (data['error'] != null) {
          print('❌ API returned error: ${data['error']}');
          return {
            'success': false,
            'error': data['error'],
          };
        } else {
          print('❌ API returned success=false: ${data['message']}');
          return {
            'success': false,
            'error': data['message'] ?? 'Failed to fetch rooms',
          };
        }
      } else {
        print('❌ Server error: ${response.statusCode}');
        return {
          'success': false,
          'error': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Exception fetching rooms: $e');
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
      print('➕ Adding room with data: $roomData');
      
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/modules/mobile-api/add_room_api.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(roomData),
      );

      print('➕ Response status: ${response.statusCode}');
      print('➕ Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('➕ Decoded data: $data');
        
        // Handle both {success: true} and {ok: true} formats
        final isSuccess = data['success'] == true || data['ok'] == true;
        
        if (isSuccess) {
          print('✅ Room added successfully');
          return {
            'success': true,
            'message': data['message'] ?? 'Room added successfully',
            'data': data['room'],
          };
        } else {
          print('❌ Failed to add room: ${data['message']}');
          return {
            'success': false,
            'message': data['message'] ?? 'Failed to add room',
          };
        }
      } else {
        print('❌ Server error: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Exception adding room: $e');
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
  ///   Required fields:
  ///   - owner_email: Email of the owner (for authorization)
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

      print('✏️ Updating room $roomId with data: $updateData');

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/modules/mobile-api/edit_room_api.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updateData),
      );

      print('✏️ Response status: ${response.statusCode}');
      print('✏️ Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✏️ Decoded data: $data');
        
        // Handle both {success: true} and {ok: true} formats
        final isSuccess = data['success'] == true || data['ok'] == true;
        
        if (isSuccess) {
          print('✅ Room updated successfully');
          return {
            'success': true,
            'message': data['message'] ?? 'Room updated successfully',
            'data': data['room'],
          };
        } else {
          print('❌ Failed to update room: ${data['message']}');
          return {
            'success': false,
            'message': data['message'] ?? 'Failed to update room',
          };
        }
      } else {
        print('❌ Server error: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Exception updating room: $e');
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
  /// - [ownerEmail]: Email of the owner (for authorization)
  /// 
  /// Returns:
  /// - Map with keys:
  ///   - success: boolean indicating if the room was deleted
  ///   - message: Success or error message
  Future<Map<String, dynamic>> deleteRoom(int roomId, String ownerEmail) async {
    try {
      print('🗑️ Deleting room $roomId for owner $ownerEmail');
      
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/modules/mobile-api/delete_room_api.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'room_id': roomId,
          'owner_email': ownerEmail,
        }),
      );

      print('🗑️ Response status: ${response.statusCode}');
      print('🗑️ Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('🗑️ Decoded data: $data');
        
        // Handle both {success: true} and {ok: true} formats
        final isSuccess = data['success'] == true || data['ok'] == true;
        
        if (isSuccess) {
          print('✅ Room deleted successfully');
          return {
            'success': true,
            'message': data['message'] ?? 'Room deleted successfully',
          };
        } else {
          print('❌ Failed to delete room: ${data['message']}');
          return {
            'success': false,
            'message': data['message'] ?? 'Failed to delete room',
          };
        }
      } else {
        print('❌ Server error: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Exception deleting room: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}
