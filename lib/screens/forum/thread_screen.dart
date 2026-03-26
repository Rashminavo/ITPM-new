import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/forum_post_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/forum_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utiles/date_helper.dart';
import 'report_dialog.dart';

class ThreadScreen extends StatefulWidget {
  final ForumPostModel post;
  const ThreadScreen({super.key, required this.post});

  @override
  State<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isAnonymous = true;

  void _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;
    final uid = context.read<AuthProvider>().currentUser?.uid ?? '';
    final commentId = const Uuid().v4();

    await FirebaseFirestore.instance
        .collection('forum_posts')
        .doc(widget.post.postId)
        .collection('comments')
        .doc(commentId)
        .set({
      'commentId': commentId,
      'authorId': uid,
      'content': _commentController.text.trim(),
      'isAnonymous': _isAnonymous,
      'upvotes': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });

    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thread'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flag_outlined),
            onPressed: () => showDialog(
              context: context,
              builder: (_) => ReportDialog(
                targetId: widget.post.postId,
                targetType: 'post',
                reportedBy: uid,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Original post
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person_outline, size: 16, color: AppColors.grey500),
                            const SizedBox(width: 4),
                            Text(
                              widget.post.isAnonymous ? 'Anonymous' : 'Community Member',
                              style: const TextStyle(color: AppColors.grey500, fontSize: 12),
                            ),
                            const Spacer(),
                            Text(
                              DateHelper.formatChatTimestamp(widget.post.createdAt),
                              style: const TextStyle(color: AppColors.grey400, fontSize: 11),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(widget.post.title,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(widget.post.content, style: const TextStyle(height: 1.5)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_upward, size: 20),
                              color: widget.post.upvotedBy.contains(uid)
                                  ? AppColors.success
                                  : AppColors.grey500,
                              onPressed: () => context.read<ForumProvider>().vote(
                                    postId: widget.post.postId,
                                    userId: uid,
                                    isUpvote: true,
                                  ),
                            ),
                            Text('${widget.post.upvotes}'),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.arrow_downward, size: 20),
                              color: widget.post.downvotedBy.contains(uid)
                                  ? AppColors.error
                                  : AppColors.grey500,
                              onPressed: () => context.read<ForumProvider>().vote(
                                    postId: widget.post.postId,
                                    userId: uid,
                                    isUpvote: false,
                                  ),
                            ),
                            Text('${widget.post.downvotes}'),
                          ],
                        ),
                        const Divider(height: 24),
                        const Text('Comments', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                // Comments stream
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('forum_posts')
                      .doc(widget.post.postId)
                      .collection('comments')
                      .orderBy('createdAt', descending: false)
                      .snapshots(),
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return const SliverToBoxAdapter(
                          child: Center(child: CircularProgressIndicator()));
                    }
                    final comments = snap.data!.docs;
                    if (comments.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No comments yet. Be the first!',
                              style: TextStyle(color: AppColors.grey500)),
                        ),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) {
                          final c = comments[i].data() as Map<String, dynamic>;
                          final isAnon = c['isAnonymous'] as bool? ?? true;
                          final ts = (c['createdAt'] as Timestamp?)?.toDate();
                          return ListTile(
                            leading: const CircleAvatar(
                              radius: 14,
                              child: Icon(Icons.person, size: 16),
                            ),
                            title: Text(isAnon ? 'Anonymous' : 'Member',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            subtitle: Text(c['content'] ?? ''),
                            trailing: ts != null
                                ? Text(DateHelper.formatChatTimestamp(ts),
                                    style: const TextStyle(fontSize: 11, color: AppColors.grey400))
                                : null,
                          );
                        },
                        childCount: comments.length,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Comment input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.grey200)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isAnonymous ? Icons.visibility_off : Icons.visibility,
                    size: 20,
                    color: AppColors.grey500,
                  ),
                  tooltip: _isAnonymous ? 'Posting anonymously' : 'Posting as you',
                  onPressed: () => setState(() => _isAnonymous = !_isAnonymous),
                ),
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: AppColors.primary,
                  onPressed: _submitComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}