import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../widgets/owner/dorms/certification_management_widget.dart';

/// Screen for viewing and managing dorm details including certifications
class DormDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> dorm;
  final String ownerEmail;

  const DormDetailsScreen({
    super.key,
    required this.dorm,
    required this.ownerEmail,
  });

  @override
  Widget build(BuildContext context) {
    final dormId = int.tryParse(dorm['dorm_id'].toString()) ?? 0;
    final dormName = dorm['name'] ?? 'Unknown Dorm';
    final address = dorm['address'] ?? '';
    final description = dorm['description'] ?? '';
    final features = dorm['features'] ?? '';
    final depositRequired = dorm['deposit_required'] == 1 || 
                           dorm['deposit_required'] == true ||
                           dorm['deposit_required'] == '1';
    final depositMonths = dorm['deposit_months'] ?? 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(dormName),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dorm Information Section
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF9333EA), Color(0xFFC084FC)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.apartment,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dormName,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Active',
                                      style: TextStyle(
                                        color: Color(0xFF10B981),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (depositRequired) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF59E0B).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '$depositMonths mo. deposit',
                                        style: const TextStyle(
                                          color: Color(0xFFF59E0B),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    _buildInfoRow(Icons.location_on, 'Address', address),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.description, 'Description', description),
                    if (features.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.star, 'Features', features),
                    ],
                  ],
                ),
              ),
            ),

            // Certification Management Section
            CertificationManagementWidget(
              dormId: dormId,
              ownerEmail: ownerEmail,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value.isEmpty ? 'Not provided' : value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
