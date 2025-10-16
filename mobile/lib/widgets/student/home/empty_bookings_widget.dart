import 'package:flutter/material.dart';

class EmptyBookingsWidget extends StatelessWidget {
  final VoidCallback onBrowseDorms;

  const EmptyBookingsWidget({
    super.key,
    required this.onBrowseDorms,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.bookmark_border,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No active bookings',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: onBrowseDorms,
              child: const Text('Browse Dorms'),
            ),
          ],
        ),
      ),
    );
  }
}
