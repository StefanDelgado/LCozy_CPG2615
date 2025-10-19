import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';

class TenantCard extends StatelessWidget {
  final Map<String, dynamic> tenant;
  final bool isActive;
  final VoidCallback? onChat;
  final VoidCallback? onViewHistory;
  final VoidCallback? onManagePayment;

  static const Color _green = Color(0xFF27AE60);
  static const Color _orange = AppTheme.primary;

  const TenantCard({
    super.key,
    required this.tenant,
    required this.isActive,
    this.onChat,
    this.onViewHistory,
    this.onManagePayment,
  });

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '??';
    return name.split(' ')
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((e) => e[0])
        .join('')
        .toUpperCase();
  }

  String _calculateDaysUntilDue(String? nextDueDate) {
    if (nextDueDate == null || nextDueDate.isEmpty || nextDueDate == 'Not set') {
      return 'Not set';
    }
    
    try {
      final due = DateTime.parse(nextDueDate);
      final today = DateTime.now();
      final difference = due.difference(today).inDays;
      
      if (difference < 0) return 'Overdue';
      if (difference == 0) return 'Due today';
      return '$difference days';
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tenantName = tenant['tenant_name']?.toString() ?? 'No Name';
    final dormName = tenant['dorm_name']?.toString() ?? 'Unknown Dorm';
    final roomType = tenant['room_type']?.toString() ?? 'Unknown Room';
    final roomNumber = tenant['room_number']?.toString();
    final email = tenant['email']?.toString() ?? 'No email';
    final phone = tenant['phone']?.toString() ?? 'No phone';
    final checkIn = tenant['start_date']?.toString() ?? 'Not set';
    final contractEnd = tenant['end_date']?.toString() ?? 'Not set';
    final monthlyRent = tenant['price']?.toString() ?? '₱0';
    final lastPayment = tenant['last_payment_date']?.toString() ?? 'No payment';
    final nextPayment = tenant['next_due_date']?.toString() ?? 'Not set';
    final paymentStatus = tenant['payment_status']?.toString().toLowerCase() ?? 'pending';

    final roomInfo = '$dormName - $roomType${roomNumber != null ? ' (Room $roomNumber)' : ''}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          _buildHeader(tenantName, roomInfo, paymentStatus),
          const SizedBox(height: 10),
          _buildContactInfo(email, phone),
          const SizedBox(height: 12),
          _buildDatesSection(checkIn, contractEnd),
          const SizedBox(height: 14),
          _buildPaymentSection(monthlyRent, lastPayment, nextPayment),
          const SizedBox(height: 14),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader(String tenantName, String roomInfo, String paymentStatus) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
          radius: 26,
          child: Text(
            _getInitials(tenantName),
            style: TextStyle(
              color: AppTheme.primaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tenantName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              Text(
                roomInfo,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14.5,
                ),
              ),
            ],
          ),
        ),
        if (isActive)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: paymentStatus == 'paid' 
                ? _green.withValues(alpha: 0.12)
                : _orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              paymentStatus.toUpperCase(),
              style: TextStyle(
                color: paymentStatus == 'paid' ? _green : _orange,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContactInfo(String email, String phone) {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.email_outlined, color: Colors.grey[600], size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: Text(email, style: const TextStyle(fontSize: 13.5)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.phone, color: Colors.grey[600], size: 18),
            const SizedBox(width: 6),
            Text(phone, style: const TextStyle(fontSize: 13.5)),
          ],
        ),
      ],
    );
  }

  Widget _buildDatesSection(String checkIn, String contractEnd) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Check-in:', style: TextStyle(fontSize: 13, color: Colors.black54)),
                const SizedBox(height: 2),
                Text(checkIn, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Contract End:', style: TextStyle(fontSize: 13, color: Colors.black54)),
                const SizedBox(height: 2),
                Text(contractEnd, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSection(String monthlyRent, String lastPayment, String nextPayment) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _green.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payments_outlined, color: _green, size: 20),
              const SizedBox(width: 6),
              const Text(
                'Payment Details',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Monthly Rent:', style: TextStyle(fontSize: 13, color: Colors.black54)),
                    const SizedBox(height: 2),
                    Text(monthlyRent, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 10),
                    const Text('Next Payment:', style: TextStyle(fontSize: 13, color: Colors.black54)),
                    const SizedBox(height: 2),
                    Text(nextPayment, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Last Payment:', style: TextStyle(fontSize: 13, color: Colors.black54)),
                    const SizedBox(height: 2),
                    Text(lastPayment, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 10),
                    const Text('Days Until Due:', style: TextStyle(fontSize: 13, color: Colors.black54)),
                    const SizedBox(height: 2),
                    Text(_calculateDaysUntilDue(nextPayment), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onChat,
            icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF757575), size: 20),
            label: const Text('Chat', style: TextStyle(color: Color(0xFF757575), fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF757575),
              side: const BorderSide(color: Color(0xFFBDBDBD)),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onViewHistory,
            icon: const Icon(Icons.history, color: Color(0xFF757575), size: 20),
            label: const Text('History', style: TextStyle(color: Color(0xFF757575), fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF757575),
              side: const BorderSide(color: Color(0xFFBDBDBD)),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onManagePayment,
            icon: const Icon(Icons.payments_outlined, color: _green, size: 20),
            label: const Text('Payment', style: TextStyle(color: _green, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              foregroundColor: _green,
              side: const BorderSide(color: _green),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            ),
          ),
        ),
      ],
    );
  }
}
