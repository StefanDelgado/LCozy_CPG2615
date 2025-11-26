import 'package:flutter/material.dart';
import '../../services/checkout_service.dart';
import '../../utils/app_theme.dart';
import 'package:intl/intl.dart';

class OwnerPastTenantsScreen extends StatefulWidget {
  final int ownerId;

  const OwnerPastTenantsScreen({Key? key, required this.ownerId})
      : super(key: key);

  @override
  State<OwnerPastTenantsScreen> createState() => _OwnerPastTenantsScreenState();
}

class _OwnerPastTenantsScreenState extends State<OwnerPastTenantsScreen> {
  List<dynamic> _pastTenants = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPastTenants();
  }

  Future<void> _loadPastTenants() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result =
        await CheckoutService.getPastTenants(ownerId: widget.ownerId);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result['success'] == true) {
          _pastTenants = result['data'] ?? [];
        } else {
          _errorMessage = result['error'] ?? 'Failed to load past tenants';
        }
      });
    }
  }

  List<dynamic> get _filteredTenants {
    if (_searchQuery.isEmpty) return _pastTenants;

    return _pastTenants.where((tenant) {
      final name = tenant['tenant_name']?.toString().toLowerCase() ?? '';
      final dorm = tenant['dorm_name']?.toString().toLowerCase() ?? '';
      final room = tenant['room_type']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();

      return name.contains(query) || dorm.contains(query) || room.contains(query);
    }).toList();
  }

  Widget _buildTenantCard(Map<String, dynamic> tenant) {
    final totalPaid = tenant['total_paid'] ?? 0.0;
    final outstanding = tenant['outstanding_balance'] ?? 0.0;
    final paymentStatus = tenant['payment_status'];
    final durationDays = tenant['duration_days'] ?? 0;

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
                CircleAvatar(
                  backgroundColor: AppTheme.primary,
                  child: Text(
                    (tenant['tenant_name'] ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tenant['tenant_name'] ?? 'Unknown Tenant',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        tenant['tenant_email'] ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildPaymentBadge(paymentStatus),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.location_city,
              tenant['dorm_name'] ?? 'Unknown Dorm',
            ),
            _buildInfoRow(
              Icons.meeting_room,
              '${tenant['room_type']} - ${tenant['booking_type']}',
            ),
            _buildInfoRow(
              Icons.location_on,
              tenant['dorm_address'] ?? 'No address',
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatColumn(
                          'Check-in',
                          _formatDate(tenant['check_in_date']),
                          Icons.login,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey[300],
                      ),
                      Expanded(
                        child: _buildStatColumn(
                          'Check-out',
                          _formatDate(tenant['checkout_date']),
                          Icons.logout,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey[300],
                      ),
                      Expanded(
                        child: _buildStatColumn(
                          'Duration',
                          '$durationDays days',
                          Icons.calendar_today,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPaymentInfo(
                          'Total Paid',
                          totalPaid,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildPaymentInfo(
                          'Outstanding',
                          outstanding,
                          Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppTheme.primary),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentInfo(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '₱${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentBadge(String status) {
    final isComplete = status == 'complete';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isComplete ? Colors.green : Colors.orange,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isComplete ? Icons.check_circle : Icons.warning,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            isComplete ? 'PAID' : 'PENDING',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? date) {
    if (date == null) return 'N/A';
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('MMM dd, yyyy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredTenants;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Past Tenants'),
        backgroundColor: AppTheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPastTenants,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search by name, dorm, or room...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          // Statistics summary
          if (!_isLoading && _pastTenants.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    'Total Tenants',
                    '${_pastTenants.length}',
                    Icons.people,
                  ),
                  Container(width: 1, height: 40, color: AppTheme.primary),
                  _buildSummaryItem(
                    'Results',
                    '${filteredList.length}',
                    Icons.filter_list,
                  ),
                ],
              ),
            ),
          // List
          Expanded(
            child: _isLoading
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
                              onPressed: _loadPastTenants,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : filteredList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.history,
                                    size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isEmpty
                                      ? 'No past tenants yet'
                                      : 'No results found',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadPastTenants,
                            child: ListView.builder(
                              itemCount: filteredList.length,
                              itemBuilder: (context, index) =>
                                  _buildTenantCard(filteredList[index]),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primary, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
