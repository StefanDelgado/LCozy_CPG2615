import 'package:flutter/material.dart';
import '../../../utils/helpers.dart';

class ContactTab extends StatelessWidget {
  final Map<String, dynamic> owner;
  final String currentUserEmail;
  final VoidCallback onSendMessage;

  const ContactTab({
    super.key,
    required this.owner,
    required this.currentUserEmail,
    required this.onSendMessage,
  });

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Owner Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildContactRow(
            Icons.person,
            'Name',
            Helpers.safeText(owner['name'], 'Not available'),
          ),
          _buildContactRow(
            Icons.email,
            'Email',
            Helpers.safeText(owner['email'], 'Not available'),
          ),
          _buildContactRow(
            Icons.phone,
            'Phone',
            Helpers.safeText(owner['phone'], 'Not provided'),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onSendMessage,
              icon: const Icon(Icons.message),
              label: const Text('Send Message'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
