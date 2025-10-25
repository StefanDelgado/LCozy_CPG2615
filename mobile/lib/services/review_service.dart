
  import 'dart:convert';
  import 'package:http/http.dart' as http;
  import '../utils/constants.dart';

class ReviewService {
  Future<Map<String, dynamic>> submitReview({
    required String dormId,
    required String studentEmail,
    required int bookingId,
    required int studentId,
    required int stars,
    required String review,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/modules/mobile-api/reviews/submit_review_api.php');
    final body = jsonEncode({
      'dorm_id': dormId,
      'student_email': studentEmail,
      'booking_id': bookingId,
      'student_id': studentId,
      'rating': stars,
      'comment': review,
    });
    final response = await http.post(url, body: body, headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {'success': false, 'error': 'Server error'};
    }
  }
  Future<Map<String, dynamic>> getDormReviews(int dormId) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/modules/mobile-api/reviews/fetch_reviews_api.php?dorm_id=$dormId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      // Normalize API response to { success: bool, data: [...] }
      if (body is Map<String, dynamic> && body['success'] == true) {
        return {
          'success': true,
          'data': body['reviews'] ?? [],
          'avg_rating': body['avg_rating'] ?? 0,
          'total_reviews': body['total_reviews'] ?? 0,
        };
      }
      return {'success': false, 'error': body['error'] ?? 'Unknown response'};
    } else {
      return {'success': false, 'error': 'Server error'};
    }
  }

  // ...other methods (e.g., submitReview) can go here...
}
