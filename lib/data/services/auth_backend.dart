import 'auth_service.dart';

/// Backend-agnostic auth contract.
///
/// `LocalAuthService` (shared_preferences) and `SupabaseAuthService`
/// (Supabase Auth + `profiles` table) both satisfy this interface, so
/// `AuthProvider` and the UI never change when you switch backends.
///
/// Every implementation throws [AuthException] with an Indonesian message —
/// the provider turns that straight into the inline form error.
abstract interface class AuthBackend {
  /// Restored session on cold start, or `null` when signed out.
  Future<AuthUser?> currentUser();

  /// Email suggested for the "Ingat saya" prefill.
  Future<String?> rememberedEmail();

  Future<AuthUser> register({
    required String name,
    required String email,
    required String password,
    required String focus,
  });

  Future<AuthUser> login({
    required String emailOrUsername,
    required String password,
    required bool rememberMe,
  });

  /// Native Google Sign-In. Throws [AuthException] with an Indonesian message
  /// on failure or when the provider isn't wired to a cloud backend.
  Future<AuthUser> signInWithGoogle();

  Future<void> logout();
}
