class AppConstants {
  static const String appName = 'SnapCash';
  // Base API URL. Override with --dart-define=API_BASE_URL=... for different envs.
  // Note: From Android emulator, host machine's localhost is 10.0.2.2 (or 10.0.3.2 on some emulators).
  // So if running backend on host:8081 and testing via emulator, consider using http://10.0.2.2:8081
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://snapcash-api.fardil.com',
  );
}
