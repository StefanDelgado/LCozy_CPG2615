import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';
import '../../services/tenant_service.dart';
import '../../services/checkout_service.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_display_widget.dart';
import '../../widgets/owner/tenants/tenant_tab_selector.dart';
import '../../widgets/owner/tenants/tenant_card.dart';

/// Screen for managing current and past tenants
/// 
/// Features:
/// - Tab-based view (Current/Checkout Requests/Past tenants)
/// - Comprehensive tenant information display
/// - Payment tracking and status
/// - Contact actions (Chat, History, Payment)
/// - Checkout request management (Approve/Disapprove)
class OwnerTenantsScreen extends StatefulWidget {
  final String ownerEmail;
  final int ownerId;
  
  const OwnerTenantsScreen({
    super.key,
    required this.ownerEmail,
    required this.ownerId,
  });
  
  @override
  State<OwnerTenantsScreen> createState() => _OwnerTenantsScreenState();
}

class _OwnerTenantsScreenState extends State<OwnerTenantsScreen> {
  final TenantService _tenantService = TenantService();
  
  // UI State
  int _selectedTab = 0;
  bool _isLoading = true;
  String? _error;
  
  // Data
  List<Map<String, dynamic>> _currentTenants = [];
  List<Map<String, dynamic>> _checkoutRequests = [];
  List<Map<String, dynamic>> _pastTenants = [];

  // Theme
  static const Color _orange = AppTheme.primary;
  static const Color _background = Color(0xFFFDF6F0);

  @override
  void initState() {
    super.initState();
    _fetchTenants();
    _fetchCheckoutRequests();
  }

  /// Fetches current and past tenants from the API
  Future<void> _fetchTenants() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _tenantService.getOwnerTenants(widget.ownerEmail);

      if (result['success'] == true) {
        final data = result['data'];
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
        throw Exception(result['error'] ?? 'Failed to load tenants');
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load tenants: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Fetches checkout requests from the API
  Future<void> _fetchCheckoutRequests() async {
    try {
      final result = await CheckoutService.getOwnerRequests(
        ownerId: widget.ownerId,
      );

      if (result['success'] == true) {
        final data = result['data'];
        // Get only pending (requested status) requests for the checkout tab
        final grouped = data['grouped'] ?? {};
        
        setState(() {
          _checkoutRequests = List<Map<String, dynamic>>.from(
            grouped['pending'] ?? []
          );
        });
      }
    } catch (e) {
      // Silently fail for checkout requests
      print('Failed to load checkout requests: $e');
    }
  }

  /// Refreshes all data
  Future<void> _refreshData() async {
    await Future.wait([
      _fetchTenants(),
      _fetchCheckoutRequests(),
    ]);
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

  /// Handles approving a checkout request
  Future<void> _onApproveCheckout(Map<String, dynamic> request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Checkout'),
        content: Text(
          'Approve checkout request from ${request['tenant_name']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      
      final result = await CheckoutService.approveCheckout(
        requestId: request['request_id'],
        ownerId: widget.ownerId,
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Checkout request approved!'),
            backgroundColor: Colors.green,
          ),
        );
        _refreshData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Failed to approve checkout'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Handles disapproving a checkout request
  Future<void> _onDisapproveCheckout(Map<String, dynamic> request) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disapprove Checkout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Disapprove checkout request from ${request['tenant_name']}?',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                hintText: 'Why are you disapproving?',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Disapprove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      
      final result = await CheckoutService.disapproveCheckout(
        requestId: request['request_id'],
        ownerId: widget.ownerId,
        reason: reasonController.text,
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Checkout request disapproved'),
            backgroundColor: Colors.orange,
          ),
        );
        _refreshData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Failed to disapprove checkout'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> displayList;
    
    switch (_selectedTab) {
      case 0:
        displayList = _currentTenants;
        break;
      case 1:
        displayList = _checkoutRequests;
        break;
      case 2:
        displayList = _pastTenants;
        break;
      default:
        displayList = _currentTenants;
    }

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
                checkoutRequestsCount: _checkoutRequests.length,
                onTabChanged: _onTabChanged,
              ),
            ),
            
            // Content List
            Expanded(
              child: _buildContent(displayList),
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
  Widget _buildContent(List<Map<String, dynamic>> items) {
    if (_isLoading) {
      return const LoadingWidget();
    }

    if (_error != null) {
      return ErrorDisplayWidget(
        message: _error!,
        onRetry: _refreshData,
      );
    }

    if (items.isEmpty) {
      String emptyTitle = '';
      String emptySubtitle = '';
      
      switch (_selectedTab) {
        case 0:
          emptyTitle = 'No current tenants';
          emptySubtitle = 'Tenants will appear here once they check in';
          break;
        case 1:
          emptyTitle = 'No checkout requests';
          emptySubtitle = 'Checkout requests from tenants will appear here';
          break;
        case 2:
          emptyTitle = 'No past tenants';
          emptySubtitle = 'Past tenants will appear here';
          break;
      }

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedTab == 0 
                ? Icons.people_outline 
                : _selectedTab == 1 
                  ? Icons.exit_to_app 
                  : Icons.history,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              emptyTitle,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              emptySubtitle,
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
      onRefresh: _refreshData,
      color: _orange,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          
          // Show checkout request card for checkout tab
          if (_selectedTab == 1) {
            return _buildCheckoutRequestCard(item);
          }
          
          // Show tenant card for current and past tenants
          return TenantCard(
            tenant: item,
            isActive: _selectedTab == 0,
            onChat: () => _onChatTenant(item),
            onViewHistory: () => _onViewHistory(item),
            onManagePayment: () => _onManagePayment(item),
          );
        },
      ),
    );
  }

  /// Builds a checkout request card
  Widget _buildCheckoutRequestCard(Map<String, dynamic> request) {
    final tenantName = request['tenant_name'] ?? 'Unknown Tenant';
    final dormName = request['dorm_name'] ?? 'N/A';
    final roomType = request['room_type'] ?? 'N/A';
    final reason = request['request_reason'];
    final requestDate = request['created_at'] ?? 'N/A';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with tenant name and badge
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tenantName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dormName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'PENDING',
                  style: TextStyle(
                    color: Colors.orange[800],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          
          // Details
          _buildDetailRow(Icons.meeting_room, 'Room', roomType),
          const SizedBox(height: 8),
          _buildDetailRow(Icons.calendar_today, 'Requested', requestDate),
          
          if (reason != null && reason.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildDetailRow(Icons.message, 'Reason', reason),
          ],
          
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _onDisapproveCheckout(request),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Disapprove'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red[700],
                    side: BorderSide(color: Colors.red[700]!),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _onApproveCheckout(request),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Helper to build detail row
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
