import 'package:flutter/material.dart';
import '../../services/chat_service.dart';
import '../../widgets/chat/chat_list_tile.dart';
import '../../widgets/common/error_display_widget.dart';
import 'chat_conversation_screen.dart';

/// Chat list screen
/// Displays all conversations for the current user
class ChatListScreen extends StatefulWidget {
  final String currentUserEmail;
  final bool showAppBar;

  const ChatListScreen({
    super.key,
    required this.currentUserEmail,
    this.showAppBar = false,
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

    final result = await ChatService.getUserChats(widget.currentUserEmail);

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

  void _navigateToChat(String otherUserEmail) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatConversationScreen(
          currentUserEmail: widget.currentUserEmail,
          otherUserEmail: otherUserEmail,
          currentUserRole: "student", // Can be passed as parameter if needed
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text("Messages"),
              backgroundColor: const Color(0xFFFF9800),
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
                            'Start a conversation with a dorm owner!',
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
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 8),
                        itemCount: _chats.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final chat = _chats[index];
                          final otherUserEmail = chat['other_user_email'];
                          final lastMessage = chat['last_message'] ?? '';

                          return ChatListTile(
                            otherUserEmail: otherUserEmail,
                            lastMessage: lastMessage,
                            currentUserEmail: widget.currentUserEmail,
                            onTap: () => _navigateToChat(otherUserEmail),
                          );
                        },
                      ),
                    ),
    );
  }
}
