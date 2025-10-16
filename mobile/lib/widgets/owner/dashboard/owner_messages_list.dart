import 'package:flutter/material.dart';
import '../../../screens/shared/chat_list_screen.dart';

class OwnerMessagesList extends StatefulWidget {
  final String ownerEmail;

  const OwnerMessagesList({
    super.key,
    required this.ownerEmail,
  });

  @override
  State<OwnerMessagesList> createState() => _OwnerMessagesListState();
}

class _OwnerMessagesListState extends State<OwnerMessagesList> {
  @override
  Widget build(BuildContext context) {
    // Simply navigate to the shared ChatListScreen
    return ChatListScreen(
      currentUserEmail: widget.ownerEmail,
      currentUserRole: 'owner',
      showAppBar: true,
    );
  }
}
