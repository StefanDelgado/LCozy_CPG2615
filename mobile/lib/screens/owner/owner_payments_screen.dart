import 'package:flutter/material.dart';
import '../../services/payment_service.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_display_widget.dart';
import '../../widgets/owner/payments/payment_stats_widget.dart';
import '../../widgets/owner/payments/payment_filter_chips.dart';
import '../../widgets/owner/payments/payment_card.dart';

/// Screen for managing and tracking tenant payments
/// 
/// Features:
/// - Payment statistics (revenue, pending amounts)
/// - Search functionality
/// - Filter by status (All, Completed, Pending, Failed)
/// - Payment history with details
/// - Manual payment marking
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
  final PaymentService _paymentService = PaymentService();
  
  // UI State
  bool _isLoading = true;
  String? _error;
  String _selectedFilter = 'All';
  String _searchQuery = '';

  // Data
  Map<String, dynamic> _stats = {};
  List<dynamic> _payments = [];

  // Theme
  static const Color _orange = Color(0xFFFF9800);
  static const Color _background = Color(0xFFF9F6FB);

  @override
  void initState() {
    super.initState();
    _fetchPayments();
  }

  /// Fetches payment data and statistics from the API
  Future<void> _fetchPayments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _paymentService.getOwnerPayments(widget.ownerEmail);

      if (result['success']) {
        final data = result['data'];
        setState(() {
          _stats = data['stats'] ?? {};
          _payments = data['payments'] ?? [];
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

  /// Returns filtered payments based on selected filter and search query
  List<dynamic> _getFilteredPayments() {
    var filtered = _payments;

    // Apply status filter
    if (_selectedFilter != 'All') {
      filtered = filtered.where((p) => 
        p['status'].toString().toLowerCase() == _selectedFilter.toLowerCase()
      ).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) {
        final name = p['tenant_name']?.toString().toLowerCase() ?? '';
        final dorm = p['dorm_name']?.toString().toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || dorm.contains(query);
      }).toList();
    }

    return filtered;
  }

  /// Handles filter change
  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  /// Handles search query change
  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  /// Handles marking a payment as paid manually
  void _onMarkAsPaid(Map<String, dynamic> payment) {
    // TODO: Implement mark as paid functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Marking payment as paid for ${payment['tenant_name']}...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Handles viewing payment receipt
  void _onViewReceipt(Map<String, dynamic> payment) {
    // TODO: Implement view receipt functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing receipt for ${payment['tenant_name']}...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Handles exporting payment data
  void _onExport() {
    // TODO: Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exporting payment data...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  /// Builds the app bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _orange,
      elevation: 0,
      title: const Text(
        'Payment History',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.upload_file, color: Colors.white),
          onPressed: _onExport,
          tooltip: 'Export',
        ),
      ],
    );
  }

  /// Builds the main body content
  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget();
    }

    if (_error != null) {
      return ErrorDisplayWidget(
        message: _error!,
        onRetry: _fetchPayments,
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchPayments,
      color: _orange,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Statistics Cards
            PaymentStatsWidget(
              stats: _stats,
              backgroundColor: _orange,
            ),
            
            // Search and Filter
            _buildSearchAndFilter(),
            
            // Payment List
            _buildPaymentList(),
          ],
        ),
      ),
    );
  }

  /// Builds the search and filter section
  Widget _buildSearchAndFilter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          // Search Bar
          TextField(
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search by tenant or dorm name...',
              prefixIcon: const Icon(Icons.search),
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
          
          // Filter Chips
          PaymentFilterChips(
            selectedFilter: _selectedFilter,
            onFilterChanged: _onFilterChanged,
          ),
        ],
      ),
    );
  }

  /// Builds the payment list
  Widget _buildPaymentList() {
    final filteredPayments = _getFilteredPayments();

    if (filteredPayments.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.payment_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No payments found'
                  : _selectedFilter != 'All'
                      ? 'No $_selectedFilter payments'
                      : 'No payments yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try a different search term'
                  : 'Payment history will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: filteredPayments.length,
      itemBuilder: (context, index) {
        final payment = filteredPayments[index];
        
        return PaymentCard(
          payment: payment,
          onMarkAsPaid: () => _onMarkAsPaid(payment),
          onViewReceipt: () => _onViewReceipt(payment),
        );
      },
    );
  }
}
