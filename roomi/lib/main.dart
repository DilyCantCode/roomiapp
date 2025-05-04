import 'package:flutter/material.dart';
import 'routes/create_circle.dart';
import 'routes/bills.dart';
import 'routes/settings.dart';
import 'routes/lease.dart';
import 'routes/message_center.dart';
import 'routes/circle.dart';
import 'login.dart';
import 'package:firebase_core/firebase_core.dart'; // we add firebase 
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // initialize firebase
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
      // Set LoginScreen as the home
      home: const LoginScreen(),
      routes: {
        '/home': (context) => const MyHomePage(title: 'Roomi App :)'),
        '/create_circle': (context) => const CreateCircleScreen(),
        '/bills': (context) => const BillsScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/route4': (context) => const LeaseScreen(),
        '/message_center': (context) => const MessageCenterScreen(),
        '/circle': (context) => const CircleScreen(),
      },
    );
  }
}
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  Future<void> addTestCircle() async {
    await FirebaseFirestore.instance.collection('circles').add({
     'name': 'Test Circle',
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<void> addTestCircle() async {
   await FirebaseFirestore.instance.collection('circles').add({
    'name': 'Test Circle',
    'created_at': FieldValue.serverTimestamp(),
    });
  }
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      // First column
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
      const SizedBox(width: 40), // Space between columns
      // Second column
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
          ElevatedButton(
            child: const Text('Message Center'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MessageCenterScreen()),
              );
            },
          ),
          ElevatedButton(
            child: const Text('Circle'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CircleScreen()),
              );
            },
          ),
        ],
      ),
    ],
  ),
),

    /*  body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'click to go to area',
            ),
           // const SizedBox(height: 50),
            ElevatedButton(
              child: const Text('Add Test Circle to Firestore'),
              onPressed: () {
                addTestCircle(); // this will insert the dummy circle into Firestore
              },
            ),
          //  const SizedBox(height: 50),
              ElevatedButton(
              child: const Text('View Monthly Bills'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder:
                 (context) => const BillsScreen()),
                );
              }
            ),
          //  const SizedBox(height: 50), 


              ElevatedButton(
              child: const Text('Settings'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder:
                 (context) => const SettingsScreen()),
                );
              }
            ),
          //  const SizedBox(height: 50), 


             ElevatedButton(
              child: const Text('Lease'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder:
                 (context) => const LeaseScreen()),
                );
              }
              ),
         //     const SizedBox(height: 50), 


              ElevatedButton(
              child: const Text('message center'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder:
                 (context) => const MessageCenterScreen()),
                );
              }
              ),
  
          ],
        ),
      ),*/
    );
  }
}
