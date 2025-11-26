import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/certification_service.dart';
import '../../../utils/app_theme.dart';

/// Widget for managing dorm certifications
class CertificationManagementWidget extends StatefulWidget {
  final int dormId;
  final String ownerEmail;
  final bool isReadOnly;

  const CertificationManagementWidget({
    super.key,
    required this.dormId,
    required this.ownerEmail,
    this.isReadOnly = false,
  });

  @override
  State<CertificationManagementWidget> createState() =>
      _CertificationManagementWidgetState();
}

class _CertificationManagementWidgetState
    extends State<CertificationManagementWidget> {
  final CertificationService _certService = CertificationService();
  List<Map<String, dynamic>> _certifications = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCertifications();
  }

  Future<void> _loadCertifications() async {
    setState(() => _isLoading = true);

    try {
      final result = await _certService.getCertifications(widget.dormId);

      if (result['success'] == true) {
        setState(() {
          _certifications =
              List<Map<String, dynamic>>.from(result['certifications'] ?? []);
        });
      } else {
        _showSnackBar('Failed to load certifications', isError: true);
      }
    } catch (e) {
      print('[CertificationWidget] Load error: $e');
      _showSnackBar('Error loading certifications', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadFile() async {
    try {
      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result == null) return;

      final file = File(result.files.single.path!);

      // Check file size (5MB limit)
      final fileSize = await file.length();
      if (fileSize > 5 * 1024 * 1024) {
        _showSnackBar('File size must be less than 5MB', isError: true);
        return;
      }

      // Ask for certification type
      String? certType = await _showCertificationTypeDialog();
      if (certType == null) return;

      // Show loading
      setState(() => _isLoading = true);

      // Upload
      final uploadResult = await _certService.uploadCertification(
        dormId: widget.dormId,
        ownerEmail: widget.ownerEmail,
        certificationFile: file,
        certificationType: certType,
      );

      if (uploadResult['success'] == true) {
        _showSnackBar('Certification uploaded successfully');
        await _loadCertifications();
      } else {
        _showSnackBar(
          uploadResult['error'] ?? 'Upload failed',
          isError: true,
        );
      }
    } catch (e) {
      print('[CertificationWidget] Upload error: $e');
      _showSnackBar('Error uploading file', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String?> _showCertificationTypeDialog() async {
    final controller = TextEditingController();

    final types = [
      'Business Permit',
      'Fire Safety Certificate',
      'Sanitary Permit',
      'Barangay Clearance',
      'Building Permit',
      'Other',
    ];

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Certification Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Type',
                border: OutlineInputBorder(),
              ),
              items: types
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null && value != 'Other') {
                  controller.text = value;
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Certification Name',
                hintText: 'Enter certification name',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(context, text);
              }
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCertification(int certId, String fileName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Certification'),
        content: Text('Are you sure you want to delete "$fileName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final result = await _certService.deleteCertification(
        certificationId: certId,
        ownerEmail: widget.ownerEmail,
      );

      if (result['success'] == true) {
        _showSnackBar('Certification deleted');
        await _loadCertifications();
      } else {
        _showSnackBar(result['error'] ?? 'Delete failed', isError: true);
      }
    } catch (e) {
      print('[CertificationWidget] Delete error: $e');
      _showSnackBar('Error deleting certification', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openCertification(String filePath) async {
    final url = _certService.getCertificationUrl(filePath);
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showSnackBar('Cannot open file', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Certifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!widget.isReadOnly)
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: AppTheme.primary),
                    onPressed: _isLoading ? null : _pickAndUploadFile,
                    tooltip: 'Upload Certification',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_certifications.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'No certifications uploaded yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _certifications.length,
                itemBuilder: (context, index) {
                  final cert = _certifications[index];
                  final fileName = cert['file_name'] ?? 'Unknown';
                  final certType = cert['certification_type'] ?? 'Document';
                  final uploadedAt = cert['uploaded_at'] ?? '';
                  final filePath = cert['file_path'] ?? '';
                  final certId = cert['certification_id'] ?? 0;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(
                        _getFileIcon(fileName),
                        color: AppTheme.primary,
                        size: 32,
                      ),
                      title: Text(
                        certType,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Uploaded: ${_formatDate(uploadedAt)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility),
                            onPressed: () => _openCertification(filePath),
                            tooltip: 'View',
                          ),
                          if (!widget.isReadOnly)
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _deleteCertification(certId, fileName),
                              tooltip: 'Delete',
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
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
