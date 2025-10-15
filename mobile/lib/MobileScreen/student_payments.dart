import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class StudentPaymentsScreen extends StatefulWidget {
  final String userEmail;

  const StudentPaymentsScreen({Key? key, required this.userEmail}) : super(key: key);

  @override
  _StudentPaymentsScreenState createState() => _StudentPaymentsScreenState();
}

class _StudentPaymentsScreenState extends State<StudentPaymentsScreen> {
  bool isLoading = true;
  String error = '';
  
  Map<String, dynamic> statistics = {};
  List<dynamic> payments = [];

  @override
  void initState() {
    super.initState();
    fetchPayments();
  }

  Future<void> fetchPayments() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final response = await http.get(
        Uri.parse('http://cozydorms.life/modules/mobile-api/student_payments_api.php?student_email=${widget.userEmail}'),
      );

      print('Payments Response: ${response.statusCode}');
      print('Payments Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['ok'] == true) {
          setState(() {
            statistics = data['statistics'] ?? {};
            payments = data['payments'] ?? [];
            isLoading = false;
          });
        } else {
          throw Exception(data['error'] ?? 'Failed to load payments');
        }
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching payments: $e');
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> uploadReceipt(int paymentId) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return;

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Read image as bytes
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Send to API
      final response = await http.post(
        Uri.parse('http://cozydorms.life/modules/mobile-api/upload_receipt_api.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'payment_id': paymentId,
          'student_email': widget.userEmail,
          'receipt_base64': 'data:image/jpeg;base64,$base64Image',
          'receipt_filename': image.name,
        }),
      );

      // Close loading dialog
      Navigator.pop(context);

      print('Upload Response: ${response.statusCode}');
      print('Upload Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['ok'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Receipt uploaded successfully'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Refresh payments
          fetchPayments();
        } else {
          throw Exception(data['error'] ?? 'Upload failed');
        }
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      print('Error uploading receipt: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'submitted':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      case 'expired':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'submitted':
        return Icons.upload_file;
      case 'rejected':
        return Icons.cancel;
      case 'expired':
        return Icons.event_busy;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Payments'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error loading payments'),
                      const SizedBox(height: 8),
                      Text(error, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: fetchPayments,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchPayments,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // Statistics Cards
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      'Pending',
                                      '${statistics['pending_count'] ?? 0}',
                                      Icons.schedule,
                                      Colors.orange,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildStatCard(
                                      'Overdue',
                                      '${statistics['overdue_count'] ?? 0}',
                                      Icons.warning,
                                      Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      'Total Due',
                                      '₱${(statistics['total_due'] ?? 0).toStringAsFixed(2)}',
                                      Icons.payment,
                                      Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildStatCard(
                                      'Total Paid',
                                      '₱${(statistics['paid_amount'] ?? 0).toStringAsFixed(2)}',
                                      Icons.check_circle,
                                      Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // Payments List
                        if (payments.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(32),
                            child: Text(
                              'No payments found',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            itemCount: payments.length,
                            itemBuilder: (context, index) {
                              final payment = payments[index];
                              return _buildPaymentCard(payment);
                            },
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> payment) {
    final status = payment['status'] ?? 'pending';
    final isOverdue = payment['is_overdue'] == true;
    final amount = payment['amount'] ?? 0;
    final dueDate = payment['due_date'] ?? 'N/A';
    final dueStatus = payment['due_status'];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    payment['dorm_name'] ?? 'Unknown Dorm',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        getStatusIcon(status),
                        size: 16,
                        color: getStatusColor(status),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: getStatusColor(status),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Room info
            Text(
              'Room: ${payment['room_type'] ?? 'N/A'}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            
            // Amount
            Text(
              '₱${amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            
            // Due date info
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Due: $dueDate',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                if (dueStatus != null) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isOverdue ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      dueStatus,
                      style: TextStyle(
                        fontSize: 12,
                        color: isOverdue ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            
            // Payment date (if paid)
            if (payment['payment_date'] != null && status == 'paid') ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.event_available, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Paid: ${payment['payment_date']}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
            
            // Notes
            if (payment['notes'] != null && payment['notes'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.note, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        payment['notes'],
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Action buttons
            if (status == 'pending')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => uploadReceipt(payment['payment_id']),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload Receipt'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              )
            else if (payment['receipt_url'] != null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Show receipt viewer
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Receipt'),
                        content: Image.network(
                          payment['receipt_url'],
                          errorBuilder: (context, error, stackTrace) {
                            return const Text('Failed to load receipt');
                          },
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.receipt),
                  label: const Text('View Receipt'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
