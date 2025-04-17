// lib/routes/create_circle.dart
import 'package:flutter/material.dart';

class CreateCircleScreen extends StatelessWidget {
  const CreateCircleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create a New Circle')),
      body: Center(
        child: Column(
         // mainAxisAlignment: MainAxisAlignment.,
          children: <Widget>[
          const Text('Circle Name'),
          const SizedBox(height: 25),
          const SizedBox(width: 250, child: TextField(
                
                decoration: InputDecoration(
                  labelText: 'Enter your new Circle Name',
                  border: OutlineInputBorder(),
                ),
              ),
              ),
              const SizedBox(height: 25),
          ElevatedButton(
              child: const Text('Copy Invite Link'),
              onPressed: () {
                    //need a link to send to friends?
              }
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              child: const Text('Create Circle'),
              onPressed: () {
                  
              }
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
