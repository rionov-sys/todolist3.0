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

  /// Supabase project URL — override with --dart-define to keep secrets out
  /// of source control:
  ///
  /// ```sh
  /// flutter run \
  ///   --dart-define=SUPABASE_URL=https://xyzcompany.supabase.co \
  ///   --dart-define=SUPABASE_ANON_KEY=eyJhbGciOi...
  /// ```
  ///
  /// Without defines the app boots in local-only mode (auth + tasks served
  /// from the on-device cache), so `flutter analyze` / APK builds stay green
  /// before you wire real credentials.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Web OAuth client ID from Google Cloud Console (OAuth 2.0 Client IDs →
  /// Web client). Supabase uses it to verify the Google `idToken` on Android
  /// and iOS. Pass with --dart-define:
  ///
  /// ```sh
  /// flutter run \
  ///   --dart-define=SUPABASE_URL=https://xyz.supabase.co \
  ///   --dart-define=SUPABASE_ANON_KEY=eyJ... \
  ///   --dart-define=GOOGLE_WEB_CLIENT_ID=xxxx.apps.googleusercontent.com
  /// ```
  ///
  /// Empty = Google Sign-In disabled (button falls back to a friendly notice).
  static const String googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '',
  );

  /// iOS client ID (only needed for the iOS build; leave empty on Android).
  static const String googleIosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
    defaultValue: '',
  );

  /// True when the Web client ID was injected at build time.
  static bool get hasGoogleConfig => googleWebClientId.isNotEmpty;

  /// True once real Supabase credentials were injected at build time.
  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

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