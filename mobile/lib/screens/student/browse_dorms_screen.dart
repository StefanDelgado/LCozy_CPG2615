import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../utils/constants.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../student/view_details_screen.dart';

/// Screen for browsing and searching available dorms
class BrowseDormsScreen extends StatefulWidget {
  final String? searchQuery;
  final String userEmail;
  
  const BrowseDormsScreen({
    super.key, 
    this.searchQuery,
    required this.userEmail,
  });

  @override
  State<BrowseDormsScreen> createState() => _BrowseDormsScreenState();
}

class _BrowseDormsScreenState extends State<BrowseDormsScreen> {
  bool isLoading = true;
  String? error;
  List<Map<String, dynamic>> dorms = [];

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
      final uri = Uri.parse(ApiConstants.studentDashboardEndpoint);
      final rsp = await http.get(uri);
      
      if (rsp.statusCode != 200) {
        throw Exception('Server error: ${rsp.statusCode}');
      }
      
      final data = jsonDecode(rsp.body);
      
      if (data is Map && data['ok'] == true && data['dorms'] != null) {
        var list = List.from(data['dorms']);
        var items = list.map((e) => Map<String, dynamic>.from(e)).toList();
        
        // Apply search filter if query provided
        if (widget.searchQuery != null && widget.searchQuery!.trim().isNotEmpty) {
          final q = widget.searchQuery!.toLowerCase();
          items = items.where((p) {
            final t = (p['title'] ?? '').toString().toLowerCase();
            final l = (p['location'] ?? '').toString().toLowerCase();
            return t.contains(q) || l.contains(q);
          }).toList();
        }
        
        setState(() {
          dorms = items;
          isLoading = false;
        });
      } else {
        throw Exception('Invalid response from server');
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
        title: Text(
          widget.searchQuery == null || widget.searchQuery!.isEmpty 
            ? 'Browse Dorms' 
            : 'Search: ${widget.searchQuery}'
        ),
        backgroundColor: Colors.orange,
      ),
      body: RefreshIndicator(
        onRefresh: fetchDorms,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
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
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text(
                'No dorms found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ),
        ],
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: dorms.length,
      itemBuilder: (context, i) => _buildDormCard(dorms[i]),
    );
  }

  Widget _buildDormCard(Map<String, dynamic> dorm) {
    final image = dorm['image'] ?? '';
    final title = dorm['title'] ?? 'Unnamed Dorm';
    final location = dorm['location'] ?? '';
    final minPrice = dorm['min_price'] ?? '';
    final available = dorm['available_rooms']?.toString() ?? '0';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToDetails(dorm),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            _buildDormImage(image),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.black54),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: const TextStyle(color: Colors.black54, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (minPrice != null && minPrice != '') 
                          Text(
                            minPrice,
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$available rooms',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDormImage(String? image) {
    return Container(
      width: 110,
      height: 90,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomLeft: Radius.circular(12),
        ),
        color: Colors.grey[200],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomLeft: Radius.circular(12),
        ),
        child: (image != null && image.isNotEmpty)
            ? Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.home,
                  size: 40,
                  color: Colors.grey,
                ),
              )
            : const Icon(
                Icons.home,
                size: 40,
                color: Colors.grey,
              ),
      ),
    );
  }

  void _navigateToDetails(Map<String, dynamic> dorm) {
    // Convert to format expected by ViewDetailsScreen
    final property = <String, String>{
      'dorm_id': dorm['dorm_id']?.toString() ?? '',
      'title': dorm['title']?.toString() ?? '',
      'location': dorm['location']?.toString() ?? '',
      'desc': dorm['desc']?.toString() ?? '',
      'image': dorm['image']?.toString() ?? '',
      'owner_email': dorm['owner_email']?.toString() ?? '',
      'owner_name': dorm['owner_name']?.toString() ?? '',
      'min_price': dorm['min_price']?.toString() ?? '',
      'available_rooms': dorm['available_rooms']?.toString() ?? '',
    };
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ViewDetailsScreen(
          property: property,
          userEmail: widget.userEmail,
        ),
      ),
    );
  }
}
