// lib/routes/lease.dart
import 'package:flutter/material.dart';

class LeaseScreen extends StatelessWidget {
  const LeaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lease')),
      body: Center(
        child: Column(
         // mainAxisAlignment: MainAxisAlignment.,
          children: <Widget>[
          const Text('Upload your lease'),
          const SizedBox(height: 25),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Upload PDF'),
        ),
        const SizedBox(height: 25),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Back to Home'),
        ),


          ]
        )
      ),
    );
  }
}
