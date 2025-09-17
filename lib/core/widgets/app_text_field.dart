import 'package:flutter/material.dart';
import '../utils/validators.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscure;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final VoidCallback? onSubmittedAction;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onSubmittedAction,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
  });

  factory AppTextField.username({
    required TextEditingController controller,
  }) => AppTextField(
        controller: controller,
        label: 'Username',
        hint: 'Enter username',
        prefixIcon: const Icon(Icons.person_outline),
        validator: (v) => Validators.notEmpty(v, fieldName: 'Username'),
        textInputAction: TextInputAction.next,
      );

  factory AppTextField.password({
    required TextEditingController controller,
    bool last = true,
    VoidCallback? onSubmit,
  }) => AppTextField(
        controller: controller,
        label: 'Password',
        hint: 'Enter password',
        obscure: true,
        prefixIcon: const Icon(Icons.lock_outline),
        validator: (v) {
          final base = Validators.notEmpty(v, fieldName: 'Password');
            if (base != null) return base;
            if (v != null && v.length < 6) return 'Minimum 6 characters';
            return null;
        },
        textInputAction: last ? TextInputAction.done : TextInputAction.next,
        onSubmittedAction: onSubmit,
      );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      enabled: enabled,
      onFieldSubmitted: (_) => onSubmittedAction?.call(),
    );
  }
}
