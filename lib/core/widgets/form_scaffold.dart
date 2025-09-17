import 'package:flutter/material.dart';

class FormScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const FormScaffold({super.key, required this.title, this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (subtitle != null) Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium)),
            child,
          ],
        ),
      ),
    );
  }
}
