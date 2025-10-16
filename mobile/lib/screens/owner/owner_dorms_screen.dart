import 'package:flutter/material.dart';
import '../../services/dorm_service.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/owner/dorms/dorm_card.dart';
import '../../widgets/owner/dorms/add_dorm_dialog.dart';
import '../../widgets/owner/dorms/edit_dorm_dialog.dart';
import 'room_management_screen.dart';

/// Screen for managing owner's dormitories
class OwnerDormsScreen extends StatefulWidget {
  final String ownerEmail;
  
  const OwnerDormsScreen({
    super.key,
    required this.ownerEmail,
  });

  @override
  State<OwnerDormsScreen> createState() => _OwnerDormsScreenState();
}

class _OwnerDormsScreenState extends State<OwnerDormsScreen> {
  final DormService _dormService = DormService();
  bool isLoading = true;
  List<Map<String, dynamic>> dorms = [];
  String? error;

  @override
  void initState() {
    super.initState();
    fetchDorms();
  }

  Future<void> fetchDorms() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final result = await _dormService.getOwnerDorms(widget.ownerEmail);
      
      if (result['success']) {
        setState(() {
          dorms = List<Map<String, dynamic>>.from(result['data'] ?? []);
          isLoading = false;
        });
      } else {
        throw Exception(result['message'] ?? 'Failed to load dorms');
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _addDorm(Map<String, String> dormData) async {
    try {
      final result = await _dormService.addDorm({
        'owner_email': widget.ownerEmail,
        ...dormData,
      });

      if (result['success']) {
        await fetchDorms();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Dorm added successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception(result['message'] ?? 'Failed to add dorm');
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

  void _showAddDormDialog() {
    showDialog(
      context: context,
      builder: (context) => AddDormDialog(
        onAdd: _addDorm,
      ),
    );
  }

  void _navigateToRoomManagement(Map<String, dynamic> dorm) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoomManagementScreen(
          dorm: dorm,
          ownerEmail: widget.ownerEmail,
        ),
      ),
    ).then((_) => fetchDorms()); // Refresh when coming back
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Dorms'),
        backgroundColor: Colors.orange,
      ),
      body: RefreshIndicator(
        onRefresh: fetchDorms,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDormDialog,
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
        onRetry: fetchDorms,
      );
    }

    if (dorms.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          Padding(
            padding: EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.home_work,
                  size: 80,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No dorms added yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap the + button to add your first dormitory',
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
      itemCount: dorms.length,
      itemBuilder: (context, index) {
        final dorm = dorms[index];
        return DormCard(
          dorm: dorm,
          onManageRooms: () => _navigateToRoomManagement(dorm),
          onEdit: () => _editDorm(dorm),
          onDelete: () => _deleteDorm(dorm),
        );
      },
    );
  }

  void _editDorm(Map<String, dynamic> dorm) {
    showDialog(
      context: context,
      builder: (context) => EditDormDialog(
        dorm: dorm,
        onUpdate: _updateDorm,
      ),
    );
  }

  Future<void> _updateDorm(String dormId, Map<String, String> dormData) async {
    try {
      final result = await _dormService.updateDorm(dormId, dormData);

      if (result['success']) {
        await fetchDorms();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Dorm updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception(result['message'] ?? 'Failed to update dorm');
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

  void _deleteDorm(Map<String, dynamic> dorm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Dorm'),
        content: Text('Are you sure you want to delete "${dorm['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performDelete(dorm);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _performDelete(Map<String, dynamic> dorm) async {
    try {
      final result = await _dormService.deleteDorm(dorm['dorm_id'].toString());

      if (result['success']) {
        await fetchDorms();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Dorm deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception(result['message'] ?? 'Failed to delete dorm');
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
}
