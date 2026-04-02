import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/common/avatar_widget.dart';

class BuddyCard extends StatelessWidget {
  final UserModel buddy;
  final int matchScore;
  final VoidCallback onRequest;

  const BuddyCard({
    super.key,
    required this.buddy,
    required this.matchScore,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AvatarWidget(name: buddy.name, photoUrl: buddy.photoUrl, radius: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        buddy.name,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      const Spacer(),
                      _MatchScoreBadge(score: matchScore),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(buddy.faculty, style: TextStyle(color: AppColors.grey600, fontSize: 13)),
                  Text(buddy.hostel, style: TextStyle(color: AppColors.grey500, fontSize: 12)),
                  if (buddy.bio.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      buddy.bio,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: AppColors.grey700, fontSize: 13),
                    ),
                  ],
                  if (buddy.skills.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: buddy.skills
                          .take(3)
                          .map((skill) => Chip(
                                label: Text(skill),
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                              ))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onRequest,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text('Send Buddy Request'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchScoreBadge extends StatelessWidget {
  final int score;
  const _MatchScoreBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.matchScoreColor(score).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$score% match',
        style: TextStyle(
          color: AppColors.matchScoreColor(score),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}