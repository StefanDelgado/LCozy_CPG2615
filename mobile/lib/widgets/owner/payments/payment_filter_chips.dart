import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';

class PaymentFilterChips extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const PaymentFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _FilterChip(label: 'All', selected: selectedFilter == 'All', onTap: () => onFilterChanged('All')),
        _FilterChip(label: 'Completed', selected: selectedFilter == 'Completed', onTap: () => onFilterChanged('Completed')),
        _FilterChip(label: 'Pending', selected: selectedFilter == 'Pending', onTap: () => onFilterChanged('Pending')),
        _FilterChip(label: 'Failed', selected: selectedFilter == 'Failed', onTap: () => onFilterChanged('Failed')),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        child: Chip(
          label: Text(label, style: TextStyle(color: selected ? Colors.white : Colors.black87)),
          backgroundColor: selected ? AppTheme.primary : const Color(0xFFF5F5F5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
