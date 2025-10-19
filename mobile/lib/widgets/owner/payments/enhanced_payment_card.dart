import 'package:flutter/material.dart';
import '../../common/avatar_circle.dart';
import '../../common/status_badge.dart';

/// Enhanced payment card widget matching web design
/// Features: Avatar, student info, payment details, actions
class EnhancedPaymentCard extends StatelessWidget {
  final Map<String, dynamic> payment;
  final bool isProcessing;
  final VoidCallback? onMarkAsPaid;
  final VoidCallback? onReject;
  final VoidCallback? onViewReceipt;
  final Function(String)? onStatusChanged;

  const EnhancedPaymentCard({
    super.key,
    required this.payment,
    this.isProcessing = false,
    this.onMarkAsPaid,
    this.onReject,
    this.onViewReceipt,
    this.onStatusChanged,
  });

  String _getTimeLeft() {
    try {
      final createdAt = DateTime.parse(payment['created_at'] ?? '');
      final now = DateTime.now();
      final hoursElapsed = now.difference(createdAt).inHours;
      final hoursLeft = 48 - hoursElapsed;
      
      if (hoursLeft > 0) {
        return '$hoursLeft hours left';
      } else {
        return 'Expired';
      }
    } catch (e) {
      return '';
    }
  }

  bool _isExpired() {
    try {
      final createdAt = DateTime.parse(payment['created_at'] ?? '');
      final now = DateTime.now();
      final hoursElapsed = now.difference(createdAt).inHours;
      return hoursElapsed >= 48 && 
             payment['status'].toString().toLowerCase() == 'pending';
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _isExpired() ? 'expired' : payment['status']?.toString() ?? 'pending';
    final studentName = payment['tenant_name']?.toString() ?? 'Unknown';
    final dormName = payment['dorm_name']?.toString() ?? '';
    final roomType = payment['room_type']?.toString() ?? '';
    final amount = double.tryParse(payment['amount']?.toString() ?? '0') ?? 0.0;
    final dueDate = payment['due_date']?.toString() ?? '';
    final hasReceipt = payment['receipt_image'] != null && 
                       payment['receipt_image'].toString().isNotEmpty;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFf8f9fa),
                  Colors.grey[200]!,
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                AvatarCircle(
                  name: studentName,
                  radius: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2c3e50),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '🏠 $dormName${roomType.isNotEmpty ? " • $roomType" : ""}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6c757d),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(status: status),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _InfoItem(
                        label: '💵 Amount',
                        value: '₱${amount.toStringAsFixed(2)}',
                      ),
                    ),
                    Expanded(
                      child: _InfoItem(
                        label: '📅 Due Date',
                        value: dueDate,
                      ),
                    ),
                  ],
                ),
                if (status == 'pending' && !_isExpired()) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoItem(
                          label: '⏳ Time Left',
                          value: _getTimeLeft(),
                        ),
                      ),
                      Expanded(
                        child: _InfoItem(
                          label: '📎 Receipt',
                          value: hasReceipt ? 'Available' : 'No receipt',
                          valueColor: hasReceipt ? const Color(0xFF667eea) : const Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 12),
                  _InfoItem(
                    label: '📎 Receipt',
                    value: hasReceipt ? 'View Receipt' : 'No receipt',
                    valueColor: hasReceipt ? const Color(0xFF667eea) : const Color(0xFF999999),
                    onTap: hasReceipt ? onViewReceipt : null,
                  ),
                ],
              ],
            ),
          ),

          // Actions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFf8f9fa),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                // Status Dropdown
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFe9ecef), width: 2),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: status,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF495057),
                        ),
                        items: ['pending', 'submitted', 'paid', 'expired']
                            .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(
                                    s[0].toUpperCase() + s.substring(1),
                                  ),
                                ))
                            .toList(),
                        onChanged: isProcessing || onStatusChanged == null
                            ? null
                            : (newStatus) {
                                if (newStatus != null && newStatus != status) {
                                  onStatusChanged!(newStatus);
                                }
                              },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Delete Button
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFfc4a1a), Color(0xFFf7b733)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: isProcessing ? null : onReject,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.delete, color: Colors.white, size: 18),
                                  SizedBox(width: 4),
                                  Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final VoidCallback? onTap;

  const _InfoItem({
    required this.label,
    required this.value,
    this.valueColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final child = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6c757d),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            color: valueColor ?? const Color(0xFF2c3e50),
            fontWeight: FontWeight.w600,
            decoration: onTap != null ? TextDecoration.underline : null,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: child,
      );
    }

    return child;
  }
}
