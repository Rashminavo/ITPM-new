import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String feedbackId;
  final String matchId;
  final String reviewerId;
  final String revieweeId;
  final int rating;
  final String comment;
  final bool isAnonymous;
  final DateTime createdAt;

  FeedbackModel({
    required this.feedbackId,
    required this.matchId,
    required this.reviewerId,
    required this.revieweeId,
    required this.rating,
    required this.comment,
    required this.isAnonymous,
    required this.createdAt,
  });

  factory FeedbackModel.fromMap(Map<String, dynamic> map) {
    return FeedbackModel(
      feedbackId: map['feedbackId'] ?? '',
      matchId: map['matchId'] ?? '',
      reviewerId: map['reviewerId'] ?? '',
      revieweeId: map['revieweeId'] ?? '',
      rating: map['rating'] ?? 3,
      comment: map['comment'] ?? '',
      isAnonymous: map['isAnonymous'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'feedbackId': feedbackId,
        'matchId': matchId,
        'reviewerId': reviewerId,
        'revieweeId': revieweeId,
        'rating': rating,
        'comment': comment,
        'isAnonymous': isAnonymous,
        'createdAt': createdAt,
      };
}