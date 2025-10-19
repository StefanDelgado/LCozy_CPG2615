import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Login.dart';

// ==================== RegisterScreen Widget ====================
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

// ==================== RegisterScreen State ====================
class _RegisterScreenState extends State<RegisterScreen> {
  String selectedRole = 'Student';
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  // ----------- REGISTER LOGIC SECTION -----------
  Future<void> register() async {
    setState(() {
      errorMessage = '';
    });

    // Local validation
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      setState(() {
        errorMessage = 'Please fill in all fields.';
      });
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        errorMessage = 'Passwords do not match.';
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://cozydorms.life/modules/mobile-api/auth/register_api.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'password': passwordController.text,
          'role': selectedRole.toLowerCase(),
        }),
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration Successful!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          
          // Navigate to login after delay
          await Future.delayed(Duration(seconds: 2));
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          }
        } else {
          throw Exception(data['error'] ?? 'Registration failed');
        }
      } else if (response.statusCode == 409) {
        setState(() {
          errorMessage = 'Email already registered.';
        });
      } else {
        throw Exception('Server error');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Registration failed: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // ----------- UI SECTION -----------
  @override
  Widget build(BuildContext context) {
    final orangeColor = AppTheme.primary;

    return Scaffold(
      backgroundColor: orangeColor,
      // ----------- APPBAR SECTION -----------
      appBar: AppBar(
        backgroundColor: orangeColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 16),
          // ----------- HEADER SECTION -----------
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: orangeColor, size: 40),
          ),
          SizedBox(height: 12),
          Text(
            'Register',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Create your CozyDorm account',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 18),
          // ----------- FORM SECTION -----------
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: BoxDecoration(
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
                    // ----------- ROLE DROPDOWN SECTION -----------
                    Text('Role', style: TextStyle(fontSize: 15)),
                    DropdownButton<String>(
                      value: selectedRole,
                      isExpanded: true,
                      items: ['Student', 'Owner']
                          .map((role) => DropdownMenuItem(
                                value: role,
                                child: Text(role),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value!;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    // ----------- NAME INPUT SECTION -----------
                    Text('Full Name', style: TextStyle(fontSize: 15)),
                    SizedBox(height: 4),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Enter your full name',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                    ),
                    SizedBox(height: 10),
                    // ----------- EMAIL INPUT SECTION -----------
                    Text('Email Address', style: TextStyle(fontSize: 15)),
                    SizedBox(height: 4),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                    ),
                    SizedBox(height: 10),
                    // ----------- PASSWORD INPUT SECTION -----------
                    Text('Password', style: TextStyle(fontSize: 15)),
                    SizedBox(height: 4),
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    // ----------- CONFIRM PASSWORD INPUT SECTION -----------
                    Text('Confirm Password', style: TextStyle(fontSize: 15)),
                    SizedBox(height: 4),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: obscureConfirmPassword,
                      decoration: InputDecoration(
                        hintText: 'Confirm your password',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              obscureConfirmPassword = !obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    // ----------- ERROR MESSAGE SECTION -----------
                    if (errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          errorMessage,
                          style: TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),
                    SizedBox(height: 10),
                    // ----------- SUBMIT BUTTON SECTION -----------
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: orangeColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: isLoading ? null : register,
                        child: isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
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
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}