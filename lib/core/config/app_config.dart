/// Compile-time configuration.
///
/// The API base URL can be overridden per platform without code changes:
///
/// ```sh
/// # Web / Windows / macOS (backend running locally)
/// flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080/api
///
/// # Android emulator (host machine loopback)
/// flutter run -d <device> --dart-define=API_BASE_URL=http://10.0.2.2:8080/api
/// ```
abstract final class AppConfig {
  AppConfig._();

  /// Defaults to the host loopback that works on web/desktop.
  /// Point it at your backend before shipping.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api',
  );

  /// Every HTTP call is capped so the UI never hangs on a dead connection.
  static const Duration httpTimeout = Duration(seconds: 6);

  /// Display name used in greetings.
  static const String userName = 'Rifat';

  /// App-wide accent used in the header wordmark.
  static const String appName = 'KeepGrinding';
}