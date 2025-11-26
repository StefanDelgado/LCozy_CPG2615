import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/auth_button.dart';
import '../../widgets/auth/role_selector.dart';
import 'login_screen.dart';

/// Registration screen for new users
/// Supports both student and owner roles
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedRole = 'Student';
  bool _isLoading = false;
  String _errorMessage = '';
  String _emailError = '';
  String _passwordError = '';
  bool _termsAccepted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Validates email format in real-time
  void _validateEmail(String email) {
    setState(() {
      if (email.isEmpty) {
        _emailError = '';
      } else if (!email.contains('@')) {
        _emailError = 'Email must contain @';
      } else if (!email.contains('.')) {
        _emailError = 'Email must contain a domain (e.g., .com)';
      } else {
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(email)) {
          _emailError = 'Please enter a valid email format';
        } else {
          _emailError = '';
        }
      }
    });
  }

  /// Validates password match in real-time
  void _validatePasswordMatch(String confirmPassword) {
    setState(() {
      if (confirmPassword.isEmpty) {
        _passwordError = '';
      } else if (_passwordController.text != confirmPassword) {
        _passwordError = 'Passwords do not match';
      } else {
        _passwordError = '';
      }
    });
  }

  /// Validates password complexity
  String? _validatePasswordComplexity(String password) {
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    
    // Check for uppercase letter
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least 1 uppercase letter';
    }
    
    // Check for lowercase letter
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least 1 lowercase letter';
    }
    
    // Check for number
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least 1 number';
    }
    
    // Check for special character
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least 1 special character';
    }
    
    return null; // Password is valid
  }

  /// Builds a requirement item widget
  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 14,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms and Conditions'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'LCozy Dormitory Management System',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                '1. Acceptance of Terms',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                'By registering and using the LCozy Dormitory Management System, you agree to be bound by these Terms and Conditions.',
              ),
              const SizedBox(height: 12),
              const Text(
                '2. User Responsibilities',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              if (_selectedRole == 'Student') ...[
                const Text('For Students:'),
                const Text('• Provide accurate and truthful information'),
                const Text('• Pay rent and fees on time'),
                const Text('• Respect dorm rules and regulations'),
                const Text('• Report issues promptly'),
                const Text('• Maintain cleanliness in shared spaces'),
              ] else ...[
                const Text('For Dorm Owners:'),
                const Text('• Provide accurate facility information'),
                const Text('• Maintain safe living conditions'),
                const Text('• Address tenant concerns promptly'),
                const Text('• Comply with local regulations'),
                const Text('• Process payments fairly'),
              ],
              const SizedBox(height: 12),
              const Text(
                '3. Privacy and Data Protection',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                'We collect and protect personal information necessary for dormitory management. Your data will not be shared without consent.',
              ),
              const SizedBox(height: 12),
              const Text(
                '4. Payment Terms',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                'All payments through the system. Late payments may incur penalties.',
              ),
              const SizedBox(height: 12),
              const Text(
                '5. Cancellation Policy',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                'Students may cancel bookings before payment without penalty. After payment, cancellations require owner approval.',
              ),
              const SizedBox(height: 12),
              const Text(
                '6. Liability',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                'LCozy acts as a platform. We are not responsible for disputes, property damage, or personal injuries.',
              ),
              const SizedBox(height: 12),
              const Text(
                '7. Termination',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                'We reserve the right to terminate accounts that violate terms or engage in fraudulent activities.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRegister() async {
    // Clear previous error
    setState(() {
      _errorMessage = '';
    });

    // Validation
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _confirmPasswordController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields.';
      });
      return;
    }

    // Check terms acceptance
    if (!_termsAccepted) {
      setState(() {
        _errorMessage = 'Please accept the Terms and Conditions to continue.';
      });
      return;
    }

    // Email validation - must contain @ and .
    final email = _emailController.text.trim();
    if (!email.contains('@') || !email.contains('.')) {
      setState(() {
        _errorMessage = 'Please enter a valid email address (must contain @ and .)';
      });
      return;
    }

    // More strict email validation using regex
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      setState(() {
        _errorMessage = 'Please enter a valid email address';
      });
      return;
    }

    // Check if passwords match
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match.';
      });
      return;
    }

    // Validate password complexity
    final passwordComplexityError = _validatePasswordComplexity(_passwordController.text);
    if (passwordComplexityError != null) {
      setState(() {
        _errorMessage = passwordComplexityError;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Call auth service
    final result = await AuthService.register(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      role: _selectedRole,
    );

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (result['success'] == true) {
      String notify = result['message'] ?? '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(notify),
          backgroundColor: result['verified'] == 1
              ? Colors.green
              : (result['verified'] == 0 ? Colors.orange : Colors.red),
          duration: Duration(seconds: 3),
        ),
      );
      if (result['verified'] == 1) {
        // Navigate to login after short delay
        await Future.delayed(Duration(seconds: 2));
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } else {
      setState(() {
        _errorMessage = result['error'] ?? 'Registration failed. Please try again.';
      });
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orangeColor = AppTheme.primary;

    return Scaffold(
      backgroundColor: orangeColor,
      appBar: AppBar(
        backgroundColor: orangeColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _navigateToLogin,
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // Header
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: orangeColor, size: 40),
          ),
          const SizedBox(height: 12),
          const Text(
            'Register',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Create your CozyDorm account',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 18),

          // Form
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Role Selector
                    RoleSelector(
                      selectedRole: _selectedRole,
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Name Field
                    AuthTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hintText: 'Enter your full name',
                      prefixIcon: Icons.person_outline,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),

                    // Email Field
                    AuthTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      hintText: 'Enter your email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onChanged: _validateEmail,
                    ),
                    if (_emailError.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, left: 12),
                        child: Text(
                          _emailError,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Password Field
                    AuthTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      textInputAction: TextInputAction.next,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 12, right: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Password Requirements:',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          _buildRequirement('At least 8 characters'),
                          _buildRequirement('At least 1 uppercase letter (A-Z)'),
                          _buildRequirement('At least 1 lowercase letter (a-z)'),
                          _buildRequirement('At least 1 number (0-9)'),
                          _buildRequirement('At least 1 special character (!@#\$%^&*...)'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password Field
                    AuthTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      hintText: 'Confirm your password',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      onChanged: _validatePasswordMatch,
                    ),
                    if (_passwordError.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, left: 12),
                        child: Text(
                          _passwordError,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Terms and Conditions Checkbox
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _termsAccepted ? AppTheme.primary : Colors.grey[300]!,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _termsAccepted,
                            activeColor: AppTheme.primary,
                            onChanged: (value) {
                              setState(() {
                                _termsAccepted = value ?? false;
                              });
                            },
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _termsAccepted = !_termsAccepted;
                                });
                              },
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[800],
                                  ),
                                  children: [
                                    const TextSpan(text: 'I agree to the '),
                                    WidgetSpan(
                                      child: GestureDetector(
                                        onTap: _showTermsDialog,
                                        child: Text(
                                          'Terms and Conditions',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: AppTheme.primary,
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Error Message
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),

                    // Register Button
                    AuthButton(
                      text: 'Create Account',
                      onPressed: _handleRegister,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
