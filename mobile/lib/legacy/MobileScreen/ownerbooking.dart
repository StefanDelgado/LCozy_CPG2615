import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// ==================== OwnerBookingScreen Widget ====================
class OwnerBookingScreen extends StatefulWidget {
  final String ownerEmail;

  const OwnerBookingScreen({
    super.key,
    required this.ownerEmail,
  });

  @override
  State<OwnerBookingScreen> createState() => _OwnerBookingScreenState();
}

// ==================== OwnerBookingScreen State ====================
class _OwnerBookingScreenState extends State<OwnerBookingScreen> {
  bool isLoading = true;
  String? error;
  List<Map<String, dynamic>> bookings = [];
  int selectedTab = 0;

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  // ----------- FETCH BOOKINGS SECTION -----------
  Future<void> fetchBookings() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('http://cozydorms.life/modules/mobile-api/owner_bookings_api.php?owner_email=${widget.ownerEmail}'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          setState(() {
            bookings = List<Map<String, dynamic>>.from(data['bookings']);
            isLoading = false;
          });
        } else {
          throw Exception(data['error'] ?? 'Unknown error');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  // ----------- APPROVE BOOKING SECTION -----------
  Future<void> approveBooking(int bookingId) async {
    try {
      final response = await http.post(
        Uri.parse('http://cozydorms.life/modules/mobile-api/owner_bookings_api.php'),
        body: {
          'action': 'approve',
          'booking_id': bookingId.toString(),
          'owner_email': widget.ownerEmail,
        },
      );

      final data = jsonDecode(response.body);
      if (data['ok'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking approved successfully')),
        );
        fetchBookings(); // Refresh the list
      } else {
        throw Exception(data['error'] ?? 'Failed to approve booking');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter bookings based on selected tab
    final filteredBookings = bookings.where((booking) {
      return selectedTab == 0 
          ? (booking['status'] ?? '').toString().toLowerCase() == 'pending'
          : (booking['status'] ?? '').toString().toLowerCase() == 'approved';
    }).toList();

    // ----------- MAIN UI SECTION -----------
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F0),
      appBar: AppBar(
        title: const Text('Booking Requests'),
        backgroundColor: const Color(0xFFFF9800),
      ),
      body: Column(
        children: [
          // Tab buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: _TabButton(
                    label: 'Pending',
                    isSelected: selectedTab == 0,
                    onTap: () => setState(() => selectedTab = 0),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TabButton(
                    label: 'Approved',
                    isSelected: selectedTab == 1,
                    onTap: () => setState(() => selectedTab = 1),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: isLoading 
              ? const Center(child: CircularProgressIndicator())
              : error != null
                ? Center(child: Text(error!))
                : filteredBookings.isEmpty
                  ? Center(
                      child: Text(
                        selectedTab == 0 
                          ? 'No pending bookings' 
                          : 'No approved bookings'
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredBookings.length,
                      itemBuilder: (context, index) {
                        final booking = filteredBookings[index];
                        return _BookingCard(
                          booking: booking,
                          onApprove: () => approveBooking(booking['booking_id'] ?? 0),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

// ==================== CustomTab Widget SECTION ====================
class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFFFF9800) : Colors.grey[200],
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(label),
    );
  }
}

// ==================== BookingCard Widget SECTION ====================
class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final VoidCallback onApprove;

  const _BookingCard({
    required this.booking,
    required this.onApprove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking['student_name'] ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(booking['requested_at'] ?? ''),
              ],
            ),
            const Divider(),
            _InfoRow(label: 'Dorm', value: booking['dorm_name'] ?? ''),
            _InfoRow(label: 'Room', value: booking['room_type'] ?? ''),
            _InfoRow(label: 'Duration', value: booking['duration'] ?? ''),
            _InfoRow(label: 'Price', value: booking['price'] ?? ''),
            if ((booking['status'] ?? '').toString().toLowerCase() == 'pending')
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onApprove,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('Approve'),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ==================== BookingInfo Widget SECTION ====================
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}