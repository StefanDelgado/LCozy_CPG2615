import 'package:flutter/material.dart';
import '../../services/booking_service.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_display_widget.dart';
import '../../widgets/owner/bookings/booking_tab_button.dart';
import '../../widgets/owner/bookings/booking_card.dart';
import '../../../utils/app_theme.dart';
import '../shared/chat_conversation_screen.dart';

/// Screen for managing booking requests
/// 
/// Features:
/// - Tab-based view (Pending/Approved bookings)
/// - Booking approval functionality
/// - Booking details display
/// - Pull-to-refresh
class OwnerBookingScreen extends StatefulWidget {
  final String ownerEmail;

  const OwnerBookingScreen({
    super.key,
    required this.ownerEmail,
  });

  @override
  State<OwnerBookingScreen> createState() => _OwnerBookingScreenState();
}

class _OwnerBookingScreenState extends State<OwnerBookingScreen> {
  final BookingService _bookingService = BookingService();
  
  // UI State
  bool _isLoading = true;
  bool _isProcessing = false; // Track if approve/reject is in progress
  String? _error;
  int _selectedTab = 0;

  // Data
  List<Map<String, dynamic>> _bookings = [];

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  /// Fetches booking data from the API
  Future<void> _fetchBookings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _bookingService.getOwnerBookings(widget.ownerEmail);

      if (result['success']) {
        setState(() {
          _bookings = List<Map<String, dynamic>>.from(result['data'] ?? []);
          _isLoading = false;
        });
      } else {
        throw Exception(result['error'] ?? 'Failed to load bookings');
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load bookings: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Approves a booking
  Future<void> _approveBooking(Map<String, dynamic> booking) async {
    print('📋 [OwnerBooking] ========================================');
    print('📋 [OwnerBooking] APPROVE BOOKING CLICKED');
    print('📋 [OwnerBooking] ========================================');
    
    // Prevent multiple clicks
    if (_isProcessing) {
      print('📋 [OwnerBooking] ⚠️ Already processing a booking action, ignoring click');
      return;
    }
    
    print('📋 [OwnerBooking] Full booking data: $booking');
    print('📋 [OwnerBooking] Owner email: ${widget.ownerEmail}');
    print('📋 [OwnerBooking] Context mounted: $mounted');

    final bookingId = booking['booking_id'] ?? booking['id'];
    print('📋 [OwnerBooking] Extracted booking_id: $bookingId (type: ${bookingId.runtimeType})');
    
    if (bookingId == null) {
      print('📋 [OwnerBooking] ❌ CRITICAL: Booking ID is null!');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Booking ID is missing'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    print('📋 [OwnerBooking] Starting approval process...');
    print('📋 [OwnerBooking] Calling updateBookingStatus with:');
    print('📋 [OwnerBooking]   - bookingId: $bookingId');
    print('📋 [OwnerBooking]   - action: approve');
    print('📋 [OwnerBooking]   - ownerEmail: ${widget.ownerEmail}');

    // Show loading indicator
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text('Processing approval...'),
            ],
          ),
          duration: Duration(seconds: 30),
        ),
      );
    }

    try {
      print('📋 [OwnerBooking] ⏳ Awaiting API response...');
      
      final result = await _bookingService.updateBookingStatus(
        bookingId: bookingId.toString(),
        action: 'approve',
        ownerEmail: widget.ownerEmail,
      );

      // Clear loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }

      print('📋 [OwnerBooking] ========================================');
      print('📋 [OwnerBooking] API RESPONSE RECEIVED');
      print('📋 [OwnerBooking] ========================================');
      print('📋 [OwnerBooking] Full result: $result');
      print('📋 [OwnerBooking] Success: ${result['success']}');
      print('📋 [OwnerBooking] Message: ${result['message']}');

      if (result['success'] == true) {
        print('📋 [OwnerBooking] ✅ Approval successful!');
        if (mounted) {
          print('📋 [OwnerBooking] Showing success message...');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Booking approved successfully'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
          print('📋 [OwnerBooking] Refreshing bookings list...');
          _fetchBookings(); // Refresh the list
        } else {
          print('📋 [OwnerBooking] ⚠️ Context not mounted, skipping UI updates');
        }
      } else {
        print('📋 [OwnerBooking] ❌ Approval failed: ${result['message']}');
        final errorMessage = result['message'] ?? 'Failed to approve booking';
        print('📋 [OwnerBooking] Throwing exception: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e, stackTrace) {
      // Clear loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }
      
      print('📋 [OwnerBooking] ========================================');
      print('📋 [OwnerBooking] EXCEPTION CAUGHT');
      print('📋 [OwnerBooking] ========================================');
      print('📋 [OwnerBooking] ❌ Error type: ${e.runtimeType}');
      print('📋 [OwnerBooking] ❌ Error message: $e');
      print('📋 [OwnerBooking] ❌ Stack trace: $stackTrace');
      
      if (mounted) {
        print('📋 [OwnerBooking] Showing error message to user...');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
        print('📋 [OwnerBooking] Error message shown');
      } else {
        print('📋 [OwnerBooking] ⚠️ Context not mounted, cannot show error message');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
      print('📋 [OwnerBooking] ========================================');
      print('📋 [OwnerBooking] APPROVE BOOKING COMPLETE');
      print('📋 [OwnerBooking] ========================================');
    }
  }

  /// Rejects a booking
  Future<void> _rejectBooking(Map<String, dynamic> booking) async {
    print('📋 [OwnerBooking] ========================================');
    print('📋 [OwnerBooking] REJECT BOOKING CLICKED');
    print('📋 [OwnerBooking] ========================================');
    
    // Prevent multiple clicks
    if (_isProcessing) {
      print('📋 [OwnerBooking] ⚠️ Already processing a booking action, ignoring click');
      return;
    }
    
    print('📋 [OwnerBooking] Full booking data: $booking');
    print('📋 [OwnerBooking] Owner email: ${widget.ownerEmail}');

    final bookingId = booking['booking_id'] ?? booking['id'];
    print('📋 [OwnerBooking] Extracted booking_id: $bookingId (type: ${bookingId.runtimeType})');
    
    if (bookingId == null) {
      print('📋 [OwnerBooking] ❌ CRITICAL: Booking ID is null!');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Booking ID is missing'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
      return;
    }

    // Show confirmation dialog
    print('📋 [OwnerBooking] Showing confirmation dialog...');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disapprove Booking'),
        content: Text('Are you sure you want to disapprove the booking request from ${booking['student_name'] ?? 'this student'}?'),
        actions: [
          TextButton(
            onPressed: () {
              print('📋 [OwnerBooking] User cancelled rejection');
              Navigator.pop(context, false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              print('📋 [OwnerBooking] User confirmed rejection');
              Navigator.pop(context, true);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Disapprove'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      print('📋 [OwnerBooking] Rejection cancelled by user');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    print('📋 [OwnerBooking] Starting rejection process...');
    print('📋 [OwnerBooking] Calling updateBookingStatus with:');
    print('📋 [OwnerBooking]   - bookingId: $bookingId');
    print('📋 [OwnerBooking]   - action: reject');
    print('📋 [OwnerBooking]   - ownerEmail: ${widget.ownerEmail}');

    // Show loading indicator
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text('Processing rejection...'),
            ],
          ),
          duration: Duration(seconds: 30),
        ),
      );
    }

    try {
      print('📋 [OwnerBooking] ⏳ Awaiting API response...');
      
      final result = await _bookingService.updateBookingStatus(
        bookingId: bookingId.toString(),
        action: 'reject',
        ownerEmail: widget.ownerEmail,
      );

      // Clear loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }

      print('📋 [OwnerBooking] ========================================');
      print('📋 [OwnerBooking] API RESPONSE RECEIVED');
      print('📋 [OwnerBooking] ========================================');
      print('📋 [OwnerBooking] Full result: $result');
      print('📋 [OwnerBooking] Success: ${result['success']}');
      print('📋 [OwnerBooking] Message: ${result['message']}');

      if (result['success'] == true) {
        print('📋 [OwnerBooking] ✅ Rejection successful!');
        if (mounted) {
          print('📋 [OwnerBooking] Showing success message...');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Booking rejected successfully'),
              backgroundColor: AppTheme.primary,
              duration: const Duration(seconds: 3),
            ),
          );
          print('📋 [OwnerBooking] Refreshing bookings list...');
          _fetchBookings(); // Refresh the list
        } else {
          print('📋 [OwnerBooking] ⚠️ Context not mounted, skipping UI updates');
        }
      } else {
        print('📋 [OwnerBooking] ❌ Rejection failed: ${result['message']}');
        final errorMessage = result['message'] ?? 'Failed to disapprove booking';
        print('📋 [OwnerBooking] Throwing exception: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e, stackTrace) {
      // Clear loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }
      
      print('📋 [OwnerBooking] ========================================');
      print('📋 [OwnerBooking] EXCEPTION CAUGHT');
      print('📋 [OwnerBooking] ========================================');
      print('📋 [OwnerBooking] ❌ Error type: ${e.runtimeType}');
      print('📋 [OwnerBooking] ❌ Error message: $e');
      print('📋 [OwnerBooking] ❌ Stack trace: $stackTrace');
      
      if (mounted) {
        print('📋 [OwnerBooking] Showing error message to user...');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
        print('📋 [OwnerBooking] Error message shown');
      } else {
        print('📋 [OwnerBooking] ⚠️ Context not mounted, cannot show error message');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
      print('📋 [OwnerBooking] ========================================');
      print('📋 [OwnerBooking] REJECT BOOKING COMPLETE');
      print('📋 [OwnerBooking] ========================================');
    }
  }

  /// Acknowledges a cancelled booking
  Future<void> _acknowledgeCancellation(Map<String, dynamic> booking) async {
    print('📋 [OwnerBooking] ACKNOWLEDGE CANCELLATION CLICKED');
    
    if (_isProcessing) {
      print('📋 [OwnerBooking] Already processing, ignoring click');
      return;
    }

    final bookingId = booking['booking_id'] ?? booking['id'];
    
    if (bookingId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Booking ID is missing'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Check if already acknowledged
    final isAcknowledged = booking['cancellation_acknowledged'] == 1 || 
                          booking['cancellation_acknowledged'] == '1' ||
                          booking['cancellation_acknowledged'] == true;
    
    if (isAcknowledged) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This cancellation has already been acknowledged'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Acknowledge Cancellation'),
        content: Text('Acknowledge the cancellation request from ${booking['student_name'] ?? 'this student'}? This will mark the cancellation as reviewed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.blue),
            child: const Text('Acknowledge'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isProcessing = true);

    // Show loading indicator
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text('Processing acknowledgement...'),
            ],
          ),
          duration: Duration(seconds: 30),
        ),
      );
    }

    try {
      final result = await _bookingService.acknowledgeCancellation(
        bookingId: int.parse(bookingId.toString()),
        ownerEmail: widget.ownerEmail,
      );

      // Clear loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }

      if (result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Cancellation acknowledged successfully'),
              backgroundColor: Colors.blue,
              duration: const Duration(seconds: 3),
            ),
          );
          _fetchBookings(); // Refresh the list
        }
      } else {
        throw Exception(result['message'] ?? 'Failed to acknowledge cancellation');
      }
    } catch (e) {
      // Clear loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  /// Rejects a cancellation request and reverts booking to approved
  Future<void> _rejectCancellationRequest(Map<String, dynamic> booking) async {
    print('📋 [OwnerBooking] REJECT CANCELLATION REQUEST CLICKED');
    
    if (_isProcessing) {
      print('📋 [OwnerBooking] Already processing, ignoring click');
      return;
    }

    final bookingId = booking['booking_id'] ?? booking['id'];
    
    if (bookingId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Booking ID is missing'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disapprove Cancellation Request?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to disapprove the cancellation request from ${booking['student_name'] ?? 'this student'}?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 18, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        'What happens:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildInfoItem('The booking will return to APPROVED status'),
                  _buildInfoItem('The student can proceed with their booking'),
                  _buildInfoItem('No cancellation will occur'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No, Keep Request'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Disapprove Request'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isProcessing = true);

    // Show loading indicator
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text('Disapproving cancellation request...'),
            ],
          ),
          duration: Duration(seconds: 30),
        ),
      );
    }

    try {
      final result = await _bookingService.rejectCancellationRequest(
        bookingId: int.parse(bookingId.toString()),
        ownerEmail: widget.ownerEmail,
      );

      // Clear loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }

      if (result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Cancellation request disapproved successfully'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
          _fetchBookings(); // Refresh the list
        }
      } else {
        throw Exception(result['error'] ?? 'Failed to disapprove cancellation request');
      }
    } catch (e) {
      // Clear loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Opens chat with the student who cancelled
  Future<void> _messageStudent(Map<String, dynamic> booking) async {
    try {
      final studentEmail = booking['student_email']?.toString();
      final studentName = booking['student_name']?.toString() ?? 'Student';
      final studentId = booking['student_id'];
      final dormId = booking['dorm_id'];
      final dormName = booking['dorm_name']?.toString() ?? booking['dorm']?.toString() ?? 'Dorm';

      if (studentEmail == null || studentEmail.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student email not available'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (studentId == null || dormId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open chat. Missing information.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      print('📨 [OwnerBooking] Opening chat with student: $studentName ($studentEmail) about $dormName');
      
      // Navigate to chat conversation screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatConversationScreen(
            currentUserEmail: widget.ownerEmail,
            currentUserRole: 'owner',
            otherUserId: int.parse(studentId.toString()),
            otherUserName: studentName,
            otherUserEmail: studentEmail,
            dormId: int.parse(dormId.toString()),
            dormName: dormName,
          ),
        ),
      );
    } catch (e) {
      print('❌ [OwnerBooking] Error opening chat: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening chat: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Filters bookings based on the selected tab
  List<Map<String, dynamic>> _filteredBookings() {
    return _bookings.where((booking) {
      // Normalize status: remove spaces and convert to lowercase for comparison
      final status = (booking['status'] ?? '').toString().toLowerCase().replaceAll(' ', '_');
      if (_selectedTab == 0) {
        return status == 'pending';
      } else if (_selectedTab == 1) {
        return status == 'approved';
      } else {
        // Cancelled tab shows both cancellation_requested and cancelled
        return status == 'cancelled' || status == 'cancellation_requested';
      }
    }).toList();
  }

  /// Handles tab change
  void _onTabChanged(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        title: const Text('Booking Requests'),
        backgroundColor: AppTheme.primary,
      ),
      body: Column(
        children: [
          // Tab Buttons
          _buildTabButtons(),
          
          // Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  /// Builds the tab buttons
  Widget _buildTabButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: BookingTabButton(
              label: 'Pending',
              isSelected: _selectedTab == 0,
              onTap: () => _onTabChanged(0),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: BookingTabButton(
              label: 'Approved',
              isSelected: _selectedTab == 1,
              onTap: () => _onTabChanged(1),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: BookingTabButton(
              label: 'Cancelled',
              isSelected: _selectedTab == 2,
              onTap: () => _onTabChanged(2),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the main content area
  Widget _buildContent() {
    if (_isLoading) {
      return const LoadingWidget();
    }

    if (_error != null) {
      return ErrorDisplayWidget(
        message: _error!,
        onRetry: _fetchBookings,
      );
    }

    final filteredBookings = _filteredBookings();

    if (filteredBookings.isEmpty) {
      IconData emptyIcon;
      String emptyTitle;
      String emptySubtitle;
      
      if (_selectedTab == 0) {
        emptyIcon = Icons.pending_actions_outlined;
        emptyTitle = 'No pending bookings';
        emptySubtitle = 'New booking requests will appear here';
      } else if (_selectedTab == 1) {
        emptyIcon = Icons.check_circle_outline;
        emptyTitle = 'No approved bookings';
        emptySubtitle = 'Approved bookings will appear here';
      } else {
        emptyIcon = Icons.cancel_outlined;
        emptyTitle = 'No cancelled bookings';
        emptySubtitle = 'Cancelled bookings will appear here';
      }
      
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              emptyIcon,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              emptyTitle,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              emptySubtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchBookings,
      color: AppTheme.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredBookings.length,
        itemBuilder: (context, index) {
          final booking = filteredBookings[index];
          // Normalize status: remove spaces and convert to lowercase for comparison
          final status = (booking['status'] ?? '').toString().toLowerCase().replaceAll(' ', '_');
          final isCancellationRequested = status == 'cancellation_requested';
          final isCancelled = status == 'cancelled';
          
          return BookingCard(
            booking: booking,
            onApprove: status == 'pending' ? () => _approveBooking(booking) : null,
            onReject: status == 'pending' ? () => _rejectBooking(booking) : null,
            onAcknowledge: isCancellationRequested
                ? () => _acknowledgeCancellation(booking) 
                : null,
            onRejectCancellation: isCancellationRequested
                ? () => _rejectCancellationRequest(booking)
                : null,
            onMessage: (isCancellationRequested || isCancelled) 
                ? () => _messageStudent(booking) 
                : null,
            isProcessing: _isProcessing,
          );
        },
      ),
    );
  }
}
