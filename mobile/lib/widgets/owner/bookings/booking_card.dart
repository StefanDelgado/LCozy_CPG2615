import 'package:flutter/material.dart';

/// Booking card widget displaying booking details
class BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final VoidCallback? onApprove;

  const BookingCard({
    super.key,
    required this.booking,
    this.onApprove,
  });

  @override
  Widget build(BuildContext context) {
    final studentName = booking['student_name']?.toString() ?? 'Unknown';
    final requestedAt = booking['requested_at']?.toString() ?? '';
    final dormName = booking['dorm_name']?.toString() ?? 'Unknown Dorm';
    final roomType = booking['room_type']?.toString() ?? 'Unknown Room';
    final duration = booking['duration']?.toString() ?? 'Not specified';
    final price = booking['price']?.toString() ?? '₱0';
    final status = (booking['status'] ?? '').toString().toLowerCase();
    final isPending = status == 'pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  studentName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  requestedAt,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            
            const Divider(height: 24),
            
            // Booking Details
            _InfoRow(label: 'Dorm', value: dormName),
            _InfoRow(label: 'Room', value: roomType),
            _InfoRow(label: 'Duration', value: duration),
            _InfoRow(label: 'Price', value: price),
            
            // Approve Button (only for pending bookings)
            if (isPending && onApprove != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onApprove,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Approve Booking'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Info row widget for displaying label-value pairs
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
