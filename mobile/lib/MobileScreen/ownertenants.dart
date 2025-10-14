import 'package:flutter/material.dart';

// ==================== OwnerTenantsScreen Widget ====================
class OwnerTenantsScreen extends StatefulWidget {
  const OwnerTenantsScreen({super.key});

  @override
  State<OwnerTenantsScreen> createState() => _OwnerTenantsScreenState();
}

// ==================== OwnerTenantsScreen State ====================
class _OwnerTenantsScreenState extends State<OwnerTenantsScreen> {
  int selectedTab = 0;
  int pendingCount = 1;

  @override
  Widget build(BuildContext context) {
    final orange = const Color(0xFFFF9800);
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F0),
      body: SafeArea(
        child: Column(
          children: [
            // ----------- HEADER SECTION -----------
            Container(
              padding: const EdgeInsets.only(left: 8, right: 20, top: 18, bottom: 18),
              decoration: BoxDecoration(
                color: orange,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Tenant Management",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          "Track and manage your tenants",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // ----------- TABS SECTION -----------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [orange, orange.withOpacity(0.85)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _TenantsTab(
                      label: 'Current tenants',
                      selected: selectedTab == 0,
                      count: pendingCount,
                      onTap: () => setState(() => selectedTab = 0),
                    ),
                    _TenantsTab(
                      label: 'Past tenants',
                      selected: selectedTab == 1,
                      onTap: () => setState(() => selectedTab = 1),
                    ),
                  ],
                ),
              ),
            ),
            // ----------- TENANT LIST SECTION -----------
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                  shrinkWrap: true,
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  children: [
                    if (selectedTab == 0) ...[
                      AnnaCruzTenantCard(),
                    ],
                    if (selectedTab == 1)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 60),
                          child: Text(
                            "No past tenants.",
                            style: TextStyle(color: Colors.grey[600], fontSize: 16),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== TenantsTab Widget SECTION ====================
class _TenantsTab extends StatelessWidget {
  final String label;
  final bool selected;
  final int? count;
  final VoidCallback onTap;

  const _TenantsTab({
    required this.label,
    required this.selected,
    this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final orange = const Color(0xFFFF9800);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 2),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? orange : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (count != null && selected)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                      decoration: BoxDecoration(
                        color: orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        count.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== AnnaCruzTenantCard Widget SECTION ====================
class AnnaCruzTenantCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final green = Color(0xFF27AE60);
    final border = Color(0xFFE0E0E0);
    final labelStyle = TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500, fontSize: 13.5);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ----------- TOP ROW SECTION -----------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Colors.orange[50],
                radius: 26,
                child: Text(
                  "AC",
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Anna Cruz",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: green.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Paid",
                            style: TextStyle(
                              color: green,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      "Sunset Dormitory - Room 2A",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // ----------- EMAIL AND PHONE SECTION -----------
          Row(
            children: [
              Icon(Icons.email_outlined, color: Colors.grey[600], size: 18),
              const SizedBox(width: 6),
              const Text(
                "anna.cruz@email.com",
                style: TextStyle(fontSize: 13.5),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.phone, color: Colors.grey[600], size: 18),
              const SizedBox(width: 6),
              const Text(
                "+63 912 345 6789",
                style: TextStyle(fontSize: 13.5),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ----------- CHECK-IN AND CONTRACT END SECTION -----------
          Row(
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
                    children: const [
                      Text("Check-in:", style: TextStyle(fontSize: 13, color: Colors.black54)),
                      SizedBox(height: 2),
                      Text("Feb 1, 2024", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
                    children: const [
                      Text("Contract End:", style: TextStyle(fontSize: 13, color: Colors.black54)),
                      SizedBox(height: 2),
                      Text("Feb 1, 2025", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // ----------- PAYMENT DETAILS SECTION -----------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: green.withOpacity(0.07),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.payments_outlined, color: green, size: 20),
                    const SizedBox(width: 6),
                    const Text(
                      "Payment Details",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
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
                          Text("Monthly Rent:", style: labelStyle),
                          const SizedBox(height: 2),
                          const Text(
                            "₱8,000",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text("Next Payment:", style: labelStyle),
                          const SizedBox(height: 2),
                          const Text(
                            "Mar 1, 2024",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Last Payment:", style: labelStyle),
                          const SizedBox(height: 2),
                          const Text(
                            "Feb 1, 2024",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 10),
                          Text("Days Until Due:", style: labelStyle),
                          const SizedBox(height: 2),
                          const Text(
                            "15 days",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // ----------- ACTION BUTTONS SECTION -----------
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF757575), size: 20),
                  label: const Text("Chat", style: TextStyle(color: Color(0xFF757575), fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF757575),
                    side: const BorderSide(color: Color(0xFFBDBDBD)),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.history, color: Color(0xFF757575), size: 20),
                  label: const Text("History", style: TextStyle(color: Color(0xFF757575), fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF757575),
                    side: const BorderSide(color: Color(0xFFBDBDBD)),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.payments_outlined, color: Color(0xFF27AE60), size: 20),
                  label: const Text("Payment", style: TextStyle(color: Color(0xFF27AE60), fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF27AE60),
                    side: const BorderSide(color: Color(0xFF27AE60)),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}