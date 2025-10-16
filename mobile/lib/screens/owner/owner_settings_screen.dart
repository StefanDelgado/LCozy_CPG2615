import 'package:flutter/material.dart';

import '../../widgets/owner/settings/settings_list_tile.dart';

/// Screen for owner settings and profile management
/// 
/// Features:
/// - Profile display
/// - Settings options (Edit Profile, Change Password, Notifications, etc.)
/// - Privacy Policy and Help & Support
/// - Logout functionality
class OwnerSettingsScreen extends StatelessWidget {
  final String ownerName;
  final String ownerEmail;
  final String ownerRole;
  final String avatarUrl;

  static const Color _orange = Color(0xFFFF9800);

  const OwnerSettingsScreen({
    super.key,
    required this.ownerName,
    required this.ownerEmail,
    required this.ownerRole,
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
            ownerName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            ownerEmail,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Chip(
            label: Text(ownerRole),
            backgroundColor: Colors.white,
            labelStyle: const TextStyle(
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
          const SizedBox(height: 8),
          SettingsListTile(
            icon: Icons.notifications_none,
            iconColor: _orange,
            title: 'Notifications',
            onTap: () => _onNotifications(context),
          ),
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
          const SizedBox(height: 8),
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
