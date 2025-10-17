import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';
import 'package:http/http.dart' as http;

// ==================== StudentChatListScreen Widget ====================
class StudentChatListScreen extends StatefulWidget {
  final String currentUserEmail;
  final bool showAppBar;
  const StudentChatListScreen({
    super.key,
    required this.currentUserEmail,
    this.showAppBar = false,
  });

  @override
  State<StudentChatListScreen> createState() => _StudentChatListScreenState();
}

// ==================== StudentChatListScreen State ====================
class _StudentChatListScreenState extends State<StudentChatListScreen> {
  List chats = [];
  final String apiBase = 'https://bradedsale.helioho.st/chat_api/chat_api.php';

  @override
  void initState() {
    super.initState();
    fetchChats();
  }

  // ----------- FETCH CHATS SECTION -----------
  Future<void> fetchChats() async {
    try {
      final response = await http.get(
        Uri.parse('$apiBase?action=get_user_chats&user_email=${widget.currentUserEmail}'),
      );
      if (response.statusCode == 200) {
        setState(() {
          chats = jsonDecode(response.body);
        });
      }
    } catch (e) {}
  }

  // ----------- FETCH USER NAME SECTION -----------
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
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text("Messages"),
              backgroundColor: AppTheme.primary,
            )
          : null,
      backgroundColor: const Color(0xFFF9F6FB),
      body: chats.isEmpty
          ? Center(
              child: Text(
                'No messages yet.',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              itemCount: chats.length,
              separatorBuilder: (_, __) => const SizedBox(height: 2),
              itemBuilder: (context, index) {
                final chat = chats[index];
                final otherUserEmail = chat['other_user_email'];
                final lastMessage = chat['last_message'] ?? '';
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primary,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: FutureBuilder<String>(
                    future: fetchUserName(otherUserEmail),
                    builder: (context, snapshot) {
                      final displayName = snapshot.data ?? otherUserEmail;
                      return Text(displayName, style: TextStyle(fontWeight: FontWeight.bold));
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
                        builder: (_) => StudentOwnerChatScreen(
                          currentUserEmail: widget.currentUserEmail,
                          otherUserEmail: otherUserEmail,
                          currentUserRole: "student",
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

// ==================== StudentOwnerChatScreen Widget ====================
class StudentOwnerChatScreen extends StatefulWidget {
  final String currentUserEmail;
  final String otherUserEmail;
  final String currentUserRole;

  const StudentOwnerChatScreen({
    super.key,
    required this.currentUserEmail,
    required this.otherUserEmail,
    required this.currentUserRole,
  });

  @override
  State<StudentOwnerChatScreen> createState() => _StudentOwnerChatScreenState();
}

// ==================== StudentOwnerChatScreen State ====================
class _StudentOwnerChatScreenState extends State<StudentOwnerChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List messages = [];
  final String apiBase = 'https://bradedsale.helioho.st/chat_api/chat_api.php';

  String get chatId {
    final emails = [widget.currentUserEmail, widget.otherUserEmail]..sort();
    return '${emails[0]}_${emails[1]}';
  }

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  // ----------- FETCH MESSAGES SECTION -----------
  Future<void> fetchMessages() async {
    try {
      final response = await http.get(
        Uri.parse('$apiBase?action=get_messages&chat_id=$chatId'),
      );
      if (response.statusCode == 200) {
        setState(() {
          messages = jsonDecode(response.body);
        });
      }
    } catch (e) {}
  }

  // ----------- SEND MESSAGE SECTION -----------
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    try {
      await http.post(
        Uri.parse('$apiBase?action=send_message'),
        body: {
          'chat_id': chatId,
          'sender_id': widget.currentUserEmail,
          'receiver_id': widget.otherUserEmail,
          'message': text,
        },
      );
      _controller.clear();
      fetchMessages();
    } catch (e) {}
  }

  // ----------- FETCH USER NAME SECTION -----------
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
        title: FutureBuilder<String>(
          future: fetchUserName(widget.otherUserEmail),
          builder: (context, snapshot) {
            final displayName = snapshot.data ?? widget.otherUserEmail;
            return Text(displayName);
          },
        ),
        backgroundColor: AppTheme.primary,
      ),
      body: Column(
        children: [
          // ----------- MESSAGES LIST SECTION -----------
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: messages.map<Widget>((msg) {
                final isMe = msg['sender_id'] == widget.currentUserEmail;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isMe ? AppTheme.primary : Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      msg['message'],
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black87,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // ----------- MESSAGE INPUT SECTION -----------
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppTheme.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      if (_controller.text.trim().isNotEmpty) {
                        sendMessage(_controller.text.trim());
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFFDF6F0),
    );
  }
}