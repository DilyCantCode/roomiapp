import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class CircleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Create a new circle
  Future<String> createCircle(String name) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('Not authenticated');

    final docRef = await _firestore.collection('circles').add({
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': currentUser.uid,
      'members': [currentUser.uid],
      'lastActivity': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  //Join circle with invite code
 Future<Map<String, String>> joinCircleWithCode(String code) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) throw Exception('User not authenticated');

  try {
    final normalizedCode = code.trim().toUpperCase();
    if (normalizedCode.length != 6) {
      throw Exception('Invite code must be exactly 6 characters');
    }
    print('Normalized Code: $normalizedCode');

    final query = await FirebaseFirestore.instance
        .collectionGroup('inviteCodes')
        .where('code', isEqualTo: normalizedCode)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('Invalid invite code');
    }

    final codeDoc = query.docs.first;
    final codeData = codeDoc.data();
    final circleRef = codeDoc.reference.parent.parent;

    if (circleRef == null) throw Exception('Circle reference not found');

    final uses = codeData['uses'] ?? 0;
    final maxUses = codeData['maxUses'] ?? 0;
    if (uses >= maxUses) throw Exception('This code has reached its maximum uses');

    final expiresAtStr = codeData['expiresAt'];
    if (expiresAtStr is String) {
      final expiresAt = DateTime.tryParse(expiresAtStr);
      if (expiresAt == null || expiresAt.isBefore(DateTime.now())) {
        throw Exception('This code has expired');
      }
    } else {
      throw Exception('Invalid expiration format');
    }

    final circleSnap = await circleRef.get();
    if (!circleSnap.exists) throw Exception('Circle not found');

    final members = List<String>.from(circleSnap.data()?['members'] ?? []);
    if (members.contains(currentUser.uid)) {
      throw Exception('You are already a member of this circle');
    }

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(codeDoc.reference, {
        'uses': FieldValue.increment(1),
      });

      transaction.update(circleRef, {
        'members': FieldValue.arrayUnion([currentUser.uid]),
      });

      final logRef = codeDoc.reference.collection('logs').doc(currentUser.uid);
      transaction.set(logRef, {
        'joinedAt': FieldValue.serverTimestamp(),
      });
    });

    return {
      'circleId': circleRef.id,
      'name': circleSnap.data()?['name'] ?? 'Unnamed Circle',
    };

  } on FirebaseException catch (e) {
    // This will show up in Android Studio logcat / debug console
    print('Firestore error caught: $e');
    throw Exception('Firestore error: ${e.message}');
  } catch (e) {
    print('General join error: $e');
    throw Exception('Join circle failed: $e');
  }
}


  // Generate invite code for a circle
  Future<String> generateInviteCode(String circleId) async {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final code = List.generate(6, (index) => chars[Random().nextInt(chars.length)]).join();

    await _firestore
        .collection('circles')
        .doc(circleId)
        .collection('inviteCodes')
        .doc(code)
        .set({
          'code': code, 
          'createdAt': FieldValue.serverTimestamp(),
          'createdBy': FirebaseAuth.instance.currentUser!.uid,
          'expiresAt': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
          'maxUses': 9999999, // unlimited uses cause it was causing issues LOL
          'uses': 0,
        });

    return code;
  }

  // Get stream of user's circles
  Stream<QuerySnapshot> getUserCircles(String userId) {
    return _firestore
        .collection('circles')
        .where('members', arrayContains: userId)
        .orderBy('lastActivity', descending: true)
        .snapshots();
  }

  // Send message to circle
  Future<void> sendMessage(String circleId, String text) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('Not authenticated');

    await _firestore
        .collection('circles')
        .doc(circleId)
        .collection('messages')
        .add({
          'text': text,
          'senderId': currentUser.uid,
          'timestamp': FieldValue.serverTimestamp(),
        });

    // Update last activity
    await _firestore
        .collection('circles')
        .doc(circleId)
        .update({'lastActivity': FieldValue.serverTimestamp()});
  }

  // Get circle messages stream
  Stream<QuerySnapshot> getMessages(String circleId) {
    return _firestore
        .collection('circles')
        .doc(circleId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots();
  }

  // Remove user from circle
  Future<void> leaveCircle(String circleId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('Not authenticated');

    await _firestore
        .collection('circles')
        .doc(circleId)
        .update({
          'members': FieldValue.arrayRemove([currentUser.uid])
        });
  }
}
