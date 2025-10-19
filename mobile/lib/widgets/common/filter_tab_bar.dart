import 'package:flutter/material.dart';

/// Reusable filter tab bar widget
/// Used for filtering data by different categories
class FilterTabBar extends StatefulWidget {
  final List<String> tabs;
  final Function(String) onTabChanged;
  final String initialTab;

  const FilterTabBar({
    super.key,
    required this.tabs,
    required this.onTabChanged,
    String? initialTab,
  }) : initialTab = initialTab ?? '';

  @override
  State<FilterTabBar> createState() => _FilterTabBarState();
}

class _FilterTabBarState extends State<FilterTabBar> {
  late String _activeTab;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab.isNotEmpty 
        ? widget.initialTab 
        : (widget.tabs.isNotEmpty ? widget.tabs[0] : '');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: widget.tabs.map((tab) {
          final isActive = tab == _activeTab;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(tab),
              selected: isActive,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _activeTab = tab);
                  widget.onTabChanged(tab);
                }
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF667eea),
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isActive ? Colors.white : const Color(0xFF495057),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isActive 
                      ? const Color(0xFF667eea) 
                      : const Color(0xFFe9ecef),
                  width: 2,
                ),
              ),
              elevation: isActive ? 4 : 0,
              shadowColor: const Color(0xFF667eea).withOpacity(0.3),
            ),
          );
        }).toList(),
      ),
    );
  }
}
