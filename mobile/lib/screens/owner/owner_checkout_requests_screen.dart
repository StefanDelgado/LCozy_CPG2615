import 'package:flutter/material.dart';
import '../../services/checkout_service.dart';
import '../../utils/app_theme.dart';

class OwnerCheckoutRequestsScreen extends StatefulWidget {
  final int ownerId;

  const OwnerCheckoutRequestsScreen({Key? key, required this.ownerId})
      : super(key: key);

  @override
  State<OwnerCheckoutRequestsScreen> createState() =>
      _OwnerCheckoutRequestsScreenState();
}

class _OwnerCheckoutRequestsScreenState
    extends State<OwnerCheckoutRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _requestsData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result =
        await CheckoutService.getOwnerRequests(ownerId: widget.ownerId);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result['success'] == true) {
          _requestsData = result['data'];
        } else {
          _errorMessage = result['error'] ?? 'Failed to load requests';
        }
      });
    }
  }

  Future<void> _handleApprove(Map<String, dynamic> request) async {
    final confirmed = await _showConfirmDialog(
      title: 'Approve Checkout',
      content:
          'Approve checkout request for ${request['tenant_name']} at ${request['dorm_name']}?',
      confirmText: 'Approve',
      confirmColor: Colors.green,
    );

    if (confirmed == true) {
      await _processAction(
        () => CheckoutService.approveCheckout(
          requestId: request['request_id'],
          ownerId: widget.ownerId,
        ),
        'Checkout request approved successfully',
      );
    }
  }

  Future<void> _handleDisapprove(Map<String, dynamic> request) async {
    final confirmed = await _showConfirmDialog(
      title: 'Disapprove Checkout',
      content:
          'Disapprove checkout request for ${request['tenant_name']}? The booking will remain active.',
      confirmText: 'Disapprove',
      confirmColor: Colors.red,
    );

    if (confirmed == true) {
      await _processAction(
        () => CheckoutService.disapproveCheckout(
          requestId: request['request_id'],
          ownerId: widget.ownerId,
        ),
        'Checkout request disapproved',
      );
    }
  }

  Future<void> _handleComplete(Map<String, dynamic> request) async {
    final confirmed = await _showConfirmDialog(
      title: 'Complete Checkout',
      content:
          'Mark checkout as complete for ${request['tenant_name']}? This will finalize the checkout process.',
      confirmText: 'Complete',
      confirmColor: Colors.blue,
    );

    if (confirmed == true) {
      await _processAction(
        () => CheckoutService.completeCheckout(
          requestId: request['request_id'],
          ownerId: widget.ownerId,
        ),
        'Checkout completed. Tenant moved to past tenants.',
      );
    }
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String content,
    required String confirmText,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  Future<void> _processAction(
    Future<Map<String, dynamic>> Function() action,
    String successMessage,
  ) async {
    // Show loading
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final result = await action();

    if (!mounted) return;
    Navigator.pop(context); // Close loading

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          backgroundColor: Colors.green,
        ),
      );
      _loadRequests(); // Refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Operation failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final status = request['status'];
    final canApprove = request['can_approve'] == true;
    final canComplete = request['can_complete'] == true;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request['tenant_name'] ?? 'Unknown Tenant',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        request['dorm_name'] ?? 'Unknown Dorm',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(status),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(Icons.meeting_room, 'Room: ${request['room_type']}'),
            _buildInfoRow(
              Icons.calendar_today,
              'From: ${request['start_date']}',
            ),
            _buildInfoRow(
              Icons.event,
              'Until: ${request['end_date'] ?? 'Ongoing'}',
            ),
            _buildInfoRow(
              Icons.attach_money,
              'Price: ₱${request['price']?.toStringAsFixed(2)}',
            ),
            _buildInfoRow(
              Icons.access_time,
              'Requested: ${request['created_at']}',
            ),
            if (request['request_reason'] != null &&
                request['request_reason'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reason:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request['request_reason'],
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
            if (canApprove || canComplete) ...[
              const SizedBox(height: 16),
              if (canApprove)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _handleApprove(request),
                        icon: const Icon(Icons.check_circle, size: 18),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _handleDisapprove(request),
                        icon: const Icon(Icons.cancel, size: 18),
                        label: const Text('Disapprove'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              if (canComplete)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _handleComplete(request),
                    icon: const Icon(Icons.done_all, size: 18),
                    label: const Text('Mark Complete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor = Colors.white;
    String displayText = status;

    switch (status) {
      case 'requested':
        bgColor = Colors.orange;
        displayText = 'Pending';
        break;
      case 'approved':
        bgColor = Colors.blue;
        break;
      case 'completed':
        bgColor = Colors.green;
        break;
      case 'disapproved':
        bgColor = Colors.red;
        break;
      default:
        bgColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTabContent(List<dynamic> requests) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No requests',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRequests,
      child: ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) => _buildRequestCard(requests[index]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final counts = _requestsData?['count'] ?? {};
    final grouped = _requestsData?['grouped'] ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout Requests'),
        backgroundColor: AppTheme.primary,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'Pending',
              icon: Badge(
                label: Text('${counts['pending'] ?? 0}'),
                isLabelVisible: (counts['pending'] ?? 0) > 0,
                child: const Icon(Icons.pending_actions),
              ),
            ),
            Tab(
              text: 'Approved',
              icon: Badge(
                label: Text('${counts['approved'] ?? 0}'),
                isLabelVisible: (counts['approved'] ?? 0) > 0,
                child: const Icon(Icons.check_circle_outline),
              ),
            ),
            Tab(
              text: 'Completed',
              icon: Badge(
                label: Text('${counts['completed'] ?? 0}'),
                isLabelVisible: (counts['completed'] ?? 0) > 0,
                child: const Icon(Icons.done_all),
              ),
            ),
            Tab(
              text: 'Disapproved',
              icon: Badge(
                label: Text('${counts['disapproved'] ?? 0}'),
                isLabelVisible: (counts['disapproved'] ?? 0) > 0,
                child: const Icon(Icons.cancel),
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_errorMessage!,
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadRequests,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTabContent(grouped['pending'] ?? []),
                    _buildTabContent(grouped['approved'] ?? []),
                    _buildTabContent(grouped['completed'] ?? []),
                    _buildTabContent(grouped['disapproved'] ?? []),
                  ],
                ),
    );
  }
}
