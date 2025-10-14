import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
    if (emailController.text.isEmpty ||
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

    final url = Uri.parse('https://bradedsale.helioho.st/Dormitory/register.php');
    final response = await http.post(
      url,
      body: {
        'role': selectedRole.toLowerCase(), // Ensure role is lowercase
        'email': emailController.text.trim(),
        'password': passwordController.text.trim(),
      },
    );

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration Successful!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      });
    } else if (response.statusCode == 409) {
      setState(() {
        errorMessage = 'Email already registered.';
      });
    } else {
      setState(() {
        errorMessage = 'Registration failed. Try again.';
      });
    }
  }

  // ----------- UI SECTION -----------
  @override
  Widget build(BuildContext context) {
    final orangeColor = Color(0xFFFF9800);

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
}