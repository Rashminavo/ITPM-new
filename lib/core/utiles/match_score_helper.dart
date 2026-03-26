import '../../models/user_model.dart';

class MatchScoreHelper {
  // Calculates a compatibility score (0–100) between two users
  static int calculate(UserModel currentUser, UserModel otherUser) {
    int score = 0;

    // Same faculty: +30
    if (currentUser.faculty == otherUser.faculty) score += 30;

    // Same hostel: +20
    if (currentUser.hostel == otherUser.hostel) score += 20;

    // Overlapping availability slots: +5 per slot (max 20)
    final overlapSlots = currentUser.availability
        .where((slot) => otherUser.availability.contains(slot))
        .length;
    score += ((overlapSlots * 5).clamp(0, 20) as int);

    // Shared skills: +5 per skill (max 30)
    final sharedSkills = currentUser.skills
        .where((skill) => otherUser.skills.contains(skill))
        .length;
    score += ((sharedSkills * 5).clamp(0, 30) as int);

    return score.clamp(0, 100) as int;
  }
}