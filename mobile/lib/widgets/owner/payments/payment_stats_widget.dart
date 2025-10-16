import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';

class PaymentStatsWidget extends StatelessWidget {
  final Map<String, dynamic> stats;
  final Color backgroundColor;

  const PaymentStatsWidget({
    super.key,
    required this.stats,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final monthlyRevenue = double.tryParse(stats['monthly_revenue']?.toString() ?? '0') ?? 0.0;
    final pendingAmount = double.tryParse(stats['pending_amount']?.toString() ?? '0') ?? 0.0;

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: 'Total Revenue',
              value: '${monthlyRevenue.toStringAsFixed(2)}',
              sublabel: 'This month',
              color: Colors.white,
              textColor: AppTheme.primary,
              icon: Icons.payments,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _StatCard(
              label: 'Pending',
              value: '${pendingAmount.toStringAsFixed(2)}',
              sublabel: 'Outstanding',
              color: Colors.white, // White background like Total Revenue
              textColor: AppTheme.primary, // Purple text
              icon: Icons.access_time,
              hasBorder: true, // Add border
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sublabel;
  final Color color;
  final Color textColor;
  final IconData icon;
  final bool hasBorder;

  const _StatCard({
    required this.label,
    required this.value,
    required this.sublabel,
    required this.color,
    required this.textColor,
    required this.icon,
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: hasBorder ? Border.all(
          color: AppTheme.primary,
          width: 2,
        ) : null,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: textColor, size: 20),
                const SizedBox(width: 6),
                Text(label, style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 22)),
            Text(sublabel, style: TextStyle(color: textColor.withValues(alpha: 0.8), fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
