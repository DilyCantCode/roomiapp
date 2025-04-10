// lib/routes/route6.dart
import 'package:flutter/material.dart';

class Route6Screen extends StatelessWidget {
  const Route6Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Route 6')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Back to Home'),
        ),
      ),
    );
  }
}
