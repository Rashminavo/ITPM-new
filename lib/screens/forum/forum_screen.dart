import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/forum_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/forum_post_model.dart';
import 'create_post_screen.dart';
import 'thread_screen.dart';
import 'report_dialog.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ForumProvider>().loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    final forumProvider = context.watch<ForumProvider>();
    final currentUserId = context.watch<AuthProvider>().currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Community Forum')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreatePostScreen()),
        ),
        icon: const Icon(Icons.edit),
        label: const Text('Post Tip'),
      ),
      body: forumProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: forumProvider.posts.length,
              itemBuilder: (context, index) {
                final post = forumProvider.posts[index];
                return _PostCard(
                  post: post,
                  currentUserId: currentUserId,
                  onUpvote: () => context.read<ForumProvider>().vote(
                        postId: post.postId,
                        userId: currentUserId,
                        isUpvote: true,
                      ),
                  onDownvote: () => context.read<ForumProvider>().vote(
                        postId: post.postId,
                        userId: currentUserId,
                        isUpvote: false,
                      ),
                  onReport: () => showDialog(
                    context: context,
                    builder: (_) => ReportDialog(
                      targetId: post.postId,
                      targetType: 'post',
                      reportedBy: currentUserId,
                    ),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ThreadScreen(post: post),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final ForumPostModel post;
  final String currentUserId;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;
  final VoidCallback onReport;
  final VoidCallback onTap;

  const _PostCard({
    required this.post,
    required this.currentUserId,
    required this.onUpvote,
    required this.onDownvote,
    required this.onReport,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasUpvoted = post.upvotedBy.contains(currentUserId);
    final hasDownvoted = post.downvotedBy.contains(currentUserId);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    post.isAnonymous ? 'Anonymous' : 'Community Member',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.flag_outlined, size: 18),
                    color: Colors.red.shade300,
                    onPressed: onReport,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                post.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                post.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  // Tags
                  Expanded(
                    child: Wrap(
                      spacing: 4,
                      children: post.tags
                          .map((tag) => Chip(
                                label: Text(tag, style: const TextStyle(fontSize: 10)),
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                              ))
                          .toList(),
                    ),
                  ),
                  // Vote buttons
                  IconButton(
                    icon: Icon(
                      Icons.arrow_upward,
                      color: hasUpvoted ? Colors.green : Colors.grey,
                    ),
                    onPressed: onUpvote,
                  ),
                  Text('${post.upvotes}'),
                  IconButton(
                    icon: Icon(
                      Icons.arrow_downward,
                      color: hasDownvoted ? Colors.red : Colors.grey,
                    ),
                    onPressed: onDownvote,
                  ),
                  Text('${post.downvotes}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}