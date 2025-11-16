import 'package:flutter/material.dart';

enum SnackKind { info, success, warning, error }

class AppSnackbars {
  static void show(
    BuildContext context, {
    required String message,
    SnackKind kind = SnackKind.info,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final cs = Theme.of(context).colorScheme;
    final Color bg;
    final Color fg = Colors.white;
    switch (kind) {
      case SnackKind.success:
        bg = Colors.green.shade600;
        break;
      case SnackKind.warning:
        bg = Colors.orange.shade700;
        break;
      case SnackKind.error:
        bg = Colors.red.shade700;
        break;
      case SnackKind.info:
        bg = cs.primary;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: fg)),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        action: actionLabel != null
            ? SnackBarAction(label: actionLabel, onPressed: onAction ?? () {})
            : null,
      ),
    );
  }

  static void success(BuildContext context, String message) =>
      show(context, message: message, kind: SnackKind.success);
  static void info(BuildContext context, String message) =>
      show(context, message: message, kind: SnackKind.info);
  static void warn(BuildContext context, String message) =>
      show(context, message: message, kind: SnackKind.warning);
  static void error(BuildContext context, String message) =>
      show(context, message: message, kind: SnackKind.error);
}
