import 'package:flutter/foundation.dart';
import '../services/booking_service.dart';

/// Provider for managing booking data state across the app.
/// 
/// Handles:
/// - Student bookings (dashboard data)
/// - Owner bookings (booking requests)
/// - Creating new bookings
/// - Updating booking status (approve/reject)
/// - Loading and error states
/// 
/// Usage:
/// ```dart
/// // In widget
/// final bookingProvider = context.watch<BookingProvider>();
/// 
/// // Fetch student bookings
/// await context.read<BookingProvider>().fetchStudentBookings(email);
/// 
/// // Access bookings
/// final bookings = bookingProvider.studentBookings;
/// ```
class BookingProvider with ChangeNotifier {
  final BookingService _bookingService = BookingService();

  // State
  List<Map<String, dynamic>> _studentBookings = [];
  List<Map<String, dynamic>> _ownerBookings = [];
  Map<String, dynamic>? _studentStats;
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  // Getters
  List<Map<String, dynamic>> get studentBookings => _studentBookings;
  List<Map<String, dynamic>> get ownerBookings => _ownerBookings;
  Map<String, dynamic>? get studentStats => _studentStats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;
  
  int get studentBookingsCount => _studentBookings.length;
  int get ownerBookingsCount => _ownerBookings.length;
  bool get hasStudentBookings => _studentBookings.isNotEmpty;
  bool get hasOwnerBookings => _ownerBookings.isNotEmpty;

  /// Fetch student bookings with dashboard statistics.
  /// 
  /// Parameters:
  /// - [studentEmail]: Email of the student
  /// 
  /// Updates [studentBookings] and [studentStats] with data from server.
  /// 
  /// Returns `true` if successful, `false` otherwise.
  Future<bool> fetchStudentBookings(String studentEmail) async {
    _setLoading(true);
    _error = null;

    try {
      final result = await _bookingService.getStudentBookings(studentEmail);

      if (result['success'] == true) {
        final data = result['data'];
        _studentBookings = List<Map<String, dynamic>>.from(
          data['bookings'] ?? []
        );
        _studentStats = data['stats'];
        _error = null;
        _setLoading(false);
        return true;
      } else {
        _error = result['error'] ?? 'Failed to load student bookings';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error loading student bookings: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  /// Fetch owner bookings (booking requests for owner's dorms).
  /// 
  /// Parameters:
  /// - [ownerEmail]: Email of the dorm owner
  /// 
  /// Updates [ownerBookings] list with booking requests.
  /// 
  /// Returns `true` if successful, `false` otherwise.
  Future<bool> fetchOwnerBookings(String ownerEmail) async {
    _setLoading(true);
    _error = null;

    try {
      final result = await _bookingService.getOwnerBookings(ownerEmail);

      if (result['success'] == true) {
        _ownerBookings = List<Map<String, dynamic>>.from(
          result['data'] ?? []
        );
        _error = null;
        _setLoading(false);
        return true;
      } else {
        _error = result['error'] ?? 'Failed to load owner bookings';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error loading owner bookings: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  /// Create a new booking.
  /// 
  /// Parameters:
  /// - [bookingData]: Map containing booking information:
  ///   - student_email: string
  ///   - room_id: int
  ///   - checkin_date: string (YYYY-MM-DD)
  ///   - checkout_date: string (YYYY-MM-DD)
  ///   - number_of_occupants: int
  ///   - special_requests: string (optional)
  /// 
  /// Automatically refreshes student bookings after successful creation.
  /// 
  /// Returns `true` if successful, `false` otherwise.
  Future<bool> createBooking(Map<String, dynamic> bookingData) async {
    _setLoading(true);
    _error = null;
    _successMessage = null;

    try {
      final result = await _bookingService.createBooking(bookingData);

      if (result['success'] == true) {
        _successMessage = result['message'] ?? 'Booking created successfully';
        
        // Refresh student bookings
        final studentEmail = bookingData['student_email'] as String;
        await fetchStudentBookings(studentEmail);
        
        _error = null;
        return true;
      } else {
        _error = result['error'] ?? 'Failed to create booking';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error creating booking: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  /// Update booking status (approve or reject).
  /// 
  /// Parameters:
  /// - [bookingId]: ID of the booking to update
  /// - [action]: 'approve' or 'reject'
  /// - [ownerEmail]: Email of the owner (for refreshing list)
  /// 
  /// Automatically refreshes owner bookings after successful update.
  /// 
  /// Returns `true` if successful, `false` otherwise.
  Future<bool> updateBookingStatus(
    String bookingId,
    String action,
    String ownerEmail,
  ) async {
    _setLoading(true);
    _error = null;
    _successMessage = null;

    try {
      final result = await _bookingService.updateBookingStatus(
        bookingId: bookingId,
        action: action,
        ownerEmail: ownerEmail,
      );

      if (result['success'] == true) {
        _successMessage = result['message'] ?? 
          'Booking ${action == 'approve' ? 'approved' : 'rejected'} successfully';
        
        // Refresh owner bookings
        await fetchOwnerBookings(ownerEmail);
        
        _error = null;
        return true;
      } else {
        _error = result['error'] ?? 'Failed to update booking';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error updating booking: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  /// Clear any error messages.
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear success message.
  void clearSuccessMessage() {
    _successMessage = null;
    notifyListeners();
  }

  /// Get bookings filtered by status.
  /// 
  /// Parameters:
  /// - [status]: 'pending', 'approved', 'rejected', 'completed', or 'cancelled'
  /// - [isStudent]: If true, filters student bookings; otherwise owner bookings
  /// 
  /// Returns filtered list of bookings.
  List<Map<String, dynamic>> getBookingsByStatus(String status, {bool isStudent = true}) {
    final bookings = isStudent ? _studentBookings : _ownerBookings;
    return bookings.where((booking) {
      final bookingStatus = (booking['status'] ?? '').toString().toLowerCase();
      return bookingStatus == status.toLowerCase();
    }).toList();
  }

  /// Get pending bookings count.
  int get pendingBookingsCount {
    return _ownerBookings.where((booking) {
      final status = (booking['status'] ?? '').toString().toLowerCase();
      return status == 'pending';
    }).length;
  }

  /// Get approved bookings count.
  int get approvedBookingsCount {
    return _ownerBookings.where((booking) {
      final status = (booking['status'] ?? '').toString().toLowerCase();
      return status == 'approved';
    }).length;
  }

  /// Get rejected bookings count.
  int get rejectedBookingsCount {
    return _ownerBookings.where((booking) {
      final status = (booking['status'] ?? '').toString().toLowerCase();
      return status == 'rejected';
    }).length;
  }

  /// Check if a student has any active bookings.
  bool get hasActiveBookings {
    return _studentBookings.any((booking) {
      final status = (booking['status'] ?? '').toString().toLowerCase();
      return status == 'approved' || status == 'pending';
    });
  }

  /// Get student statistics value by key.
  dynamic getStatValue(String key) {
    return _studentStats?[key];
  }

  /// Set loading state and notify listeners.
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Refresh all bookings.
  /// 
  /// Parameters:
  /// - [studentEmail]: Email of student (optional)
  /// - [ownerEmail]: Email of owner (optional)
  /// 
  /// Fetches student bookings if studentEmail provided,
  /// owner bookings if ownerEmail provided, or both if both provided.
  Future<void> refreshAll({
    String? studentEmail,
    String? ownerEmail,
  }) async {
    if (studentEmail != null) {
      await fetchStudentBookings(studentEmail);
    }
    if (ownerEmail != null) {
      await fetchOwnerBookings(ownerEmail);
    }
  }

  /// Clear all booking data.
  void clearAll() {
    _studentBookings = [];
    _ownerBookings = [];
    _studentStats = null;
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Search bookings by dorm name or room number.
  /// 
  /// Parameters:
  /// - [query]: Search string
  /// - [isStudent]: If true, searches student bookings; otherwise owner bookings
  /// 
  /// Returns filtered list of bookings.
  List<Map<String, dynamic>> searchBookings(String query, {bool isStudent = true}) {
    if (query.isEmpty) {
      return isStudent ? _studentBookings : _ownerBookings;
    }

    final bookings = isStudent ? _studentBookings : _ownerBookings;
    final lowerQuery = query.toLowerCase();

    return bookings.where((booking) {
      final dormName = (booking['dorm_name'] ?? '').toString().toLowerCase();
      final roomNumber = (booking['room_number'] ?? '').toString().toLowerCase();
      final studentName = (booking['student_name'] ?? '').toString().toLowerCase();

      return dormName.contains(lowerQuery) ||
          roomNumber.contains(lowerQuery) ||
          studentName.contains(lowerQuery);
    }).toList();
  }
}
