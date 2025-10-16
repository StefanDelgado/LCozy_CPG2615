import 'package:flutter/material.dart';
import '../../services/booking_service.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_display_widget.dart';
import '../../widgets/owner/bookings/booking_tab_button.dart';
import '../../widgets/owner/bookings/booking_card.dart';

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

  // Theme
  static const Color _orange = Color(0xFFFF9800);
  static const Color _background = Color(0xFFFDF6F0);

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
        title: const Text('Reject Booking'),
        content: Text('Are you sure you want to reject the booking request from ${booking['student_name'] ?? 'this student'}?'),
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
            child: const Text('Reject'),
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
              backgroundColor: Colors.orange,
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
        final errorMessage = result['message'] ?? 'Failed to reject booking';
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

  /// Returns filtered bookings based on selected tab
  List<Map<String, dynamic>> _getFilteredBookings() {
    return _bookings.where((booking) {
      final status = (booking['status'] ?? '').toString().toLowerCase();
      return _selectedTab == 0 
          ? status == 'pending'
          : status == 'approved';
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
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text('Booking Requests'),
        backgroundColor: _orange,
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

    final filteredBookings = _getFilteredBookings();

    if (filteredBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedTab == 0 
                  ? Icons.pending_actions_outlined
                  : Icons.check_circle_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _selectedTab == 0 
                  ? 'No pending bookings'
                  : 'No approved bookings',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedTab == 0
                  ? 'New booking requests will appear here'
                  : 'Approved bookings will appear here',
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
      color: _orange,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredBookings.length,
        itemBuilder: (context, index) {
          final booking = filteredBookings[index];
          
          return BookingCard(
            booking: booking,
            onApprove: () => _approveBooking(booking),
            onReject: () => _rejectBooking(booking),
            isProcessing: _isProcessing,
          );
        },
      ),
    );
  }
}
