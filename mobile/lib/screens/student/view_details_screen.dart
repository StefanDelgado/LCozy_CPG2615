import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' show ErrorDisplayWidget;
import '../../widgets/student/view_details/overview_tab.dart';
import '../../widgets/student/view_details/rooms_tab.dart';
import '../../widgets/student/view_details/reviews_tab.dart';
import '../../widgets/student/view_details/contact_tab.dart';
import '../../widgets/student/view_details/stat_chip.dart';
import '../../utils/constants.dart';
// Temporary imports from legacy structure
import '../../legacy/MobileScreen/student_owner_chat.dart';
import '../../legacy/MobileScreen/booking_form.dart';

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
    _tabController = TabController(length: 4, vsync: this);
    fetchDormDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchDormDetails() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/mobile-api/get_dorm_details.php?dorm_id=${widget.property['dorm_id']}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            dormDetails = data['dorm'];
            _rooms = data['rooms'] ?? [];
            _reviews = data['reviews'] ?? [];
            _images = (data['images'] as List?)?.map((e) => e.toString()).toList() ?? [];
            
            // Parse features from comma-separated string
            final featuresString = dormDetails['features']?.toString() ?? '';
            _features = featuresString.isNotEmpty 
                ? featuresString.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
                : [];
            
            isLoading = false;
          });
        } else {
          setState(() {
            error = data['message'] ?? 'Failed to load dorm details';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          error = 'Server error. Please try again later.';
          isLoading = false;
        });
      }
    } catch (e) {
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
    final ownerEmail = dormDetails['owner_email']?.toString();
    if (ownerEmail == null || ownerEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Owner information not available')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentOwnerChatScreen(
          currentUserEmail: widget.userEmail,
          otherUserEmail: ownerEmail,
          currentUserRole: 'student',
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
    final monthlyRate = double.tryParse(dormDetails['monthly_rate']?.toString() ?? '0') ?? 0.0;
    final availableSlots = int.tryParse(dormDetails['available_slots']?.toString() ?? '0') ?? 0;
    final totalSlots = int.tryParse(dormDetails['total_capacity']?.toString() ?? '0') ?? 0;
    final rating = double.tryParse(dormDetails['average_rating']?.toString() ?? '0') ?? 0.0;
    final reviewCount = int.tryParse(dormDetails['review_count']?.toString() ?? '0') ?? 0;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Image Gallery AppBar
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
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
                        text: '$availableSlots/$totalSlots Slots',
                        color: Colors.blue,
                      ),
                      StatChip(
                        icon: Icons.attach_money,
                        text: '₱${monthlyRate.toStringAsFixed(0)}/mo',
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
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Rooms'),
                    Tab(text: 'Reviews'),
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
                      RoomsTab(rooms: _rooms),
                      ReviewsTab(reviews: _reviews),
                      ContactTab(
                        owner: dormDetails,
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
              color: Colors.grey.withOpacity(0.3),
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
                onPressed: availableSlots > 0 ? _navigateToBookingForm : null,
                icon: const Icon(Icons.calendar_month),
                label: Text(availableSlots > 0 ? 'Book Now' : 'Fully Booked'),
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
