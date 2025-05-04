import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateCircleScreen extends StatefulWidget {
  const CreateCircleScreen({super.key});

  @override
  State<CreateCircleScreen> createState() => _CreateCircleScreenState();
}

class _CreateCircleScreenState extends State<CreateCircleScreen> {
  final TextEditingController _circleNameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _createCircle() async {
    final circleName = _circleNameController.text.trim();

    if (circleName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a circle name')),
      );
      return;
    }

    try {
      await _firestore.collection('circles').add({
        'name': circleName,
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Circle created successfully!')),
      );

      Navigator.pop(context); // Go back to home screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating circle: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create a New Circle')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Circle Name'),
            const SizedBox(height: 25),
            SizedBox(
              width: 250,
              child: TextField(
                controller: _circleNameController,
                decoration: const InputDecoration(
                  labelText: 'Enter your new Circle Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              child: const Text('Create Circle'),
              onPressed: _createCircle,
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}