import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../services/storage_service.dart';
import '../../widgets/common/custom_button.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _bioController = TextEditingController();
  final _skillController = TextEditingController();
  final List<String> _selectedSkills = [];
  final List<String> _selectedAvailability = [];
  File? _selectedImage;
  bool _isSaving = false;

  final List<String> _suggestedSkills = [
    'Mathematics', 'Physics', 'Chemistry', 'Biology',
    'Programming', 'Python', 'Java', 'Web Dev',
    'English', 'Research', 'Study Tips', 'Exam Prep',
    'Machine Learning', 'Data Science', 'Design', 'Writing',
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 500,
    );
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  void _addCustomSkill() {
    final skill = _skillController.text.trim();
    if (skill.isNotEmpty && !_selectedSkills.contains(skill)) {
      setState(() {
        _selectedSkills.add(skill);
        _skillController.clear();
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final uid = authProvider.currentUser?.uid ?? '';
      String photoUrl = '';

      // Upload photo if selected
      if (_selectedImage != null) {
        photoUrl = await StorageService().uploadProfilePhoto(uid, _selectedImage!);
      }

      await authProvider.updateProfile({
        'bio': _bioController.text.trim(),
        'skills': _selectedSkills,
        'availability': _selectedAvailability,
        if (photoUrl.isNotEmpty) 'photoUrl': photoUrl,
      });

      if (mounted) context.go('/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text('Set Up Profile'),
        actions: [
          TextButton(
            onPressed: () => context.go('/home'),
            child: const Text('Skip'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: 1.0,
              backgroundColor: AppColors.grey200,
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 6),
            const Text(
              'Step 2 of 2 — Complete your profile',
              style: TextStyle(fontSize: 12, color: AppColors.grey500),
            ),

            const SizedBox(height: 24),

            // Profile photo
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primaryLight.withOpacity(0.3),
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : null,
                      child: _selectedImage == null
                          ? const Icon(Icons.person,
                              size: 50, color: AppColors.primary)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt,
                            color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Tap to add profile photo',
                style: TextStyle(color: AppColors.grey500, fontSize: 13),
              ),
            ),

            const SizedBox(height: 24),

            // Bio
            const Text(
              'Bio',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _bioController,
              maxLines: 3,
              maxLength: 150,
              decoration: const InputDecoration(
                hintText: 'Tell others a bit about yourself...',
              ),
            ),

            const SizedBox(height: 20),

            // Skills
            const Text(
              'Skills & Subjects',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 4),
            const Text(
              'Add skills you can help others with',
              style: TextStyle(color: AppColors.grey500, fontSize: 13),
            ),
            const SizedBox(height: 10),

            // Suggested skills chips
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _suggestedSkills.map((skill) {
                final selected = _selectedSkills.contains(skill);
                return FilterChip(
                  label: Text(skill),
                  selected: selected,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _selectedSkills.add(skill);
                      } else {
                        _selectedSkills.remove(skill);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            // Custom skill input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _skillController,
                    decoration: const InputDecoration(
                      hintText: 'Add a custom skill...',
                      isDense: true,
                    ),
                    onSubmitted: (_) => _addCustomSkill(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addCustomSkill,
                  icon: const Icon(Icons.add_circle, color: AppColors.primary),
                ),
              ],
            ),

            // Custom skills added
            if (_selectedSkills
                .where((s) => !_suggestedSkills.contains(s))
                .isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _selectedSkills
                    .where((s) => !_suggestedSkills.contains(s))
                    .map((skill) => Chip(
                          label: Text(skill),
                          deleteIcon: const Icon(Icons.close, size: 14),
                          onDeleted: () =>
                              setState(() => _selectedSkills.remove(skill)),
                        ))
                    .toList(),
              ),
            ],

            const SizedBox(height: 24),

            // Availability
            const Text(
              'Availability',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 4),
            const Text(
              'When are you free to meet or chat?',
              style: TextStyle(color: AppColors.grey500, fontSize: 13),
            ),
            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: AppStrings.availabilitySlots.map((slot) {
                final selected = _selectedAvailability.contains(slot);
                return FilterChip(
                  label: Text(slot, style: const TextStyle(fontSize: 12)),
                  selected: selected,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _selectedAvailability.add(slot);
                      } else {
                        _selectedAvailability.remove(slot);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // Save button
            CustomButton(
              label: 'Save & Continue',
              onPressed: _saveProfile,
              isLoading: _isSaving,
              width: double.infinity,
              icon: Icons.check,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}