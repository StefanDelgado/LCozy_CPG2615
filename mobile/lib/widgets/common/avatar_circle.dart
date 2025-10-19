import 'package:flutter/material.dart';

/// Reusable circular avatar widget with gradient background
/// Used for user initials display
class AvatarCircle extends StatelessWidget {
  final String name;
  final double radius;
  final Gradient? gradient;

  const AvatarCircle({
    super.key,
    required this.name,
    this.radius = 22,
    this.gradient,
  });

  /// Get the first letter of the name
  String _getInitial() {
    if (name.isEmpty) return '?';
    return name.trim()[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        gradient: gradient ??
            const LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          _getInitial(),
          style: TextStyle(
            color: Colors.white,
            fontSize: radius * 0.8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
