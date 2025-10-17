import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';
import '../../services/chat_service.dart';
import '../../widgets/common/error_display_widget.dart';
import 'chat_conversation_screen.dart';

/// Chat list screen
/// Displays all conversations for the current user
class ChatListScreen extends StatefulWidget {
  final String currentUserEmail;
  final String currentUserRole; // 'student' or 'owner'
  final bool showAppBar;

  const ChatListScreen({
    super.key,
    required this.currentUserEmail,
    required this.currentUserRole,
    this.showAppBar = true,
  });

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List _chats = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchChats();
  }

  Future<void> _fetchChats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final result = await ChatService.getUserChats(
      widget.currentUserEmail,
      widget.currentUserRole,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result['success'] == true) {
        _chats = result['chats'] ?? [];
      } else {
        _errorMessage = result['error'] ?? 'Failed to load chats';
      }
    });
  }

  void _navigateToChat(Map<String, dynamic> chat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatConversationScreen(
          currentUserEmail: widget.currentUserEmail,
          currentUserRole: widget.currentUserRole,
          otherUserId: chat['other_user_id'],
          otherUserName: chat['other_user_name'],
          otherUserEmail: chat['other_user_email'],
          dormId: chat['dorm_id'],
          dormName: chat['dorm_name'],
        ),
      ),
    ).then((_) => _fetchChats()); // Refresh when returning
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text("Messages"),
              backgroundColor: AppTheme.primary,
            )
          : null,
      backgroundColor: const Color(0xFFF9F6FB),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? ErrorDisplayWidget(
                  message: _errorMessage,
                  onRetry: _fetchChats,
                )
              : _chats.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No messages yet.',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.currentUserRole == 'student'
                                ? 'Start a conversation with a dorm owner!'
                                : 'Students will message you about bookings.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchChats,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _chats.length,
                        itemBuilder: (context, index) {
                          final chat = _chats[index];
                          final unreadCount = chat['unread_count'] ?? 0;
                          final hasUnread = unreadCount > 0;

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.primary,
                                child: Text(
                                  chat['other_user_name']
                                          ?.substring(0, 1)
                                          .toUpperCase() ??
                                      '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      chat['other_user_name'] ?? 'Unknown',
                                      style: TextStyle(
                                        fontWeight: hasUnread
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  if (hasUnread)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '$unreadCount',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    chat['dorm_name'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    chat['last_message'] ?? 'No messages yet',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: hasUnread
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => _navigateToChat(chat),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
