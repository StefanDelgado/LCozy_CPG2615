import 'package:flutter/material.dart';
import '../../services/booking_service.dart';
import '../../../utils/app_theme.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' show ErrorDisplayWidget;
import '../../widgets/owner/dashboard/owner_stat_card.dart';
import '../../widgets/student/home/booking_card.dart';
import '../../widgets/student/home/quick_action_button.dart';
import '../../widgets/student/home/empty_bookings_widget.dart';
import 'submit_review_screen.dart';
import 'view_details_screen.dart';
import 'student_reservations.dart';
import 'booking_details_screen.dart';
// Temporary imports from legacy structure
import 'browse_dorms_screen.dart';
import 'student_payments_screen.dart';
import 'student_profile_screen.dart';
import '../shared/chat_list_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  final String userName;
  final String userEmail;

  const StudentHomeScreen({
    super.key, 
    required this.userName,
    required this.userEmail,
  });

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final BookingService _bookingService = BookingService();
  bool isLoading = true;
  Map<String, dynamic> dashboardData = {};
  String error = '';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final result = await _bookingService.getStudentBookings(widget.userEmail);
      
      print('[DEBUG STUDENT] API result: $result');

      if (result['success']) {
        final data = result['data'];
        print('[DEBUG STUDENT] Full data structure: $data');
        print('[DEBUG STUDENT] data.keys: ${data.keys}');
        print('[DEBUG STUDENT] stats: ${data['stats']}');
        print('[DEBUG STUDENT] stats.keys: ${data['stats']?.keys}');
        print('[DEBUG STUDENT] recent_messages from stats: ${data['stats']?['recent_messages']}');
        
        if (data['stats'] != null && data['student'] != null) {
          setState(() {
            dashboardData = {
              ...data['stats'],
              'student': data['student'],
            };
            print('[DEBUG STUDENT] dashboardData after set: $dashboardData');
            print('[DEBUG STUDENT] dashboardData.keys: ${dashboardData.keys}');
            print('[DEBUG STUDENT] dashboardData[recent_messages]: ${dashboardData['recent_messages']}');
            isLoading = false;
          });
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception(result['error'] ?? 'Failed to load dashboard');
      }
    } catch (e) {
      print('[ERROR STUDENT] Dashboard fetch error: $e');
      setState(() {
        error = 'Failed to load dashboard: ${e.toString()}';
        // Set default empty values
        dashboardData = {
          'active_reservations': 0,
          'payments_due': 0,
          'unread_messages': 0,
          'active_bookings': []
        };
        isLoading = false;
      });
    }
  }

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
    
    switch (index) {
      case 1: // Browse
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BrowseDormsScreen(userEmail: widget.userEmail),
          ),
        );
        break;
      case 2: // Payments
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudentPaymentsScreen(userEmail: widget.userEmail),
          ),
        );
        break;
      case 3: // Messages
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatListScreen(
              currentUserEmail: widget.userEmail,
              currentUserRole: 'student',
            ),
          ),
        );
        break;
      case 4: // Profile
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudentProfileScreen(
              studentName: widget.userName,
              studentEmail: widget.userEmail,
            ),
          ),
        );
        break;
    }
  }

  void _navigateToBrowseDorms() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BrowseDormsScreen(userEmail: widget.userEmail),
      ),
    );
  }

  void _navigateToPayments() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentPaymentsScreen(userEmail: widget.userEmail),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildBottomNavBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Container(
                color: AppTheme.scaffoldBg,
                child: isLoading
                    ? const LoadingWidget(message: 'Loading dashboard...')
                    : error.isNotEmpty
                        ? ErrorDisplayWidget(
                            error: error,
                            onRetry: fetchDashboardData,
                          )
                        : _buildDashboardContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onNavTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.primary,
      unselectedItemColor: AppTheme.muted,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Browse'),
        BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Payment'),
        BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6B21A8), Color(0xFF7C3AED)], // Darker purple gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome back!',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatListScreen(
                            currentUserEmail: widget.userEmail,
                            currentUserRole: 'student',
                          ),
                        ),
                      );
                    },
                  ),
                  if ((dashboardData['unread_messages'] ?? 0) > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.primary, width: 2),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '${dashboardData['unread_messages'] ?? 0}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OwnerStatCard(
                icon: Icons.bookmark,
                value: "${dashboardData['active_reservations'] ?? 0}",
                label: "Active",
              ),
              OwnerStatCard(
                icon: Icons.payment,
                value: "₱${dashboardData['payments_due'] ?? 0}",
                label: "Due",
              ),
              OwnerStatCard(
                icon: Icons.message,
                value: "${dashboardData['unread_messages'] ?? 0}",
                label: "Messages",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
  final activeBookings = (dashboardData['active_bookings'] as List?) ?? [];
  final completedBookings = (dashboardData['completed_bookings'] as List?) ?? [];
  final cancelledBookings = (dashboardData['cancelled_bookings'] as List?) ?? [];
  final rejectedBookings = (dashboardData['rejected_bookings'] as List?) ?? [];
  final pendingBookings = (dashboardData['pending_bookings'] as List?) ?? [];
  final approvedBookings = (dashboardData['approved_bookings'] as List?) ?? [];
  final ongoingBookings = (dashboardData['ongoing_bookings'] as List?) ?? [];
  final allBookings = [
    ...activeBookings,
    ...completedBookings,
    ...cancelledBookings,
    ...rejectedBookings,
    ...pendingBookings,
    ...approvedBookings,
    ...ongoingBookings,
  ];

  return RefreshIndicator(
    onRefresh: fetchDashboardData,
    child: SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildActiveBookingsSection(activeBookings, completedBookings, allBookings),
          const SizedBox(height: 24),
          _buildNotificationsSection(),
          const SizedBox(height: 24),
          _buildQuickActionsSection(),
        ],
      ),
    ),
  );
}

  Widget _buildActiveBookingsSection(List activeBookings, List completedBookings, List allBookings) {
    final visibleBookings = [
      ...activeBookings,
      ...completedBookings,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Active Bookings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (activeBookings.isNotEmpty || completedBookings.isNotEmpty)
              TextButton(
                onPressed: () {
                  // Debug: print number of unique dorms connected to user
                  final dormIds = allBookings
                      .map((booking) => booking['dorm']?['dorm_id']?.toString())
                      .where((id) => id != null && id.isNotEmpty)
                      .toSet();
                  print('DEBUG: Number of unique dorms connected to user: \'${dormIds.length}\'');
                  final studentId = dashboardData['student']?['id'] ?? 0;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentReservationsScreen(
                        bookings: allBookings,
                        userEmail: widget.userEmail,
                        studentId: studentId,
                      ),
                    ),
                  );
                },
                child: const Text('View All'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (visibleBookings.isEmpty)
          EmptyBookingsWidget(onBrowseDorms: _navigateToBrowseDorms)
        else
          ...visibleBookings.map((booking) {
            final status = booking['status'].toString().toLowerCase();
            final dorm = booking['dorm'] ?? {};
            final studentId = dashboardData['student']?['id'] ?? 0;
            final isActiveBooking = (status == 'active' || status == 'approved' || 
                                      status.contains('checkout'));
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    if (isActiveBooking) {
                      // Navigate to booking details for active bookings
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingDetailsScreen(
                            booking: booking,
                            userEmail: widget.userEmail,
                            studentId: studentId,
                          ),
                        ),
                      ).then((shouldRefresh) {
                        if (shouldRefresh == true) {
                          fetchDashboardData();
                        }
                      });
                    } else {
                      // Navigate to dorm details for other statuses
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewDetailsScreen(
                            property: {
                              'dorm_id': dorm['dorm_id']?.toString() ?? '',
                              'name': dorm['name']?.toString() ?? '',
                              'address': dorm['address']?.toString() ?? '',
                            },
                            userEmail: widget.userEmail,
                          ),
                        ),
                      );
                    }
                  },
                  child: BookingCard(booking: booking),
                ),
                if (status == 'completed')
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 4, bottom: 12),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.rate_review, size: 18),
                      label: const Text('Write Review'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(120, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onPressed: () {
            final studentId = dashboardData['student']?['id'] ?? 0;
            final dormId = dorm['dorm_id']?.toString() ?? '';
            final bookingId = booking['booking_id'] is int ? booking['booking_id'] : int.tryParse(booking['booking_id']?.toString() ?? '0') ?? 0;
            print('[DEBUG] booking object: ' + booking.toString());
            print('[DEBUG] Review Navigation: dormId=$dormId, studentEmail=${widget.userEmail}, bookingId=$bookingId, studentId=$studentId');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubmitReviewScreen(
                              dormId: dormId,
                              studentEmail: widget.userEmail,
                              bookingId: bookingId,
                              studentId: studentId,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          }),
      ],
    );
  }

  Widget _buildNotificationsSection() {
    final recentMessages = (dashboardData['recent_messages'] as List?) ?? [];
    
    print('[DEBUG NOTIFICATIONS] dashboardData keys: ${dashboardData.keys}');
    print('[DEBUG NOTIFICATIONS] recent_messages: $recentMessages');
    print('[DEBUG NOTIFICATIONS] recent_messages length: ${recentMessages.length}');
    
    // TEMPORARY: Always show the section for testing
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatListScreen(
                      currentUserEmail: widget.userEmail,
                      currentUserRole: 'student',
                    ),
                  ),
                );
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (recentMessages.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.notifications_none, color: Colors.grey[400], size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No new notifications',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ...recentMessages.take(3).map((notification) {
          // Determine notification type
          final notificationType = notification['notification_type'] ?? 'message';
          final isBookingUpdate = notificationType == 'booking_update';
          
          // Common fields
          final body = notification['body'] ?? '';
          final createdAt = notification['created_at'] ?? '';
          final urgency = notification['urgency'] ?? 'normal';
          final dormName = notification['dorm_name'] ?? '';
          
          // Type-specific fields
          final senderName = notification['sender_name'] ?? 'System';
          final roomType = notification['room_type'] ?? '';
          
          // Display title
          final title = isBookingUpdate ? 'Booking Update' : senderName;
          
          // Icon and color based on type
          final icon = isBookingUpdate ? Icons.event_note : Icons.message;
          final iconColor = isBookingUpdate 
              ? const Color(0xFF3498DB) 
              : AppTheme.primary;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: urgency == 'urgent' 
                  ? Colors.red.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
                width: urgency == 'urgent' ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                if (isBookingUpdate) {
                  // Navigate to bookings tab
                  setState(() {
                    _selectedIndex = 1; // Bookings tab
                  });
                } else {
                  // Navigate to messages
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatListScreen(
                        currentUserEmail: widget.userEmail,
                        currentUserRole: 'student',
                      ),
                    ),
                  );
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          icon,
                          color: iconColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                if (urgency == 'urgent')
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      'URGENT',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (dormName.isNotEmpty)
                              Text(
                                isBookingUpdate && roomType.isNotEmpty
                                    ? '$dormName • $roomType'
                                    : dormName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    body.length > 100 ? '${body.substring(0, 100)}...' : body,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTimeAgo(createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  String _formatTimeAgo(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final difference = DateTime.now().difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return dateTimeStr;
    }
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            QuickActionButton(
              icon: Icons.search,
              label: 'Browse',
              onTap: _navigateToBrowseDorms,
            ),
            QuickActionButton(
              icon: Icons.payment,
              label: 'Payments',
              onTap: _navigateToPayments,
            ),
            QuickActionButton(
              icon: Icons.message,
              label: 'Messages',
              onTap: () => Navigator.pushNamed(context, '/student_messages'),
            ),
            QuickActionButton(
              icon: Icons.help,
              label: 'Help',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Help feature coming soon')),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
