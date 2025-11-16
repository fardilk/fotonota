import 'package:flutter/material.dart';
import '../design_tokens.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onAction;
  final IconData actionIcon;
  const SectionHeader({super.key, required this.title, this.onAction, this.actionIcon = Icons.refresh});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppText.sectionTitle(context))),
        if (onAction != null) IconButton(onPressed: onAction, icon: Icon(actionIcon, size: 18))
      ],
    );
  }
}
