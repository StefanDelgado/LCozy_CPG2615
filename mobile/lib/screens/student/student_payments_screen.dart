import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../../services/payment_service.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' show ErrorDisplayWidget;
import '../../widgets/student/payments/payment_stat_card.dart';
import '../../widgets/student/payments/payment_card.dart';

class StudentPaymentsScreen extends StatefulWidget {
  final String userEmail;

  const StudentPaymentsScreen({super.key, required this.userEmail});

  @override
  State<StudentPaymentsScreen> createState() => _StudentPaymentsScreenState();
}

class _StudentPaymentsScreenState extends State<StudentPaymentsScreen> {
  final PaymentService _paymentService = PaymentService();
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
      final result = await _paymentService.getStudentPayments(widget.userEmail);

      if (result['success']) {
        setState(() {
          final paymentData = result['data'];
          // Note: The API might return data differently
          // Adjust based on actual API response structure
          if (paymentData is List) {
            payments = paymentData;
            statistics = {}; // Empty if no stats in response
          } else if (paymentData is Map) {
            statistics = paymentData['statistics'] ?? {};
            payments = paymentData['payments'] ?? paymentData;
          }
          isLoading = false;
        });
      } else {
        throw Exception(result['error'] ?? 'Failed to load payments');
      }
    } catch (e) {
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
      if (!mounted) return;
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
      final result = await _paymentService.uploadPaymentProof({
        'payment_id': paymentId,
        'student_email': widget.userEmail,
        'receipt_base64': 'data:image/jpeg;base64,$base64Image',
        'receipt_filename': image.name,
      });

      // Close loading dialog
      if (!mounted) return;
      Navigator.pop(context);

      if (result['success']) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Receipt uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Refresh payments
        fetchPayments();
      } else {
        throw Exception(result['message'] ?? 'Upload failed');
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
          ? const LoadingWidget(message: 'Loading payments...')
          : error.isNotEmpty
              ? ErrorDisplayWidget(
                  error: error,
                  onRetry: fetchPayments,
                )
              : _buildPaymentsContent(),
    );
  }

  Widget _buildPaymentsContent() {
    return RefreshIndicator(
      onRefresh: fetchPayments,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildStatisticsSection(),
            _buildPaymentsListSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: PaymentStatCard(
                  label: 'Pending',
                  value: '${statistics['pending_count'] ?? 0}',
                  icon: Icons.schedule,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PaymentStatCard(
                  label: 'Overdue',
                  value: '${statistics['overdue_count'] ?? 0}',
                  icon: Icons.warning,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: PaymentStatCard(
                  label: 'Total Due',
                  value: '₱${(statistics['total_due'] ?? 0).toStringAsFixed(2)}',
                  icon: Icons.payment,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PaymentStatCard(
                  label: 'Total Paid',
                  value: '₱${(statistics['paid_amount'] ?? 0).toStringAsFixed(2)}',
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsListSection() {
    if (payments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.payment,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No payments found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        final paymentId = payment['payment_id'];
        
        return PaymentCard(
          payment: payment,
          onUploadReceipt: () => uploadReceipt(paymentId),
        );
      },
    );
  }
}
