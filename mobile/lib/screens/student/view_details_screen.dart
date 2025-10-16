import 'package:flutter/material.dart';
import '../../services/dorm_service.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' show ErrorDisplayWidget;
import '../../widgets/student/view_details/overview_tab.dart';
import '../../widgets/student/view_details/rooms_tab.dart';
import '../../widgets/student/view_details/reviews_tab.dart';
import '../../widgets/student/view_details/contact_tab.dart';
import '../../widgets/student/tabs/location_tab.dart';
import '../../widgets/student/view_details/stat_chip.dart';
import '../shared/chat_conversation_screen.dart';
import 'booking_form_screen.dart';

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

class _ViewDetailsScreenState extends State<ViewDetailsScreen> with SingleTickerProviderStateMixin {
  final DormService _dormService = DormService();
  bool isLoading = true;
  String error = '';
  Map<String, dynamic> dormDetails = {};
  List<dynamic> _rooms = [];
  List<dynamic> _reviews = [];
  List<String> _images = [];
  List<String> _features = [];
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    fetchDormDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchDormDetails() async {
    print('📱 [ViewDetails] Fetching dorm details...');
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final result = await _dormService.getDormDetails(
        widget.property['dorm_id']?.toString() ?? '',
      );

      print('📱 [ViewDetails] Service result success: ${result['success']}');
      
      if (result['success']) {
        final dormData = result['data'];
        final roomsData = result['rooms'] ?? [];
        final reviewsData = result['reviews'] ?? [];
        
        print('📱 [ViewDetails] Dorm data: ${dormData != null ? "loaded" : "null"}');
        print('📱 [ViewDetails] Rooms count: ${roomsData.length}');
        print('📱 [ViewDetails] Reviews count: ${reviewsData.length}');
        
        setState(() {
          dormDetails = dormData ?? {};
          _rooms = roomsData is List ? roomsData : [];
          _reviews = reviewsData is List ? reviewsData : [];
          
          // Extract images from dorm data
          if (dormData != null && dormData['images'] != null) {
            _images = (dormData['images'] as List?)
                ?.map((e) => e.toString())
                .toList() ?? [];
          }
          
          // Parse features from comma-separated string or array
          if (dormData != null && dormData['features'] != null) {
            if (dormData['features'] is List) {
              _features = (dormData['features'] as List)
                  .map((e) => e.toString())
                  .where((e) => e.isNotEmpty)
                  .toList();
            } else {
              final featuresString = dormData['features']?.toString() ?? '';
              _features = featuresString.isNotEmpty 
                  ? featuresString.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
                  : [];
            }
          }
          
          isLoading = false;
        });
        
        print('📱 [ViewDetails] ✅ State updated successfully');
        print('📱 [ViewDetails] Final rooms count: ${_rooms.length}');
      } else {
        print('📱 [ViewDetails] ❌ Failed: ${result['message']}');
        setState(() {
          error = result['message'] ?? 'Failed to load dorm details';
          isLoading = false;
        });
      }
    } catch (e) {
      print('📱 [ViewDetails] ❌ Exception: $e');
      setState(() {
        error = 'Failed to connect. Please check your internet connection.';
        isLoading = false;
      });
    }
  }

  void _navigateToBookingForm() {
    if (_rooms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No rooms available for booking')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingFormScreen(
          dormId: widget.property['dorm_id'] ?? '',
          dormName: widget.property['name'] ?? '',
          rooms: _rooms,
          studentEmail: widget.userEmail,
        ),
      ),
    );
  }

  void _navigateToChat() {
    // Extract owner information
    final owner = dormDetails['owner'] as Map<String, dynamic>?;
    final ownerEmail = owner?['email']?.toString() ?? dormDetails['owner_email']?.toString();
    final ownerId = owner?['user_id'] as int? ?? dormDetails['owner_id'] as int?;
    final ownerName = owner?['name']?.toString() ?? dormDetails['owner_name']?.toString() ?? 'Owner';
    final dormId = dormDetails['dorm_id'] as int? ?? int.tryParse(widget.property['dorm_id'] ?? '');
    final dormName = dormDetails['name']?.toString() ?? widget.property['name'] ?? '';
    
    if (ownerEmail == null || ownerEmail.isEmpty || ownerId == null || dormId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Owner information not available')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatConversationScreen(
          currentUserEmail: widget.userEmail,
          currentUserRole: 'student',
          otherUserId: ownerId,
          otherUserName: ownerName,
          otherUserEmail: ownerEmail,
          dormId: dormId,
          dormName: dormName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: LoadingWidget(message: 'Loading dorm details...'),
      );
    }

    if (error.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.property['name'] ?? 'Dorm Details'),
        ),
        body: ErrorDisplayWidget(
          error: error,
          onRetry: fetchDormDetails,
        ),
      );
    }

    final name = dormDetails['name']?.toString() ?? '';
    final address = dormDetails['address']?.toString() ?? '';
    
    // Extract stats from nested object
    final stats = dormDetails['stats'] as Map<String, dynamic>? ?? {};
    final pricing = dormDetails['pricing'] as Map<String, dynamic>? ?? {};
    
    // Available rooms calculation
    final totalRooms = stats['total_rooms'] as int? ?? _rooms.length;
    final availableRooms = stats['available_rooms'] as int? ?? 
        _rooms.where((room) => room['is_available'] == true).length;
    
    // Price range
    final minPrice = pricing['min_price'] as num? ?? 0;
    final maxPrice = pricing['max_price'] as num? ?? 0;
    final priceDisplay = minPrice > 0 
        ? (minPrice == maxPrice 
            ? '₱${minPrice.toStringAsFixed(0)}/mo' 
            : '₱${minPrice.toStringAsFixed(0)}-${maxPrice.toStringAsFixed(0)}/mo')
        : '₱0/mo';
    
    // Rating
    final rating = (stats['avg_rating'] as num?)?.toDouble() ?? 0.0;
    final reviewCount = stats['total_reviews'] as int? ?? _reviews.length;
    
    // Check if fully booked
    final isFullyBooked = availableRooms == 0;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Image Gallery AppBar
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            backgroundColor: Colors.black.withOpacity(0.3),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3.0,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ],
                ),
              ),
              background: _images.isNotEmpty
                  ? PageView.builder(
                      itemCount: _images.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          _images[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              ),
                            );
                          },
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.apartment,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Row
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      StatChip(
                        icon: Icons.bed,
                        text: '$availableRooms/$totalRooms Slots',
                        color: Colors.blue,
                      ),
                      StatChip(
                        icon: Icons.attach_money,
                        text: priceDisplay,
                        color: Colors.green,
                      ),
                      StatChip(
                        icon: Icons.star,
                        text: rating > 0 ? '$rating ($reviewCount)' : 'N/A',
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ),

                // Address
                if (address.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            address,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Tabs
                TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Theme.of(context).primaryColor,
                  isScrollable: true,
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Rooms'),
                    Tab(text: 'Reviews'),
                    Tab(text: 'Location'),
                    Tab(text: 'Contact'),
                  ],
                ),

                // Tab Content
                SizedBox(
                  height: 400, // Fixed height for TabBarView
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      OverviewTab(
                        dormDetails: dormDetails,
                        features: _features,
                      ),
                      RoomsTab(
                        rooms: _rooms,
                        dormId: dormDetails['dorm_id']?.toString() ?? widget.property['dorm_id']?.toString() ?? '',
                        dormName: dormDetails['name']?.toString() ?? widget.property['name']?.toString() ?? '',
                        studentEmail: widget.userEmail,
                      ),
                      ReviewsTab(reviews: _reviews),
                      LocationTab(dorm: dormDetails),
                      ContactTab(
                        owner: dormDetails['owner'] as Map<String, dynamic>? ?? {},
                        currentUserEmail: widget.userEmail,
                        onSendMessage: _navigateToChat,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Bottom Action Buttons
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _navigateToChat,
                icon: const Icon(Icons.message),
                label: const Text('Message'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: !isFullyBooked ? _navigateToBookingForm : null,
                icon: const Icon(Icons.calendar_month),
                label: Text(isFullyBooked ? 'Fully Booked' : 'Book Now'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
