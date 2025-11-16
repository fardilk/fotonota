import 'package:flutter/material.dart';
import '../design_tokens.dart';

class ProfileBanner extends StatelessWidget {
  final String? profileName;
  final VoidCallback onCreateOrEdit;
  const ProfileBanner({super.key, required this.profileName, required this.onCreateOrEdit});
  @override
  Widget build(BuildContext context) {
    if (profileName == null) {
      return Card(
        color: Colors.orange.shade50,
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Profile Incomplete', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: Spacing.sm),
              const Text('Complete your profile to enable uploads & automatic OCR notes.'),
              const SizedBox(height: Spacing.md),
              FilledButton(onPressed: onCreateOrEdit, child: const Text('Create Profile')),
            ],
          ),
        ),
      );
    }
    return Row(
      children: [
        const Icon(Icons.verified_user, color: Colors.green),
        const SizedBox(width: Spacing.sm),
        Expanded(child: Text('Profile: $profileName')),
        TextButton(onPressed: onCreateOrEdit, child: const Text('Edit')),
      ],
    );
  }
}
