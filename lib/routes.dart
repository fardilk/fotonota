import 'package:flutter/material.dart';
import 'core/config/route_names.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/auth/presentation/login_success_page.dart';
import 'features/auth/presentation/register_page.dart';
import 'features/dashboard/presentation/dashboard_page.dart';
import 'features/camera/presentation/pages/camera_page.dart';
import 'features/report/presentation/report_page.dart';
import 'features/report/presentation/revenue_page.dart';
import 'features/splash/presentation/splash_page.dart';
import 'features/onboarding/presentation/onboarding_page.dart';

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case RouteNames.splash:
      return MaterialPageRoute(builder: (_) => const SplashPage());
    case RouteNames.onboarding:
      return MaterialPageRoute(builder: (_) => const OnboardingPage());
    case RouteNames.login:
      return MaterialPageRoute(builder: (_) => const LoginPage());
    case RouteNames.register:
      return MaterialPageRoute(builder: (_) => const RegisterPage());
    case RouteNames.loginSuccess:
      return MaterialPageRoute(builder: (_) => const LoginSuccessPage());
    case RouteNames.dashboard:
      return MaterialPageRoute(builder: (_) => const DashboardPage());
    case RouteNames.camera:
      return MaterialPageRoute(builder: (_) => const CameraPage());
    case RouteNames.report:
      return MaterialPageRoute(builder: (_) => const ReportPage());
    case RouteNames.revenue:
      return MaterialPageRoute(builder: (_) => const RevenuePage());
  }
  return null;
}
