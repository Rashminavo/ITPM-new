import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/buddy_match_model.dart';
import '../models/meetup_model.dart';
import '../models/feedback_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Users ───────────────────────────────────────────────
  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }

  Stream<UserModel?> userStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map(
          (doc) => doc.exists ? UserModel.fromMap(doc.data()!) : null,
        );
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  Future<List<UserModel>> getMultipleUsers(List<String> uids) async {
    if (uids.isEmpty) return [];
    final snapshots = await Future.wait(
      uids.map((uid) => _db.collection('users').doc(uid).get()),
    );
    return snapshots
        .where((doc) => doc.exists)
        .map((doc) => UserModel.fromMap(doc.data()!))
        .toList();
  }

  // ─── Matches ─────────────────────────────────────────────
  Stream<List<BuddyMatchModel>> getMatchesStream(String userId) {
    // Firestore doesn't support OR queries directly; merge two streams
    final s1 = _db
        .collection('matches')
        .where('user1Id', isEqualTo: userId)
        .snapshots()
        .map((s) => s.docs.map((d) => BuddyMatchModel.fromMap(d.data())).toList());
    return s1; // For full OR, combine in BuddyProvider
  }

  Stream<List<BuddyMatchModel>> getMatchesAsUser2Stream(String userId) {
    return _db
        .collection('matches')
        .where('user2Id', isEqualTo: userId)
        .snapshots()
        .map((s) => s.docs.map((d) => BuddyMatchModel.fromMap(d.data())).toList());
  }

  Future<void> updateMatchStatus(String matchId, String status) async {
    await _db.collection('matches').doc(matchId).update({'status': status});
  }

  // ─── Meetups ─────────────────────────────────────────────
  Stream<List<MeetupModel>> getMeetupsForMatch(String matchId) {
    return _db
        .collection('meetups')
        .where('matchId', isEqualTo: matchId)
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((s) => s.docs.map((d) => MeetupModel.fromMap(d.data())).toList());
  }

  Stream<List<MeetupModel>> getUpcomingMeetups(String userId) {
    return _db
        .collection('meetups')
        .where('participants', arrayContains: userId)
        .where('status', isEqualTo: 'scheduled')
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((s) => s.docs.map((d) => MeetupModel.fromMap(d.data())).toList());
  }

  Future<void> updateMeetupStatus(String meetupId, String status) async {
    await _db.collection('meetups').doc(meetupId).update({'status': status});
  }

  // ─── Feedback ─────────────────────────────────────────────
  Stream<List<FeedbackModel>> getFeedbackForUser(String userId) {
    return _db
        .collection('feedback')
        .where('revieweeId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => FeedbackModel.fromMap(d.data())).toList());
  }

  Future<bool> hasFeedbackForMatch(String matchId, String reviewerId) async {
    final snap = await _db
        .collection('feedback')
        .where('matchId', isEqualTo: matchId)
        .where('reviewerId', isEqualTo: reviewerId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }
}