import 'package:flutter/material.dart';

class DemoWatermark extends StatelessWidget {
  final Widget child;
  const DemoWatermark({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      child,
      Positioned(
        left: 8,
        top: 8,
        child: Opacity(
          opacity: 0.6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(6)),
            child: const Text('DEMO BUILD', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    ]);
  }
}
