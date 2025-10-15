import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'viewdetails.dart';
import 'browse_dorms.dart';
//import 'student_bookings.dart';
//import 'student_payments.dart';
//import 'student_messages.dart';

class StudentHomeScreen extends StatefulWidget {
  final String userName;
  final String userEmail;

  const StudentHomeScreen({
    Key? key, 
    required this.userName,
    required this.userEmail,
  }) : super(key: key);

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
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
      final response = await http.get(
        Uri.parse('http://cozydorms.life/modules/mobile-api/student_dashboard_api.php?student_email=${Uri.encodeComponent(widget.userEmail)}'),
      );

      print('Dashboard API Response: ${response.statusCode}');
      print('Dashboard API Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true && data['stats'] != null) {
          setState(() {
            dashboardData = data['stats'];
            isLoading = false;
          });
        } else {
          throw Exception(data['error'] ?? 'Invalid response format');
        }
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      print('Dashboard fetch error: $e');
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
          MaterialPageRoute(builder: (context) => const BrowseDormsScreen()),
        );
        break;
      case 2: // Bookings
        Navigator.pushNamed(context, '/student_reservations');
        break;
      case 3: // Messages
        Navigator.pushNamed(context, '/student_messages');
        break;
      case 4: // Profile
        // TODO: Navigate to profile screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile feature coming soon')),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orange = const Color(0xFFFF9800);
    final scaffoldBg = const Color(0xFFF9F6FB);

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Browse'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Orange header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [orange, orange.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
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
                        icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: Container(
                color: scaffoldBg,
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : error.isNotEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                                const SizedBox(height: 16),
                                const Text(
                                  'Error loading dashboard',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 32),
                                  child: Text(
                                    error,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: fetchDashboardData,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: fetchDashboardData,
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Stats row
                                  Row(
                                    children: [
                                      _miniStat('Active', '${dashboardData['active_reservations'] ?? 0}', orange),
                                      _miniStat('Due', '₱${dashboardData['payments_due'] ?? 0}', Colors.redAccent),
                                      _miniStat('Messages', '${dashboardData['unread_messages'] ?? 0}', Colors.green),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  // Active Bookings Section
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
                                      if ((dashboardData['active_bookings'] as List?)?.isNotEmpty ?? false)
                                        TextButton(
                                          onPressed: () {
                                            // Navigate to all bookings
                                          },
                                          child: const Text('View All'),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Bookings List
                                  if ((dashboardData['active_bookings'] as List?)?.isEmpty ?? true)
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(32.0),
                                        child: Column(
                                          children: [
                                            Icon(Icons.bookmark_border, size: 64, color: Colors.grey[300]),
                                            const SizedBox(height: 16),
                                            Text(
                                              'No active bookings',
                                              style: TextStyle(color: Colors.grey[600]),
                                            ),
                                            const SizedBox(height: 8),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => const BrowseDormsScreen(),
                                                  ),
                                                );
                                              },
                                              child: const Text('Browse Dorms'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  else
                                    ...((dashboardData['active_bookings'] as List).map((booking) {
                                      return _buildBookingCard(booking);
                                    })),

                                  const SizedBox(height: 24),

                                  // Quick Actions
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
                                      _quickAction(Icons.search, 'Browse', () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const BrowseDormsScreen(),
                                          ),
                                        );
                                      }),
                                      _quickAction(Icons.payment, 'Payments', () {
                                        Navigator.pushNamed(context, '/student_payments');
                                      }),
                                      _quickAction(Icons.message, 'Messages', () {
                                        Navigator.pushNamed(context, '/student_messages');
                                      }),
                                      _quickAction(Icons.help, 'Help', () {}),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final status = booking['status'] ?? 'pending';
    final statusColor = status == 'approved' ? Colors.green : Colors.orange;
    final dorm = booking['dorm'] ?? {};
    final room = booking['room'] ?? {};
    final daysUntil = booking['days_until_checkin'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  dorm['name'] ?? 'Unknown Dorm',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            dorm['address'] ?? '',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.meeting_room, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                room['room_type'] ?? 'Unknown Room',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(width: 16),
              Icon(Icons.people, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${room['capacity'] ?? 0} persons',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₱${room['price'] ?? 0}/month',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF9800),
                ),
              ),
              if (daysUntil > 0)
                Text(
                  'Check-in in $daysUntil days',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFFFF9800)),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppTheme {
  // Web palette (from Main/assets/style.css root)
  static const Color primary = Color(0xFF8B5CF6); // purple
  static const Color primary2 = Color(0xFFA78BFA);
  static const Color bg = Color(0xFFF6F3FF);
  static const Color panel = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF1F1147);
  static const Color muted = Color(0xFF7A68B8);

  static const Gradient headerGradient = LinearGradient(
    colors: [Color(0xFFA18CD1), Color(0xFFFBC2EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData lightTheme() {
    final base = ThemeData.light();
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(seedColor: primary),
      scaffoldBackgroundColor: bg,
      primaryColor: primary,
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        elevation: 0,
        titleTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F5FF),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: ink,
        displayColor: ink,
      ),
      cardTheme: CardTheme(
        color: panel,
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: primary),
    );
  }

  // Reusable card decoration for custom containers
  static BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: panel,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: Offset(0, 4)),
      ],
    );
  }
}