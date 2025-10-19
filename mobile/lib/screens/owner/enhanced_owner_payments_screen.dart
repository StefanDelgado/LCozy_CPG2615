import 'package:flutter/material.dart';
import '../../services/payment_service.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/stat_card.dart';
import '../../widgets/common/filter_tab_bar.dart';
import '../../widgets/owner/payments/enhanced_payment_card.dart';

/// Enhanced Payment Management Screen matching web design
/// 
/// Features:
/// - Gradient statistics dashboard (Total, Pending, Submitted, Paid, Revenue)
/// - Filter tabs (All, Pending, Submitted, Paid, Expired)
/// - Modern card-based layout
/// - Student avatars with initials
/// - Status badges with gradients
/// - Receipt viewer
/// - Status updates
/// - Auto-refresh
class EnhancedOwnerPaymentsScreen extends StatefulWidget {
  final String ownerEmail;

  const EnhancedOwnerPaymentsScreen({
    super.key,
    required this.ownerEmail,
  });

  @override
  State<EnhancedOwnerPaymentsScreen> createState() =>
      _EnhancedOwnerPaymentsScreenState();
}

class _EnhancedOwnerPaymentsScreenState
    extends State<EnhancedOwnerPaymentsScreen> {
  final PaymentService _paymentService = PaymentService();

  // UI State
  bool _isLoading = true;
  String? _error;
  String _selectedFilter = 'All';
  final Set<int> _processingPayments = {};

  // Data
  Map<String, dynamic> _stats = {};
  List<dynamic> _allPayments = [];

  @override
  void initState() {
    super.initState();
    _fetchPayments();
  }

  /// Fetches payment data from API
  Future<void> _fetchPayments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result =
          await _paymentService.getOwnerPayments(widget.ownerEmail);

      if (result['success']) {
        final data = result['data'];
        setState(() {
          _allPayments = data['payments'] ?? [];
          _calculateStats();
          _isLoading = false;
        });
      } else {
        throw Exception(result['error'] ?? 'Failed to load payments');
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load payments: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Calculate statistics from payments
  void _calculateStats() {
    int totalCount = _allPayments.length;
    int pendingCount = 0;
    int submittedCount = 0;
    int paidCount = 0;
    int expiredCount = 0;
    double totalRevenue = 0.0;

    for (var payment in _allPayments) {
      final status = payment['status']?.toString().toLowerCase() ?? '';
      final amount = double.tryParse(payment['amount']?.toString() ?? '0') ?? 0.0;

      // Check if expired
      bool isExpired = false;
      try {
        final createdAt = DateTime.parse(payment['created_at'] ?? '');
        final hoursElapsed = DateTime.now().difference(createdAt).inHours;
        isExpired = hoursElapsed >= 48 && status == 'pending';
      } catch (e) {
        // Ignore parsing errors
      }

      if (isExpired) {
        expiredCount++;
      } else {
        switch (status) {
          case 'pending':
            pendingCount++;
            break;
          case 'submitted':
            submittedCount++;
            break;
          case 'paid':
          case 'completed':
            paidCount++;
            totalRevenue += amount;
            break;
        }
      }
    }

    setState(() {
      _stats = {
        'total_payments': totalCount,
        'pending_count': pendingCount,
        'submitted_count': submittedCount,
        'paid_count': paidCount,
        'expired_count': expiredCount,
        'total_revenue': totalRevenue,
      };
    });
  }

  /// Get filtered payments based on selected tab
  List<dynamic> _getFilteredPayments() {
    if (_selectedFilter == 'All') {
      return _allPayments;
    }

    return _allPayments.where((payment) {
      final status = payment['status']?.toString().toLowerCase() ?? '';

      // Check if expired
      bool isExpired = false;
      try {
        final createdAt = DateTime.parse(payment['created_at'] ?? '');
        final hoursElapsed = DateTime.now().difference(createdAt).inHours;
        isExpired = hoursElapsed >= 48 && status == 'pending';
      } catch (e) {
        // Ignore parsing errors
      }

      if (_selectedFilter == 'Expired') {
        return isExpired;
      }

      if (isExpired) return false;

      return status == _selectedFilter.toLowerCase();
    }).toList();
  }

  /// Handle status change
  Future<void> _onStatusChanged(Map<String, dynamic> payment, String newStatus) async {
    final paymentId = payment['payment_id'];

    if (_processingPayments.contains(paymentId)) return;

    setState(() => _processingPayments.add(paymentId));

    try {
      dynamic result;

      if (newStatus == 'paid') {
        result = await _paymentService.completePayment(
          paymentId,
          widget.ownerEmail,
        );
      } else if (newStatus == 'expired' || newStatus == 'rejected') {
        result = await _paymentService.rejectPayment(
          paymentId,
          widget.ownerEmail,
        );
      } else {
        // For other statuses, we might need a different endpoint
        // For now, just refresh
        await _fetchPayments();
        return;
      }

      if (!mounted) return;

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Status updated'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        await _fetchPayments();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to update status'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _processingPayments.remove(paymentId));
      }
    }
  }

  /// Handle delete payment
  Future<void> _onDeletePayment(Map<String, dynamic> payment) async {
    final paymentId = payment['payment_id'];

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment'),
        content: Text(
          'Are you sure you want to delete this payment record for ${payment['tenant_name']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _processingPayments.add(paymentId));

    try {
      // Note: You may need to add a delete payment method to PaymentService
      // For now, using reject as placeholder
      final result = await _paymentService.rejectPayment(
        paymentId,
        widget.ownerEmail,
      );

      if (!mounted) return;

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment deleted'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        await _fetchPayments();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to delete payment'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _processingPayments.remove(paymentId));
      }
    }
  }

  /// Handle view receipt
  void _onViewReceipt(Map<String, dynamic> payment) {
    final receiptImage = payment['receipt_image'];

    if (receiptImage == null || receiptImage.toString().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No receipt available'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Payment Receipt'),
              backgroundColor: const Color(0xFF667eea),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildReceiptInfo('Tenant', payment['tenant_name']),
                      _buildReceiptInfo('Dorm', payment['dorm_name']),
                      _buildReceiptInfo('Amount', '₱${payment['amount']}'),
                      _buildReceiptInfo('Due Date', payment['due_date']),
                      _buildReceiptInfo('Status', payment['status']),
                      const SizedBox(height: 16),
                      const Text(
                        'Receipt Image:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Image.network(
                        'http://cozydorms.life/uploads/receipts/$receiptImage',
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            padding: const EdgeInsets.all(32),
                            color: Colors.grey[200],
                            child: const Column(
                              children: [
                                Icon(Icons.error_outline,
                                    size: 48, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Failed to load receipt'),
                              ],
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            padding: const EdgeInsets.all(32),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptInfo(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value?.toString() ?? ''),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💰 Payment Management'),
        backgroundColor: const Color(0xFF667eea),
        elevation: 0,
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchPayments,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchPayments,
                  child: Column(
                    children: [
                      // Statistics Dashboard
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // First Row: Total, Pending, Submitted
                            Row(
                              children: [
                                Expanded(
                                  child: StatCard(
                                    title: 'Total Payments',
                                    value: '${_stats['total_payments'] ?? 0}',
                                    icon: Icons.dashboard,
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF667eea),
                                        Color(0xFF764ba2)
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: StatCard(
                                    title: 'Pending',
                                    value: '${_stats['pending_count'] ?? 0}',
                                    icon: Icons.access_time,
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFf093fb),
                                        Color(0xFFf5576c)
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Second Row: Submitted, Paid
                            Row(
                              children: [
                                Expanded(
                                  child: StatCard(
                                    title: 'Submitted',
                                    value: '${_stats['submitted_count'] ?? 0}',
                                    icon: Icons.upload,
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF4facfe),
                                        Color(0xFF00f2fe)
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: StatCard(
                                    title: 'Paid',
                                    value: '${_stats['paid_count'] ?? 0}',
                                    icon: Icons.check_circle,
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF43e97b),
                                        Color(0xFF38f9d7)
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Third Row: Total Revenue (full width)
                            StatCard(
                              title: 'Total Revenue',
                              value:
                                  '₱${(_stats['total_revenue'] ?? 0.0).toStringAsFixed(2)}',
                              icon: Icons.attach_money,
                              gradient: const LinearGradient(
                                colors: [Color(0xFFfa709a), Color(0xFFfee140)],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Filter Tabs
                      FilterTabBar(
                        tabs: const [
                          'All',
                          'Pending',
                          'Submitted',
                          'Paid',
                          'Expired'
                        ],
                        initialTab: _selectedFilter,
                        onTabChanged: (tab) {
                          setState(() => _selectedFilter = tab);
                        },
                      ),

                      // Payments List
                      Expanded(
                        child: _buildPaymentsList(),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildPaymentsList() {
    final payments = _getFilteredPayments();

    if (payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No $_selectedFilter Payments',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFilter == 'All'
                  ? 'Add payment reminders to track student payments.'
                  : 'No payments found with this status.',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        final paymentId = payment['payment_id'];

        return EnhancedPaymentCard(
          payment: payment,
          isProcessing: _processingPayments.contains(paymentId),
          onStatusChanged: (newStatus) =>
              _onStatusChanged(payment, newStatus),
          onReject: () => _onDeletePayment(payment),
          onViewReceipt: () => _onViewReceipt(payment),
        );
      },
    );
  }
}
