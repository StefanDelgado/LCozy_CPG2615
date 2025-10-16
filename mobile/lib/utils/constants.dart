/// API endpoints and configuration
class ApiConstants {
  static const String baseUrl = 'http://cozydorms.life';
  
  // Auth endpoints
  static const String loginEndpoint = '$baseUrl/login_api.php';
  static const String registerEndpoint = '$baseUrl/register_api.php';
  
  // Student endpoints
  static const String studentDashboardEndpoint = '$baseUrl/modules/mobile-api/student_dashboard_api.php';
  static const String studentPaymentsEndpoint = '$baseUrl/modules/mobile-api/student_payments_api.php';
  static const String browseDormsEndpoint = '$baseUrl/modules/mobile-api/browse_dorms_api.php';
  static const String dormDetailsEndpoint = '$baseUrl/modules/mobile-api/dorm_details_api.php';
  static const String createBookingEndpoint = '$baseUrl/modules/mobile-api/create_booking_api.php';
  static const String uploadReceiptEndpoint = '$baseUrl/modules/mobile-api/upload_receipt_api.php';
  
  // Owner endpoints
  // Add owner endpoints here when needed
  
  // Upload paths
  static const String uploadsPath = '$baseUrl/uploads';
  static const String receiptsPath = '$uploadsPath/receipts';
  static const String dormImagesPath = '$uploadsPath';
}

/// UI Constants
class UIConstants {
  // Colors
  static const primaryColor = 0xFF4A3AFF;
  static const orangeColor = 0xFFFF9800;
  
  // Padding
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  // Border radius
  static const double defaultRadius = 12.0;
  static const double smallRadius = 8.0;
  static const double largeRadius = 16.0;
  
  // Font sizes
  static const double titleFontSize = 24.0;
  static const double headingFontSize = 18.0;
  static const double bodyFontSize = 14.0;
  static const double captionFontSize = 12.0;
}

/// App text constants
class AppTexts {
  static const String appName = 'CozyDorm';
  
  // Common
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String retry = 'Retry';
  static const String submit = 'Submit';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  
  // Auth
  static const String login = 'Login';
  static const String register = 'Register';
  static const String logout = 'Logout';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String forgotPassword = 'Forgot Password?';
  
  // Validation messages
  static const String emailRequired = 'Email is required';
  static const String emailInvalid = 'Enter a valid email';
  static const String passwordRequired = 'Password is required';
  static const String passwordTooShort = 'Password must be at least 6 characters';
  static const String passwordsNotMatch = 'Passwords do not match';
}

/// Payment status enum
enum PaymentStatus {
  pending,
  submitted,
  paid,
  rejected,
  expired,
}

/// Booking status enum
enum BookingStatus {
  pending,
  approved,
  rejected,
  cancelled,
  completed,
}
