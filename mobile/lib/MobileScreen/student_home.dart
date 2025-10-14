import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'viewdetails.dart';

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

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      final response = await http.get(
        Uri.parse('http://cozydorms.life/modules/mobile-api/student_dashboard_api.php?student_email=${widget.userEmail}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          setState(() {
            dashboardData = data['stats'];
            isLoading = false;
          });
        } else {
          throw Exception(data['error']);
        }
      } else {
        throw Exception('Server error');
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final orange = Color(0xFFFF9800);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: isLoading
        ? Center(child: CircularProgressIndicator())
        : error.isNotEmpty
        ? Center(child: Text(error))
        : RefreshIndicator(
            onRefresh: fetchDashboardData,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    color: orange,
                    padding: EdgeInsets.fromLTRB(20, 60, 20, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(color: Colors.white70),
                        ),
                        Text(
                          widget.userName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Stats Grid
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Overview',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        GridView.count(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.5,
                          children: [
                            _StatCard(
                              title: 'Active\nReservations',
                              value: '${dashboardData['active_reservations'] ?? 0}',
                              icon: Icons.home,
                              color: Colors.blue,
                            ),
                            _StatCard(
                              title: 'Payments\nDue',
                              value: '₱${(dashboardData['payments_due'] ?? 0).toStringAsFixed(2)}',
                              icon: Icons.payment,
                              color: Colors.orange,
                            ),
                            _StatCard(
                              title: 'Unread\nMessages',
                              value: '${dashboardData['unread_messages'] ?? 0}',
                              icon: Icons.message,
                              color: Colors.green,
                            ),
                            _StatCard(
                              title: 'Active\nBookings',
                              value: '${(dashboardData['active_bookings'] as List?)?.length ?? 0}',
                              icon: Icons.book_online,
                              color: Colors.purple,
                            ),
                          ],
                        ),

                        // Recent Bookings
                        if ((dashboardData['active_bookings'] as List?)?.isNotEmpty ?? false) ...[
                          SizedBox(height: 24),
                          Text(
                            'Recent Bookings',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          ...List.generate(
                            (dashboardData['active_bookings'] as List).length,
                            (index) {
                              final booking = dashboardData['active_bookings'][index];
                              return Card(
                                margin: EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  title: Text(booking['dorm_name']),
                                  subtitle: Text('${booking['room_type']} • ${booking['owner_name']}'),
                                  trailing: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: booking['status'] == 'approved'
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      booking['status'].toUpperCase(),
                                      style: TextStyle(
                                        color: booking['status'] == 'approved'
                                            ? Colors.green
                                            : Colors.orange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}