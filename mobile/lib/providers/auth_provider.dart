import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

/// Provider for managing authentication state across the app.
/// 
/// Handles:
/// - User login/logout
/// - Registration
/// - Authentication status
/// - User role and email persistence
/// 
/// Usage:
/// ```dart
/// // In widget
/// final authProvider = context.watch<AuthProvider>();
/// if (authProvider.isAuthenticated) {
///   // Show authenticated UI
/// }
/// 
/// // To login
/// await context.read<AuthProvider>().login(email, password, role);
/// ```
class AuthProvider with ChangeNotifier {
  // State
  bool _isAuthenticated = false;
  String? _userEmail;
  String? _userRole; // 'student', 'owner', or 'admin'
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _userEmail;
  String? get userRole => _userRole;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  bool get isStudent => _userRole == 'student';
  bool get isOwner => _userRole == 'owner';
  bool get isAdmin => _userRole == 'admin';

  /// Login with email, password, and role.
  /// 
  /// Parameters:
  /// - [email]: User's email address
  /// - [password]: User's password
  /// - [role]: User role ('student', 'owner', or 'admin')
  /// 
  /// Returns `true` if login successful, `false` otherwise.
  /// 
  /// Updates [error] if login fails.
  Future<bool> login(String email, String password, String role) async {
    _setLoading(true);
    _error = null;

    try {
      final result = await AuthService.login(
        email: email,
        password: password,
      );

      if (result['success'] == true) {
        _isAuthenticated = true;
        _userEmail = email;
        _userRole = result['role'] ?? role; // Use role from server
        _error = null;
        _setLoading(false);
        return true;
      } else {
        _error = result['error'] ?? 'Login failed';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Login error: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  /// Register a new user.
  /// 
  /// Parameters:
  /// - [userData]: Map containing registration data:
  ///   - email: string
  ///   - password: string
  ///   - name: string
  ///   - role: string ('student' or 'owner')
  ///   - contact_number: string (optional)
  /// 
  /// Returns `true` if registration successful, `false` otherwise.
  /// 
  /// Updates [error] if registration fails.
  Future<bool> register(Map<String, dynamic> userData) async {
    _setLoading(true);
    _error = null;

    try {
      final result = await AuthService.register(
        name: userData['name'] as String,
        email: userData['email'] as String,
        password: userData['password'] as String,
        role: userData['role'] as String,
      );

      if (result['success'] == true) {
        // Auto-login after successful registration
        final email = userData['email'] as String;
        final role = userData['role'] as String;
        
        _isAuthenticated = true;
        _userEmail = email;
        _userRole = role;
        _error = null;
        _setLoading(false);
        return true;
      } else {
        _error = result['error'] ?? 'Registration failed';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Registration error: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  /// Logout the current user.
  /// 
  /// Clears all authentication state and notifies listeners.
  void logout() {
    _isAuthenticated = false;
    _userEmail = null;
    _userRole = null;
    _error = null;
    notifyListeners();
  }

  /// Check if user is authenticated (for app initialization).
  /// 
  /// In a production app, this would check stored credentials/tokens.
  /// Currently returns false as we don't have persistent storage.
  Future<void> checkAuthStatus() async {
    _setLoading(true);
    
    // TODO: In production, check SharedPreferences or SecureStorage for saved auth
    // For now, assume not authenticated on app start
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate check
    
    _isAuthenticated = false;
    _setLoading(false);
  }

  /// Clear any error messages.
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Set loading state and notify listeners.
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Update user email (for profile updates).
  void updateUserEmail(String email) {
    _userEmail = email;
    notifyListeners();
  }

  /// Get user display name from email.
  /// 
  /// Extracts name from email (part before @).
  String? get userDisplayName {
    if (_userEmail == null) return null;
    return _userEmail!.split('@')[0];
  }

  /// Check if specific role matches current user.
  bool hasRole(String role) {
    return _userRole == role;
  }

  /// Get role-specific home route.
  String get homeRoute {
    switch (_userRole) {
      case 'student':
        return '/student/home';
      case 'owner':
        return '/owner/dashboard';
      case 'admin':
        return '/admin/dashboard';
      default:
        return '/login';
    }
  }
}
