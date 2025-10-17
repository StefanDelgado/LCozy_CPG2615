import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

class OwnerDormsScreen extends StatefulWidget {
  final String ownerEmail;
  
  const OwnerDormsScreen({
    Key? key,
    required this.ownerEmail,
  }) : super(key: key);

  @override
  State<OwnerDormsScreen> createState() => _OwnerDormsScreenState();
}

class _OwnerDormsScreenState extends State<OwnerDormsScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> dorms = [];
  String? error;
  
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _featuresController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDorms();
  }

  Future<void> fetchDorms() async {
    try {
      final response = await http.get(
        Uri.parse('http://cozydorms.life/modules/mobile-api/owner_dorms_api.php?owner_email=${widget.ownerEmail}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          setState(() {
            dorms = List<Map<String, dynamic>>.from(data['dorms']);
            isLoading = false;
          });
        } else {
          throw Exception(data['error']);
        }
      } else {
        throw Exception('Server error');
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _addDorm() async {
    try {
      final response = await http.post(
        Uri.parse('http://cozydorms.life/modules/mobile-api/add_dorm_api.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'owner_email': widget.ownerEmail,
          'name': _nameController.text,
          'address': _addressController.text,
          'description': _descriptionController.text,
          'features': _featuresController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          // Clear form
          _nameController.clear();
          _addressController.clear();
          _descriptionController.clear();
          _featuresController.clear();
          
          // Refresh dorms list
          await fetchDorms();
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Dorm added successfully'))
          );
          
          Navigator.pop(context); // Close dialog
        } else {
          throw Exception(data['error']);
        }
      } else {
        throw Exception('Server error');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'))
      );
    }
  }

  void _showAddDormDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Dormitory'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Dorm Name'),
                  validator: (value) => 
                    value?.isEmpty ?? true ? 'Required' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(labelText: 'Address'),
                  validator: (value) => 
                    value?.isEmpty ?? true ? 'Required' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (value) => 
                    value?.isEmpty ?? true ? 'Required' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _featuresController,
                  decoration: InputDecoration(
                    labelText: 'Features',
                    helperText: 'Comma separated (e.g. WiFi, Aircon, etc.)'
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                _addDorm();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
            ),
            child: Text('Add Dorm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Dorms'),
        backgroundColor: AppTheme.primary,
      ),
      body: isLoading 
        ? Center(child: CircularProgressIndicator())
        : error != null
        ? Center(child: Text(error!))
        : dorms.isEmpty
        ? Center(child: Text('No dorms added yet'))
        : ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: dorms.length,
            itemBuilder: (context, index) {
              final dorm = dorms[index];
              return DormCard(
                dorm: dorm,
                ownerEmail: widget.ownerEmail, // Pass owner email
              );
            },
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDormDialog,
        child: Icon(Icons.add),
        backgroundColor: AppTheme.primary,
      ),
    );
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _featuresController.dispose();
    super.dispose();
  }
}

class RoomManagementScreen extends StatefulWidget {
  final Map<String, dynamic> dorm;
  final String ownerEmail;

  const RoomManagementScreen({
    Key? key,
    required this.dorm,
    required this.ownerEmail,
  }) : super(key: key);

  @override
  State<RoomManagementScreen> createState() => _RoomManagementScreenState();
}

class _RoomManagementScreenState extends State<RoomManagementScreen> {
  List<Map<String, dynamic>> rooms = [];
  bool isLoading = true;
  
  final _formKey = GlobalKey<FormState>();
  final _roomTypeController = TextEditingController();
  final _capacityController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchRooms();
  }

  Future<void> fetchRooms() async {
    try {
      final response = await http.get(
        Uri.parse('http://cozydorms.life/modules/mobile-api/fetch_rooms.php?dorm_id=${widget.dorm['dorm_id']}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          setState(() {
            rooms = List<Map<String, dynamic>>.from(data['rooms']);
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching rooms: $e');
    }
  }

  Future<void> _addRoom() async {
    try {
      final response = await http.post(
        Uri.parse('http://cozydorms.life/modules/mobile-api/add_room_api.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'owner_email': widget.ownerEmail,
          'dorm_id': widget.dorm['dorm_id'],
          'room_type': _roomTypeController.text,
          'capacity': int.parse(_capacityController.text),
          'price': double.parse(_priceController.text),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          _roomTypeController.clear();
          _capacityController.clear();
          _priceController.clear();
          await fetchRooms();
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Room added successfully'))
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'))
      );
    }
  }

  void _showAddRoomDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Room'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Room Type'),
                items: ['Single', 'Double', 'Twin', 'Suite']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) => _roomTypeController.text = value ?? '',
                validator: (value) => value == null ? 'Required' : null,
              ),
              TextFormField(
                controller: _capacityController,
                decoration: InputDecoration(labelText: 'Capacity'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price (₱)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                _addRoom();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
            ),
            child: Text('Add Room'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRoom(int roomId) async {
    try {
      final response = await http.post(
        Uri.parse('http://cozydorms.life/modules/mobile-api/delete_room_api.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'owner_email': widget.ownerEmail,
          'room_id': roomId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          await fetchRooms();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Room deleted successfully'))
          );
        } else {
          throw Exception(data['error']);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'))
      );
    }
  }

  Future<void> _editRoom(Map<String, dynamic> room) async {
    _roomTypeController.text = room['room_type'];
    _capacityController.text = room['capacity'].toString();
    _priceController.text = room['price'].toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Room'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Room Type'),
                value: _roomTypeController.text,
                items: ['Single', 'Double', 'Twin', 'Suite']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) => _roomTypeController.text = value ?? '',
                validator: (value) => value == null ? 'Required' : null,
              ),
              TextFormField(
                controller: _capacityController,
                decoration: InputDecoration(labelText: 'Capacity'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price (₱)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                try {
                  final response = await http.post(
                    Uri.parse('http://cozydorms.life/modules/mobile-api/edit_room_api.php'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'owner_email': widget.ownerEmail,
                      'room_id': room['room_id'],
                      'room_type': _roomTypeController.text,
                      'capacity': int.parse(_capacityController.text),
                      'price': double.parse(_priceController.text),
                    }),
                  );

                  if (response.statusCode == 200) {
                    final data = jsonDecode(response.body);
                    if (data['ok'] == true) {
                      await fetchRooms();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Room updated successfully'))
                      );
                    }
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'))
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
            ),
            child: Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Rooms'),
        backgroundColor: AppTheme.primary,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                return Card(
                  child: ListTile(
                    title: Text(room['room_type']),
                    subtitle: Text(
                      'Capacity: ${room['capacity']} • ₱${room['price']}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: room['status'] == 'vacant'
                                ? Colors.green.withOpacity(0.1)
                                : AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            room['status'].toString().toUpperCase(),
                            style: TextStyle(
                              color: room['status'] == 'vacant'
                                  ? Colors.green
                                  : AppTheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: ListTile(
                                leading: Icon(Icons.edit),
                                title: Text('Edit'),
                                contentPadding: EdgeInsets.zero,
                              ),
                              onTap: () => Future(() => _editRoom(room)),
                            ),
                            PopupMenuItem(
                              child: ListTile(
                                leading: Icon(Icons.delete, color: Colors.red),
                                title: Text('Delete', style: TextStyle(color: Colors.red)),
                                contentPadding: EdgeInsets.zero,
                              ),
                              onTap: () => showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Delete Room'),
                                  content: Text('Are you sure you want to delete this room?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _deleteRoom(room['room_id']);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: Text('Delete'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRoomDialog,
        child: Icon(Icons.add),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  @override
  void dispose() {
    _roomTypeController.dispose();
    _capacityController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}

// Update the DormCard class to make it tappable
class DormCard extends StatelessWidget {
  final Map<String, dynamic> dorm;
  final String ownerEmail;

  const DormCard({
    Key? key,
    required this.dorm,
    required this.ownerEmail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell( // Make the card tappable
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RoomManagementScreen(
                dorm: dorm,
                ownerEmail: ownerEmail,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (dorm['cover_image'] != null)
              Image.network(
                'http://cozydorms.life/uploads/${dorm['cover_image']}',
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150,
                  color: Colors.grey[200],
                  child: Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          dorm['name'] ?? 'Unnamed Dorm',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildStatusBadge(dorm['verified']),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    dorm['address'] ?? 'No address provided',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  if (dorm['description'] != null) ...[
                    SizedBox(height: 8),
                    Text(dorm['description']),
                  ],
                  SizedBox(height: 16),
                  Row(
                    children: [
                      _buildInfoChip(Icons.meeting_room, '${dorm['room_count'] ?? 0} Rooms'),
                      SizedBox(width: 12),
                      _buildInfoChip(Icons.book, '${dorm['active_bookings'] ?? 0} Active'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(dynamic verified) {
    Color color;
    String text;
    
    if (verified == 1) {
      color = Colors.green;
      text = 'Verified';
    } else if (verified == -1) {
      color = Colors.red;
      text = 'Rejected';
    } else {
      color = AppTheme.primary;
      text = 'Pending';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 4),
        Text(label, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }
}