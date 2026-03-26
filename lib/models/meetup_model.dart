import 'package:cloud_firestore/cloud_firestore.dart';

class MeetupModel {
  final String meetupId;
  final String matchId;
  final List<String> participants;
  final String title;
  final DateTime dateTime;
  final String location;
  final String notes;
  final String status; // "scheduled", "completed", "cancelled"
  final String createdBy;

  MeetupModel({
    required this.meetupId,
    required this.matchId,
    required this.participants,
    required this.title,
    required this.dateTime,
    required this.location,
    this.notes = '',
    required this.status,
    required this.createdBy,
  });

  bool isUpcoming() => dateTime.isAfter(DateTime.now()) && status == 'scheduled';
  bool isPast() => dateTime.isBefore(DateTime.now()) || status == 'completed';

  factory MeetupModel.fromMap(Map<String, dynamic> map) {
    return MeetupModel(
      meetupId: map['meetupId'] ?? '',
      matchId: map['matchId'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      title: map['title'] ?? 'Study Session',
      dateTime: (map['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      location: map['location'] ?? '',
      notes: map['notes'] ?? '',
      status: map['status'] ?? 'scheduled',
      createdBy: map['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'meetupId': meetupId,
        'matchId': matchId,
        'participants': participants,
        'title': title,
        'dateTime': dateTime,
        'location': location,
        'notes': notes,
        'status': status,
        'createdBy': createdBy,
      };
}