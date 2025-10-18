import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/config/app_theme.dart';
import 'core/config/route_names.dart';
import 'routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/env.dart';
import 'core/widgets/demo_watermark.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Env.initFirebase) {
    await Firebase.initializeApp();
  }
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Env.appName,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      initialRoute: RouteNames.splash,
      onGenerateRoute: onGenerateRoute,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        if (Env.showDebugMenu && child != null) return DemoWatermark(child: child);
        return child!;
      },
    );
  }
}
