import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:roomi/routes/join_circle.dart';
import 'firebase_options.dart';

import 'routes/create_circle.dart';
import 'routes/bills.dart';
import 'routes/settings.dart';
import 'routes/lease.dart';
//import 'routes/message_center.dart';
import 'routes/circle.dart';
import 'login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, 
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roomi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(), // ✅ Start at login
      routes: {
        '/home': (context) => const MyHomePage(title: 'Roomi App :)'),
        '/create_circle': (context) => const CreateCircleScreen(),
        '/bills': (context) => const BillsScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/route4': (context) => const LeaseScreen(),
       // '/message_center': (context) => const MessageCenterScreen(),
        '/circle': (context) => const CircleScreen(),
        '/join_circle': (context) => const JoinCircleScreen(),

      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<void> addTestCircle() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    await FirebaseFirestore.instance.collection('circles').add({
      'name': 'Test Circle',
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': currentUser.uid,
      'members': [currentUser.uid],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Left Column
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  child: const Text('Create a circle'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CreateCircleScreen()),
                    );
                  },
                ),
                ElevatedButton(
                  child: const Text('View Monthly Bills'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BillsScreen()),
                    );
                  },
                ),
                ElevatedButton(
                  child: const Text('Settings'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(width: 40),
            // Right Column
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  child: const Text('Lease'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LeaseScreen()),
                    );
                  },
                ),
            /*    ElevatedButton(
                  child: const Text('Message Center'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MessageCenterScreen()),
                    );
                  },
                ),*/
                ElevatedButton(
                  child: const Text('Circle'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CircleScreen()),
                    );
                  },
                ),
                ElevatedButton(
                  child: const Text('Join a Circle'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const JoinCircleScreen()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
