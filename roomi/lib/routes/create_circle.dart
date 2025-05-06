import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart'; 
import 'dart:math';

class CreateCircleScreen extends StatefulWidget {
  const CreateCircleScreen({super.key});

  @override
  State<CreateCircleScreen> createState() => _CreateCircleScreenState();
}

class _CreateCircleScreenState extends State<CreateCircleScreen> {
  final TextEditingController _circleNameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _generatedInviteCode;
  bool _isCreating = false;

  @override
  void dispose() {
    _circleNameController.dispose();
    super.dispose();
  }

  Future<void> _createCircle() async {
    final circleName = _circleNameController.text.trim();
    final currentUser = FirebaseAuth.instance.currentUser;

    if (circleName.isEmpty || currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a circle name or log in')),
      );
      return;
    }

    setState(() => _isCreating = true);
    
    try {
      // Create the circle
      final circleRef = await _firestore.collection('circles').add({
        'name': circleName,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': currentUser.uid,
        'members': [currentUser.uid],
      });

      // Generate an invite code
      final inviteCode = await _generateInviteCode(circleRef.id);
      
      setState(() => _generatedInviteCode = inviteCode);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Circle created successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating circle: $e')),
      );
    } finally {
      setState(() => _isCreating = false);
    }
  }

  Future<String> _generateInviteCode(String circleId) async {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final code = List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
    
    await _firestore
  .collection('circles')
  .doc(circleId)
  .collection('inviteCodes')
  .doc(code)
  .set({
    'code': code, 
    'createdAt': FieldValue.serverTimestamp(),
    'createdBy': FirebaseAuth.instance.currentUser!.uid,
  });

    
    return code;
  }

  Future<void> _copyInviteCode() async {
    if (_generatedInviteCode == null) return;
    await Clipboard.setData(ClipboardData(text: _generatedInviteCode!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invite code copied to clipboard!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create a New Circle')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_generatedInviteCode == null) ...[
                const Text(
                  'Create Your Circle',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _circleNameController,
                  decoration: const InputDecoration(
                    labelText: 'Circle Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.group),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  icon: _isCreating 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Icon(Icons.create),
                  label: Text(_isCreating ? 'Creating...' : 'Create Circle'),
                  onPressed: _isCreating ? null : _createCircle,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ] else ...[
                const Icon(Icons.check_circle, color: Colors.green, size: 80),
                const SizedBox(height: 20),
                const Text(
                  'Circle Created!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Share this invite code with others:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: _copyInviteCode,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Text(
                      _generatedInviteCode!,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _copyInviteCode,
                  child: const Text('Tap to copy'),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Done', style: TextStyle(color: Colors.white)),
                ),
              ],
              const SizedBox(height: 20),
              if (_generatedInviteCode == null)
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}