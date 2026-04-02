import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class FileShareSheet extends StatelessWidget {
  final VoidCallback onPickDocument;
  final VoidCallback onPickImage;

  const FileShareSheet({
    super.key,
    required this.onPickDocument,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Share a File',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _FileOption(
                icon: Icons.description,
                label: 'Document',
                color: AppColors.primary,
                onTap: () {
                  Navigator.pop(context);
                  onPickDocument();
                },
              ),
              _FileOption(
                icon: Icons.image,
                label: 'Image',
                color: AppColors.accent,
                onTap: () {
                  Navigator.pop(context);
                  onPickImage();
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _FileOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _FileOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}