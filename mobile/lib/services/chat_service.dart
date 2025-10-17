import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

/// Chat service for messaging functionality
/// Handles conversations and messages between students and owners
class ChatService {
  static const String _conversationsEndpoint = 
      '${ApiConstants.baseUrl}/modules/mobile-api/messaging/conversation_api.php';
  static const String _messagesEndpoint = 
      '${ApiConstants.baseUrl}/modules/mobile-api/messaging/messages_api.php';
  static const String _sendMessageEndpoint = 
      '${ApiConstants.baseUrl}/modules/mobile-api/messaging/send_message_api.php';

  /// Get all conversations for a user (student or owner)
  /// Returns list of conversations with last message and unread count
  static Future<Map<String, dynamic>> getUserChats(
    String userEmail, 
    String userRole,
  ) async {
    try {
      print('💬 [Chat] Fetching conversations for: $userEmail ($userRole)');
      final response = await http.get(
        Uri.parse('$_conversationsEndpoint?user_email=${Uri.encodeComponent(userEmail)}&user_role=$userRole'),
      );

      print('💬 [Chat] Response status: ${response.statusCode}');
      print('💬 [Chat] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          return {
            'success': true,
            'chats': data['conversations'] ?? [],
          };
        } else {
          return {
            'success': false,
            'error': data['error'] ?? 'Failed to load conversations',
          };
        }
      } else {
        return {
          'success': false,
          'error': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('💬 [Chat] Error: $e');
      return {
        'success': false,
        'error': 'Network error. Please try again.',
      };
    }
  }

  /// Get messages for a specific conversation
  /// Returns list of messages ordered by timestamp
  static Future<Map<String, dynamic>> getMessages(
    String userEmail,
    int dormId,
    int otherUserId,
  ) async {
    try {
      print('💬 [Chat] Fetching messages for dorm: $dormId with user: $otherUserId');
      final response = await http.get(
        Uri.parse(
          '$_messagesEndpoint?user_email=${Uri.encodeComponent(userEmail)}&dorm_id=$dormId&other_user_id=$otherUserId',
        ),
      );

      print('💬 [Chat] Messages response: ${response.statusCode}');
      print('💬 [Chat] Messages body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          return {
            'success': true,
            'messages': data['messages'] ?? [],
          };
        } else {
          return {
            'success': false,
            'error': data['error'] ?? 'Failed to load messages',
          };
        }
      } else {
        return {
          'success': false,
          'error': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('💬 [Chat] Error: $e');
      return {
        'success': false,
        'error': 'Network error. Please try again.',
      };
    }
  }

  /// Send a message in a conversation
  /// Returns success status and the created message
  static Future<Map<String, dynamic>> sendMessage({
    required String senderEmail,
    required int receiverId,
    required int dormId,
    required String message,
  }) async {
    if (message.trim().isEmpty) {
      return {
        'success': false,
        'error': 'Message cannot be empty',
      };
    }

    try {
      print('💬 [Chat] Sending message from $senderEmail to user $receiverId');
      final response = await http.post(
        Uri.parse(_sendMessageEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sender_email': senderEmail,
          'receiver_id': receiverId,
          'dorm_id': dormId,
          'message': message.trim(),
        }),
      );

      print('💬 [Chat] Send response: ${response.statusCode}');
      print('💬 [Chat] Send body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          return {
            'success': true,
            'message_data': data['data'],
          };
        } else {
          return {
            'success': false,
            'error': data['error'] ?? 'Failed to send message',
          };
        }
      } else {
        return {
          'success': false,
          'error': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('💬 [Chat] Error: $e');
      return {
        'success': false,
        'error': 'Network error. Please try again.',
      };
    }
  }

  /// Get user's display name by email (deprecated - using data from conversation API now)
  /// Returns the user's name or email if not found
  static Future<String> getUserName(String email) async {
    // This method is kept for backwards compatibility
    // The conversation API now returns user names directly
    return email;
  }

  /// Generate chat ID from two email addresses (deprecated - using dorm-based conversations now)
  /// Always returns same ID regardless of email order
  static String generateChatId(String email1, String email2) {
    final emails = [email1, email2]..sort();
    return '${emails[0]}_${emails[1]}';
  }
}
