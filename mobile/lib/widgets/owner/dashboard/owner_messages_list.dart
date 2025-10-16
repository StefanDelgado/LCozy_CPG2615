import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../screens/shared/chat_conversation_screen.dart';

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
  List<Map<String, dynamic>> chats = [];
  final String apiBase = 'https://bradedsale.helioho.st/chat_api/chat_api.php';

  @override
  void initState() {
    super.initState();
    fetchChats();
  }

  Future<void> fetchChats() async {
    try {
      final response = await http.get(
        Uri.parse('$apiBase?action=get_user_chats&user_email=${widget.ownerEmail}'),
      );
      if (response.statusCode == 200) {
        setState(() {
          chats = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        });
      }
    } catch (e) {
      // Optionally handle error
    }
  }

  Future<String> fetchUserName(String email) async {
    final response = await http.get(
      Uri.parse('$apiBase?action=get_user_name&email=$email'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['name'] ?? email;
    }
    return email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Colors.orange,
      ),
      body: chats.isEmpty
          ? const Center(child: Text('No messages yet.'))
          : ListView.separated(
              itemCount: chats.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final chat = chats[index];
                final otherUserEmail = chat['other_user_email'];
                final lastMessage = chat['last_message'] ?? '';
                
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: FutureBuilder<String>(
                    future: fetchUserName(otherUserEmail),
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
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatConversationScreen(
                          currentUserEmail: widget.ownerEmail,
                          otherUserEmail: otherUserEmail,
                          currentUserRole: "owner",
                        ),
                      ),
                    ).then((_) => fetchChats()); // Refresh after returning
                  },
                );
              },
            ),
    );
  }
}
