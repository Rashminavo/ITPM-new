import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/buddy_match_model.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';
import '../../widgets/common/avatar_widget.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utiles/date_helper.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('matches')
            .where('status', isEqualTo: 'ended')
            .get(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final allMatches = snap.data!.docs
              .map((d) => BuddyMatchModel.fromMap(d.data() as Map<String, dynamic>))
              .where((m) => m.user1Id == uid || m.user2Id == uid)
              .toList();

          if (allMatches.isEmpty) {
            return const Center(
              child: Text('No past buddy sessions yet.',
                  style: TextStyle(color: AppColors.grey500)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: allMatches.length,
            itemBuilder: (context, index) {
              final match = allMatches[index];
              final buddyId = match.buddyId(uid);
              return FutureBuilder<UserModel?>(
                future: FirestoreService().getUser(buddyId),
                builder: (_, userSnap) {
                  final buddy = userSnap.data;
                  return Card(
                    child: ListTile(
                      leading: AvatarWidget(name: buddy?.name ?? '?', radius: 22),
                      title: Text(buddy?.name ?? 'Former Buddy'),
                      subtitle: Text(
                        'Session ended • ${DateHelper.formatFullDate(match.createdAt)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.grey200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${match.matchScore}% match',
                          style: const TextStyle(fontSize: 11, color: AppColors.grey600),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}