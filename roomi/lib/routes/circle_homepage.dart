import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:roomi/routes/message_center.dart';
import 'package:roomi/services/circle_service.dart';

class CircleHomepageScreen extends StatelessWidget {
  final String circleId;
  final Map<String, dynamic> circleData;

  const CircleHomepageScreen({
    super.key,
    required this.circleId,
    required this.circleData,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final circleService = CircleService();

    return Scaffold(
      appBar: AppBar(title: Text(circleData['name'] ?? 'Circle')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Welcome to ${circleData['name']}!\nCircle ID: $circleId',
              textAlign: TextAlign.center,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MessageCenterScreen(circleId: circleId),
                ),
              );
            },
            child: const Text('Message Center'),
          ),
          const SizedBox(height: 20),
          const Text('Members:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(
            child: ListView.builder(
              itemCount: (circleData['members'] as List<dynamic>).length,
              itemBuilder: (context, index) {
                final memberUid = circleData['members'][index];
                return ListTile(
                  title: Text(memberUid),
                  trailing: (circleData['createdBy'] == currentUser?.uid &&
                          memberUid != currentUser?.uid)
                      ? IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () async {
                            try {
                              await circleService.kickMember(circleId, memberUid);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Member removed')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          },
                        )
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
