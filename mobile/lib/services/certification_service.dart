import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/api_constants.dart';

class CertificationService {
  /// Upload a certification file for a dorm
  Future<Map<String, dynamic>> uploadCertification({
    required int dormId,
    required String ownerEmail,
    required File certificationFile,
    String? certificationType,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/modules/mobile-api/dorms/upload_certification.php');
      
      var request = http.MultipartRequest('POST', uri);
      
      // Add form fields
      request.fields['dorm_id'] = dormId.toString();
      request.fields['owner_email'] = ownerEmail;
      if (certificationType != null && certificationType.isNotEmpty) {
        request.fields['certification_type'] = certificationType;
      }
      
      // Add file
      request.files.add(
        await http.MultipartFile.fromPath(
          'certification_file',
          certificationFile.path,
        ),
      );
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('[CertificationService] Upload response: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        return {
          'success': false,
          'error': 'Server returned ${response.statusCode}',
        };
      }
    } catch (e) {
      print('[CertificationService] Upload error: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Get all certifications for a dorm
  Future<Map<String, dynamic>> getCertifications(int dormId) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/modules/mobile-api/dorms/get_certifications.php?dorm_id=$dormId'
      );
      
      final response = await http.get(uri);
      
      print('[CertificationService] Get certifications response: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        return {
          'success': false,
          'error': 'Server returned ${response.statusCode}',
        };
      }
    } catch (e) {
      print('[CertificationService] Get certifications error: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Delete a certification
  Future<Map<String, dynamic>> deleteCertification({
    required int certificationId,
    required String ownerEmail,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/modules/mobile-api/dorms/delete_certification.php'
      );
      
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'certification_id': certificationId,
          'owner_email': ownerEmail,
        }),
      );
      
      print('[CertificationService] Delete response: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        return {
          'success': false,
          'error': 'Server returned ${response.statusCode}',
        };
      }
    } catch (e) {
      print('[CertificationService] Delete error: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Get certification file URL
  String getCertificationUrl(String filePath) {
    return '${ApiConstants.baseUrl}/$filePath';
  }
}
