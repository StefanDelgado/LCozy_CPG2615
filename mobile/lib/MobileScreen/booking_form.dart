import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ==================== BookingFormScreen Widget ====================
class BookingFormScreen extends StatefulWidget {
  final Map<String, String> property;
  final String studentEmail;

  const BookingFormScreen({
    super.key,
    required this.property,
    required this.studentEmail,
  });

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

// ==================== BookingFormScreen State ====================
class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? roomType;
  String duration = '';
  DateTime? startDate;
  String message = '';
  bool isSubmitting = false;

  // ----------- ROOM TYPES SECTION -----------
  final List<String> roomTypes = [
    'Single Room',
    'Double Room',
    'Shared Room',
  ];

  // ----------- SUBMIT BOOKING LOGIC SECTION -----------
  Future<void> submitBooking() async {
    setState(() {
      isSubmitting = true;
    });

    final response = await http.post(
      Uri.parse('https://bradedsale.helioho.st/booking_api/booking_api.php?action=submit_booking'),
      body: {
        'student_email': widget.studentEmail,
        'owner_email': widget.property['owner_email'] ?? '',
        'dorm': widget.property['title'] ?? '',
        'room_type': roomType ?? '',
        'duration': duration,
        'start_date': startDate != null ? startDate!.toIso8601String().split('T').first : '',
        'price': widget.property['price'] ?? '',
        'message': message,
      },
    );

    setState(() {
      isSubmitting = false;
    });

    if (response.statusCode == 200 && response.body.contains('success')) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Booking Submitted'),
          content: Text('Your booking request has been sent to the owner.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // go back to details
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit booking. Please try again.')),
      );
    }
  }

  // ----------- UI SECTION -----------
  @override
  Widget build(BuildContext context) {
    final orange = Color(0xFFFF9800);

    return Scaffold(
      appBar: AppBar(
        title: Text('Reserve Dorm'),
        backgroundColor: orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // ----------- PROPERTY TITLE SECTION -----------
              Text(
                widget.property['title'] ?? '',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(height: 18),
              // ----------- ROOM TYPE DROPDOWN SECTION -----------
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Room Type',
                  border: OutlineInputBorder(),
                ),
                value: roomType,
                items: roomTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type, style: TextStyle(color: Colors.black)),
                  );
                }).toList(),
                onChanged: (val) => setState(() => roomType = val),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 14),
              // ----------- START DATE PICKER SECTION -----------
              GestureDetector(
                onTap: () async {
                  FocusScope.of(context).unfocus();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(DateTime.now().year + 2),
                  );
                  if (picked != null) {
                    setState(() {
                      startDate = picked;
                    });
                  }
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Start Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today, color: orange),
                    ),
                    validator: (val) => startDate == null ? 'Required' : null,
                    controller: TextEditingController(
                      text: startDate == null
                          ? ''
                          : "${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}",
                    ),
                  ),
                ),
              ),
              SizedBox(height: 14),
              // ----------- DURATION INPUT SECTION -----------
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Duration (e.g. 6 months)',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                onSaved: (val) => duration = val ?? '',
              ),
              SizedBox(height: 14),
              // ----------- MESSAGE TO OWNER SECTION -----------
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Message to Owner',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onSaved: (val) => message = val ?? '',
              ),
              SizedBox(height: 24),
              // ----------- SUBMIT BUTTON SECTION -----------
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isSubmitting
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text('Submit Booking Request', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: isSubmitting
                    ? null
                    : () {
                        if (_formKey.currentState?.validate() ?? false) {
                          _formKey.currentState?.save();
                          submitBooking();
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}