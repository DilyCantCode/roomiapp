import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CircleScreen extends StatelessWidget {
  const CircleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('You must be logged in to view circles')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Your Circles')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('circles')
            .where('members', arrayContains: currentUser.uid) // ✅ filter by current user
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final circles = snapshot.data!.docs;

          if (circles.isEmpty) {
            return const Center(child: Text('No circles found.'));
          }

          return ListView.builder(
            itemCount: circles.length,
            itemBuilder: (context, index) {
              final data = circles[index].data() as Map<String, dynamic>;
              final name = data['name'] ?? 'Unnamed Circle';
              final createdAt = data['createdAt']?.toDate().toString() ?? 'Unknown time';

              return ListTile(
                title: Text(name),
                subtitle: Text('Created at: $createdAt'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        child: const Icon(Icons.home),
      ),
    );
  }
}
