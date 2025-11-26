import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/certification_service.dart';
import '../../../utils/app_theme.dart';

/// Tab for displaying dorm certifications (student view - read-only)
class CertificationsTab extends StatefulWidget {
  final int dormId;

  const CertificationsTab({
    super.key,
    required this.dormId,
  });

  @override
  State<CertificationsTab> createState() => _CertificationsTabState();
}

class _CertificationsTabState extends State<CertificationsTab> {
  final CertificationService _certService = CertificationService();
  List<Map<String, dynamic>> _certifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCertifications();
  }

  Future<void> _loadCertifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _certService.getCertifications(widget.dormId);

      if (result['success'] == true) {
        setState(() {
          _certifications =
              List<Map<String, dynamic>>.from(result['certifications'] ?? []);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = result['error'] ?? 'Failed to load certifications';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('[CertificationsTab] Load error: $e');
      setState(() {
        _error = 'Error loading certifications';
        _isLoading = false;
      });
    }
  }

  Future<void> _openCertification(String filePath) async {
    final url = _certService.getCertificationUrl(filePath);
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot open file')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCertifications,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_certifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.verified,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No certifications uploaded yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The owner hasn\'t uploaded any certifications',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Info banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'These are the official certifications uploaded by the dorm owner. Tap to view.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Certifications list
        ..._certifications.map((cert) {
          final fileName = cert['file_name'] ?? 'Unknown';
          final certType = cert['certification_type'] ?? 'Document';
          final uploadedAt = cert['uploaded_at'] ?? '';
          final filePath = cert['file_path'] ?? '';

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            child: InkWell(
              onTap: () => _openCertification(filePath),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getFileIcon(fileName),
                        color: AppTheme.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            certType,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            fileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 12,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Uploaded: ${_formatDate(uploadedAt)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // View button
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.visibility,
                        color: Colors.green.shade700,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),

        // Verification badge at bottom
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.green.shade50,
                Colors.green.shade100,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade300),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verified Certifications',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.green.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_certifications.length} ${_certifications.length == 1 ? 'certification' : 'certifications'} uploaded',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getFileIcon(String fileName) {
    if (fileName.toLowerCase().endsWith('.pdf')) {
      return Icons.picture_as_pdf;
    } else if (fileName.toLowerCase().endsWith('.jpg') ||
        fileName.toLowerCase().endsWith('.jpeg') ||
        fileName.toLowerCase().endsWith('.png')) {
      return Icons.image;
    }
    return Icons.insert_drive_file;
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }
}
