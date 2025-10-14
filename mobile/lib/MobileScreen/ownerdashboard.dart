import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ownerbooking.dart';
import 'student_owner_chat.dart';
import 'ownerpayments.dart';
import 'ownertenants.dart';
import 'ownersetting.dart';
import 'ownerdorms.dart';

// ==================== OwnerDashboardScreen Widget ====================
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

// ==================== OwnerDashboardScreen State ====================
class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  int _selectedIndex = 0;
  Map<String, dynamic> dashboardData = {};
  bool isLoading = true;

  // ----------- NAVIGATION LOGIC SECTION -----------
  void _onNavTap(int index) {
    if (index == 5) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OwnerSettingScreen(
            ownerName: widget.ownerEmail, // Show email as name
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

  // ----------- QUICK ACTIONS LOGIC SECTION -----------
  void _onQuickActionBookingRequests() {
    setState(() {
      _selectedIndex = 1; // Bookings tab
    });
  }

  void _onQuickActionMessages() {
    setState(() {
      _selectedIndex = 2; // Messages tab
    });
  }

  void _onQuickActionPayments() {
    setState(() {
      _selectedIndex = 3; // Payments tab
    });
  }

  void _onQuickActionTenants() {
    setState(() {
      _selectedIndex = 4; // Tenants tab
    });
  }

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  // ----------- FETCH DASHBOARD DATA SECTION -----------
  Future<void> fetchDashboardData() async {
    try {
      final response = await http.get(
        Uri.parse('http://cozydorms.life/modules/mobile-api/owner_dashboard_api.php?owner_email=${widget.ownerEmail}'),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

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
      print('Dashboard fetch error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final orange = const Color(0xFFFF9800);

    // ----------- MAIN UI SECTION -----------
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6FB),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: orange,
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
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _DashboardHome(
            onBookingRequestsTap: _onQuickActionBookingRequests,
            onMessagesTap: _onQuickActionMessages,
            onPaymentsTap: _onQuickActionPayments,
            onTenantsTap: _onQuickActionTenants,
            isLoading: isLoading,
            dashboardData: dashboardData,
            ownerEmail: widget.ownerEmail,  // Add this line
          ),
          // Fix: Pass the owner email to OwnerBookingScreen
          OwnerBookingScreen(ownerEmail: widget.ownerEmail),  // <-- Update this line
          OwnerMessagesListScreen(ownerEmail: widget.ownerEmail),
          OwnerPaymentsScreen(ownerEmail: widget.ownerEmail),
          OwnerTenantsScreen(ownerEmail: widget.ownerEmail),
          Container(), // Placeholder for settings
        ],
      ),
    );
  }
}

// ==================== OwnerMessagesListScreen Widget ====================
class OwnerMessagesListScreen extends StatefulWidget {
  final String ownerEmail;
  const OwnerMessagesListScreen({super.key, required this.ownerEmail});

  @override
  State<OwnerMessagesListScreen> createState() => _OwnerMessagesListScreenState();
}

// ==================== OwnerMessagesListScreen State ====================
class _OwnerMessagesListScreenState extends State<OwnerMessagesListScreen> {
  List<Map<String, dynamic>> chats = [];
  final String apiBase = 'https://bradedsale.helioho.st/chat_api/chat_api.php';

  @override
  void initState() {
    super.initState();
    fetchChats();
  }

  // ----------- FETCH CHATS SECTION -----------
  Future<void> fetchChats() async {
    try {
      final response = await http.get(
        Uri.parse('$apiBase?action=get_user_chats&user_email=${widget.ownerEmail}'),
      );
      if (response.statusCode == 200) {
        setState(() {
          chats = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        });
      }
    } catch (e) {
      // Optionally handle error
    }
  }

  // ----------- FETCH USER NAME SECTION -----------
  Future<String> fetchUserName(String email) async {
    final response = await http.get(
      Uri.parse('$apiBase?action=get_user_name&email=$email'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['name'] ?? email;
    }
    return email;
  }

  @override
  Widget build(BuildContext context) {
    // ----------- MESSAGES LIST UI SECTION -----------
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
        backgroundColor: Colors.orange,
      ),
      body: chats.isEmpty
          ? Center(child: Text('No messages yet.'))
          : ListView.separated(
              itemCount: chats.length,
              separatorBuilder: (_, __) => Divider(height: 1),
              itemBuilder: (context, index) {
                final chat = chats[index];
                final otherUserEmail = chat['other_user_email'];
                final lastMessage = chat['last_message'] ?? '';
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: FutureBuilder<String>(
                    future: fetchUserName(otherUserEmail),
                    builder: (context, snapshot) {
                      final displayName = snapshot.data ?? otherUserEmail;
                      return Text(displayName, style: TextStyle(fontWeight: FontWeight.bold));
                    },
                  ),
                  subtitle: Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentOwnerChatScreen(
                          currentUserEmail: widget.ownerEmail,
                          otherUserEmail: otherUserEmail,
                          currentUserRole: "owner",
                        ),
                      ),
                    ).then((_) => fetchChats()); // Refresh after returning
                  },
                );
              },
            ),
    );
  }
}

// ==================== DashboardHome Widget ====================
class _DashboardHome extends StatelessWidget {
  final VoidCallback onBookingRequestsTap;
  final VoidCallback onMessagesTap;
  final VoidCallback onPaymentsTap;
  final VoidCallback onTenantsTap;
  final bool isLoading;
  final Map<String, dynamic> dashboardData;
  final String ownerEmail;  // Add this line

  const _DashboardHome({
    required this.onBookingRequestsTap,
    required this.onMessagesTap,
    required this.onPaymentsTap,
    required this.onTenantsTap,
    required this.isLoading,
    required this.dashboardData,
    required this.ownerEmail,  // Add this line
  });

  @override
  Widget build(BuildContext context) {
    final orange = const Color(0xFFFF9800);

    // ----------- DASHBOARD HOME UI SECTION -----------
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ----------- ORANGE HEADER SECTION -----------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
            decoration: BoxDecoration(
              color: orange,
              borderRadius: const BorderRadius.only(
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
                  "Welcome back, John",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatCard(
                      icon: Icons.meeting_room,
                      value: "${dashboardData['stats']?['rooms']?.toString() ?? '0'}",
                      label: "Total Rooms",
                    ),
                    _StatCard(
                      icon: Icons.people,
                      value: "${dashboardData['stats']?['tenants']?.toString() ?? '0'}", 
                      label: "Total Tenants",
                    ),
                    _StatCard(
                      icon: Icons.attach_money,
                      value: "₱${((dashboardData['stats']?['monthly_revenue'] ?? 0.0)/1000).toStringAsFixed(1)}K",
                      label: "Monthly Revenue",
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // ----------- QUICK ACTIONS SECTION -----------
          Padding(
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
                        child: _QuickActionTile(
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
                                  ownerEmail: ownerEmail,  // Use ownerEmail instead of widget.ownerEmail
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _QuickActionTile(
                          icon: Icons.message,
                          label: "Messages",
                          color: const Color(0xFFFFF3E0),
                          iconColor: const Color(0xFFFF9800),
                          borderColor: const Color(0xFFFF9800),
                          textColor: Colors.black87,
                          onTap: onMessagesTap,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionTile(
                          icon: Icons.list_alt,
                          label: "Booking Requests",
                          color: const Color(0xFFFFF3E0),
                          iconColor: const Color(0xFFFF9800),
                          borderColor: const Color(0xFFFF9800),
                          textColor: Colors.black87,
                          onTap: onBookingRequestsTap,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _QuickActionTile(
                          icon: Icons.payments,
                          label: "Payments",
                          color: const Color(0xFFFFF3E0),
                          iconColor: const Color(0xFFFF9800),
                          borderColor: const Color(0xFFFF9800),
                          textColor: Colors.black87,
                          onTap: onPaymentsTap,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionTile(
                          icon: Icons.people,
                          label: "Tenants",
                          color: const Color(0xFFFFF3E0),
                          iconColor: const Color(0xFFFF9800),
                          borderColor: const Color(0xFFFF9800),
                          textColor: Colors.black87,
                          onTap: onTenantsTap,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: SizedBox()), // Empty for layout symmetry
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          // ----------- RECENT ACTIVITIES SECTION -----------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Text(
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
                ? const Center(child: CircularProgressIndicator())
                : (dashboardData['stats']?['recent_activities'] ?? []).isEmpty
                    ? const Center(
                        child: Text('No recent activities'),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: (dashboardData['stats']?['recent_activities'] ?? []).length,
                        itemBuilder: (context, index) {
                          final activity = dashboardData['stats']['recent_activities'][index];
                          final isPayment = activity['type'] == 'payment';
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _ActivityTile(
                              icon: isPayment ? Icons.payments : Icons.meeting_room,
                              iconBg: isPayment ? const Color(0xFFE0F7E9) : const Color(0xFFFFF3E0),
                              iconColor: isPayment ? Colors.green : Colors.orange,
                              title: isPayment ? 'Payment Received' : 'New Booking Request',
                              subtitle: isPayment 
                                ? "${activity['student_name']} paid ₱${activity['amount']} for ${activity['dorm_name']}"
                                : "${activity['student_name']} requested to book ${activity['dorm_name']}",
                              time: _formatTimeAgo(DateTime.parse(activity['created_at'])),
                            ),
                          );
                        },
                      ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ----------- TIME AGO FORMATTER -----------
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

// ==================== StatCard Widget ====================
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ==================== QuickActionTile Widget ====================
class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final Color borderColor;
  final Color textColor;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
    required this.borderColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor.withOpacity(0.5), width: 1.3),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: borderColor.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: borderColor.withOpacity(0.10),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(7),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== ActivityTile Widget ====================
class _ActivityTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;

  const _ActivityTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            time,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}