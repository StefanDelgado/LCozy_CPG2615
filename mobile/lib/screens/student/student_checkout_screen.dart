import 'package:flutter/material.dart';
import '../../services/checkout_service.dart';
import '../../utils/app_theme.dart';

class StudentCheckoutScreen extends StatefulWidget {
  final int studentId;

  const StudentCheckoutScreen({Key? key, required this.studentId})
      : super(key: key);

  @override
  State<StudentCheckoutScreen> createState() => _StudentCheckoutScreenState();
}

class _StudentCheckoutScreenState extends State<StudentCheckoutScreen> {
  List<dynamic> _bookings = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result =
        await CheckoutService.getStudentBookings(studentId: widget.studentId);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result['success'] == true) {
          _bookings = result['data'] ?? [];
        } else {
          _errorMessage = result['error'] ?? 'Failed to load bookings';
        }
      });
    }
  }

  Future<void> _showCheckoutDialog(Map<String, dynamic> booking) async {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Checkout'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dorm: ${booking['dorm_name']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Room: ${booking['room_type']}'),
              const SizedBox(height: 16),
              TextFormField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason (optional)',
                  hintText: 'Why are you checking out?',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                maxLength: 500,
              ),
              const SizedBox(height: 8),
              const Text(
                'The owner will review your request.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Submit Request'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _submitCheckoutRequest(booking['booking_id'], reasonController.text);
    }
  }

  Future<void> _submitCheckoutRequest(int bookingId, String reason) async {
    // Show loading
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final result = await CheckoutService.requestCheckout(
      studentId: widget.studentId,
      bookingId: bookingId,
      reason: reason,
    );

    if (!mounted) return;
    Navigator.pop(context); // Close loading

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Checkout request submitted!'),
          backgroundColor: Colors.green,
        ),
      );
      _loadBookings(); // Refresh list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Failed to submit request'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final canRequestCheckout = booking['can_request_checkout'] == true;
    final checkoutStatus = booking['checkout_status'];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    booking['dorm_name'] ?? 'Unknown Dorm',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusBadge(booking['status'], checkoutStatus),
              ],
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.meeting_room, 'Room: ${booking['room_type']}'),
            _buildInfoRow(Icons.category, 'Type: ${booking['booking_type']}'),
            _buildInfoRow(
              Icons.calendar_today,
              'From: ${booking['start_date']}',
            ),
            _buildInfoRow(
              Icons.event,
              'Until: ${booking['end_date'] ?? 'Ongoing'}',
            ),
            _buildInfoRow(
              Icons.attach_money,
              'Price: ₱${booking['price']?.toStringAsFixed(2)}',
            ),
            if (checkoutStatus != null) ...[
              const Divider(height: 24),
              _buildInfoRow(
                Icons.info_outline,
                'Checkout Status: ${checkoutStatus.toString().toUpperCase()}',
              ),
              if (booking['checkout_requested_at'] != null)
                _buildInfoRow(
                  Icons.access_time,
                  'Requested: ${booking['checkout_requested_at']}',
                ),
            ],
            if (canRequestCheckout) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showCheckoutDialog(booking),
                  icon: const Icon(Icons.logout),
                  label: const Text('Request Checkout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, String? checkoutStatus) {
    Color bgColor;
    Color textColor = Colors.white;
    String displayText = checkoutStatus ?? status;

    switch (checkoutStatus ?? status) {
      case 'active':
      case 'approved':
        bgColor = Colors.green;
        break;
      case 'requested':
        bgColor = Colors.orange;
        displayText = 'Checkout Pending';
        break;
      case 'checkout_requested':
        bgColor = Colors.orange;
        displayText = 'Pending';
        break;
      case 'checkout_approved':
        bgColor = Colors.blue;
        displayText = 'Approved';
        break;
      case 'completed':
        bgColor = Colors.grey;
        break;
      default:
        bgColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Checkout'),
        backgroundColor: AppTheme.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_errorMessage!,
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadBookings,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _bookings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined,
                              size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No active bookings',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadBookings,
                      child: ListView.builder(
                        itemCount: _bookings.length,
                        itemBuilder: (context, index) =>
                            _buildBookingCard(_bookings[index]),
                      ),
                    ),
    );
  }
}
