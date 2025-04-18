import 'package:flutter/material.dart';
import 'routes/create_circle.dart';
import 'routes/bills.dart';
import 'routes/settings.dart';
import 'routes/lease.dart';
import 'routes/message_center.dart';
import 'routes/route6.dart';
import 'login.dart';

void main() {
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
        '/route6': (context) => const Route6Screen(),
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

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'click to go to area',
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              child: const Text('Create a circle'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder:
                 (context) => const CreateCircleScreen()),
                );
              }
            ),
            const SizedBox(height: 50),
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
            const SizedBox(height: 50), 


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
            const SizedBox(height: 50), 


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
              const SizedBox(height: 50), 


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
      ),
    );
  }
}
