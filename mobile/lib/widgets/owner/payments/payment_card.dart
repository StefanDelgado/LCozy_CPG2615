import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';

/// Payment card widget displaying payment details
class PaymentCard extends StatelessWidget {
  final Map<String, dynamic> payment;
  final VoidCallback? onMarkAsPaid;
  final VoidCallback? onViewReceipt;
  final VoidCallback? onReject;

  const PaymentCard({
    super.key,
    required this.payment,
    this.onMarkAsPaid,
    this.onViewReceipt,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final name = payment['tenant_name']?.toString() ?? 'Unknown';
    final dormName = payment['dorm_name']?.toString() ?? 'Unknown Dorm';
    final roomType = payment['room_type']?.toString() ?? 'Unknown Room';
    final dorm = '$dormName - $roomType';
    final amount = double.tryParse(payment['amount']?.toString() ?? '0') ?? 0.0;
    final status = payment['status']?.toString() ?? 'Pending';
    final dueDate = payment['due_date']?.toString() ?? 'Not set';
    final paidDate = payment['payment_date']?.toString();
    final method = 'GCash'; // Default method
    final transactionId = payment['receipt_image']?.toString();

    // Normalize status checking
    final statusLower = status.toLowerCase();
    final isCompleted = statusLower == 'completed' || statusLower == 'paid';
    final isPending = statusLower == 'pending' || statusLower == 'submitted';
    final isFailed = statusLower == 'failed' || statusLower == 'rejected';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(name, amount, isCompleted, isPending),
            const SizedBox(height: 2),
            Text(dorm, style: const TextStyle(color: Colors.black54, fontSize: 13)),
            const SizedBox(height: 10),
            _buildDates(dueDate, paidDate, isCompleted),
            const SizedBox(height: 4),
            _buildMethod(method, transactionId),
            const SizedBox(height: 8),
            _buildStatusAndAction(status, isCompleted, isPending, isFailed),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String name, double amount, bool isCompleted, bool isPending) {
    return Row(
      children: [
        Icon(
          isCompleted ? Icons.check_circle : isPending ? Icons.access_time : Icons.error,
          color: isCompleted ? Colors.green : isPending ? AppTheme.primary : Colors.red,
          size: 22,
        ),
        const SizedBox(width: 8),
        Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const Spacer(),
        Text(
          '₱${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: isCompleted ? Colors.green : isPending ? AppTheme.primary : Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildDates(String dueDate, String? paidDate, bool isCompleted) {
    return Row(
      children: [
        const Text('Due Date: ', style: TextStyle(color: Colors.black54, fontSize: 12)),
        Text(dueDate, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 16),
        if (isCompleted && paidDate != null) ...[
          const Text('Paid Date: ', style: TextStyle(color: Colors.black54, fontSize: 12)),
          Text(paidDate, style: const TextStyle(fontSize: 12)),
        ],
      ],
    );
  }

  Widget _buildMethod(String method, String? transactionId) {
    return Row(
      children: [
        const Text('Method: ', style: TextStyle(color: Colors.black54, fontSize: 12)),
        Text(method, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 16),
        if (transactionId != null) ...[
          const Text('Transaction ID: ', style: TextStyle(color: Colors.black54, fontSize: 12)),
          Flexible(
            child: Text(
              transactionId,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusAndAction(String status, bool isCompleted, bool isPending, bool isFailed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green.withValues(alpha: 0.15)
                    : isPending
                        ? AppTheme.primary.withValues(alpha: 0.15)
                        : Colors.red.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: isCompleted
                      ? Colors.green
                      : isPending
                          ? AppTheme.primary
                          : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const Spacer(),
            // View Receipt Button (for all statuses)
            TextButton.icon(
              onPressed: onViewReceipt,
              icon: const Icon(Icons.receipt_long, size: 18),
              label: const Text('View', style: TextStyle(fontSize: 13)),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
            ),
          ],
        ),
        
        // Action buttons for pending payments
        if (isPending) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onPressed: onReject,
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Disapprove', style: TextStyle(fontSize: 13)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onPressed: onMarkAsPaid,
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Complete', style: TextStyle(fontSize: 13)),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
