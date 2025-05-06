import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class CircleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Create a new circle
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

  // 2. Join circle with invite code
 Future<void> joinCircleWithCode(String code) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) throw Exception('User not authenticated');

  try {
    final normalizedCode = code.trim().toUpperCase();
    print('Normalized Code: $normalizedCode');

    // Search all inviteCodes subcollections by document ID (invite code)
    final query = await FirebaseFirestore.instance
        .collectionGroup('inviteCodes') // Search through all 'inviteCodes' subcollections
        .where(FieldPath.documentId, isEqualTo: normalizedCode) // Match against the document ID
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('Invalid invite code');
    }

    final codeDoc = query.docs.first;
    final circleRef = codeDoc.reference.parent.parent;
    if (circleRef == null) {
      throw Exception('Circle reference not found');
    }

    // Get the invite code data
    final codeData = codeDoc.data();

    // Check usage limits
    final uses = codeData['uses'] ?? 0;
    final maxUses = codeData['maxUses'] ?? 0;

    if (uses >= maxUses) {
      throw Exception('This code has reached its maximum uses');
    }

    // Check expiration
    final expiresAtStr = codeData['expiresAt'];
    if (expiresAtStr is String) {
      final expiresAt = DateTime.tryParse(expiresAtStr);
      if (expiresAt == null || expiresAt.isBefore(DateTime.now())) {
        throw Exception('This code has expired');
      }
    } else {
      throw Exception('Invalid expiration format');
    }

    // Check if user is already a member
    final circleSnap = await circleRef.get();
    if (!circleSnap.exists) {
      throw Exception('Circle not found');
    }

    final members = List<String>.from(circleSnap.data()?['members'] ?? []);
    if (members.contains(currentUser.uid)) {
      throw Exception('You are already a member of this circle');
    }

    // Run the join transaction
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Increment code uses
      transaction.update(codeDoc.reference, {
        'uses': FieldValue.increment(1),
      });

      // Add user to members array
      transaction.update(circleRef, {
        'members': FieldValue.arrayUnion([currentUser.uid]),
      });
    });
  } on FirebaseException catch (e) {
    throw Exception('Firestore error: ${e.message}');
  } catch (e) {
    throw Exception('Join circle failed: $e');
  }
}


  // 3. Generate invite code for a circle
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
          'maxUses': 10,
          'uses': 0,
        });

    return code;
  }

  // 4. Get stream of user's circles
  Stream<QuerySnapshot> getUserCircles(String userId) {
    return _firestore
        .collection('circles')
        .where('members', arrayContains: userId)
        .orderBy('lastActivity', descending: true)
        .snapshots();
  }

  // 5. Send message to circle
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

  // 6. Get circle messages stream
  Stream<QuerySnapshot> getMessages(String circleId) {
    return _firestore
        .collection('circles')
        .doc(circleId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots();
  }

  // 7. Remove user from circle
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
