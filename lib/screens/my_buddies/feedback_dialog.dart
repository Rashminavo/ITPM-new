import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class FeedbackDialog extends StatefulWidget {
  final String matchId;
  final String reviewerId;
  final String revieweeId;

  const FeedbackDialog({
    super.key,
    required this.matchId,
    required this.reviewerId,
    required this.revieweeId,
  });

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  int _rating = 3;
  final TextEditingController _commentController = TextEditingController();
  bool _isAnonymous = true;
  bool _submitting = false;

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final feedbackId = const Uuid().v4();
    await FirebaseFirestore.instance.collection('feedback').doc(feedbackId).set({
      'feedbackId': feedbackId,
      'matchId': widget.matchId,
      'reviewerId': widget.reviewerId,
      'revieweeId': widget.revieweeId,
      'rating': _rating,
      'comment': _commentController.text.trim(),
      'isAnonymous': _isAnonymous,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback submitted anonymously!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rate your Buddy Session'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('How was your meetup experience?'),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              return IconButton(
                icon: Icon(
                  i < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 32,
                ),
                onPressed: () => setState(() => _rating = i + 1),
              );
            }),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Leave a comment (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          CheckboxListTile(
            title: const Text('Post anonymously'),
            value: _isAnonymous,
            onChanged: (v) => setState(() => _isAnonymous = v ?? true),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const CircularProgressIndicator(strokeWidth: 2)
              : const Text('Submit'),
        ),
      ],
    );
  }
}