import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'viewdetails.dart';
import 'browse_dorms.dart';

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
        Uri.parse('http://cozydorms.life/modules/mobile-api/student_dashboard_api.php?student_email=${widget.userEmail}'),
      );

      print('Dashboard API Response: ${response.statusCode}');
      print('Dashboard API Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          setState(() {
            dashboardData = data['stats'] ?? {
              'active_reservations': 0,
              'payments_due': 0,
              'unread_messages': 0,
              'active_bookings': []
            };
            isLoading = false;
          });
        } else {
          throw Exception(data['error'] ?? 'Unknown error');
        }
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      print('Dashboard fetch error: $e');
      setState(() {
        error = 'Failed to load dashboard: ${e.toString()}';
        // Set default values so UI doesn't break
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

  @override
  Widget build(BuildContext context) {
    final orange = const Color(0xFFFF9800);
    final scaffoldBg = const Color(0xFFF9F6FB);
    final panelBg = Colors.white;

    return Scaffold(
      backgroundColor: Colors.white,
      // removed BottomNavigationBar that contained the Wishlist
      body: SafeArea(
        child: Column(
          children: [
            // Orange header similar to owner dashboard
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [orange.withOpacity(0.95), orange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.school, color: orange, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Student Dashboard', style: TextStyle(color: Colors.white70)),
                        Text(widget.userName,
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Main white panel (owner-like)
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: panelBg,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 6))],
                ),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : error.isNotEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, size: 48, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'Error loading dashboard',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  error,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                ),
                                SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: fetchDashboardData,
                                  child: Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Stats row (owner-like cards)
                                Row(
                                  children: [
                                    _miniStat('Active', '${dashboardData['active_reservations'] ?? 0}', orange),
                                    _miniStat('Due', '₱${dashboardData['payments_due'] ?? 0}', Colors.redAccent),
                                    _miniStat('Messages', '${dashboardData['unread_messages'] ?? 0}', Colors.green),
                                  ],
                                ),
                                const SizedBox(height: 18),

                                // Quick actions (owner-style tiles)
                                Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: [
                                    _actionTile(Icons.search, 'Browse Dorms', orange, () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const BrowseDormsScreen()),
                                      );
                                    }),
                                    _actionTile(Icons.book_online, 'My Bookings', Colors.orange.shade200, () {
                                      Navigator.pushNamed(context, '/student_reservations');
                                    }),
                                    _actionTile(Icons.payments, 'Payments', Colors.orange.shade200, () {
                                      Navigator.pushNamed(context, '/student_payments');
                                    }),
                                    _actionTile(Icons.message, 'Messages', Colors.orange.shade200, () {
                                      Navigator.pushNamed(context, '/student_messages');
                                    }),
                                  ],
                                ),
                                const SizedBox(height: 18),

                                // Notifications (replaces Featured Properties)
                                Text('Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                                const SizedBox(height: 12),
                                // Show notifications returned from the dashboard API. Expected shape: List of {title, body, time}
                                if ((dashboardData['notifications'] ?? []).isEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 24),
                                    alignment: Alignment.center,
                                    child: Text('No notifications', style: TextStyle(color: Colors.black54)),
                                  )
                                else
                                  Column(
                                    children: List<Widget>.from(
                                      (dashboardData['notifications'] as List).map((n) => _notificationTile(n)),
                                    ),
                                  ),
                              ],
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // helper for small stat card
  Widget _miniStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  // helper for quick action tile
  Widget _actionTile(IconData icon, String label, Color bg, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: bg.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: bg.withOpacity(0.18)),
        ),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: bg, child: Icon(icon, color: Colors.white, size: 18), radius: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          ],
        ),
      ),
    );
  }

  // helper to render a single notification entry
  Widget _notificationTile(dynamic n) {
    final title = n['title'] ?? 'Notification';
    final body = n['body'] ?? '';
    final time = n['time'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 18, backgroundColor: Colors.orange.shade100, child: Icon(Icons.notifications, color: Colors.orange)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(body, style: const TextStyle(color: Colors.black87)),
                if (time.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(time, style: const TextStyle(fontSize: 12, color: Colors.black45)),
                ]
              ],
            ),
          ),
        ],
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