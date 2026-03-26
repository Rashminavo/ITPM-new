import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/forum_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_strings.dart';
import '../../widgets/common/custom_button.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final List<String> _selectedTags = [];
  bool _isAnonymous = true;
  bool _isSubmitting = false;

  final List<String> _availableTags = [
    'Study Tips', 'Hostel Life', 'Faculty Help', 'Career',
    'Mental Health', 'Events', 'Food', 'Sports', 'Tech', 'Other',
  ];

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and content are required.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final uid = context.read<AuthProvider>().currentUser?.uid ?? '';

    await context.read<ForumProvider>().createPost(
          authorId: uid,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          tags: _selectedTags,
          isAnonymous: _isAnonymous,
        );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post published!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title', hintText: 'Share a tip or story...'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Content',
                hintText: 'Write your post here...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Tags', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _availableTags.map((tag) {
                final selected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: selected,
                  onSelected: (val) {
                    setState(() {
                      if (val) _selectedTags.add(tag);
                      else _selectedTags.remove(tag);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Post anonymously'),
              subtitle: const Text('Your name will be hidden from others'),
              value: _isAnonymous,
              onChanged: (v) => setState(() => _isAnonymous = v),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 20),
            CustomButton(
              label: 'Publish Post',
              onPressed: _submit,
              isLoading: _isSubmitting,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}