import 'dart:convert';
import 'package:http/http.dart' as http;

/// Chat service for messaging functionality
/// Handles conversations and messages between students and owners
class ChatService {
  static const String _apiBase =
      'https://bradedsale.helioho.st/chat_api/chat_api.php';

  /// Get all chats for a user
  /// Returns list of conversations with last message
  static Future<Map<String, dynamic>> getUserChats(String userEmail) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBase?action=get_user_chats&user_email=$userEmail'),
      );

      if (response.statusCode == 200) {
        final List chats = jsonDecode(response.body);
        return {
          'success': true,
          'chats': chats,
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to load chats',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error. Please try again.',
      };
    }
  }

  /// Get messages for a specific chat
  /// Returns list of messages ordered by timestamp
  static Future<Map<String, dynamic>> getMessages(String chatId) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBase?action=get_messages&chat_id=$chatId'),
      );

      if (response.statusCode == 200) {
        final List messages = jsonDecode(response.body);
        return {
          'success': true,
          'messages': messages,
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to load messages',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error. Please try again.',
      };
    }
  }

  /// Send a message in a chat
  /// Returns success status
  static Future<Map<String, dynamic>> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String message,
  }) async {
    if (message.trim().isEmpty) {
      return {
        'success': false,
        'error': 'Message cannot be empty',
      };
    }

    try {
      final response = await http.post(
        Uri.parse('$_apiBase?action=send_message'),
        body: {
          'chat_id': chatId,
          'sender_id': senderId,
          'receiver_id': receiverId,
          'message': message.trim(),
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to send message',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error. Please try again.',
      };
    }
  }

  /// Get user's display name by email
  /// Returns the user's name or email if not found
  static Future<String> getUserName(String email) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBase?action=get_user_name&email=$email'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['name'] ?? email;
      }
    } catch (e) {
      // Return email if fetch fails
    }
    return email;
  }

  /// Generate chat ID from two email addresses
  /// Always returns same ID regardless of email order
  static String generateChatId(String email1, String email2) {
    final emails = [email1, email2]..sort();
    return '${emails[0]}_${emails[1]}';
  }
}
