import 'package:flutter/material.dart';

// ==================== ProfileScreen Widget ====================
class ProfileScreen extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String userRole;
  final String avatarUrl;

  const ProfileScreen({
    super.key,
    this.userName = "John Doe",
    this.userEmail = "john.doe@email.com",
    this.userRole = "Student",
    this.avatarUrl = "",
  });

  @override
  Widget build(BuildContext context) {
    final orange = Color(0xFFFF9800);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      // ----------- APPBAR SECTION -----------
      appBar: AppBar(
        backgroundColor: orange,
        elevation: 0,
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ----------- PROFILE HEADER SECTION -----------
            Container(
              color: orange,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.white,
                    backgroundImage: avatarUrl.isNotEmpty
                        ? NetworkImage(avatarUrl)
                        : null,
                    child: avatarUrl.isEmpty
                        ? Icon(Icons.person, size: 48, color: orange)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userEmail, // Bold white email
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userEmail, // Faded email
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(userRole),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(color: orange, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // ----------- SETTINGS OPTIONS SECTION -----------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                    child: ListTile(
                      leading: Icon(Icons.edit, color: orange),
                      title: const Text('Edit Profile'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                      onTap: () {
                        Navigator.pushNamed(context, '/editProfile');
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                    child: ListTile(
                      leading: Icon(Icons.lock_outline, color: orange),
                      title: const Text('Change Password'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                      onTap: () {
                        Navigator.pushNamed(context, '/changePassword');
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                    child: ListTile(
                      leading: Icon(Icons.notifications_none, color: orange),
                      title: const Text('Notifications'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                      onTap: () {
                        Navigator.pushNamed(context, '/notifications');
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                    child: ListTile(
                      leading: Icon(Icons.privacy_tip_outlined, color: orange),
                      title: const Text('Privacy Policy'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                      onTap: () {
                        Navigator.pushNamed(context, '/privacy');
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                    child: ListTile(
                      leading: Icon(Icons.help_outline, color: orange),
                      title: const Text('Help & Support'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                      onTap: () {
                        Navigator.pushNamed(context, '/help');
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  // ----------- LOGOUT SECTION -----------
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                    child: ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text('Logout', style: TextStyle(color: Colors.red)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.red),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Logout'),
                            content: const Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              TextButton(
                                child: const Text('Logout', style: TextStyle(color: Colors.red)),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.pushReplacementNamed(context, '/login');
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // ----------- FOOTER SECTION -----------
            Text(
              'CozyDorm © 2025',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}