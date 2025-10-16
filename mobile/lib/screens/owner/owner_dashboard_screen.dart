import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../widgets/common/loading_widget.dart';
import '../../widgets/owner/dashboard/owner_stat_card.dart';
import '../../widgets/owner/dashboard/owner_quick_action_tile.dart';
import '../../widgets/owner/dashboard/owner_activity_tile.dart';
import '../../widgets/owner/dashboard/owner_messages_list.dart';
// Temporary imports from legacy structure
import '../../legacy/MobileScreen/ownerbooking.dart';
import '../../legacy/MobileScreen/ownerpayments.dart';
import '../../legacy/MobileScreen/ownertenants.dart';
import '../../legacy/MobileScreen/ownersetting.dart';
import '../../legacy/MobileScreen/ownerdorms.dart';

class OwnerDashboardScreen extends StatefulWidget {
  final String ownerEmail;
  final String ownerRole;

  const OwnerDashboardScreen({
    Key? key,
    required this.ownerEmail,
    required this.ownerRole,
  }) : super(key: key);

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  int _selectedIndex = 0;
  Map<String, dynamic> dashboardData = {};
  bool isLoading = true;
  
  static const Color _orange = Color(0xFFFF9800);
  static const Color _scaffoldBg = Color(0xFFF9F6FB);

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      final response = await http.get(
        Uri.parse('http://cozydorms.life/modules/mobile-api/owner_dashboard_api.php?owner_email=${widget.ownerEmail}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true && data['stats'] != null) {
          setState(() {
            dashboardData = data;
            isLoading = false;
          });
        } else {
          throw Exception(data['error'] ?? 'Invalid response format');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onNavTap(int index) {
    if (index == 5) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OwnerSettingScreen(
            ownerName: widget.ownerEmail,
            ownerEmail: widget.ownerEmail,
            ownerRole: widget.ownerRole,
          ),
        ),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _switchToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBg,
      bottomNavigationBar: _buildBottomNavBar(),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboardHome(),
          OwnerBookingScreen(ownerEmail: widget.ownerEmail),
          OwnerMessagesList(ownerEmail: widget.ownerEmail),
          OwnerPaymentsScreen(ownerEmail: widget.ownerEmail),
          OwnerTenantsScreen(ownerEmail: widget.ownerEmail),
          Container(), // Placeholder for settings
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      selectedItemColor: _orange,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      onTap: _onNavTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Bookings"),
        BottomNavigationBarItem(icon: Icon(Icons.message), label: "Messages"),
        BottomNavigationBarItem(icon: Icon(Icons.payments), label: "Payments"),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: "Tenants"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
      ],
    );
  }

  Widget _buildDashboardHome() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildQuickActionsSection(),
          const SizedBox(height: 28),
          _buildRecentActivitiesSection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final stats = dashboardData['stats'] ?? {};
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      decoration: const BoxDecoration(
        color: _orange,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Owner Dashboard",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Welcome back",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OwnerStatCard(
                icon: Icons.meeting_room,
                value: "${stats['rooms'] ?? 0}",
                label: "Total Rooms",
              ),
              OwnerStatCard(
                icon: Icons.people,
                value: "${stats['tenants'] ?? 0}",
                label: "Total Tenants",
              ),
              OwnerStatCard(
                icon: Icons.attach_money,
                value: "₱${((stats['monthly_revenue'] ?? 0.0) / 1000).toStringAsFixed(1)}K",
                label: "Monthly Revenue",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF6E5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.orange.withOpacity(0.15), width: 1.3),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.07),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Quick Actions",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OwnerQuickActionTile(
                    icon: Icons.apartment,
                    label: "Manage Dorms",
                    color: const Color(0xFFFFF3E0),
                    iconColor: const Color(0xFFFF9800),
                    borderColor: const Color(0xFFFF9800),
                    textColor: Colors.black87,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OwnerDormsScreen(
                            ownerEmail: widget.ownerEmail,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OwnerQuickActionTile(
                    icon: Icons.message,
                    label: "Messages",
                    color: const Color(0xFFFFF3E0),
                    iconColor: const Color(0xFFFF9800),
                    borderColor: const Color(0xFFFF9800),
                    textColor: Colors.black87,
                    onTap: () => _switchToTab(2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OwnerQuickActionTile(
                    icon: Icons.list_alt,
                    label: "Booking Requests",
                    color: const Color(0xFFFFF3E0),
                    iconColor: const Color(0xFFFF9800),
                    borderColor: const Color(0xFFFF9800),
                    textColor: Colors.black87,
                    onTap: () => _switchToTab(1),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OwnerQuickActionTile(
                    icon: Icons.payments,
                    label: "Payments",
                    color: const Color(0xFFFFF3E0),
                    iconColor: const Color(0xFFFF9800),
                    borderColor: const Color(0xFFFF9800),
                    textColor: Colors.black87,
                    onTap: () => _switchToTab(3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OwnerQuickActionTile(
                    icon: Icons.people,
                    label: "Tenants",
                    color: const Color(0xFFFFF3E0),
                    iconColor: const Color(0xFFFF9800),
                    borderColor: const Color(0xFFFF9800),
                    textColor: Colors.black87,
                    onTap: () => _switchToTab(4),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(child: SizedBox()), // Empty for layout symmetry
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitiesSection() {
    final activities = (dashboardData['stats']?['recent_activities'] ?? []) as List;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Recent Activities",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: isLoading
              ? const LoadingWidget(message: 'Loading activities...')
              : activities.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('No recent activities'),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: activities.length,
                      itemBuilder: (context, index) {
                        final activity = activities[index];
                        final isPayment = activity['type'] == 'payment';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: OwnerActivityTile(
                            icon: isPayment ? Icons.payments : Icons.meeting_room,
                            iconBg: isPayment
                                ? const Color(0xFFE0F7E9)
                                : const Color(0xFFFFF3E0),
                            iconColor: isPayment ? Colors.green : Colors.orange,
                            title: isPayment
                                ? 'Payment Received'
                                : 'New Booking Request',
                            subtitle: isPayment
                                ? "${activity['student_name']} paid ₱${activity['amount']} for ${activity['dorm_name']}"
                                : "${activity['student_name']} requested to book ${activity['dorm_name']}",
                            time: _formatTimeAgo(
                              DateTime.parse(activity['created_at']),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
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
  }
}
