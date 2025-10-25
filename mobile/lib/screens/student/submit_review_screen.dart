import 'package:flutter/material.dart';
import '../../services/review_service.dart';

class SubmitReviewScreen extends StatefulWidget {
  final String dormId;
  final String studentEmail;
  final int bookingId;
  final int studentId;

  const SubmitReviewScreen({
    super.key,
    required this.dormId,
    required this.studentEmail,
    required this.bookingId,
    required this.studentId,
  });

  @override
  State<SubmitReviewScreen> createState() => _SubmitReviewScreenState();
}

class _SubmitReviewScreenState extends State<SubmitReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  int _stars = 5;
  String _review = '';
  bool _isSubmitting = false;
  String? _error;

  final ReviewService _reviewService = ReviewService();

  void _submitReview() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isSubmitting = true; _error = null; });
    _formKey.currentState!.save();
    try {
      final result = await _reviewService.submitReview(
        dormId: widget.dormId,
        studentEmail: widget.studentEmail,
        bookingId: widget.bookingId,
        studentId: widget.studentId,
        stars: _stars,
        review: _review,
      );
      if (result['success'] == true) {
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        setState(() { _error = result['error'] ?? 'Failed to submit review.'; });
      }
    } catch (e) {
      setState(() { _error = 'Error: ${e.toString()}'; });
    } finally {
      setState(() { _isSubmitting = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Review')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your Rating:', style: TextStyle(fontSize: 16)),
              Row(
                children: List.generate(5, (i) => IconButton(
                  icon: Icon(
                    i < _stars ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () => setState(() => _stars = i + 1),
                )),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Your Review',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your review' : null,
                onSaved: (v) => _review = v!.trim(),
              ),
              const SizedBox(height: 24),
              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReview,
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Submit Review'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
