import 'package:flutter/material.dart';

class PillBottomNav extends StatelessWidget {
  final void Function(int index) onTap;
  final int currentIndex;
  final List<IconData> icons;
  const PillBottomNav({super.key, required this.onTap, required this.currentIndex, required this.icons});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Material(
          color: cs.primary,
          elevation: 6,
          borderRadius: BorderRadius.circular(30),
          child: SizedBox(
            height: 56,
            child: Row(
              children: List.generate(icons.length, (i) {
                final radius = switch (i) { 0 => const BorderRadius.horizontal(left: Radius.circular(30)), _ => i == icons.length - 1 ? const BorderRadius.horizontal(right: Radius.circular(30)) : BorderRadius.zero };
                return Expanded(
                  child: InkWell(
                    borderRadius: radius,
                    onTap: () => onTap(i),
                    child: Center(child: Icon(icons[i], color: Colors.white)),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
