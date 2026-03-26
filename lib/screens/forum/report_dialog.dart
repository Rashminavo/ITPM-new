import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class ReportDialog extends StatefulWidget {
  final String targetId;
  final String targetType;
  final String reportedBy;

  const ReportDialog({
    super.key,
    required this.targetId,
    required this.targetType,
    required this.reportedBy,
  });

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  String? _selectedReason;
  bool _submitting = false;

  final List<String> _reasons = [
    'Inappropriate content',
    'Harassment or bullying',
    'Misinformation',
    'Spam or advertising',
    'Other',
  ];

  Future<void> _submit() async {
    if (_selectedReason == null) return;
    setState(() => _submitting = true);

    await FirebaseFirestore.instance.collection('reports').doc(const Uuid().v4()).set({
      'reportId': const Uuid().v4(),
      'reportedBy': widget.reportedBy,
      'targetId': widget.targetId,
      'targetType': widget.targetType,
      'reason': _selectedReason,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Increment reportCount on the post
    if (widget.targetType == 'post') {
      await FirebaseFirestore.instance
          .collection('forum_posts')
          .doc(widget.targetId)
          .update({'reportCount': FieldValue.increment(1)});
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report submitted. Thank you!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Report Content'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: _reasons
            .map((reason) => RadioListTile<String>(
                  title: Text(reason),
                  value: reason,
                  groupValue: _selectedReason,
                  onChanged: (v) => setState(() => _selectedReason = v),
                ))
            .toList(),
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
              : const Text('Submit Report'),
        ),
      ],
    );
  }
}