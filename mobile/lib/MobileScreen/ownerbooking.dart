import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// ==================== OwnerBookingScreen Widget ====================
class OwnerBookingScreen extends StatefulWidget {
  const OwnerBookingScreen({super.key});

  @override
  State<OwnerBookingScreen> createState() => _OwnerBookingScreenState();
}

// ==================== OwnerBookingScreen State ====================
class _OwnerBookingScreenState extends State<OwnerBookingScreen> {
  int selectedTab = 0;
  int pendingCount = 0;
  List bookings = [];
  final String ownerEmail = "brad@gmail.com"; // Replace with actual owner email

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  // ----------- FETCH BOOKINGS SECTION -----------
  Future<void> fetchBookings() async {
    try {
      final response = await http.get(
        Uri.parse('http://cozydorms.life/modules/mobile-api/owner_bookings_api.php?owner_email=$ownerEmail'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          setState(() {
            bookings = data['bookings'];
            pendingCount = bookings.where((b) => 
              b['status'].toString().toLowerCase() == 'pending'
            ).length;
          });
        } else {
          throw Exception(data['error'] ?? 'Failed to load bookings');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching bookings: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load bookings'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final orange = const Color(0xFFFF9800);
    List filteredBookings;
    // ----------- TAB FILTERING LOGIC SECTION -----------
    if (selectedTab == 0) {
      filteredBookings = bookings.where((b) => b['status'] == 'Pending').toList();
    } else {
      filteredBookings = bookings.where((b) => b['status'] == 'Approved').toList();
    }

    // ----------- MAIN UI SECTION -----------
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F0),
      body: SafeArea(
        child: Column(
          children: [
            // ----------- HEADER SECTION -----------
            Container(
              padding: const EdgeInsets.only(left: 8, right: 20, top: 18, bottom: 18),
              decoration: BoxDecoration(
                color: orange,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Booking Requests",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Manage student applications",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // ----------- TABS SECTION -----------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [orange, orange.withOpacity(0.85)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _CustomTab(
                      label: 'Pending',
                      selected: selectedTab == 0,
                      count: pendingCount,
                      onTap: () {
                        setState(() => selectedTab = 0);
                      },
                    ),
                    _CustomTab(
                      label: 'Approved',
                      selected: selectedTab == 1,
                      onTap: () {
                        setState(() => selectedTab = 1);
                      },
                    ),
                  ],
                ),
              ),
            ),
            // ----------- BOOKING LIST SECTION -----------
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: filteredBookings.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 60),
                          child: Text(
                            selectedTab == 0
                                ? "No pending bookings."
                                : "No approved bookings.",
                            style: TextStyle(color: Colors.grey[600], fontSize: 16),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                        itemCount: filteredBookings.length,
                        itemBuilder: (context, index) {
                          final b = filteredBookings[index];
                          return Column(
                            children: [
                              BookingCard(
                                name: b['student_email'] ?? '',
                                initials: b['student_email'] != null
                                    ? b['student_email'].substring(0, 2).toUpperCase()
                                    : '',
                                requestedAgo: b['requested_at'] ?? '',
                                status: b['status'] ?? '',
                                dorm: b['dorm'] ?? '',
                                roomType: b['room_type'] ?? '',
                                duration: b['duration'] ?? '',
                                startDate: b['start_date'] ?? '',
                                price: b['price'] ?? '',
                                message: b['message'] ?? '',
                                onApprove: () {
                                  approveBooking(b['id']);
                                },
                                onChat: () {
                                  // Implement chat logic here
                                },
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------- APPROVE BOOKING SECTION -----------
  Future<void> approveBooking(dynamic bookingId) async {
    try {
      final response = await http.post(
        Uri.parse('http://cozydorms.life/modules/mobile-api/owner_bookings_api.php'),
        body: {
          'action': 'approve',
          'booking_id': bookingId.toString(),
          'owner_email': ownerEmail
        },
      );

      final data = jsonDecode(response.body);
      if (data['ok'] == true) {
        await fetchBookings(); // Refresh list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking approved successfully'))
        );
      } else {
        throw Exception(data['error']);
      }
    } catch (e) {
      print('Error approving booking: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to approve booking'))
      );
    }
  }
}

// ==================== CustomTab Widget SECTION ====================
class _CustomTab extends StatelessWidget {
  final String label;
  final bool selected;
  final int? count;
  final VoidCallback onTap;

  const _CustomTab({
    required this.label,
    required this.selected,
    this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final orange = const Color(0xFFFF9800);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 2),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? orange : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (count != null && selected)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                      decoration: BoxDecoration(
                        color: orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        count.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== BookingCard Widget SECTION ====================
class BookingCard extends StatelessWidget {
  final String name;
  final String initials;
  final String requestedAgo;
  final String status;
  final String dorm;
  final String roomType;
  final String duration;
  final String startDate;
  final String price;
  final String message;
  final VoidCallback onApprove;
  final VoidCallback onChat;

  const BookingCard({
    super.key,
    required this.name,
    required this.initials,
    required this.requestedAgo,
    required this.status,
    required this.dorm,
    required this.roomType,
    required this.duration,
    required this.startDate,
    required this.price,
    required this.message,
    required this.onApprove,
    required this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    final orange = const Color(0xFFFF9800);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: orange.withOpacity(0.13)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ----------- TOP ROW SECTION -----------
          Row(
            children: [
              CircleAvatar(
                backgroundColor: orange.withOpacity(0.15),
                child: Text(
                  initials,
                  style: TextStyle(
                    color: orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "Requested $requestedAgo",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: orange.withOpacity(0.13),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // ----------- DORM AND ROOM TYPE SECTION -----------
          Row(
            children: [
              Expanded(
                child: _BookingInfo(label: "Dorm:", value: dorm),
              ),
              Expanded(
                child: _BookingInfo(label: "Room Type:", value: roomType),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // ----------- DURATION AND START DATE SECTION -----------
          Row(
            children: [
              Expanded(
                child: _BookingInfo(label: "Duration:", value: duration),
              ),
              Expanded(
                child: _BookingInfo(label: "Start Date:", value: startDate),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // ----------- PRICE SECTION -----------
          Row(
            children: [
              Icon(Icons.credit_card, color: orange, size: 20),
              const SizedBox(width: 6),
              Text(
                price,
                style: TextStyle(
                  color: orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // ----------- MESSAGE SECTION -----------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: orange.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              message,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(height: 12),
          // ----------- ACTION BUTTONS SECTION -----------
          Row(
            children: [
              // Approve Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onApprove,
                  icon: const Icon(Icons.check, color: Colors.white, size: 20),
                  label: const Text("Approve", style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF219653),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Chat Button
              Container(
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: onChat,
                  icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF757575), size: 20),
                  label: const Text("Chat", style: TextStyle(color: Color(0xFF757575), fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF757575),
                    side: const BorderSide(color: Color(0xFFBDBDBD)),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================== BookingInfo Widget SECTION ====================
class _BookingInfo extends StatelessWidget {
  final String label;
  final String value;

  const _BookingInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: RichText(
        text: TextSpan(
          text: "$label ",
          style: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
            fontSize: 13.5,
          ),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}