import 'package:flutter/material.dart';
import '../../services/booking_service.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' show ErrorDisplayWidget;
import '../../widgets/student/home/dashboard_stat_card.dart';
import '../../widgets/student/home/booking_card.dart';
import '../../widgets/student/home/quick_action_button.dart';
import '../../widgets/student/home/empty_bookings_widget.dart';
// Temporary imports from legacy structure
import 'browse_dorms_screen.dart';
import '../../legacy/MobileScreen/student_payments.dart';
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
  
  static const Color _orange = Color(0xFFFF9800);
  static const Color _scaffoldBg = Color(0xFFF9F6FB);

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
      case 2: // Bookings
        Navigator.pushNamed(context, '/student_reservations');
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
                color: _scaffoldBg,
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
      selectedItemColor: _orange,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Browse'),
        BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Bookings'),
        BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_orange, _orange.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
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
            _buildStatsRow(),
            const SizedBox(height: 24),
            _buildActiveBookingsSection(activeBookings),
            const SizedBox(height: 24),
            _buildQuickActionsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        DashboardStatCard(
          label: 'Active',
          value: '${dashboardData['active_reservations'] ?? 0}',
          color: _orange,
        ),
        DashboardStatCard(
          label: 'Due',
          value: '₱${dashboardData['payments_due'] ?? 0}',
          color: Colors.redAccent,
        ),
        DashboardStatCard(
          label: 'Messages',
          value: '${dashboardData['unread_messages'] ?? 0}',
          color: Colors.green,
        ),
      ],
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
          ...activeBookings.map((booking) => BookingCard(booking: booking)),
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
