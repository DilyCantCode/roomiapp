import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final currentUser = FirebaseAuth.instance.currentUser;

  if (circleName.isEmpty || currentUser == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter a circle name or log in')),
    );
    return;
  }

  try {
    // 
    await FirebaseFirestore.instance.collection('circles').add({
      'name': circleName,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': currentUser.uid,
      'members': [currentUser.uid],
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Circle created successfully!')),
    );
    Navigator.pop(context);
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