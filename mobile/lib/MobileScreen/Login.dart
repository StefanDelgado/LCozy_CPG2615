import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home.dart';
import 'ownerdashboard.dart';

// ==================== LoginScreen Widget ====================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// ==================== LoginScreen State ====================
class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';
  bool obscurePassword = true;

  // ========== LOGIN LOGIC SECTION ==========
  Future<void> login() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Basic email format validation
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        isLoading = false;
        errorMessage = 'Please enter both email and password.';
      });
      return;
    }
    if (!emailRegex.hasMatch(email)) {
      setState(() {
        isLoading = false;
        errorMessage = 'Please enter a valid email address.';
      });
      return;
    }

    print('Email: "$email"');
    print('Password: "$password"');

    final url = Uri.parse('https://cozydorms.life/modules/mobile-api/login-api.php');
    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          // Optionally include an app identifier:
          'X-App-Client': 'cozydorm-mobile',
        },
        body: {
          'email': email,
          'password': password,
          'ajax': '1', // hint to server to return JSON
        },
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          print('Login response: $data');
          final role = (data['role'] ?? '').toString().toLowerCase();
          final name = (data['name'] ?? '').toString();
          final email = (data['email'] ?? '').toString();

          // ========== NAVIGATION SECTION ==========
          if (role == 'owner') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Login Successful!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            Future.delayed(Duration(seconds: 2), () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => OwnerDashboardScreen(
                    ownerEmail: email,
                    ownerRole: role,
                  ),
                ),
              );
            });
          } else if (role == 'student') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Login Successful!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            Future.delayed(Duration(seconds: 2), () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => HomeScreen(
                    userName: name,
                    userEmail: email,
                    userRole: role,
                  ),
                ),
              );
            });
          } else {
            setState(() {
              errorMessage = 'Unknown user role.';
            });
          }
        } catch (e) {
          setState(() {
            errorMessage = 'Invalid server response. Please try again later.';
          });
          print('JSON decode error: $e');
        }
      } else {
        // Try to show server error message if available
        String msg = 'Login failed. Check your credentials.';
        try {
          final data = json.decode(response.body);
          if (data['error'] != null) msg = data['error'];
        } catch (_) {}
        setState(() {
          errorMessage = msg;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Network error. Please try again.';
      });
      print('Login error: $e');
    }
  }

  // ========== UI SECTION ==========
  @override
  Widget build(BuildContext context) {
    final orangeColor = Color(0xFFFF9800);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ----------- Header Section -----------
            Container(
              color: orangeColor,
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.home, color: orangeColor, size: 48),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'CozyDorm',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Find your perfect home away from\nhome',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // ----------- Login Form Section -----------
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Sign in to continue to your account',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 32),
                  Text('Email Address', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text('Password', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    enableSuggestions: false,
                    autocorrect: false,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      prefixIcon: Icon(Icons.lock_outline),
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  if (errorMessage.isNotEmpty)
                    Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: orangeColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: isLoading ? null : login,
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
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: orangeColor, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: Text(
                            'Register',
                            style: TextStyle(
                              fontSize: 18,
                              color: orangeColor,
                            ),
                          ),
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
  }
}