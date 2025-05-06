import 'package:flutter/material.dart';
import 'package:roomi/routes/message_center.dart'; // Make sure this is the correct path

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
    return Scaffold(
      appBar: AppBar(title: Text(circleData['name'] ?? 'Circle')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to ${circleData['name']}!\nCircle ID: $circleId',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
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
          ],
        ),
      ),
    );
  }
}
