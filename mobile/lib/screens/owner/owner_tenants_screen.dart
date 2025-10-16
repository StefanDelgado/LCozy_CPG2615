import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../utils/api_constants.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_display_widget.dart';
import '../../widgets/owner/tenants/tenant_tab_selector.dart';
import '../../widgets/owner/tenants/tenant_card.dart';

/// Screen for managing current and past tenants
/// 
/// Features:
/// - Tab-based view (Current/Past tenants)
/// - Comprehensive tenant information display
/// - Payment tracking and status
/// - Contact actions (Chat, History, Payment)
class OwnerTenantsScreen extends StatefulWidget {
  final String ownerEmail;
  
  const OwnerTenantsScreen({
    super.key,
    required this.ownerEmail,
  });
  
  @override
  State<OwnerTenantsScreen> createState() => _OwnerTenantsScreenState();
}

class _OwnerTenantsScreenState extends State<OwnerTenantsScreen> {
  // UI State
  int _selectedTab = 0;
  bool _isLoading = true;
  String? _error;
  
  // Data
  List<Map<String, dynamic>> _currentTenants = [];
  List<Map<String, dynamic>> _pastTenants = [];

  // Theme
  static const Color _orange = Color(0xFFFF9800);
  static const Color _background = Color(0xFFFDF6F0);

  @override
  void initState() {
    super.initState();
    _fetchTenants();
  }

  /// Fetches current and past tenants from the API
  Future<void> _fetchTenants() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/modules/mobile-api/owner_tenants_api.php'
      ).replace(queryParameters: {
        'owner_email': widget.ownerEmail,
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['ok'] == true) {
          setState(() {
            _currentTenants = List<Map<String, dynamic>>.from(
              data['current_tenants'] ?? []
            );
            _pastTenants = List<Map<String, dynamic>>.from(
              data['past_tenants'] ?? []
            );
            _isLoading = false;
          });
        } else {
          throw Exception(data['error'] ?? 'Failed to load tenants');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load tenants: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Handles tab selection change
  void _onTabChanged(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  /// Handles chat action for a tenant
  void _onChatTenant(Map<String, dynamic> tenant) {
    // TODO: Navigate to chat screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening chat with ${tenant['tenant_name']}...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Handles viewing tenant history
  void _onViewHistory(Map<String, dynamic> tenant) {
    // TODO: Navigate to tenant history screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing history for ${tenant['tenant_name']}...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Handles payment action for a tenant
  void _onManagePayment(Map<String, dynamic> tenant) {
    // TODO: Navigate to payment management screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Managing payment for ${tenant['tenant_name']}...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tenants = _selectedTab == 0 ? _currentTenants : _pastTenants;

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Tab Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: TenantTabSelector(
                selectedTab: _selectedTab,
                currentTenantsCount: _currentTenants.length,
                onTabChanged: _onTabChanged,
              ),
            ),
            
            // Tenant List
            Expanded(
              child: _buildContent(tenants),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the header section
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(
        left: 8,
        right: 20,
        top: 18,
        bottom: 18,
      ),
      decoration: const BoxDecoration(
        color: _orange,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Tenant Management',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Track and manage your tenants',
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
    );
  }

  /// Builds the main content area
  Widget _buildContent(List<Map<String, dynamic>> tenants) {
    if (_isLoading) {
      return const LoadingWidget();
    }

    if (_error != null) {
      return ErrorDisplayWidget(
        message: _error!,
        onRetry: _fetchTenants,
      );
    }

    if (tenants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedTab == 0 ? Icons.people_outline : Icons.history,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _selectedTab == 0 
                ? 'No current tenants'
                : 'No past tenants',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedTab == 0
                ? 'Tenants will appear here once they check in'
                : 'Past tenants will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchTenants,
      color: _orange,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
        itemCount: tenants.length,
        itemBuilder: (context, index) {
          final tenant = tenants[index];
          
          return TenantCard(
            tenant: tenant,
            isActive: _selectedTab == 0,
            onChat: () => _onChatTenant(tenant),
            onViewHistory: () => _onViewHistory(tenant),
            onManagePayment: () => _onManagePayment(tenant),
          );
        },
      ),
    );
  }
}
