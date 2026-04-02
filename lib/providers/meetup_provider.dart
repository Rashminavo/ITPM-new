import 'package:flutter/material.dart';
import '../models/meetup_model.dart';
import '../services/firestore_service.dart';

class MeetupProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<MeetupModel> _upcomingMeetups = [];
  bool _isLoading = false;

  List<MeetupModel> get upcomingMeetups => _upcomingMeetups;
  bool get isLoading => _isLoading;

  void listenToUpcomingMeetups(String userId) {
    _firestoreService.getUpcomingMeetups(userId).listen((meetups) {
      _upcomingMeetups = meetups;
      notifyListeners();
    });
  }

  Stream<List<MeetupModel>> getMeetupsForMatch(String matchId) {
    return _firestoreService.getMeetupsForMatch(matchId);
  }

  Future<void> cancelMeetup(String meetupId) async {
    await _firestoreService.updateMeetupStatus(meetupId, 'cancelled');
  }

  Future<void> completeMeetup(String meetupId) async {
    await _firestoreService.updateMeetupStatus(meetupId, 'completed');
  }
}