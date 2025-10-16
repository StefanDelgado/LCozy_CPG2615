import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';

class DormCard extends StatelessWidget {
  final Map<String, dynamic> dorm;
  final VoidCallback onManageRooms;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DormCard({
    super.key,
    required this.dorm,
    required this.onManageRooms,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and 3-dot menu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    dorm['name'] ?? 'Unknown Dorm',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // 3-dot menu
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.blue, size: 20),
                          SizedBox(width: 12),
                          Text('Edit Dorm'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 20),
                          SizedBox(width: 12),
                          Text('Delete Dorm'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Address
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    dorm['address'] ?? 'No address',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Description
            Text(
              dorm['description'] ?? 'No description',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            
            // Features (if available)
            if (dorm['features'] != null && dorm['features'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: _buildFeatureChips(dorm['features'].toString()),
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Manage Rooms Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onManageRooms,
                icon: const Icon(Icons.meeting_room),
                label: const Text('Manage Rooms'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFeatureChips(String features) {
    final featureList = features.split(',').take(3); // Show max 3 features
    return featureList.map((feature) {
      return Chip(
        label: Text(
          feature.trim(),
          style: const TextStyle(fontSize: 11),
        ),
        backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
        padding: const EdgeInsets.all(0),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
    }).toList();
  }
}
