import 'package:flutter/material.dart';
import '../../services/booking_service.dart';
import '../../../utils/app_theme.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' show ErrorDisplayWidget;
import '../../widgets/owner/dashboard/owner_stat_card.dart';
import '../../widgets/student/home/booking_card.dart';
import '../../widgets/student/home/quick_action_button.dart';
import '../../widgets/student/home/empty_bookings_widget.dart';
import 'view_details_screen.dart';
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

      if (result['success']) {
        final data = result['data'];
        if (data['stats'] != null) {
          setState(() {
            dashboardData = data['stats'];
            isLoading = false;
          });
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception(result['error'] ?? 'Failed to load dashboard');
      }
    } catch (e) {
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
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () {},
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
    
    return RefreshIndicator(
      onRefresh: fetchDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActiveBookingsSection(activeBookings),
            const SizedBox(height: 24),
            _buildQuickActionsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveBookingsSection(List activeBookings) {
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
            if (activeBookings.isNotEmpty)
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/student_reservations');
                },
                child: const Text('View All'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (activeBookings.isEmpty)
          EmptyBookingsWidget(onBrowseDorms: _navigateToBrowseDorms)
        else
          ...activeBookings.map((booking) => GestureDetector(
            onTap: () {
              final dorm = booking['dorm'] ?? {};
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewDetailsScreen(
                    property: {
                      'dorm_id': dorm['dorm_id']?.toString() ?? '',
                      'name': dorm['name']?.toString() ?? '',
                      'address': dorm['address']?.toString() ?? '',
                      // Add more dorm fields if needed
                    },
                    userEmail: widget.userEmail,
                  ),
                ),
              );
            },
            child: BookingCard(booking: booking),
          )),
      ],
    );
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
