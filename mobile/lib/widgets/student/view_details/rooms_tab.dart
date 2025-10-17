import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/helpers.dart';
import '../../../screens/student/booking_form_screen.dart';

class RoomsTab extends StatelessWidget {
  final List<dynamic> rooms;
  final String dormId;
  final String dormName;
  final String studentEmail;

  const RoomsTab({
    super.key,
    required this.rooms,
    required this.dormId,
    required this.dormName,
    required this.studentEmail,
  });

  @override
  Widget build(BuildContext context) {
    if (rooms.isEmpty) {
      return const Center(
        child: Text('No rooms available'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        final room = rooms[index];
        final isAvailable = room['is_available'] == true;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: isAvailable ? () {
              // Navigate to booking form with this room pre-selected
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookingFormScreen(
                    dormId: dormId,
                    dormName: dormName,
                    rooms: rooms,
                    studentEmail: studentEmail,
                    preSelectedRoomId: room['room_id'],
                  ),
                ),
              );
            } : null,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        Helpers.safeText(room['room_type'], 'Unknown Room'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isAvailable 
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isAvailable ? 'Available' : 'Full',
                        style: TextStyle(
                          color: isAvailable ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.people, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Capacity: ${room['capacity']} persons',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    if (room['size'] != null) ...[
                      const SizedBox(width: 16),
                      Icon(Icons.square_foot, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${room['size']} sqm',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${Helpers.formatCurrency(room['price'])}/month',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
                if (isAvailable) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${room['available_slots']} slots remaining',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.touch_app, size: 16, color: Colors.blue[700]),
                      const SizedBox(width: 6),
                      Text(
                        'Tap to book this room',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            ),
          ),
        );
      },
    );
  }
}
