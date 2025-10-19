import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'student_owner_chat.dart';
import 'booking_form.dart';

class ViewDetailsScreen extends StatefulWidget {
  final Map<String, String> property;
  final String userEmail;
  
  const ViewDetailsScreen({
    super.key, 
    required this.property,
    required this.userEmail,
  });

  @override
  State<ViewDetailsScreen> createState() => _ViewDetailsScreenState();
}

class _ViewDetailsScreenState extends State<ViewDetailsScreen> {
  bool isLoading = true;
  String error = '';
  Map<String, dynamic> dormDetails = {};
  List<dynamic> rooms = [];
  List<dynamic> reviews = [];
  List<String> images = [];

  @override
  void initState() {
    super.initState();
    fetchDormDetails();
  }

  // Helper method to safely parse double values
  double _parseDouble(dynamic value, double defaultValue) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  // Helper method to safely display text, replacing null with N/A
  String _safeText(dynamic value, [String defaultText = 'N/A']) {
    if (value == null) return defaultText;
    String text = value.toString();
    if (text.isEmpty || text.toLowerCase() == 'null') return defaultText;
    return text;
  }

  Future<void> fetchDormDetails() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final dormId = widget.property['dorm_id'];
      if (dormId == null || dormId.isEmpty) {
        throw Exception('Dorm ID is required');
      }

      final response = await http.get(
        Uri.parse('http://cozydorms.life/modules/mobile-api/dorms/dorm_details_api.php?dorm_id=$dormId'),
      );

      print('Dorm Details API Response: ${response.statusCode}');
      print('Dorm Details API Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          setState(() {
            dormDetails = data['dorm'] ?? {};
            rooms = data['rooms'] ?? [];
            reviews = data['reviews'] ?? [];
            
            // Safely parse images list with null handling
            final imagesList = dormDetails['images'];
            if (imagesList != null && imagesList is List) {
              images = imagesList
                  .where((img) => img != null && img.toString().isNotEmpty)
                  .map((img) => img.toString())
                  .toList();
            } else {
              images = [];
            }
            
            // Add placeholder if no images
            if (images.isEmpty) {
              images.add('https://via.placeholder.com/800x400?text=No+Image');
            }
            
            isLoading = false;
          });
        } else {
          throw Exception(data['error'] ?? 'Failed to load dorm details');
        }
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching dorm details: $e');
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.primary,
          title: const Text('Loading...'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (error.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.primary,
          title: const Text('Error'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Failed to load dorm details'),
              const SizedBox(height: 8),
              Text(error, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: fetchDormDetails,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final owner = dormDetails['owner'] ?? {};
    final stats = dormDetails['stats'] ?? {};
    final pricing = dormDetails['pricing'] ?? {};
    
    // Safely parse features list with null handling
    final featuresList = dormDetails['features'];
    final features = featuresList != null && featuresList is List
        ? featuresList
            .where((f) => f != null && f.toString().isNotEmpty)
            .map((f) => f.toString())
            .toList()
        : <String>[];
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: DefaultTabController(
        length: 4,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: AppTheme.primary,
                flexibleSpace: FlexibleSpaceBar(
                  background: images.isNotEmpty
                      ? PageView.builder(
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            return Image.network(
                              images[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_not_supported, size: 64),
                                );
                              },
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported, size: 64),
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _safeText(dormDetails['name'], 'Unknown Dorm'),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (dormDetails['verified'] == true)
                            const Icon(Icons.verified, color: Colors.blue),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.grey, size: 18),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _safeText(dormDetails['address'], 'Address not available'),
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildStatChip(
                            Icons.star,
                            '${stats['avg_rating'] ?? 0} (${stats['total_reviews'] ?? 0} reviews)',
                            AppTheme.primary,
                          ),
                          const SizedBox(width: 12),
                          _buildStatChip(
                            Icons.meeting_room,
                            '${stats['available_rooms'] ?? 0}/${stats['total_rooms'] ?? 0} available',
                            Colors.green,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${pricing['currency'] ?? '₱'}${pricing['min_price'] ?? 0} - ${pricing['currency'] ?? '₱'}${pricing['max_price'] ?? 0} / month',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  const TabBar(
                    labelColor: AppTheme.primary,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppTheme.primary,
                    tabs: [
                      Tab(text: 'Overview'),
                      Tab(text: 'Rooms'),
                      Tab(text: 'Reviews'),
                      Tab(text: 'Contact'),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              // Overview Tab
              _buildOverviewTab(features),
              
              // Rooms Tab
              _buildRoomsTab(),
              
              // Reviews Tab
              _buildReviewsTab(),
              
              // Contact Tab
              _buildContactTab(owner),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentOwnerChatScreen(
                        currentUserEmail: widget.userEmail,
                        currentUserRole: 'student',
                        otherUserEmail: owner['email'] ?? '',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.message),
                label: const Text('Message Owner'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: rooms.any((room) => room['is_available'] == true)
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingFormScreen(
                              dormId: dormDetails['dorm_id']?.toString() ?? '',
                              dormName: dormDetails['name'] ?? '',
                              rooms: rooms,
                              studentEmail: widget.userEmail,
                            ),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.book_online),
                label: const Text('Book Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  disabledBackgroundColor: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(List<String> features) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About This Dorm',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            _safeText(dormDetails['description'], 'No description available.'),
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
          if (features.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Features & Amenities',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(feature)),
                ],
              ),
            )),
          ],
          const SizedBox(height: 24),
          const Text(
            'Location',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          kIsWeb
              ? Container(
                  height: 200,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Map not available on web',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : SizedBox(
                  height: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          _parseDouble(dormDetails['latitude'], 10.6765),
                          _parseDouble(dormDetails['longitude'], 122.9509),
                        ),
                        zoom: 15,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId('dorm'),
                          position: LatLng(
                            _parseDouble(dormDetails['latitude'], 10.6765),
                            _parseDouble(dormDetails['longitude'], 122.9509),
                          ),
                          infoWindow: InfoWindow(
                            title: dormDetails['name']?.toString() ?? '',
                          ),
                        ),
                      },
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildRoomsTab() {
    if (rooms.isEmpty) {
      return const Center(
        child: Text('No rooms available'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        final room = rooms[index];
        final isAvailable = room['is_available'] == true;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _safeText(room['room_type'], 'Unknown Room'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isAvailable 
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isAvailable ? 'Available' : 'Full',
                        style: TextStyle(
                          color: isAvailable ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.people, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Capacity: ${room['capacity']} persons',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    if (room['size'] != null) ...[
                      const SizedBox(width: 16),
                      Icon(Icons.square_foot, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${room['size']} sqm',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '₱${room['price']}/month',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
                if (isAvailable) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${room['available_slots']} slots remaining',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReviewsTab() {
    if (reviews.isEmpty) {
      return const Center(
        child: Text('No reviews yet'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _safeText(review['student_name'], 'Anonymous'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _safeText(review['stars'], ''),
                      style: const TextStyle(color: AppTheme.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(_safeText(review['review'], 'No comment')),
                const SizedBox(height: 4),
                Text(
                  _safeText(review['created_at'], ''),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactTab(Map<String, dynamic> owner) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Owner Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildContactRow(Icons.person, 'Name', _safeText(owner['name'], 'Not available')),
          _buildContactRow(Icons.email, 'Email', _safeText(owner['email'], 'Not available')),
          _buildContactRow(Icons.phone, 'Phone', _safeText(owner['phone'], 'Not provided')),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentOwnerChatScreen(
                      currentUserEmail: widget.userEmail,
                      currentUserRole: 'student',
                      otherUserEmail: owner['email'] ?? '',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.message),
              label: const Text('Send Message'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}