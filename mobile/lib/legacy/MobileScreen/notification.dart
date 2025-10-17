import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';

// ==================== NotificationScreen Widget ====================
class NotificationScreen extends StatelessWidget {
  final VoidCallback? onBack;
  const NotificationScreen({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    // ----------- NOTIFICATIONS DATA SECTION -----------
    final notifications = [
      {
        'title': 'Reservation Confirmed',
        'desc': 'Your reservation for Premium Student Housing is confirmed.',
        'time': '2 min ago',
        'icon': Icons.check_circle,
        'color': Color(0xFF4CAF50), // green
      },
      {
        'title': 'New Message',
        'desc': 'You have a new message from the dorm owner.',
        'time': '10 min ago',
        'icon': Icons.message,
        'color': Color(0xFF2196F3), // blue
      },
      {
        'title': 'Payment Reminder',
        'desc': 'Your payment for Urban Dorms is due tomorrow.',
        'time': '1 hr ago',
        'icon': Icons.payment,
        'color': AppTheme.primary, // purple
      },
      {
        'title': 'Special Offer',
        'desc': 'Get 10% off on Budget Dorms this month!',
        'time': '2 days ago',
        'icon': Icons.local_offer,
        'color': Color(0xFF9C27B0), // purple
      },
    ];

    // ----------- SCAFFOLD & APPBAR SECTION -----------
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        title: Text('Notifications', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
            if (onBack != null) onBack!();
          },
        ),
      ),
      // ----------- BODY SECTION -----------
      body: notifications.isEmpty
          ? Center(
              child: Text(
                'No notifications yet.',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => SizedBox(height: 10),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                // ----------- NOTIFICATION CARD SECTION -----------
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: notif['color'] as Color,
                      child: Icon(notif['icon'] as IconData, color: Colors.white),
                    ),
                    title: Text(
                      notif['title'] as String? ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      notif['desc'] as String? ?? '',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                    trailing: Text(
                      notif['time'] as String? ?? '',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}