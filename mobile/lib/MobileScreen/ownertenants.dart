import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ==================== OwnerTenantsScreen Widget ====================
class OwnerTenantsScreen extends StatefulWidget {
  final String ownerEmail;
  
  const OwnerTenantsScreen({
    Key? key,
    required this.ownerEmail,
  }) : super(key: key);
  
  @override
  State<OwnerTenantsScreen> createState() => _OwnerTenantsScreenState();
}

// ==================== OwnerTenantsScreen State ====================
class _OwnerTenantsScreenState extends State<OwnerTenantsScreen> {
  int selectedTab = 0;
  bool isLoading = true;
  String? error;
  List<Map<String, dynamic>> currentTenants = [];
  List<Map<String, dynamic>> pastTenants = [];

  @override
  void initState() {
    super.initState();
    fetchTenants();
  }

  Future<void> fetchTenants() async {
    try {
      final response = await http.get(
        Uri.parse('http://cozydorms.life/modules/mobile-api/owner_tenants_api.php?owner_email=${widget.ownerEmail}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          setState(() {
            currentTenants = List<Map<String, dynamic>>.from(data['current_tenants']);
            pastTenants = List<Map<String, dynamic>>.from(data['past_tenants']);
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
                      count: currentTenants.length,
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
                child: isLoading 
                ? const Center(child: CircularProgressIndicator())
                : error != null
                ? Center(child: Text(error!))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                    itemCount: selectedTab == 0 ? currentTenants.length : pastTenants.length,
                    itemBuilder: (context, index) {
                      final tenant = selectedTab == 0 
                        ? currentTenants[index]
                        : pastTenants[index];
                      
                      return TenantCard(
                        tenant: tenant,
                        isActive: selectedTab == 0,
                      );
                    },
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

// ==================== TenantCard Widget SECTION ====================
class TenantCard extends StatelessWidget {
  final Map<String, dynamic> tenant;
  final bool isActive;

  const TenantCard({
    Key? key,
    required this.tenant,
    required this.isActive,
  }) : super(key: key);

  // Add this getter for the label style
  TextStyle get labelStyle => const TextStyle(
    fontSize: 13, 
    color: Colors.black54
  );

  @override
  Widget build(BuildContext context) {
    final green = Color(0xFF27AE60);
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.orange[50],
                radius: 26,
                child: Text(
                  tenant['tenant_name'].toString().split(' ').map((e) => e[0]).take(2).join(''),
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tenant['tenant_name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      '${tenant['dorm_name']} - ${tenant['room_type']}',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (isActive && tenant['payment_status'] != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: tenant['payment_status'] == 'paid' 
                      ? green.withOpacity(0.12)
                      : Colors.orange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tenant['payment_status'].toString().toUpperCase(),
                    style: TextStyle(
                      color: tenant['payment_status'] == 'paid' ? green : Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
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
              Text(
                tenant['email'],
                style: const TextStyle(fontSize: 13.5),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.phone, color: Colors.grey[600], size: 18),
              const SizedBox(width: 6),
              Text(
                tenant['phone'],
                style: const TextStyle(fontSize: 13.5),
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
                    children: [
                      const Text("Check-in:", style: TextStyle(fontSize: 13, color: Colors.black54)),
                      const SizedBox(height: 2),
                      Text(
                        tenant['check_in'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
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
                      const Text("Contract End:", style: TextStyle(fontSize: 13, color: Colors.black54)),
                      const SizedBox(height: 2),
                      Text(
                        tenant['contract_end'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
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
                          Text(
                            tenant['monthly_rent'],
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text("Next Payment:", style: labelStyle),
                          const SizedBox(height: 2),
                          Text(
                            tenant['next_payment'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                          Text(
                            tenant['last_payment'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 10),
                          Text("Days Until Due:", style: labelStyle),
                          const SizedBox(height: 2),
                          Text(
                            tenant['days_until_due'],
                            style: const TextStyle(
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