import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';
import 'package:flutter/services.dart';
import '../../services/room_service.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/owner/dorms/room_card.dart';
import '../../widgets/owner/dorms/add_room_dialog.dart';
import 'owner_reviews_screen.dart';

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
  final RoomService _roomService = RoomService();
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
      final result = await _roomService.getRoomsByDorm(
        int.parse(widget.dorm['dorm_id'].toString()),
      );

      if (result['success']) {
        setState(() {
          rooms = List<Map<String, dynamic>>.from(result['data'] ?? []);
          isLoading = false;
        });
      } else {
        throw Exception(result['error'] ?? 'Failed to load rooms');
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
      final result = await _roomService.addRoom({
        'owner_email': widget.ownerEmail,
        'dorm_id': widget.dorm['dorm_id'],
        ...roomData,
      });

      if (result['success']) {
        await fetchRooms();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Room added successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception(result['message'] ?? 'Failed to add room');
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
      final result = await _roomService.updateRoom(
        int.parse(room['room_id'].toString()),
        {
          'owner_email': widget.ownerEmail,
          ...roomData,
        },
      );

      if (result['success']) {
        await fetchRooms();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Room updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception(result['message'] ?? 'Failed to update room');
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
      final result = await _roomService.deleteRoom(
        int.parse(room['room_id'].toString()),
        widget.ownerEmail,
      );

      if (result['success']) {
        await fetchRooms();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Room deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception(result['message'] ?? 'Failed to delete room');
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
        backgroundColor: AppTheme.primary,
      ),
      body: RefreshIndicator(
        onRefresh: fetchRooms,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRoomDialog,
        backgroundColor: AppTheme.primary,
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

    // Show a prominent "View Reviews" button followed by the rooms list
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF7C3AED)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OwnerReviewsScreen(
                    dormId: int.tryParse(widget.dorm['dorm_id'].toString()) ?? 0,
                    dormName: widget.dorm['name'] ?? '',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.rate_review, size: 20),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('View Reviews', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Rooms
        ...rooms.map((room) => RoomCard(
          room: room,
          onEdit: () => _showEditRoomDialog(room),
          onDelete: () => _deleteRoom(room),
        )).toList(),
      ],
    );
  }
}
