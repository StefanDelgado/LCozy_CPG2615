import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';

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
    final orangeColor = AppTheme.primary;

    return Container(
      color: orangeColor,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          if (showLogo) ...[
            // Clean logo without background
            SizedBox(
              width: 120,
              height: 120,
              child: Image.asset(
                'lib/Logo.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.home, color: orangeColor, size: 60),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
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
