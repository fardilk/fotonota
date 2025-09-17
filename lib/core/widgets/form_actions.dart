import 'package:flutter/material.dart';
import 'primary_button.dart';

class FormActions extends StatelessWidget {
  final Widget? leading;
  final String label;
  final VoidCallback onPressed;
  final bool loading;

  const FormActions({super.key, this.leading, required this.label, required this.onPressed, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 12)],
        Expanded(child: PrimaryButton(label: loading ? 'Please wait...' : label, onPressed: loading ? null : onPressed)),
      ],
    );
  }
}
