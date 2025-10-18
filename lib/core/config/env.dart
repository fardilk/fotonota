enum MockMode { success, empty, error }

class Env {
  static const useMock = String.fromEnvironment('USE_MOCK', defaultValue: 'false') == 'true';
  static const initFirebase = String.fromEnvironment('INIT_FIREBASE', defaultValue: 'true') == 'true';
  static const showDebugMenu = String.fromEnvironment('SHOW_DEBUG_MENU', defaultValue: 'false') == 'true';
  static const appName = String.fromEnvironment('APP_NAME', defaultValue: 'Fotonota');

  static final mockMode = () {
    const v = String.fromEnvironment('MOCK_MODE', defaultValue: 'success');
    switch (v.toLowerCase()) {
      case 'empty':
        return MockMode.empty;
      case 'error':
        return MockMode.error;
      case 'success':
      default:
        return MockMode.success;
    }
  }();
}
