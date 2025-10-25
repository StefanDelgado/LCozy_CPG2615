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
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
