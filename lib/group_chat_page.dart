import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class GroupChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupChatPage({required this.groupId, required this.groupName});

  @override
  _GroupChatPageState createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final user = FirebaseAuth.instance.currentUser;

  Future<void> _sendMessage(String message) async {
    await FirebaseFirestore.instance.collection('study_groups').doc(widget.groupId).collection('messages').add({
      'text': message,
      'senderId': user!.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    if (DateUtils.isSameDay(date, now)) return 'Today';
    if (DateUtils.isSameDay(date, now.subtract(Duration(days: 1)))) return 'Yesterday';
    return DateFormat.yMMMd().format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.groupName)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('study_groups')
                  .doc(widget.groupId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                final messages = snapshot.data!.docs;
                String? lastDateHeader;
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final senderId = msg['senderId'];
                    final isMe = senderId == user?.uid;
                    final timestamp = msg['timestamp']?.toDate() ?? DateTime.now();
                    final showHeader = index == 0 || _formatDateHeader(timestamp) != lastDateHeader;
                    lastDateHeader = _formatDateHeader(timestamp);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (showHeader)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _formatDateHeader(timestamp),
                                  style: TextStyle(color: Colors.black87, fontSize: 12),
                                ),
                              ),
                            ),
                          ),
                        Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.blueAccent : Colors.grey.shade300,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                                bottomLeft: Radius.circular(isMe ? 16 : 0),
                                bottomRight: Radius.circular(isMe ? 0 : 16),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                FutureBuilder<DocumentSnapshot>(
                                  future: FirebaseFirestore.instance.collection('users').doc(senderId).get(),
                                  builder: (context, userSnap) {
                                    if (!userSnap.hasData) return SizedBox.shrink();
                                    final username = userSnap.data!['username'] ?? 'User';
                                    return Text(
                                      username,
                                      style: TextStyle(fontSize: 11, color: Colors.black54),
                                    );
                                  },
                                ),
                                SizedBox(height: 4),
                                Text(
                                  msg['text'],
                                  style: TextStyle(color: isMe ? Colors.white : Colors.black87),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  DateFormat('hh:mm a').format(timestamp),
                                  style: TextStyle(fontSize: 10, color: isMe ? Colors.white70 : Colors.black54),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _messageController,
                    focusNode: _focusNode,
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    onFieldSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        _sendMessage(value.trim());
                        _messageController.clear();
                        _focusNode.requestFocus();
                      }
                    },
                    textInputAction: TextInputAction.newline,
                    keyboardType: TextInputType.multiline,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_messageController.text.trim().isNotEmpty) {
                      _sendMessage(_messageController.text.trim());
                      _messageController.clear();
                      _focusNode.requestFocus();
                    }
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}