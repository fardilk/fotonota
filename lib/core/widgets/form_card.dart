import 'package:flutter/material.dart';

class FormCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double elevation;
  final Color? color;
  final Duration duration;

  const FormCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.elevation = 4, this.color, this.duration = const Duration(milliseconds: 300)});

  @override
  State<FormCard> createState() => _FormCardState();
}

class _FormCardState extends State<FormCard> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: widget.duration,
      builder: (context, v, child) {
        return Opacity(
          opacity: v,
          child: Transform.translate(offset: Offset(0, (1 - v) * 8), child: child),
        );
      },
      child: Card(
        color: widget.color ?? cs.surface,
        elevation: widget.elevation,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(padding: widget.padding, child: widget.child),
      ),
    );
  }
}
