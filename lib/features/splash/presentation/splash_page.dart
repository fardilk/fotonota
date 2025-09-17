import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/utils/prefs_helper.dart';
import '../../../core/config/route_names.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Mimic minimal load; could await services init here
    await Future.delayed(const Duration(milliseconds: 600));
    final seen = await PrefsHelper.isOnboardingSeen();
    if (!mounted) return;
    if (seen) {
      Navigator.pushReplacementNamed(context, RouteNames.login);
    } else {
      Navigator.pushReplacementNamed(context, RouteNames.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App splash logo
            Image.asset(
              'assets/images/logo/logo-snap-cash-log.png',
              height: 140,
              fit: BoxFit.contain,
              errorBuilder: (c, e, st) => const Icon(Icons.image_not_supported, size: 120, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
