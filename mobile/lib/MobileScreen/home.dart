import 'package:flutter/material.dart';
import 'package:cozydorm/MobileScreen/viewdetails.dart';
import 'package:cozydorm/MobileScreen/search.dart';
import 'package:cozydorm/MobileScreen/profile.dart';
import 'package:cozydorm/MobileScreen/student_owner_chat.dart';

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
  final orange = Color(0xFFFF9800);

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
      bodyContent = SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----------- HEADER SECTION -----------
            Container(
              color: orange,
              width: double.infinity,
              padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, ${widget.userName}!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Find your perfect home',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.notifications_none, color: Colors.white, size: 28),
                        onPressed: () {
                          setState(() {
                            _selectedIndex = 4; // Switch to Alerts tab
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 18),
                  // ----------- SEARCH BAR SECTION -----------
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = 1; // Switch to Search tab
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: AbsorbPointer(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search for dorms...',
                            prefixIcon: Icon(Icons.search, color: orange),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            // ----------- FEATURED PROPERTIES TITLE SECTION -----------
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Featured Properties',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 10),
            // ----------- FILTERS ROW SECTION -----------
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: filters.map((filter) => Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: selectedFilter == filter,
                      selectedColor: orange,
                      backgroundColor: Colors.grey[200],
                      labelStyle: TextStyle(
                        color: selectedFilter == filter ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          selectedFilter = filter;
                        });
                      },
                    ),
                  )).toList(),
                ),
              ),
            ),
            SizedBox(height: 14),
            // ----------- FEATURED PROPERTIES LIST SECTION -----------
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: filteredProperties.isEmpty
                  ? [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'No properties found.',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ),
                      ),
                    ]
                  : filteredProperties.map((prop) => Container(
                    margin: EdgeInsets.only(bottom: 28),
                    height: 270,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // ----------- PROPERTY IMAGE SECTION -----------
                        ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Image.network(
                            prop['image'] ?? '',
                            height: 270,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high,
                            loadingBuilder: (context, child, progress) =>
                              progress == null
                                ? child
                                : Container(
                                    height: 270,
                                    width: double.infinity,
                                    color: Colors.grey[200],
                                    child: Center(child: CircularProgressIndicator()),
                                  ),
                            errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 270,
                                width: double.infinity,
                                color: Colors.grey[300],
                                child: Icon(Icons.broken_image, color: Colors.grey, size: 48),
                              ),
                          ),
                        ),
                        // ----------- GRADIENT OVERLAY SECTION -----------
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          height: 130,
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(28),
                              bottomRight: Radius.circular(28),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.75),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // ----------- PROPERTY INFO SECTION -----------
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Padding(
                            padding: EdgeInsets.all(28),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.location_on, color: Colors.red, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      prop['location'] ?? '',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        shadows: [Shadow(blurRadius: 2, color: Colors.black38)],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Text(
                                  prop['title'] ?? '',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.2,
                                    shadows: [Shadow(blurRadius: 3, color: Colors.black45)],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  prop['desc'] ?? '',
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.white.withOpacity(0.95),
                                    shadows: [Shadow(blurRadius: 2, color: Colors.black38)],
                                  ),
                                ),
                                SizedBox(height: 22),
                                SizedBox(
                                  width: 150,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 14),
                                      elevation: 2,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ViewDetailsScreen(property: prop),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'View Details',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
              ),
            ),
          ],
        ),
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
        selectedItemColor: orange,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Wishlist'),
          BottomNavigationBarItem(icon: Icon(Icons.message_outlined), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'Alerts'),
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
        'color': Color(0xFFFF9800),
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