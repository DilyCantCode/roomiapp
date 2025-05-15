import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'pick_location_screen.dart';

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
  String? _selectedAddress;

  @override
  void dispose() {
    _circleNameController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled.')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      final pos = await Geolocator.getCurrentPosition();
      final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        setState(() {
          _selectedAddress = '${p.street}, ${p.locality}, ${p.administrativeArea}, ${p.country}';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  Future<void> _pickLocationOnMap() async {
    final pickedAddress = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const PickLocationScreen()),
    );

    if (pickedAddress != null) {
      setState(() {
        _selectedAddress = pickedAddress;
      });
    }
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
      final existing = await _firestore
          .collection('circles')
          .where('createdBy', isEqualTo: currentUser.uid)
          .where('name', isEqualTo: circleName)
          .get();

      if (existing.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You already have a circle with this name.')),
        );
        setState(() => _isCreating = false);
        return;
      }

      final circleRef = await _firestore.collection('circles').add({
        'name': circleName,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': currentUser.uid,
        'members': [currentUser.uid],
        'lastActivity': FieldValue.serverTimestamp(),
        'location': _selectedAddress ?? '',
      });

      final inviteCode = await _generateUniqueInviteCode(circleRef.id);
      print('New invite code generated: $inviteCode');
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

  Future<String> _generateUniqueInviteCode(String circleId) async {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    String code;
    DocumentSnapshot snapshot;

    do {
      code = List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
      snapshot = await _firestore
          .collection('circles')
          .doc(circleId)
          .collection('inviteCodes')
          .doc(code)
          .get();
    } while (snapshot.exists);

    await _firestore
        .collection('circles')
        .doc(circleId)
        .collection('inviteCodes')
        .doc(code)
        .set({
      'code': code,
      'circleId': circleId,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': FirebaseAuth.instance.currentUser!.uid,
      'maxUses': 9999999,
      'uses': 0,
      'expiresAt': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
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
                const SizedBox(height: 20),
                if (_selectedAddress != null) ...[
                  Text('Selected Location:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(_selectedAddress!),
                  const SizedBox(height: 10),
                ],
                ElevatedButton.icon(
                  icon: const Icon(Icons.my_location),
                  label: const Text('Use Current Location'),
                  onPressed: _getCurrentLocation,
                  style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.map),
                  label: const Text('Pick on Map'),
                  onPressed: _pickLocationOnMap,
                  style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  icon: _isCreating
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
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