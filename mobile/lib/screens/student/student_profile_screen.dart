import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';

import '../../widgets/owner/settings/settings_list_tile.dart';

/// Screen for student profile and settings management
/// 
/// Features:
/// - Profile display (name, email, student role)
/// - Settings options (Edit Profile, Change Password, Notifications, etc.)
/// - Privacy Policy and Help & Support
/// - Logout functionality
class StudentProfileScreen extends StatelessWidget {
  final String studentName;
  final String studentEmail;
  final String avatarUrl;

  static const Color _orange = AppTheme.primary;

  const StudentProfileScreen({
    super.key,
    required this.studentName,
    required this.studentEmail,
    this.avatarUrl = '',
  });

  /// Handles edit profile action
  void _onEditProfile(BuildContext context) {
    // TODO: Navigate to edit profile screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit Profile - Coming Soon')),
    );
  }

  /// Handles change password action
  void _onChangePassword(BuildContext context) {
    // TODO: Navigate to change password screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Change Password - Coming Soon')),
    );
  }

  /// Handles notifications settings action
  void _onNotifications(BuildContext context) {
    // TODO: Navigate to notifications settings screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifications Settings - Coming Soon')),
    );
  }

  /// Handles my bookings action
  void _onMyBookings(BuildContext context) {
    Navigator.pushNamed(context, '/student_reservations');
  }

  /// Handles payment history action
  void _onPaymentHistory(BuildContext context) {
    // TODO: Navigate to payment history screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment History - Coming Soon')),
    );
  }

  /// Handles privacy policy action
  void _onPrivacyPolicy(BuildContext context) {
    // TODO: Navigate to privacy policy screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy Policy - Coming Soon')),
    );
  }

  /// Handles help & support action
  void _onHelpSupport(BuildContext context) {
    // TODO: Navigate to help & support screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help & Support - Coming Soon')),
    );
  }

  /// Handles logout action
  void _onLogout(BuildContext context) {
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
              Navigator.of(context).pop(); // Close dialog
              // Clear entire navigation stack and go to login
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (route) => false, // Remove all previous routes
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: _orange,
        elevation: 0,
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(),
            
            const SizedBox(height: 24),
            
            // Settings Options
            _buildSettingsOptions(context),
            
            const SizedBox(height: 24),
            
            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  /// Builds the profile header section
  Widget _buildProfileHeader() {
    return Container(
      color: _orange,
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
                ? const Icon(Icons.person, size: 48, color: _orange)
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            studentName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            studentEmail,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          const Chip(
            label: Text('Student'),
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: _orange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the settings options section
  Widget _buildSettingsOptions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Account Section
          _buildSectionTitle('Account'),
          const SizedBox(height: 8),
          SettingsListTile(
            icon: Icons.edit,
            iconColor: _orange,
            title: 'Edit Profile',
            onTap: () => _onEditProfile(context),
          ),
          const SizedBox(height: 8),
          SettingsListTile(
            icon: Icons.lock_outline,
            iconColor: _orange,
            title: 'Change Password',
            onTap: () => _onChangePassword(context),
          ),
          
          const SizedBox(height: 24),
          
          // Student Features Section
          _buildSectionTitle('Student Features'),
          const SizedBox(height: 8),
          SettingsListTile(
            icon: Icons.bookmark_border,
            iconColor: _orange,
            title: 'My Bookings',
            onTap: () => _onMyBookings(context),
          ),
          const SizedBox(height: 8),
          SettingsListTile(
            icon: Icons.payment,
            iconColor: _orange,
            title: 'Payment History',
            onTap: () => _onPaymentHistory(context),
          ),
          
          const SizedBox(height: 24),
          
          // Preferences Section
          _buildSectionTitle('Preferences'),
          const SizedBox(height: 8),
          SettingsListTile(
            icon: Icons.notifications_none,
            iconColor: _orange,
            title: 'Notifications',
            onTap: () => _onNotifications(context),
          ),
          
          const SizedBox(height: 24),
          
          // Support Section
          _buildSectionTitle('Support'),
          const SizedBox(height: 8),
          SettingsListTile(
            icon: Icons.privacy_tip_outlined,
            iconColor: _orange,
            title: 'Privacy Policy',
            onTap: () => _onPrivacyPolicy(context),
          ),
          const SizedBox(height: 8),
          SettingsListTile(
            icon: Icons.help_outline,
            iconColor: _orange,
            title: 'Help & Support',
            onTap: () => _onHelpSupport(context),
          ),
          
          const SizedBox(height: 24),
          
          // Logout
          SettingsListTile(
            icon: Icons.logout,
            iconColor: Colors.red,
            title: 'Logout',
            titleColor: Colors.red,
            trailingColor: Colors.red,
            onTap: () => _onLogout(context),
          ),
        ],
      ),
    );
  }

  /// Builds section title
  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Builds the footer section
  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'CozyDorm © 2025',
          style: TextStyle(color: Colors.grey[500], fontSize: 13),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
