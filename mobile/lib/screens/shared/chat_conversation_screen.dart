import 'package:flutter/material.dart';
import '../../services/chat_service.dart';
import '../../widgets/chat/message_bubble.dart';
import '../../widgets/chat/message_input.dart';
import '../../widgets/common/error_display_widget.dart';

/// Chat conversation screen
/// Displays messages between two users
class ChatConversationScreen extends StatefulWidget {
  final String currentUserEmail;
  final String otherUserEmail;
  final String currentUserRole;

  const ChatConversationScreen({
    super.key,
    required this.currentUserEmail,
    required this.otherUserEmail,
    required this.currentUserRole,
  });

  @override
  State<ChatConversationScreen> createState() =>
      _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  List _messages = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final ScrollController _scrollController = ScrollController();

  String get _chatId {
    return ChatService.generateChatId(
      widget.currentUserEmail,
      widget.otherUserEmail,
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchMessages() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final result = await ChatService.getMessages(_chatId);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result['success'] == true) {
        _messages = result['messages'] ?? [];
        _scrollToBottom();
      } else {
        _errorMessage = result['error'] ?? 'Failed to load messages';
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final result = await ChatService.sendMessage(
      chatId: _chatId,
      senderId: widget.currentUserEmail,
      receiverId: widget.otherUserEmail,
      message: text,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      // Refresh messages after sending
      await _fetchMessages();
    } else {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Failed to send message'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: ChatService.getUserName(widget.otherUserEmail),
          builder: (context, snapshot) {
            final displayName = snapshot.data ?? widget.otherUserEmail;
            return Text(displayName);
          },
        ),
        backgroundColor: const Color(0xFFFF9800),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchMessages,
            tooltip: 'Refresh messages',
          ),
        ],
      ),
      backgroundColor: const Color(0xFFFDF6F0),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? ErrorDisplayWidget(
                        message: _errorMessage,
                        onRetry: _fetchMessages,
                      )
                    : _messages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No messages yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Start the conversation!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final msg = _messages[index];
                              final isMe = msg['sender_id'] ==
                                  widget.currentUserEmail;
                              final message = msg['message'] ?? '';

                              return MessageBubble(
                                message: message,
                                isMe: isMe,
                              );
                            },
                          ),
          ),

          // Message Input
          MessageInput(
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}
