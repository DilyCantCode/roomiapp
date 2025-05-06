import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessageCenterScreen extends StatefulWidget {
  final String circleId;

  const MessageCenterScreen({super.key, required this.circleId});

  @override
  State<MessageCenterScreen> createState() => _MessageCenterScreenState();
}

class _MessageCenterScreenState extends State<MessageCenterScreen> {
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() async {
    final text = _controller.text.trim();
    final user = FirebaseAuth.instance.currentUser;

    if (text.isNotEmpty && user != null) {
      await FirebaseFirestore.instance
          .collection('circles')
          .doc(widget.circleId)
          .collection('messages')
          .add({
        'text': text,
        'username': user.email ?? 'unknown',
        'timestamp': FieldValue.serverTimestamp(),
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesRef = FirebaseFirestore.instance
        .collection('circles')
        .doc(widget.circleId)
        .collection('messages')
        .orderBy('timestamp', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messagesRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message =
                        messages[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(
                        message['username'] ?? 'unknown',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      subtitle: Text(
                        message['text'] ?? '',
                        style: const TextStyle(fontSize: 16),
                      ),
                      trailing: Text(
                        message['timestamp']?.toDate().toString() ?? '',
                        style: const TextStyle(fontSize: 8, color: Colors.grey),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
