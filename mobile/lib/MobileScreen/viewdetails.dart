import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'student_owner_chat.dart';
import 'booking_form.dart';

// ==================== ViewDetailsScreen Widget ====================
class ViewDetailsScreen extends StatelessWidget {
  final Map<String, String> property;
  const ViewDetailsScreen({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    // ----------- IMAGES SECTION -----------
    final images = [
      property['image'] ?? '',
      'https://images.unsplash.com/photo-1464983953574-0892a716854b?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd?auto=format&fit=crop&w=800&q=80',
    ];

    // ----------- USER INFO SECTION -----------
    final String currentUserEmail = "student@email.com";
    final String currentUserRole = "student";

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ----------- IMAGE CAROUSEL SECTION -----------
            SizedBox(
              height: 200,
              child: PageView.builder(
                itemCount: images.length,
                itemBuilder: (context, index) => Stack(
                  children: [
                    Positioned.fill(
                      child: images[index].isNotEmpty
                          ? Image.network(
                              images[index],
                              fit: BoxFit.cover,
                            )
                          : Container(color: Colors.grey[300]),
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      child: CircleAvatar(
                        backgroundColor: Colors.black45,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.favorite_border, color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ----------- TAB CONTROLLER SECTION -----------
            Expanded(
              child: DefaultTabController(
                length: 4,
                child: Column(
                  children: [
                    // ----------- TAB BAR SECTION -----------
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TabBar(
                        isScrollable: false,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: Colors.orange.withOpacity(0.15),
                        ),
                        labelColor: Colors.orange,
                        unselectedLabelColor: Colors.grey,
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        unselectedLabelStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                        tabs: [
                          Tab(
                            icon: Icon(Icons.info_outline, color: Colors.orange),
                            text: 'Overview',
                          ),
                          Tab(
                            icon: Icon(Icons.list_alt, color: Colors.orange),
                            text: 'Amenities',
                          ),
                          Tab(
                            icon: Icon(Icons.map_outlined, color: Colors.orange),
                            text: 'Maps',
                          ),
                          Tab(
                            icon: Icon(Icons.contact_phone_outlined, color: Colors.orange),
                            text: 'Contacts',
                          ),
                        ],
                      ),
                    ),
                    // ----------- TAB BAR VIEW SECTION -----------
                    Expanded(
                      child: TabBarView(
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          // ----------- OVERVIEW TAB SECTION -----------
                          SingleChildScrollView(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            property['title'] ?? '',
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Near University of St. La Salle, Bacolod City',
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.star, color: Colors.orange, size: 20),
                                            SizedBox(width: 2),
                                            Text('4.8', style: TextStyle(fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          '₱18,000/month',
                                          style: TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        SizedBox(
                                          width: 120,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.orange,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              padding: EdgeInsets.symmetric(vertical: 12),
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => BookingFormScreen(
                                                    property: property,
                                                    studentEmail: currentUserEmail,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Text(
                                              'Reserve',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Description',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Experience comfortable student living at Sunset Dormitory. Located in the heart of downtown campus, this modern facility offers a perfect blend of comfort, convenience, and community. With spacious rooms, modern amenities, and a vibrant student atmosphere, Sunset Dormitory is your home away from home.',
                                  style: TextStyle(fontSize: 15, color: Colors.black87),
                                ),
                                SizedBox(height: 18),
                                Text(
                                  'Key Features',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 8),
                                featureItem('24/7 Security & Access Control'),
                                featureItem('Study Rooms & Common Areas'),
                                featureItem('Laundry Facilities'),
                                featureItem('Close to Campus & Transportation'),
                              ],
                            ),
                          ),
                          // ----------- AMENITIES TAB SECTION -----------
                          SingleChildScrollView(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Amenities',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.black87,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: 16),
                                amenitiesItem(Icons.security, '24/7 Security & Access Control'),
                                SizedBox(height: 12),
                                amenitiesItem(Icons.meeting_room, 'Study Rooms & Common Areas'),
                                SizedBox(height: 12),
                                amenitiesItem(Icons.local_laundry_service, 'Laundry Facilities'),
                                SizedBox(height: 12),
                                amenitiesItem(Icons.directions_bus, 'Close to Campus & Transportation'),
                              ],
                            ),
                          ),
                          // ----------- MAPS TAB SECTION -----------
                          SingleChildScrollView(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Location & Nearby',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 12),
                                kIsWeb
                                    ? Container(
                                        height: 200,
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Map is not supported on web.\nPlease use Android or iOS.',
                                          style: TextStyle(fontSize: 16, color: Colors.grey),
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    : SizedBox(
                                        height: 200,
                                        child: GoogleMap(
                                          initialCameraPosition: CameraPosition(
                                            target: LatLng(10.6661, 122.9506),
                                            zoom: 15,
                                          ),
                                          markers: {
                                            Marker(
                                              markerId: MarkerId('dorm'),
                                              position: LatLng(10.6661, 122.9506),
                                              infoWindow: InfoWindow(title: property['title']),
                                            ),
                                          },
                                        ),
                                      ),
                              ],
                            ),
                          ),
                          // ----------- CONTACTS TAB SECTION -----------
                          SingleChildScrollView(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Contact Information',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 12),
                                ListTile(
                                  leading: Icon(Icons.phone, color: Colors.orange),
                                  title: Text('0912 345 6789'),
                                  subtitle: Text('Call for inquiries'),
                                ),
                                ListTile(
                                  leading: Icon(Icons.email, color: Colors.orange),
                                  title: Text('info@sunsetdormitory.com'),
                                  subtitle: Text('Email us'),
                                ),
                                ListTile(
                                  leading: Icon(Icons.location_on, color: Colors.orange),
                                  title: Text('Sunset Dormitory, Bacolod City'),
                                  subtitle: Text('Near University of St. La Salle'),
                                ),
                                SizedBox(height: 20),
                                Center(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                                    ),
                                    icon: Icon(Icons.message),
                                    label: Text(
                                      "Message Owner",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => StudentOwnerChatScreen(
                                            currentUserEmail: currentUserEmail,
                                            otherUserEmail: property['owner_email'] ?? "brad@gmail.com",
                                            currentUserRole: currentUserRole,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // ----------- BOTTOM NAVIGATION SECTION -----------
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          }
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
    );
  }

  // ----------- FEATURE ITEM WIDGET SECTION -----------
  Widget featureItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(Icons.circle, color: Colors.orange, size: 8),
          SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  // ----------- AMENITIES ITEM WIDGET SECTION -----------
  Widget amenitiesItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.orange, size: 22),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}