import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/forum_post_model.dart';

class ForumProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<ForumPostModel> _posts = [];
  bool _isLoading = false;
  String? _error;

  List<ForumPostModel> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPosts() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snap = await _db
          .collection('forum_posts')
          .where('isHidden', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();
      _posts = snap.docs
          .map((d) => ForumPostModel.fromMap(d.data()))
          .toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createPost({
    required String authorId,
    required String title,
    required String content,
    required List<String> tags,
    required bool isAnonymous,
  }) async {
    final postId = const Uuid().v4();
    await _db.collection('forum_posts').doc(postId).set({
      'postId': postId,
      'authorId': authorId,
      'title': title,
      'content': content,
      'tags': tags,
      'upvotes': 0,
      'downvotes': 0,
      'upvotedBy': [],
      'downvotedBy': [],
      'isAnonymous': isAnonymous,
      'reportCount': 0,
      'isHidden': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await loadPosts();
  }

  Future<void> vote({
    required String postId,
    required String userId,
    required bool isUpvote,
  }) async {
    final ref = _db.collection('forum_posts').doc(postId);
    final post = _posts.firstWhere((p) => p.postId == postId);
    final hasUpvoted = post.upvotedBy.contains(userId);
    final hasDownvoted = post.downvotedBy.contains(userId);

    if (isUpvote) {
      if (hasUpvoted) {
        // Remove upvote
        await ref.update({
          'upvotes': FieldValue.increment(-1),
          'upvotedBy': FieldValue.arrayRemove([userId]),
        });
      } else {
        // Add upvote, remove downvote if exists
        await ref.update({
          'upvotes': FieldValue.increment(1),
          'upvotedBy': FieldValue.arrayUnion([userId]),
          if (hasDownvoted) 'downvotes': FieldValue.increment(-1),
          if (hasDownvoted) 'downvotedBy': FieldValue.arrayRemove([userId]),
        });
      }
    } else {
      if (hasDownvoted) {
        await ref.update({
          'downvotes': FieldValue.increment(-1),
          'downvotedBy': FieldValue.arrayRemove([userId]),
        });
      } else {
        await ref.update({
          'downvotes': FieldValue.increment(1),
          'downvotedBy': FieldValue.arrayUnion([userId]),
          if (hasUpvoted) 'upvotes': FieldValue.increment(-1),
          if (hasUpvoted) 'upvotedBy': FieldValue.arrayRemove([userId]),
        });
      }
    }
    await loadPosts();
  }
}