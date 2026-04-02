class UserModel {
  final String uid;
  final String name;
  final String email;
  final String faculty;
  final String hostel;
  final List<String> availability;
  final String bio;
  final List<String> skills;
  final String photoUrl;
  final bool isAvailable;
  final DateTime createdAt;
  final String fcmToken;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.faculty,
    required this.hostel,
    required this.availability,
    required this.bio,
    required this.skills,
    required this.photoUrl,
    required this.isAvailable,
    required this.createdAt,
    required this.fcmToken,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      faculty: map['faculty'] ?? '',
      hostel: map['hostel'] ?? '',
      availability: List<String>.from(map['availability'] ?? []),
      bio: map['bio'] ?? '',
      skills: List<String>.from(map['skills'] ?? []),
      photoUrl: map['photoUrl'] ?? '',
      isAvailable: map['isAvailable'] ?? true,
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      fcmToken: map['fcmToken'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'faculty': faculty,
      'hostel': hostel,
      'availability': availability,
      'bio': bio,
      'skills': skills,
      'photoUrl': photoUrl,
      'isAvailable': isAvailable,
      'createdAt': createdAt,
      'fcmToken': fcmToken,
    };
  }
}