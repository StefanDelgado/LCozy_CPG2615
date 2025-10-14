import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Dorms'),
        backgroundColor: Colors.orange,
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
              return DormCard(dorm: dorm);
            },
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add dorm
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.orange,
      ),
    );
  }
}

class DormCard extends StatelessWidget {
  final Map<String, dynamic> dorm;

  const DormCard({Key? key, required this.dorm}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
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
      color = Colors.orange;
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