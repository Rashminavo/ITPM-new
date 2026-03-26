import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/buddy_match_model.dart';

class MatchingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  // Get filtered buddy list
  Future<List<UserModel>> searchBuddies({
    required String currentUserId,
    String? faculty,
    String? hostel,
    String? availability,
  }) async {
    Query query = _firestore
        .collection('users')
        .where('isAvailable', isEqualTo: true);

    if (faculty != null && faculty.isNotEmpty) {
      query = query.where('faculty', isEqualTo: faculty);
    }
    if (hostel != null && hostel.isNotEmpty) {
      query = query.where('hostel', isEqualTo: hostel);
    }

    final snapshot = await query.limit(50).get();
    List<UserModel> users =
        snapshot.docs.map((d) => UserModel.fromMap(d.data() as Map<String, dynamic>)).toList();

    // Filter out current user and by availability client-side
    users = users.where((u) => 
      u.uid != currentUserId && 
      (availability == null || availability.isEmpty || u.availability.contains(availability))
    ).toList();

    return users;
  }

  // Send buddy request
  Future<void> sendRequest({
    required String fromUserId,
    required String toUserId,
    required int matchScore,
  }) async {
    final matchId = _uuid.v4();
    await _firestore.collection('matches').doc(matchId).set({
      'matchId': matchId,
      'user1Id': fromUserId,
      'user2Id': toUserId,
      'matchScore': matchScore,
      'status': 'pending',
      'requestedBy': fromUserId,
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessageAt': FieldValue.serverTimestamp(),
    });
  }

  // Accept/decline request
  Future<void> updateMatchStatus(String matchId, String status) async {
    await _firestore.collection('matches').doc(matchId).update({'status': status});
  }

  // Get active buddies for current user
  Stream<List<Map<String, dynamic>>> getActiveMatches(String userId) {
    return _firestore
        .collection('matches')
        .where('status', isEqualTo: 'active')
        .where('user1Id', isEqualTo: userId)
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }
}