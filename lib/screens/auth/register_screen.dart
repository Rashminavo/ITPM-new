import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _selectedFaculty;
  String? _selectedHostel;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFaculty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your faculty')),
      );
      return;
    }
    if (_selectedHostel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your hostel')),
      );
      return;
    }

    final success = await context.read<AuthProvider>().register(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          name: _nameController.text.trim(),
          faculty: _selectedFaculty!,
          hostel: _selectedHostel!,
        );

    if (success && mounted) {
      context.go('/profile-setup');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.grey900),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Join the Peer Buddy community',
                  style: TextStyle(color: AppColors.grey500),
                ),

                const SizedBox(height: 28),

                // Error message
                if (authProvider.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.error, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            authProvider.errorMessage!,
                            style: const TextStyle(
                                color: AppColors.error, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Full Name
                CustomTextField(
                  label: 'Full Name',
                  hint: 'John Perera',
                  controller: _nameController,
                  prefixIcon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Full name is required';
                    }
                    if (val.trim().length < 2) return 'Name too short';
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                // Email
                CustomTextField(
                  label: 'Email',
                  hint: 'you@university.edu',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  textInputAction: TextInputAction.next,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Email is required';
                    if (!val.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                // Faculty dropdown
                DropdownButtonFormField<String>(
                  value: _selectedFaculty,
                  decoration: const InputDecoration(
                    labelText: 'Faculty',
                    prefixIcon: Icon(Icons.school_outlined),
                  ),
                  items: AppStrings.faculties
                      .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedFaculty = val),
                  validator: (val) =>
                      val == null ? 'Please select your faculty' : null,
                ),

                const SizedBox(height: 14),

                // Hostel dropdown
                DropdownButtonFormField<String>(
                  value: _selectedHostel,
                  decoration: const InputDecoration(
                    labelText: 'Hostel',
                    prefixIcon: Icon(Icons.home_outlined),
                  ),
                  items: AppStrings.hostels
                      .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedHostel = val),
                  validator: (val) =>
                      val == null ? 'Please select your hostel' : null,
                ),

                const SizedBox(height: 14),

                // Password
                CustomTextField(
                  label: 'Password',
                  controller: _passwordController,
                  obscureText: true,
                  prefixIcon: Icons.lock_outline,
                  textInputAction: TextInputAction.next,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Password is required';
                    if (val.length < 6) return 'Min 6 characters';
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                // Confirm Password
                CustomTextField(
                  label: 'Confirm Password',
                  controller: _confirmPasswordController,
                  obscureText: true,
                  prefixIcon: Icons.lock_outline,
                  textInputAction: TextInputAction.done,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (val != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 28),

                // Register button
                CustomButton(
                  label: 'Create Account',
                  onPressed: _register,
                  isLoading: authProvider.isLoading,
                  width: double.infinity,
                ),

                const SizedBox(height: 20),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: AppColors.grey600),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: const Text(
                        'Log In',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}