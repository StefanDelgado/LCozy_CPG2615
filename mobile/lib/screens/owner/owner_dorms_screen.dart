import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../utils/constants.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/owner/dorms/dorm_card.dart';
import '../../widgets/owner/dorms/add_dorm_dialog.dart';
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
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/modules/mobile-api/owner_dorms_api.php?owner_email=${widget.ownerEmail}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          setState(() {
            dorms = List<Map<String, dynamic>>.from(data['dorms'] ?? []);
            isLoading = false;
          });
        } else {
          throw Exception(data['error'] ?? 'Failed to load dorms');
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

  Future<void> _addDorm(Map<String, String> dormData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/modules/mobile-api/add_dorm_api.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'owner_email': widget.ownerEmail,
          ...dormData,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          await fetchDorms();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Dorm added successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          throw Exception(data['error'] ?? 'Failed to add dorm');
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
    // TODO: Implement edit functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit feature coming soon')),
    );
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
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/modules/mobile-api/delete_dorm_api.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'dorm_id': dorm['dorm_id'],
          'owner_email': widget.ownerEmail,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          await fetchDorms();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Dorm deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          throw Exception(data['error'] ?? 'Failed to delete dorm');
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
}
