import 'package:flutter/material.dart';

class Spacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

class RadiusTokens {
  static const Radius sm = Radius.circular(8);
  static const Radius md = Radius.circular(12);
  static const Radius lg = Radius.circular(16);
}

class AppShadows {
  static List<BoxShadow> card = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}

class AppText {
  static TextStyle sectionTitle(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600);
  static TextStyle metricValue(BuildContext context) =>
      Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w700);
  static TextStyle subtle(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black54);
}
