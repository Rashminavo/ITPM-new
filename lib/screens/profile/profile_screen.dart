import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  bool _isEditing = false;
  late AnimationController _animationController;

  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _emailController;
  late TextEditingController _facultyController;
  late TextEditingController _hostelController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    final user = context.read<AuthProvider>().currentUserModel;
    _nameController = TextEditingController(text: user?.name ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _facultyController = TextEditingController(text: user?.faculty ?? '');
    _hostelController = TextEditingController(text: user?.hostel ?? '');
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _facultyController.dispose();
    _hostelController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUserModel;

    if (user == null) return;

    if (_nameController.text.isEmpty) {
      _showSnackBar('Please enter your name', true);
      return;
    }

    try {
      await authProvider.updateProfile({
        'name': _nameController.text,
        'bio': _bioController.text,
        'faculty': _facultyController.text,
        'hostel': _hostelController.text,
      });

      setState(() => _isEditing = false);
      _animationController.reverse();
      _showSnackBar('Profile updated successfully! ✨', false);
    } catch (e) {
      _showSnackBar('Failed to update profile', true);
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.grey900),
        ),
        content: const Text(
          'Are you sure you want to logout? You can log back in anytime.',
          style: TextStyle(color: AppColors.grey600, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<AuthProvider>().logout();
      if (mounted) {
        context.go('/login');
      }
    }
  }

  void _showSnackBar(String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        backgroundColor: isError ? AppColors.error : AppColors.primary,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _toggleEditMode() {
    setState(() => _isEditing = !_isEditing);
    if (_isEditing) {
      _animationController.forward();
    } else {
      _animationController.reverse();
      _nameController.text = context.read<AuthProvider>().currentUserModel?.name ?? '';
      _bioController.text = context.read<AuthProvider>().currentUserModel?.bio ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUserModel;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(
          child: Text('No user data available'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        elevation: 0,
        actions: [
          if (!_isEditing)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(
                child: TextButton.icon(
                  onPressed: _toggleEditMode,
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  label: const Text('Edit', style: TextStyle(fontWeight: FontWeight.w600)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),

            // Profile Picture Section with Card
            _buildProfileHeader(user),
            const SizedBox(height: 28),

            // Content Section
            if (!_isEditing)
              _buildViewMode(user)
            else
              _buildEditMode(),

            const SizedBox(height: 28),

            // Logout Button
            _buildLogoutButton(),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar Card
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary,
                    width: 4,
                  ),
                ),
                child: user.photoUrl.isNotEmpty
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: user.photoUrl,
                          width: 140,
                          height: 140,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 140,
                            height: 140,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.greenGradient,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              _buildAvatarPlaceholder(user.name, 140),
                        ),
                      )
                    : _buildAvatarPlaceholder(user.name, 140),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Name and Info
        Text(
          user.name,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.grey900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          user.email,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.grey600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryExtraLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary, width: 1),
          ),
          child: const Text(
            '🌟 Active Member',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildViewMode(dynamic user) {
    return Column(
      children: [
        _buildInfoSection('Faculty', user.faculty, Icons.school_outlined),
        const SizedBox(height: 12),
        _buildInfoSection('Hostel', user.hostel, Icons.home_outlined),
        const SizedBox(height: 12),
        _buildBioSection(user.bio),
        const SizedBox(height: 12),
        if (user.skills.isNotEmpty) ...[
          _buildSkillsSection(user.skills),
          const SizedBox(height: 12),
        ],
        if (user.availability.isNotEmpty) ...[
          _buildAvailabilitySection(user.availability),
        ],
      ],
    );
  }

  Widget _buildInfoSection(String label, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryExtraLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey500,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? 'Not provided' : value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: value.isEmpty ? AppColors.grey400 : AppColors.grey900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioSection(String bio) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryExtraLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.description_outlined, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'About Me',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey500,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            bio.isEmpty ? 'No bio added yet' : bio,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: bio.isEmpty ? AppColors.grey400 : AppColors.grey800,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection(List<String> skills) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryExtraLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.bolt_outlined, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Skills',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey500,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills
                .map(
                  (skill) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: AppColors.greenGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      skill,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilitySection(List<String> availability) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryExtraLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.schedule_outlined, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Availability',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey500,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: availability
                .map(
                  (slot) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.greenGradient,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          slot,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.grey800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEditMode() {
    return Column(
      children: [
        _buildEditField('Full Name', _nameController, Icons.person_outline, false),
        const SizedBox(height: 16),
        _buildEditField('Email', _emailController, Icons.email_outlined, true),
        const SizedBox(height: 16),
        _buildEditField('Faculty', _facultyController, Icons.school_outlined, true),
        const SizedBox(height: 16),
        _buildEditField('Hostel', _hostelController, Icons.home_outlined, true),
        const SizedBox(height: 16),
        _buildEditField('About Me', _bioController, Icons.description_outlined, false, maxLines: 3),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _toggleEditMode,
                icon: const Icon(Icons.close),
                label: const Text('Cancel'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.check),
                label: const Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEditField(
    String label,
    TextEditingController controller,
    IconData icon,
    bool readOnly, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.grey700,
              letterSpacing: 0.2,
            ),
          ),
        ),
        TextField(
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            prefixIcon: Icon(icon),
            filled: true,
            fillColor: readOnly ? AppColors.grey50 : AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.grey200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.grey200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.grey900,
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _confirmLogout,
        icon: const Icon(Icons.logout, size: 20),
        label: const Text('Logout', style: TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 4,
          shadowColor: AppColors.error.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder(String name, double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.greenGradient,
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: size * 0.5,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}
