import 'package:flutter/material.dart';
import '../../services/dashboard_service.dart';
import '../../../utils/app_theme.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/owner/dashboard/owner_stat_card.dart';
import '../../widgets/owner/dashboard/owner_quick_action_tile.dart';
import '../../widgets/owner/dashboard/owner_activity_tile.dart';
import '../../widgets/owner/dashboard/owner_messages_list.dart';
import '../../widgets/owner/dashboard/recent_bookings_widget.dart';
import '../../widgets/owner/dashboard/recent_payments_widget.dart';
import '../../widgets/owner/dashboard/recent_messages_preview_widget.dart';
// Modern refactored screens (using correct API paths)
import 'owner_dorms_screen.dart';
import 'owner_payments_screen.dart';
import 'owner_booking_screen.dart';
import 'owner_tenants_screen.dart';
import 'owner_settings_screen.dart';

class OwnerDashboardScreen extends StatefulWidget {
  final String ownerEmail;
  final String ownerRole;

  const OwnerDashboardScreen({
    super.key,
    required this.ownerEmail,
    required this.ownerRole,
  });

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  final DashboardService _dashboardService = DashboardService();
  
  int _selectedIndex = 0;
  Map<String, dynamic> dashboardData = {};
  bool isLoading = true;
  String ownerName = ''; // Store owner name
  int? ownerId; // Store owner ID

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
    _fetchOwnerName();
  }

  Future<void> _fetchOwnerName() async {
    // Extract name from email or fetch from API
    // For now, use email prefix as name
    final emailPrefix = widget.ownerEmail.split('@')[0];
    setState(() {
      ownerName = emailPrefix.replaceAll('.', ' ').split(' ').map((word) => 
        word[0].toUpperCase() + word.substring(1)
      ).join(' ');
    });
  }

  Future<void> fetchDashboardData() async {
    setState(() => isLoading = true);
    
    try {
      final result = await _dashboardService.getOwnerDashboard(widget.ownerEmail);

      if (result['success'] == true) {
        setState(() {
          dashboardData = result['data'];
          // Extract owner name and ID from API response if available
          if (dashboardData['owner_info'] != null) {
            if (dashboardData['owner_info']['name'] != null) {
              ownerName = dashboardData['owner_info']['name'];
            }
            if (dashboardData['owner_info']['owner_id'] != null) {
              ownerId = dashboardData['owner_info']['owner_id'];
            }
          }
          isLoading = false;
        });
      } else {
        throw Exception(result['error'] ?? 'Failed to load dashboard data');
      }
    } catch (e) {
      setState(() {
        dashboardData = {
          'stats': {
            'rooms': 0,
            'tenants': 0,
            'monthly_revenue': 0.0,
          },
          'recent_activities': [],
          'recent_bookings': [],
          'recent_payments': [],
          'recent_messages': [],
        };
        isLoading = false;
      });
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load dashboard: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onNavTap(int index) {
    if (index == 5) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OwnerSettingsScreen(
            ownerName: ownerName.isNotEmpty ? ownerName : widget.ownerEmail,
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
      backgroundColor: AppTheme.scaffoldBg,
      bottomNavigationBar: _buildBottomNavBar(),
      body: SafeArea(
        child: isLoading
            ? const LoadingWidget(message: 'Loading dashboard...')
            : IndexedStack(
                index: _selectedIndex,
                children: [
                  _buildDashboardHome(),
                  OwnerBookingScreen(ownerEmail: widget.ownerEmail),
                  OwnerMessagesList(ownerEmail: widget.ownerEmail),
                  OwnerPaymentsScreen(ownerEmail: widget.ownerEmail),
                  OwnerTenantsScreen(
                    ownerEmail: widget.ownerEmail,
                    ownerId: ownerId ?? 0,
                  ),
                  Container(), // Placeholder for settings
                ],
              ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      selectedItemColor: AppTheme.primary,
      unselectedItemColor: AppTheme.muted,
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
    return RefreshIndicator(
      onRefresh: fetchDashboardData,
      color: AppTheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildQuickActionsSection(),
            const SizedBox(height: 20),
            // Recent Bookings Preview
            RecentBookingsWidget(
              bookings: dashboardData['recent_bookings'] ?? [],
              onViewAll: () => _switchToTab(1),
            ),
            const SizedBox(height: 16),
            // Recent Payments Preview
            RecentPaymentsWidget(
              payments: dashboardData['recent_payments'] ?? [],
              onViewAll: () => _switchToTab(3),
            ),
            const SizedBox(height: 16),
            // Recent Messages Preview
            RecentMessagesPreviewWidget(
              messages: dashboardData['recent_messages'] ?? [],
              onViewAll: () => _switchToTab(2),
            ),
            const SizedBox(height: 20),
            _buildRecentActivitiesSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final stats = dashboardData['stats'] ?? {};
    
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
          // Logo and Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // App Logo
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'lib/Logo.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.apartment,
                            color: Color(0xFF6B21A8),
                            size: 30,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CozyDorms',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ownerName.isNotEmpty ? ownerName : 'Owner Dashboard',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
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
                value: _formatRevenue(stats['monthly_revenue']),
                label: "Revenue",
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatRevenue(dynamic revenue) {
    try {
      // Convert to double regardless of whether it's a string or number
      double amount = 0.0;
      if (revenue is String) {
        amount = double.tryParse(revenue) ?? 0.0;
      } else if (revenue is num) {
        amount = revenue.toDouble();
      }
      
      // Format to K (thousands)
      if (amount >= 1000) {
        return "₱${(amount / 1000).toStringAsFixed(1)}K";
      } else {
        return "₱${amount.toStringAsFixed(0)}";
      }
    } catch (e) {
      return "₱0";
    }
  }

  Widget _buildQuickActionsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.border, width: 1.3),
          boxShadow: AppTheme.cardShadow,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Quick Actions",
              style: AppTheme.headingSmall,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OwnerQuickActionTile(
                    icon: Icons.apartment,
                    label: "Manage Dorms",
                    color: AppTheme.cardBg,
                    iconColor: AppTheme.primary,
                    borderColor: AppTheme.primary,
                    textColor: AppTheme.textDark,
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
                const SizedBox(width: 12),
                Expanded(
                  child: OwnerQuickActionTile(
                    icon: Icons.people,
                    label: "View Tenants",
                    color: AppTheme.cardBg,
                    iconColor: AppTheme.primary,
                    borderColor: AppTheme.primary,
                    textColor: AppTheme.textDark,
                    onTap: () => _switchToTab(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OwnerQuickActionTile(
                    icon: Icons.calendar_today,
                    label: "Bookings",
                    color: AppTheme.cardBg,
                    iconColor: AppTheme.primary,
                    borderColor: AppTheme.primary,
                    textColor: AppTheme.textDark,
                    onTap: () => _switchToTab(1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OwnerQuickActionTile(
                    icon: Icons.payment,
                    label: "Payments",
                    color: AppTheme.cardBg,
                    iconColor: AppTheme.primary,
                    borderColor: AppTheme.primary,
                    textColor: AppTheme.textDark,
                    onTap: () => _switchToTab(3),
                  ),
                ),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Recent Activities",
            style: AppTheme.headingSmall,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: activities.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text(
                      'No recent activities',
                      style: TextStyle(color: AppTheme.muted),
                    ),
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
                            iconColor: isPayment ? Colors.green : AppTheme.primary,
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
