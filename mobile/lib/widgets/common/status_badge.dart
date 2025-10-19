import 'package:flutter/material.dart';

/// Reusable status badge widget with gradient background
/// Used for payment, booking, and room statuses
class StatusBadge extends StatelessWidget {
  final String status;
  final Gradient? gradient;

  const StatusBadge({
    super.key,
    required this.status,
    this.gradient,
  });

  /// Get gradient based on status
  static Gradient getStatusGradient(String status) {
    final statusLower = status.toLowerCase();
    
    switch (statusLower) {
      case 'pending':
        return const LinearGradient(
          colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
        );
      case 'submitted':
        return const LinearGradient(
          colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
        );
      case 'paid':
      case 'completed':
      case 'approved':
      case 'active':
        return const LinearGradient(
          colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
        );
      case 'expired':
      case 'rejected':
      case 'failed':
        return const LinearGradient(
          colors: [Color(0xFFfc4a1a), Color(0xFFf7b733)],
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: gradient ?? getStatusGradient(status),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
