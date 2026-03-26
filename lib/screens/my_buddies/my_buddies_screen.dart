import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/buddy_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/buddy_match_model.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';
import '../../widgets/common/avatar_widget.dart';
import '../../core/constants/app_colors.dart';
import '../chat/chat_screen.dart';
import 'feedback_dialog.dart';
import 'history_screen.dart';

class MyBuddiesScreen extends StatefulWidget {
  const MyBuddiesScreen({super.key});

  @override
  State<MyBuddiesScreen> createState() => _MyBuddiesScreenState();
}

class _MyBuddiesScreenState extends State<MyBuddiesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final uid = context.read<AuthProvider>().currentUser?.uid ?? '';
    context.read<BuddyProvider>().listenToMatches(uid);
  }

  @override
  Widget build(BuildContext context) {
    final buddyProvider = context.watch<BuddyProvider>();
    final currentUser = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Buddies'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Requests'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ActiveBuddiesList(
            matches: buddyProvider.activeMatches,
            currentUserId: currentUser?.uid ?? '',
          ),
          _PendingRequestsList(
            matches: buddyProvider.pendingMatches,
            currentUserId: currentUser?.uid ?? '',
            onAccept: (matchId) => context.read<BuddyProvider>().acceptRequest(matchId),
            onDecline: (matchId) => context.read<BuddyProvider>().declineRequest(matchId),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HistoryScreen()),
        ),
        icon: const Icon(Icons.history),
        label: const Text('History'),
      ),
    );
  }
}

class _ActiveBuddiesList extends StatelessWidget {
  final List<BuddyMatchModel> matches;
  final String currentUserId;

  const _ActiveBuddiesList({required this.matches, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 64, color: AppColors.grey300),
            SizedBox(height: 12),
            Text('No active buddies yet.\nFind someone in Buddy Search!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.grey500)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        return _ActiveBuddyCard(match: match, currentUserId: currentUserId);
      },
    );
  }
}

class _ActiveBuddyCard extends StatelessWidget {
  final BuddyMatchModel match;
  final String currentUserId;

  const _ActiveBuddyCard({required this.match, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final buddyId = match.buddyId(currentUserId);

    return FutureBuilder<UserModel?>(
      future: FirestoreService().getUser(buddyId),
      builder: (context, snapshot) {
        final buddy = snapshot.data;
        return Card(
          child: ListTile(
            leading: AvatarWidget(name: buddy?.name ?? '?', photoUrl: buddy?.photoUrl, radius: 24),
            title: Text(buddy?.name ?? 'Loading...', style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(buddy?.faculty ?? ''),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  color: AppColors.primary,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        matchId: match.matchId,
                        buddyName: buddy?.name ?? 'Buddy',
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.star_outline),
                  color: AppColors.warning,
                  onPressed: buddy == null
                      ? null
                      : () => showDialog(
                            context: context,
                            builder: (_) => FeedbackDialog(
                              matchId: match.matchId,
                              reviewerId: currentUserId,
                              revieweeId: buddyId,
                            ),
                          ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PendingRequestsList extends StatelessWidget {
  final List<BuddyMatchModel> matches;
  final String currentUserId;
  final Function(String) onAccept;
  final Function(String) onDecline;

  const _PendingRequestsList({
    required this.matches,
    required this.currentUserId,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) {
      return const Center(
        child: Text('No pending requests.', style: TextStyle(color: AppColors.grey500)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        final isIncoming = match.requestedBy != currentUserId;
        final buddyId = match.buddyId(currentUserId);

        return FutureBuilder<UserModel?>(
          future: FirestoreService().getUser(buddyId),
          builder: (context, snap) {
            final buddy = snap.data;
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    AvatarWidget(name: buddy?.name ?? '?', radius: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(buddy?.name ?? 'Loading...',
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text(
                            isIncoming ? 'Wants to be your buddy' : 'Request sent',
                            style: TextStyle(
                              fontSize: 12,
                              color: isIncoming ? AppColors.primary : AppColors.grey500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isIncoming) ...[
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: AppColors.success),
                        onPressed: () => onAccept(match.matchId),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: AppColors.error),
                        onPressed: () => onDecline(match.matchId),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}