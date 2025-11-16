class AppConstants {
  static const String appName = 'Fotonota';
  // Base API URL. Override with --dart-define=API_BASE_URL=... for different envs.
  // Production VPS backend
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://103.172.204.34:8081',
  );
}
