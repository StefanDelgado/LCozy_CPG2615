import 'package:flutter/material.dart';
import '../../services/review_service.dart';
import '../../../utils/app_theme.dart';

class OwnerReviewsScreen extends StatefulWidget {
  final int dormId;
  final String dormName;
  const OwnerReviewsScreen({super.key, required this.dormId, required this.dormName});

  @override
  State<OwnerReviewsScreen> createState() => _OwnerReviewsScreenState();
}

class _OwnerReviewsScreenState extends State<OwnerReviewsScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> reviews = [];
  String? error;
  // track review IDs that are currently being moderated to disable buttons
  final Set<int> processingReviews = {};

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    setState(() { isLoading = true; error = null; });
    try {
      final result = await ReviewService().getDormReviews(widget.dormId);
      if (result['success']) {
        setState(() {
          reviews = List<Map<String, dynamic>>.from(result['data'] ?? []);
          isLoading = false;
        });
      } else {
        throw Exception(result['message'] ?? 'Failed to load reviews');
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _confirmModeration(int reviewId, String action) async {
    final actionLabel = action == 'approve' ? 'Keep this review' : 'Report this review to admin (request removal)';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(action == 'approve' ? 'Keep review?' : 'Report review?'),
        content: Text(actionLabel),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text('Confirm')),
        ],
      ),
    );
    if (confirmed == true) {
      await _doModeration(reviewId, action);
    }
  }

  Future<void> _doModeration(int reviewId, String action) async {
    setState(() {
      processingReviews.add(reviewId);
    });
    try {
      final res = await ReviewService().moderateReview(reviewId, action);
      if (!mounted) return;
      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Action completed')));
        await fetchReviews();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['error'] ?? 'Failed to moderate review')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (!mounted) return;
      setState(() {
        processingReviews.remove(reviewId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews for ${widget.dormName}'),
        backgroundColor: AppTheme.primary,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text('Error: $error'))
              : reviews.isEmpty
                  ? Center(child: Text('No reviews yet.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: reviews.length,
                      separatorBuilder: (_, __) => Divider(),
                      itemBuilder: (context, i) {
                        final r = reviews[i];
                        final reviewId = r['review_id'] is int ? r['review_id'] as int : int.tryParse('${r['review_id']}') ?? 0;
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r['student_name'] ?? 'Unknown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.star, color: Colors.amber, size: 18),
                                    SizedBox(width: 4),
                                    Text('${r['rating']}/5', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Text('Room: ${r['room_type'] ?? 'N/A'}', style: TextStyle(color: Colors.grey[700])),
                                SizedBox(height: 8),
                                Text(r['comment'] ?? '', style: TextStyle(fontSize: 15)),
                                SizedBox(height: 8),
                                Text(r['created_at'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                SizedBox(height: 12),
                                // moderation controls
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    processingReviews.contains(reviewId)
                                        ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                                        : Row(
                                            children: [
                                              TextButton(
                                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                                                onPressed: () => _confirmModeration(reviewId, 'reject'),
                                                child: Text('Report'),
                                              ),
                                              SizedBox(width: 8),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                                                onPressed: () => _confirmModeration(reviewId, 'approve'),
                                                child: Text('Keep'),
                                              ),
                                            ],
                                          ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
