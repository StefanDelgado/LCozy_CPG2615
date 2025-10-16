import 'package:flutter/material.dart';

/// Message bubble widget
/// Displays an individual message with sender-based styling
class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final DateTime? timestamp;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFFF9800) : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
