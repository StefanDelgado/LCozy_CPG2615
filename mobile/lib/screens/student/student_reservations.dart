import 'package:flutter/material.dart';
import 'view_details_screen.dart';
import 'submit_review_screen.dart';
import 'booking_details_screen.dart';

class StudentReservationsScreen extends StatelessWidget {
  final List<dynamic> bookings;
  final String userEmail;
  final int studentId;

  const StudentReservationsScreen({
    super.key,
    required this.bookings,
    required this.userEmail,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Bookings')),
      body: bookings.isEmpty
          ? const Center(child: Text('No bookings found'))
          : ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, i) {
                final booking = bookings[i];
                final dorm = booking['dorm'] ?? {};
                final status = booking['status'].toString().toLowerCase();
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(dorm['name'] ?? 'Unknown Dorm'),
                    subtitle: Text('Status: $status'),
                    trailing: status == 'completed'
                        ? ElevatedButton.icon(
                            icon: const Icon(Icons.rate_review, size: 18),
                            label: const Text('Write Review'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.black,
                            ),
                            onPressed: () {
                              final bookingId = (booking['booking_id'] != null && booking['booking_id'] != 0)
                                  ? (booking['booking_id'] is int ? booking['booking_id'] : int.tryParse(booking['booking_id']?.toString() ?? '0') ?? 0)
                                  : (booking['id'] is int ? booking['id'] : int.tryParse(booking['id']?.toString() ?? '0') ?? 0);
                // Always use the passed-in studentId
                final studentId = this.studentId;
                              final dormId = dorm['dorm_id']?.toString() ?? '';
                              print('[DEBUG] Review Navigation: dormId=$dormId, studentEmail=$userEmail, bookingId=$bookingId, studentId=$studentId');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SubmitReviewScreen(
                                    dormId: dormId,
                                    studentEmail: userEmail,
                                    bookingId: bookingId,
                                    studentId: studentId,
                                  ),
                                ),
                              );
                            },
                          )
                        : null,
                    onTap: () {
                      final isActiveBooking = (status == 'active' || status == 'approved' || 
                                                status.contains('checkout'));
                      
                      if (isActiveBooking) {
                        // Navigate to booking details for active bookings
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingDetailsScreen(
                              booking: booking,
                              userEmail: userEmail,
                              studentId: studentId,
                            ),
                          ),
                        );
                      } else {
                        // Navigate to dorm details for other statuses
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewDetailsScreen(
                              property: {
                                'dorm_id': dorm['dorm_id']?.toString() ?? '',
                                'name': dorm['name']?.toString() ?? '',
                                'address': dorm['address']?.toString() ?? '',
                              },
                              userEmail: userEmail,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
