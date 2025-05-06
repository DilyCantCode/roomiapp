// lib/routes/message_center.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class MessageCenterScreen extends StatefulWidget {
  const MessageCenterScreen({super.key});

  @override
  State<MessageCenterScreen> createState() => _MessageCenterScreenState();
}

class _MessageCenterScreenState extends State<MessageCenterScreen> {
  final TextEditingController _controller = TextEditingController();
  String? circleDocId; // This will hold the document ID once found

  @override
  void initState() {
    super.initState();
    _fetchCircleDocumentId();
  }

  Future<void> _fetchCircleDocumentId() async {
    final query = await FirebaseFirestore.instance
        .collection('circles')
        .where('name', isEqualTo: 'MessageTesting')
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      setState(() {
        circleDocId = query.docs.first.id;
      });
    } else {
      // Handle the case where the document wasn't found
      debugPrint("No circle with name 'MessageTesting' found.");
    }
  }

  void _sendMessage() async {
  final text = _controller.text.trim();
  final user = FirebaseAuth.instance.currentUser;

  if (text.isNotEmpty && circleDocId != null && user != null) {
    await FirebaseFirestore.instance
        .collection('circles')
        .doc(circleDocId)
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
    if (circleDocId == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Messages')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final messagesRef = FirebaseFirestore.instance
        .collection('circles')
        .doc(circleDocId)
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
                    final message = messages[index].data() as Map<String, dynamic>;
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
