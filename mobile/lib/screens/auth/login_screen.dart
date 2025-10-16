import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth/auth_header.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/auth_button.dart';
import '../owner/owner_dashboard_screen.dart';
import '../student/student_home_screen.dart';

/// Login screen for user authentication
/// Supports both student and owner roles
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    print('📱 [LoginScreen] Login button pressed');
    final authProvider = context.read<AuthProvider>();
    
    // Clear previous error
    authProvider.clearError();

    // Basic validation
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both email and password.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print('📱 [LoginScreen] Calling authProvider.login()');
    // Login via provider
    final success = await authProvider.login(
      _emailController.text,
      _passwordController.text,
      'auto', // Role will be determined by backend
    );

    if (!mounted) return;

    print('📱 [LoginScreen] Login result: $success');
    print('📱 [LoginScreen] Auth state - isAuthenticated: ${authProvider.isAuthenticated}');
    print('📱 [LoginScreen] Auth state - userEmail: ${authProvider.userEmail}');
    print('📱 [LoginScreen] Auth state - userRole: ${authProvider.userRole}');

    if (success && authProvider.isAuthenticated) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login Successful!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate based on role
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      print('📱 [LoginScreen] Navigating to dashboard...');
      if (authProvider.isOwner) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OwnerDashboardScreen(
              ownerEmail: authProvider.userEmail!,
              ownerRole: authProvider.userRole!,
            ),
          ),
        );
      } else if (authProvider.isStudent) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => StudentHomeScreen(
              userName: authProvider.userDisplayName ?? 'User',
              userEmail: authProvider.userEmail!,
            ),
          ),
        );
      }
    } else {
      // Login failed - show error
      print('📱 [LoginScreen] Login failed: ${authProvider.error}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Login failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToRegister() {
    Navigator.pushNamed(context, '/register');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Header
                const AuthHeader(
                  title: 'CozyDorm',
                  subtitle: 'Find your perfect home away from\nhome',
                ),

                // Login Form
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to continue to your account',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Email Field
                      AuthTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        hintText: 'Enter your email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      AuthTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hintText: 'Enter your password',
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 16),

                      // Error Message (from provider)
                      if (authProvider.error != null && authProvider.error!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            authProvider.error!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: AuthButton(
                              text: 'Sign In',
                              onPressed: authProvider.isLoading ? null : _handleLogin,
                              isLoading: authProvider.isLoading,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AuthButton(
                              text: 'Register',
                              onPressed: _navigateToRegister,
                              isPrimary: false,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
