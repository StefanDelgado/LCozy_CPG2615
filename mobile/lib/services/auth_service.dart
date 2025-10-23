import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';
import '../utils/api_constants.dart';

/// Authentication service for login and registration
class AuthService {
  /// Login with email and password
  /// Returns a map with 'success', 'role', 'name', 'email', and 'error' keys
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    // Create HTTP client that accepts self-signed certificates
    final client = HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);
    final http = IOClient(client);

    try {
      print('🔑 [AuthService] Login request for: $email');
      
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/modules/mobile-api/auth/login-api.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email.trim(),
          'password': password.trim(),
        }),
      );

      print('🔑 [AuthService] Login Status code: ${response.statusCode}');
      print('🔑 [AuthService] Login Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          final role = (data['role'] ?? '').toString().toLowerCase();
          final name = (data['name'] ?? '').toString();
          final userEmail = (data['email'] ?? '').toString();

          print('🔑 [AuthService] Decoded - role: $role, name: $name, email: $userEmail');

          if (role.isEmpty) {
            print('🔑 [AuthService] ❌ Role is empty');
            return {
              'success': false,
              'error': 'Unknown user role.',
            };
          }

          print('🔑 [AuthService] ✅ Login successful');
          return {
            'success': true,
            'role': role,
            'name': name,
            'email': userEmail,
          };
        } catch (e) {
          print('🔑 [AuthService] ❌ JSON decode error: $e');
          return {
            'success': false,
            'error': 'Invalid server response. Please try again later.',
          };
        }
      } else {
        // Try to show server error message if available
        String errorMsg = 'Login failed. Check your credentials.';
        try {
          final data = json.decode(response.body);
          if (data['error'] != null) {
            errorMsg = data['error'];
          }
        } catch (_) {}

        print('🔑 [AuthService] ❌ Login failed: $errorMsg');
        return {
          'success': false,
          'error': errorMsg,
        };
      }
    } catch (e) {
      print('🔑 [AuthService] ❌ Login exception: $e');
      return {
        'success': false,
        'error': 'Network error. Please try again.',
      };
    } finally {
      http.close();
    }
  }

  /// Register a new user
  /// Returns a map with 'success' and 'error' keys
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    // Create HTTP client that accepts self-signed certificates
    final client = HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);
    final http = IOClient(client);

    try {
      final response = await http.post(
        Uri.parse(
            '${ApiConstants.baseUrl}/modules/mobile-api/auth/register_api.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name.trim(),
          'email': email.trim(),
          'password': password,
          'role': role.toLowerCase(),
        }),
      );

      // Debug logging (remove in production)
      // print('Register Status code: ${response.statusCode}');
      // print('Register Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          if (data['success'] == true) {
            return {
              'success': true,
              'verified': data['verified'],
              'message': data['message'],
            };
          } else {
            return {
              'success': false,
              'error': data['error'] ?? 'Registration failed',
            };
          }
        } catch (e) {
          return {
            'success': false,
            'error': 'Invalid server response.',
          };
        }
      } else if (response.statusCode == 409) {
        return {
          'success': false,
          'error': 'Email already registered.',
        };
      } else {
        return {
          'success': false,
          'error': 'Server error. Please try again.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error. Please try again.',
      };
    } finally {
      http.close();
    }
  }
}
