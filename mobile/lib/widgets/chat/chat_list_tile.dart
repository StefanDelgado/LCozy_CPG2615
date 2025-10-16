import 'package:flutter/material.dart';
import '../../services/chat_service.dart';

/// Chat list tile widget
/// Displays a conversation preview in the chat list
class ChatListTile extends StatelessWidget {
  final String otherUserEmail;
  final String lastMessage;
  final String currentUserEmail;
  final VoidCallback onTap;

  const ChatListTile({
    super.key,
    required this.otherUserEmail,
    required this.lastMessage,
    required this.currentUserEmail,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Color(0xFFFF9800),
        child: Icon(Icons.person, color: Colors.white),
      ),
      title: FutureBuilder<String>(
        future: ChatService.getUserName(otherUserEmail),
        builder: (context, snapshot) {
          final displayName = snapshot.data ?? otherUserEmail;
          return Text(
            displayName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          );
        },
      ),
      subtitle: Text(
        lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey[600]),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
