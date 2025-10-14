import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ==================== OwnerPaymentsScreen Widget ====================
class OwnerPaymentsScreen extends StatefulWidget {
  final String ownerEmail;

  const OwnerPaymentsScreen({
    super.key,
    required this.ownerEmail,
  });

  @override
  State<OwnerPaymentsScreen> createState() => _OwnerPaymentsScreenState();
}

class _OwnerPaymentsScreenState extends State<OwnerPaymentsScreen> {
  bool isLoading = true;
  String? error;
  Map<String, dynamic> stats = {};
  List<dynamic> payments = [];
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    fetchPayments();
  }

  Future<void> fetchPayments() async {
    try {
      final response = await http.get(
        Uri.parse('http://cozydorms.life/modules/mobile-api/owner_payments_api.php?owner_email=${widget.ownerEmail}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          setState(() {
            stats = data['stats'];
            payments = data['payments'];
            isLoading = false;
          });
        } else {
          throw Exception(data['error']);
        }
      } else {
        throw Exception('Server error');
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  List<dynamic> getFilteredPayments() {
    if (selectedFilter == 'All') return payments;
    return payments.where((p) => 
      p['status'].toString().toLowerCase() == selectedFilter.toLowerCase()
    ).toList();
  }

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
        child: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : error != null
        ? Center(child: Text(error!))
        : SingleChildScrollView(
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
                        value: "₱${(stats['monthly_revenue'] ?? 0).toStringAsFixed(2)}",
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
                        value: "₱${(stats['pending_amount'] ?? 0).toStringAsFixed(2)}",
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
                        _FilterChip(label: "All", selected: selectedFilter == 'All'),
                        _FilterChip(label: "Completed", selected: selectedFilter == 'Completed'),
                        _FilterChip(label: "Pending", selected: selectedFilter == 'Pending'),
                        _FilterChip(label: "Failed", selected: selectedFilter == 'Failed'),
                      ],
                    ),
                  ],
                ),
              ),
              // ----------- PAYMENT CARDS LIST SECTION -----------
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: getFilteredPayments().length,
                itemBuilder: (context, index) {
                  final payment = getFilteredPayments()[index];
                  return _PaymentCard(
                    name: payment['tenant_name'],
                    dorm: "${payment['dorm_name']} - ${payment['room_type']}",
                    amount: "₱${payment['amount'].toStringAsFixed(2)}",
                    status: payment['status'],
                    dueDate: payment['due_date'],
                    paidDate: payment['payment_date'],
                    method: payment['payment_method'] ?? 'Not specified',
                    transactionId: payment['receipt_image'],
                  );
                },
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