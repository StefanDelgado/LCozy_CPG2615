import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';

class TenantTabSelector extends StatelessWidget {
  final int selectedTab;
  final int currentTenantsCount;
  final int checkoutRequestsCount;
  final Function(int) onTabChanged;

  static const Color _orange = AppTheme.primary;

  const TenantTabSelector({
    super.key,
    required this.selectedTab,
    required this.currentTenantsCount,
    this.checkoutRequestsCount = 0,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_orange, _orange.withValues(alpha: 0.85)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildTab(
            label: 'Current',
            isSelected: selectedTab == 0,
            count: currentTenantsCount,
            onTap: () => onTabChanged(0),
          ),
          _buildTab(
            label: 'Checkout',
            isSelected: selectedTab == 1,
            count: checkoutRequestsCount,
            onTap: () => onTabChanged(1),
          ),
          _buildTab(
            label: 'Past',
            isSelected: selectedTab == 2,
            onTap: () => onTabChanged(2),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String label,
    required bool isSelected,
    int? count,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? _orange : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (count != null && isSelected)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                      decoration: BoxDecoration(
                        color: _orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        count.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
