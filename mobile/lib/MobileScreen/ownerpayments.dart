import 'package:flutter/material.dart';

// ==================== OwnerPaymentsScreen Widget ====================
class OwnerPaymentsScreen extends StatelessWidget {
  const OwnerPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orange = const Color(0xFFFF9800);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6FB),
      // ----------- APPBAR SECTION -----------
      appBar: AppBar(
        backgroundColor: orange,
        elevation: 0,
        title: const Text(
          "Payment History",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file, color: Colors.white),
            onPressed: () {},
            tooltip: "Export",
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            children: [
              // ----------- STAT CARDS SECTION -----------
              Container(
                color: orange,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: "Total Revenue",
                        value: "₱22,000",
                        sublabel: "This month",
                        color: Colors.white,
                        textColor: Colors.orange,
                        icon: Icons.payments,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        label: "Pending",
                        value: "₱14,000",
                        sublabel: "Outstanding",
                        color: const Color(0xFFFFB74D),
                        textColor: Colors.white,
                        icon: Icons.access_time,
                      ),
                    ),
                  ],
                ),
              ),
              // ----------- SEARCH & FILTER SECTION -----------
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Search by tenant or dorm name...",
                        prefixIcon: Icon(Icons.search),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _FilterChip(label: "All", selected: true),
                        _FilterChip(label: "Completed"),
                        _FilterChip(label: "Pending"),
                        _FilterChip(label: "Failed"),
                      ],
                    ),
                  ],
                ),
              ),
              // ----------- PAYMENT CARDS LIST SECTION -----------
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: const [
                  _PaymentCard(
                    name: "Anna Cruz",
                    dorm: "Sunset Dormitory - Room 2A",
                    amount: "₱8,000",
                    status: "Completed",
                    dueDate: "Mar 1, 2024",
                    paidDate: "Mar 1, 2024",
                    method: "GCash",
                    transactionId: "GC123456789",
                  ),
                  _PaymentCard(
                    name: "Sarah Lee",
                    dorm: "Sunset Dormitory - Room 3C",
                    amount: "₱8,000",
                    status: "Pending",
                    dueDate: "Mar 1, 2024",
                    paidDate: null,
                    method: "GCash",
                    transactionId: null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== StatCard Widget SECTION ====================
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sublabel;
  final Color color;
  final Color textColor;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.sublabel,
    required this.color,
    required this.textColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: textColor, size: 20),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            Text(
              sublabel,
              style: TextStyle(
                color: textColor.withOpacity(0.8),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== FilterChip Widget SECTION ====================
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;

  const _FilterChip({required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label, style: TextStyle(color: selected ? Colors.white : Colors.black87)),
        backgroundColor: selected ? Colors.orange : const Color(0xFFF5F5F5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

// ==================== PaymentCard Widget SECTION ====================
class _PaymentCard extends StatelessWidget {
  final String name;
  final String dorm;
  final String amount;
  final String status;
  final String dueDate;
  final String? paidDate;
  final String method;
  final String? transactionId;

  const _PaymentCard({
    required this.name,
    required this.dorm,
    required this.amount,
    required this.status,
    required this.dueDate,
    this.paidDate,
    required this.method,
    this.transactionId,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = status == "Completed";
    final isPending = status == "Pending";
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----------- PAYMENT CARD HEADER SECTION -----------
            Row(
              children: [
                Icon(
                  isCompleted ? Icons.check_circle : Icons.access_time,
                  color: isCompleted ? Colors.green : Colors.orange,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                Text(
                  amount,
                  style: TextStyle(
                    color: isCompleted ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(dorm, style: const TextStyle(color: Colors.black54, fontSize: 13)),
            const SizedBox(height: 10),
            // ----------- PAYMENT CARD DATES SECTION -----------
            Row(
              children: [
                Text("Due Date: ", style: TextStyle(color: Colors.black54, fontSize: 12)),
                Text(dueDate, style: TextStyle(fontSize: 12)),
                const SizedBox(width: 16),
                if (isCompleted) ...[
                  Text("Paid Date: ", style: TextStyle(color: Colors.black54, fontSize: 12)),
                  Text(paidDate ?? "", style: TextStyle(fontSize: 12)),
                ],
              ],
            ),
            const SizedBox(height: 4),
            // ----------- PAYMENT CARD METHOD SECTION -----------
            Row(
              children: [
                Text("Method: ", style: TextStyle(color: Colors.black54, fontSize: 12)),
                Text(method, style: TextStyle(fontSize: 12)),
                const SizedBox(width: 16),
                if (transactionId != null) ...[
                  Text("Transaction ID: ", style: TextStyle(color: Colors.black54, fontSize: 12)),
                  Text(transactionId!, style: TextStyle(fontSize: 12)),
                ],
              ],
            ),
            const SizedBox(height: 8),
            // ----------- PAYMENT CARD STATUS & ACTION SECTION -----------
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.green.withOpacity(0.15)
                        : isPending
                            ? Colors.orange.withOpacity(0.15)
                            : Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: isCompleted
                          ? Colors.green
                          : isPending
                              ? Colors.orange
                              : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                if (isPending)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    ),
                    onPressed: () {},
                    child: const Text("Mark as Paid (Manual)", style: TextStyle(fontSize: 13)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}