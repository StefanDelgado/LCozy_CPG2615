  Future<Map<String, dynamic>> getDormReviews(int dormId) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/modules/mobile-api/reviews/fetch_reviews_api.php?dorm_id=$dormId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {'success': false, 'error': 'Server error'};
    }
  }

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ReviewService {
import '../utils/constants.dart';
}
