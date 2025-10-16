import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';
import 'search.dart';
import 'profile.dart';
import 'student_owner_chat.dart';
import 'student_home.dart';
import 'browse_dorms.dart';

// ==================== HomeScreen Widget ====================
class HomeScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userRole;

  const HomeScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userRole,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// ==================== HomeScreen State ====================
class _HomeScreenState extends State<HomeScreen> {
  final purple = AppTheme.primary;

  int _selectedIndex = 0;
  String dormSearch = '';
  String selectedFilter = 'All';

  // ----------- FILTERS SECTION -----------
  final List<String> filters = [
    'All',
    'Near Campus',
    'City Center',
    'Budget',
  ];

  // ----------- FEATURED PROPERTIES SECTION -----------
  final List<Map<String, String>> featuredProperties = [
    {
      'image': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80',
      'location': 'Near Campus',
      'title': 'Premium Student Housing',
      'desc': 'Luxury amenities, close to university',
      'type': 'Near Campus',
      'owner_email': 'brad@gmail.com',
    },
    {
      'image': 'https://images.unsplash.com/photo-1464983953574-0892a716854b?auto=format&fit=crop&w=800&q=80',
      'location': 'City Center',
      'title': 'Urban Dorms',
      'desc': 'Modern rooms, walk to everything',
      'type': 'City Center',
      'owner_email': 'owner2@email.com',
    },
    {
      'image': 'https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd?auto=format&fit=crop&w=800&q=80',
      'location': 'Near Campus',
      'title': 'Budget Dorms',
      'desc': 'Affordable rooms for students',
      'type': 'Budget',
      'owner_email': 'owner3@email.com',
    },
  ];

  // ----------- PROPERTY FILTERING LOGIC SECTION -----------
  List<Map<String, String>> get filteredProperties {
    List<Map<String, String>> list = featuredProperties;
    if (selectedFilter != 'All') {
      list = list.where((prop) => prop['type'] == selectedFilter).toList();
    }
    if (dormSearch.isNotEmpty) {
      list = list.where((prop) =>
        prop['title']!.toLowerCase().contains(dormSearch.toLowerCase()) ||
        prop['location']!.toLowerCase().contains(dormSearch.toLowerCase()) ||
        prop['desc']!.toLowerCase().contains(dormSearch.toLowerCase())
      ).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;
    // ----------- HOME TAB SECTION -----------
    if (_selectedIndex == 0) {
      bodyContent = StudentHomeScreen(
        userName: widget.userName,
        userEmail: widget.userEmail,
      );
    }
    // ----------- SEARCH TAB SECTION -----------
    else if (_selectedIndex == 1) {
      bodyContent = SearchScreen(dorms: featuredProperties);
    }
    // ----------- MESSAGES TAB SECTION -----------
    else if (_selectedIndex == 3) {
      bodyContent = StudentChatListScreen(
        currentUserEmail: widget.userEmail,
        showAppBar: false,
      );
    }
    // ----------- ALERTS TAB SECTION -----------
    else if (_selectedIndex == 4) {
      bodyContent = NotificationTabContent();
    }
    // ----------- PROFILE TAB SECTION -----------
    else if (_selectedIndex == 5) {
      bodyContent = ProfileScreen(
        userName: widget.userName,
        userEmail: widget.userEmail,
        userRole: widget.userRole,
      );
    }
    // ----------- PLACEHOLDER TAB SECTION -----------
    else {
      bodyContent = Center(
        child: Text(
          'Coming Soon!',
          style: TextStyle(fontSize: 22, color: Colors.grey),
        ),
      );
    }

    // ----------- SCAFFOLD & BOTTOM NAVIGATION SECTION -----------
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: purple,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          // Search opens the browse dorms list (uses website API)
          if (index == 1) {
            Navigator.push(
              context, 
              MaterialPageRoute(
                builder: (_) => BrowseDormsScreen(userEmail: widget.userEmail)
              )
            );
            return;
          }
          // keep other nav functionality (Home, Messages, Profile)
          setState(() => _selectedIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.message_outlined), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
      body: SafeArea(child: bodyContent),
    );
  }
}

// ==================== NOTIFICATION TAB CONTENT SECTION ====================
class NotificationTabContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'title': 'Reservation Confirmed',
        'desc': 'Your reservation for Premium Student Housing is confirmed.',
        'time': '2 min ago',
        'icon': Icons.check_circle,
        'color': Color(0xFF4CAF50),
      },
      {
        'title': 'New Message',
        'desc': 'You have a new message from the dorm owner.',
        'time': '10 min ago',
        'icon': Icons.message,
        'color': Color(0xFF2196F3),
      },
      {
        'title': 'Payment Reminder',
        'desc': 'Your payment for Urban Dorms is due tomorrow.',
        'time': '1 hr ago',
        'icon': Icons.payment,
        'color': AppTheme.primary,
      },
      {
        'title': 'Special Offer',
        'desc': 'Get 10% off on Budget Dorms this month!',
        'time': '2 days ago',
        'icon': Icons.local_offer,
        'color': Color(0xFF9C27B0),
      },
    ];

    return notifications.isEmpty
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
          );
  }
}