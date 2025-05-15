import 'package:flutter/material.dart';
import 'package:roomi/routes/message_center.dart'; 

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
            if (circleData['location'] != null && circleData['location'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Location: ${circleData['location']}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                ),
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
