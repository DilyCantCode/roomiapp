// lib/routes/create_circle.dart
import 'package:flutter/material.dart';

class CreateCircleScreen extends StatelessWidget {
  const CreateCircleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('create circle')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Back to Home'),
        ),
      ),
    );
  }
}
