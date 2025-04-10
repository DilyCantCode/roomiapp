// lib/routes/route4.dart
import 'package:flutter/material.dart';

class Route4Screen extends StatelessWidget {
  const Route4Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Route 4')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Back to Home'),
        ),
      ),
    );
  }
}
