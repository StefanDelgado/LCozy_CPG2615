import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../services/checkout_service.dart';
import '../../services/booking_service.dart';

class BookingDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> booking;
  final String userEmail;
  final int studentId;

  const BookingDetailsScreen({
    Key? key,
    required this.booking,
    required this.userEmail,
    required this.studentId,
  }) : super(key: key);

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  bool _isLoading = false;
  final BookingService _bookingService = BookingService();

  @override
  Widget build(BuildContext context) {
    final status = widget.booking['status'] ?? 'pending';
    final dorm = widget.booking['dorm'] ?? {};
    final room = widget.booking['room'] ?? {};
    final bookingId = widget.booking['booking_id'] is int
        ? widget.booking['booking_id']
        : int.tryParse(widget.booking['booking_id']?.toString() ?? '0') ?? 0;
    final startDate = widget.booking['start_date'] ?? 'N/A';
    final endDate = widget.booking['end_date'] ?? 'Ongoing';
    final bookingType = widget.booking['booking_type'] ?? 'shared';
    final daysUntil = widget.booking['days_until_checkin'] ?? 0;

    // Check if user can request checkout
    final canRequestCheckout =
        (status == 'active' || status == 'approved') &&
        !_hasCheckoutRequest();

    // Check if user can cancel booking (pending or approved, before payment)
    final canCancelBooking = 
        (status == 'pending' || status == 'approved') &&
        !_hasPaymentMade();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
        backgroundColor: AppTheme.primary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dorm['name'] ?? 'Unknown Dorm',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(status),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Booking Information
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Dorm Information'),
                  const SizedBox(height: 12),
                  _buildInfoCard([
                    _buildInfoRow(Icons.location_on, 'Address',
                        dorm['address'] ?? 'N/A'),
                    _buildInfoRow(Icons.meeting_room, 'Room Type',
                        room['room_type'] ?? 'N/A'),
                    _buildInfoRow(Icons.people, 'Capacity',
                        '${room['capacity'] ?? 0} persons'),
                    _buildInfoRow(
                      Icons.category,
                      'Booking Type',
                      bookingType == 'whole' ? 'Whole Room' : 'Shared',
                    ),
                  ]),

                  const SizedBox(height: 24),
                  _buildSectionTitle('Booking Details'),
                  const SizedBox(height: 12),
                  _buildInfoCard([
                    _buildInfoRow(
                        Icons.receipt, 'Booking ID', '#$bookingId'),
                    _buildInfoRow(Icons.calendar_today, 'Start Date', startDate),
                    _buildInfoRow(Icons.event, 'End Date', endDate),
                    if (daysUntil > 0)
                      _buildInfoRow(Icons.access_time, 'Check-in',
                          'In $daysUntil days'),
                  ]),

                  const SizedBox(height: 24),
                  _buildSectionTitle('Payment Information'),
                  const SizedBox(height: 12),
                  _buildInfoCard([
                    _buildInfoRow(Icons.attach_money, 'Monthly Rate',
                        '₱${room['price'] ?? 0}'),
                    _buildInfoRow(Icons.payment, 'Payment Status',
                        widget.booking['payment_status'] ?? 'Pending'),
                  ]),

                  // Cancel Booking Button (for pending/approved before payment)
                  if (canCancelBooking) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _showCancelBookingDialog,
                        icon: const Icon(Icons.cancel_outlined, size: 20),
                        label: const Text(
                          'Cancel Booking',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red[700],
                          side: BorderSide(color: Colors.red[700]!, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cancel this booking before payment',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  // Checkout Button
                  if (canRequestCheckout) ...[
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _showCheckoutDialog,
                        icon: const Icon(Icons.logout, size: 20),
                        label: const Text(
                          'Request Checkout',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Request to check out from this booking',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  // Checkout Status (if already requested)
                  if (_hasCheckoutRequest()) ...[
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.pending_actions,
                              size: 48, color: Colors.orange[700]),
                          const SizedBox(height: 8),
                          const Text(
                            'Checkout Request Pending',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your checkout request is being reviewed by the owner',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasCheckoutRequest() {
    // Check if status indicates checkout was requested
    final status = widget.booking['status']?.toString().toLowerCase() ?? '';
    return status.contains('checkout');
  }

  bool _hasPaymentMade() {
    // Check if any payment has been made (paid or verified)
    // This should be checked from the booking data or payment records
    // For now, we'll assume if status is 'active' or beyond, payment was made
    final status = widget.booking['status']?.toString().toLowerCase() ?? '';
    return status == 'active' || status == 'completed' || status.contains('checkout');
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      case 'checkout_requested':
      case 'checkout_approved':
        return Colors.orange[700]!;
      default:
        return Colors.grey;
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCheckoutDialog() async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Checkout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to request checkout from this booking?',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Submit Request'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _submitCheckoutRequest(reasonController.text);
    }
  }

  Future<void> _submitCheckoutRequest(String reason) async {
    setState(() => _isLoading = true);

    final bookingId = widget.booking['booking_id'] is int
        ? widget.booking['booking_id']
        : int.tryParse(widget.booking['booking_id']?.toString() ?? '0') ?? 0;

    final result = await CheckoutService.requestCheckout(
      studentId: widget.studentId,
      bookingId: bookingId,
      reason: reason,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Checkout request submitted!'),
          backgroundColor: Colors.green,
        ),
      );
      // Go back to refresh the list
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Failed to submit request'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showCancelBookingDialog() async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red[700], size: 28),
            const SizedBox(width: 8),
            const Text('Cancel Booking?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to cancel this booking?',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[300]!),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⚠️ This action cannot be undone',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '• Your booking will be cancelled\n• Room will become available again\n• You can only cancel before payment',
                    style: TextStyle(fontSize: 12, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for cancellation (optional)',
                hintText: 'Why are you canceling?',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit_note),
              ),
              maxLines: 3,
              maxLength: 300,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Booking'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _submitCancellation(reasonController.text);
    }
  }

  Future<void> _submitCancellation(String reason) async {
    setState(() => _isLoading = true);

    final bookingId = widget.booking['booking_id'] is int
        ? widget.booking['booking_id']
        : int.tryParse(widget.booking['booking_id']?.toString() ?? '0') ?? 0;

    final result = await _bookingService.cancelBooking(
      bookingId: bookingId,
      studentEmail: widget.userEmail,
      cancellationReason: reason.isNotEmpty ? reason : null,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Booking cancelled successfully!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
      // Go back to refresh the list
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to cancel booking'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}
