import 'package:flutter/material.dart';

/// Reusable header for authentication screens
/// Displays CozyDorm logo and customizable title/subtitle
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showLogo;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.showLogo = true,
  });

  @override
  Widget build(BuildContext context) {
    final orangeColor = const Color(0xFFFF9800);

    return Container(
      color: orangeColor,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          if (showLogo) ...[
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: Icon(Icons.home, color: orangeColor, size: 48),
            ),
            const SizedBox(height: 20),
            const Text(
              'CozyDorm',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
          ],
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
