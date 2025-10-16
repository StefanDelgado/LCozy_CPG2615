import 'package:flutter/material.dart';

/// Role selector dropdown for registration
/// Allows selection between Student and Owner roles
class RoleSelector extends StatelessWidget {
  final String selectedRole;
  final void Function(String?) onChanged;

  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Role',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: selectedRole,
            isExpanded: true,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down),
            items: ['Student', 'Owner']
                .map((role) => DropdownMenuItem(
                      value: role,
                      child: Row(
                        children: [
                          Icon(
                            role == 'Student'
                                ? Icons.school_outlined
                                : Icons.business_outlined,
                            size: 20,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(width: 12),
                          Text(role),
                        ],
                      ),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
