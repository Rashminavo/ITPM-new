import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import '../models/user_model.dart';
import '../models/buddy_match_model.dart';
import '../services/matching_service.dart';
import '../services/firestore_service.dart';

class BuddyProvider extends ChangeNotifier {
  final MatchingService _matchingService = MatchingService();
  final FirestoreService _firestoreService = FirestoreService();

  List<UserModel> _buddies = [];
  List<BuddyMatchModel> _activeMatches = [];
  List<BuddyMatchModel> _pendingMatches = [];
  bool _isLoading = false;
  String? _error;

  List<UserModel> get buddies => _buddies;
  List<BuddyMatchModel> get activeMatches => _activeMatches;
  List<BuddyMatchModel> get pendingMatches => _pendingMatches;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> searchBuddies({
    required String currentUserId,
    String? faculty,
    String? hostel,
    String? availability,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      _buddies = await _matchingService.searchBuddies(
        currentUserId: currentUserId,
        faculty: faculty,
        hostel: hostel,
        availability: availability,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendRequest({
    required String fromUserId,
    required String toUserId,
    required int matchScore,
  }) async {
    await _matchingService.sendRequest(
      fromUserId: fromUserId,
      toUserId: toUserId,
      matchScore: matchScore,
    );
  }

  // Combines both user1 and user2 streams into one list
  void listenToMatches(String userId) {
    final s1 = _firestoreService.getMatchesStream(userId);
    final s2 = _firestoreService.getMatchesAsUser2Stream(userId);

    Rx.combineLatest2<List<BuddyMatchModel>, List<BuddyMatchModel>,
        List<BuddyMatchModel>>(
      s1,
      s2,
      (a, b) => [...a, ...b],
    ).listen((allMatches) {
      _activeMatches =
          allMatches.where((m) => m.status == 'active').toList();
      _pendingMatches =
          allMatches.where((m) => m.status == 'pending').toList();
      notifyListeners();
    });
  }

  Future<void> acceptRequest(String matchId) async {
    await _firestoreService.updateMatchStatus(matchId, 'active');
  }

  Future<void> declineRequest(String matchId) async {
    await _firestoreService.updateMatchStatus(matchId, 'ended');
  }
}