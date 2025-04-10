// lib/routes/route1.dart
import 'package:flutter/material.dart';

class Route1Screen extends StatelessWidget {
  const Route1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Route 1')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Back to Home'),
        ),
      ),
    );
  }
}
