import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../utils/constants.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/owner/dorms/room_card.dart';
import '../../widgets/owner/dorms/add_room_dialog.dart';

/// Screen for managing rooms within a dormitory
class RoomManagementScreen extends StatefulWidget {
  final Map<String, dynamic> dorm;
  final String ownerEmail;

  const RoomManagementScreen({
    super.key,
    required this.dorm,
    required this.ownerEmail,
  });

  @override
  State<RoomManagementScreen> createState() => _RoomManagementScreenState();
}

class _RoomManagementScreenState extends State<RoomManagementScreen> {
  List<Map<String, dynamic>> rooms = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchRooms();
  }

  Future<void> fetchRooms() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/modules/mobile-api/fetch_rooms.php?dorm_id=${widget.dorm['dorm_id']}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          setState(() {
            rooms = List<Map<String, dynamic>>.from(data['rooms'] ?? []);
            isLoading = false;
          });
        } else {
          throw Exception(data['error'] ?? 'Failed to load rooms');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _addRoom(Map<String, dynamic> roomData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/modules/mobile-api/add_room_api.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'owner_email': widget.ownerEmail,
          'dorm_id': widget.dorm['dorm_id'],
          ...roomData,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          await fetchRooms();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Room added successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          throw Exception(data['error'] ?? 'Failed to add room');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      rethrow;
    }
  }

  Future<void> _editRoom(Map<String, dynamic> room, Map<String, dynamic> roomData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/modules/mobile-api/edit_room_api.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'owner_email': widget.ownerEmail,
          'room_id': room['room_id'],
          ...roomData,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          await fetchRooms();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Room updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          throw Exception(data['error'] ?? 'Failed to update room');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      rethrow;
    }
  }

  Future<void> _deleteRoom(Map<String, dynamic> room) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Room'),
        content: Text('Are you sure you want to delete ${room['room_type']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/modules/mobile-api/delete_room_api.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'owner_email': widget.ownerEmail,
          'room_id': room['room_id'],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          await fetchRooms();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Room deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          throw Exception(data['error'] ?? 'Failed to delete room');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddRoomDialog() {
    showDialog(
      context: context,
      builder: (context) => AddRoomDialog(
        onAdd: _addRoom,
      ),
    );
  }

  void _showEditRoomDialog(Map<String, dynamic> room) {
    showDialog(
      context: context,
      builder: (context) => AddRoomDialog(
        onAdd: (roomData) => _editRoom(room, roomData),
        initialData: room,
        isEdit: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.dorm['name']} - Rooms'),
        backgroundColor: Colors.orange,
      ),
      body: RefreshIndicator(
        onRefresh: fetchRooms,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRoomDialog,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const LoadingWidget();
    }

    if (error != null) {
      return ErrorDisplayWidget(
        error: error!,
        onRetry: fetchRooms,
      );
    }

    if (rooms.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          Padding(
            padding: EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bed,
                  size: 80,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No rooms added yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap the + button to add your first room',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        final room = rooms[index];
        return RoomCard(
          room: room,
          onEdit: () => _showEditRoomDialog(room),
          onDelete: () => _deleteRoom(room),
        );
      },
    );
  }
}
