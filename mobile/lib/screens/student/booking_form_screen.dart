import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';
import '../../services/booking_service.dart';

/// Screen for creating a new booking/reservation
class BookingFormScreen extends StatefulWidget {
  final String dormId;
  final String dormName;
  final List<dynamic> rooms;
  final String studentEmail;
  final int? preSelectedRoomId;

  const BookingFormScreen({
    super.key,
    required this.dormId,
    required this.dormName,
    required this.rooms,
    required this.studentEmail,
    this.preSelectedRoomId,
  });

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final BookingService _bookingService = BookingService();
  final _formKey = GlobalKey<FormState>();
  
  Map<String, dynamic>? selectedRoom;
  String bookingType = 'shared';
  DateTime? startDate;
  DateTime? endDate;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Set default dates
    startDate = DateTime.now();
    endDate = DateTime.now().add(const Duration(days: 180)); // 6 months
    
    // Pre-select room if provided
    if (widget.preSelectedRoomId != null) {
      selectedRoom = widget.rooms.firstWhere(
        (room) => room['room_id'] == widget.preSelectedRoomId,
        orElse: () => null,
      );
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? startDate! : endDate!,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)), // 2 years
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
          // Ensure end date is after start date
          if (endDate!.isBefore(startDate!)) {
            endDate = startDate!.add(const Duration(days: 180));
          }
        } else {
          endDate = picked;
        }
      });
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedRoom == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a room')),
      );
      return;
    }

    // Check if room is available
    if (selectedRoom!['is_available'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This room is not available')),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final result = await _bookingService.createBooking({
        'student_email': widget.studentEmail,
        'room_id': selectedRoom!['room_id'],
        'booking_type': bookingType,
        'start_date': '${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}',
        'end_date': '${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}',
      });

      if (result['success']) {
        if (!mounted) return;
        
        final data = result['data'];
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 32),
                const SizedBox(width: 12),
                const Expanded(child: Text('Booking Submitted!')),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result['message'] ?? 'Booking request submitted successfully!'),
                const SizedBox(height: 16),
                if (data != null) ...[
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildInfoRow('Dorm', data['dorm_name'] ?? ''),
                  _buildInfoRow('Room', data['room_type'] ?? ''),
                  _buildInfoRow('Type', (data['booking_type'] ?? '').toString().toUpperCase()),
                  _buildInfoRow('Price', '₱${data['price'] ?? 0}/month'),
                  _buildInfoRow('Status', 'Pending Approval'),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back to previous screen
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        throw Exception(result['message'] ?? 'Booking failed');
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  Widget _buildInfoRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label, 
            style: TextStyle(
              color: highlight ? Colors.green[700] : Colors.grey,
              fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value, 
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: highlight ? Colors.green[700] : Colors.black,
              fontSize: highlight ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final purple = AppTheme.primary;
    final availableRooms = widget.rooms.where((room) => room['is_available'] == true).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Dorm Room'),
        backgroundColor: purple,
      ),
      body: availableRooms.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No available rooms',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'All rooms in this dorm are currently full',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dorm Name
                    Text(
                      widget.dormName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Room Selection
                    const Text(
                      'Select Room',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ...availableRooms.map((room) {
                      final isSelected = selectedRoom?['room_id'] == room['room_id'];
                      return Card(
                        elevation: isSelected ? 4 : 1,
                        color: isSelected 
                            ? Colors.blue.shade50  // Soft blue background
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected 
                                ? Colors.blue.shade600  // Blue border
                                : Colors.grey.shade300,
                            width: isSelected ? 2.5 : 1,
                          ),
                        ),
                        child: InkWell(
                          onTap: () => setState(() => selectedRoom = room),
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
                                        room['room_type'] ?? 'Unknown',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected 
                                              ? Colors.blue.shade700  // Blue text when selected
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade600,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check, 
                                          color: Colors.white,
                                          size: 18,
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
                                      'Capacity: ${room['capacity']}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    const SizedBox(width: 16),
                                    Icon(Icons.door_sliding, size: 16, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${room['available_slots']} slots left',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '₱${room['price']}/month',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: purple,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 24),

                    // Booking Type
                    const Text(
                      'Booking Type',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Shared'),
                            subtitle: const Text('Share room with others'),
                            value: 'shared',
                            groupValue: bookingType,
                            onChanged: (value) => setState(() => bookingType = value!),
                            activeColor: purple,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Whole Room'),
                            subtitle: const Text('Book entire room'),
                            value: 'whole',
                            groupValue: bookingType,
                            onChanged: (value) => setState(() => bookingType = value!),
                            activeColor: purple,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Booking Duration
                    const Text(
                      'Booking Duration',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context, true),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Start Date',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                '${startDate!.day}/${startDate!.month}/${startDate!.year}',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context, false),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'End Date',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                '${endDate!.day}/${endDate!.month}/${endDate!.year}',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Summary Card
                    if (selectedRoom != null) ...[
                      Card(
                        color: Colors.grey[100],
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Booking Summary',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Divider(),
                              _buildInfoRow('Room Type', selectedRoom!['room_type']),
                              _buildInfoRow('Booking Type', bookingType.toUpperCase()),
                              _buildInfoRow('Room Capacity', '${selectedRoom!['capacity']} person(s)'),
                              _buildInfoRow('Base Price', '₱${selectedRoom!['price']}/month'),
                              if (bookingType == 'shared' && selectedRoom!['capacity'] != null && selectedRoom!['capacity'] > 0)
                                _buildInfoRow(
                                  'Your Share',
                                  '₱${(selectedRoom!['price'] / selectedRoom!['capacity']).toStringAsFixed(2)}/month',
                                  highlight: true,
                                )
                              else
                                _buildInfoRow(
                                  'Total Price',
                                  '₱${selectedRoom!['price']}/month',
                                  highlight: true,
                                ),
                              _buildInfoRow(
                                'Duration',
                                '${endDate!.difference(startDate!).inDays} days',
                              ),
                              const Divider(),
                              _buildInfoRow(
                                'Status',
                                'Pending Owner Approval',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : _submitBooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: purple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isSubmitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Submit Booking Request',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Info Text
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Your booking will be pending until the owner approves it. You will receive a notification once approved.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}