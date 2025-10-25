import 'package:flutter/material.dart';
import 'student_home_screen.dart';
import 'view_details_screen.dart';
import 'submit_review_screen.dart';

class StudentReservationsScreen extends StatelessWidget {
  final List<dynamic> bookings;
  final String userEmail;

  const StudentReservationsScreen({
    super.key,
    required this.bookings,
    required this.userEmail,
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SubmitReviewScreen(
                                    dormId: dorm['dorm_id']?.toString() ?? '',
                                    studentEmail: userEmail,
                                  ),
                                ),
                              );
                            },
                          )
                        : null,
                    onTap: () {
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
                    },
                  ),
                );
              },
            ),
    );
  }
}
