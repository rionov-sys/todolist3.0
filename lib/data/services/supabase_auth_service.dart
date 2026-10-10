import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    hide AuthUser, AuthException;

import '../../core/config/app_config.dart';
import 'auth_backend.dart';
import 'auth_service.dart';

/// Supabase Auth implementation of [AuthBackend].
///
/// * credentials live in Supabase (bcrypt hashed server-side) — never on device
/// * `name` / `focus` are mirrored into a public `profiles` table so the
///   Profile screen can greet the user and preselect their focus category
/// * the session is persisted by `supabase_flutter`, so "Ingat saya" is
///   inherent — no extra local storage is needed
class SupabaseAuthService implements AuthBackend {
  SupabaseAuthService(this._client);

  final SupabaseClient _client;

  AuthUser? _cached;

  @override
  Future<AuthUser?> currentUser() async {
    final User? user = _client.auth.currentUser;
    if (user == null) {
      _cached = null;
      return null;
    }
    return _cached ??= await _loadProfile(user);
  }

  @override
  Future<String?> rememberedEmail() async =>
      _client.auth.currentUser?.email;

  @override
  Future<AuthUser> register({
    required String name,
    required String email,
    required String password,
    required String focus,
  }) async {
    final String cleanName = name.trim();
    final String cleanEmail = email.trim().toLowerCase();
    final String cleanFocus =
        focus.trim().isEmpty ? 'Pribadi' : focus.trim();

    if (cleanName.length < 3) {
      throw AuthException('Nama lengkap minimal 3 karakter.');
    }
    if (!_isEmail(cleanEmail)) {
      throw AuthException('Masukkan alamat email yang valid.');
    }
    if (password.length < 8) {
      throw AuthException('Kata sandi minimal 8 karakter.');
    }

    final AuthResponse response;
    try {
      response = await _client.auth.signUp(
        email: cleanEmail,
        password: password,
        data: <String, dynamic>{'name': cleanName, 'focus': cleanFocus},
      );
    } on AuthException catch (error) {
      throw AuthException(_friendly(error.message));
    }

    final User? user = response.user;
    if (user == null) {
      throw AuthException(
        'Registrasi gagal. Matikan konfirmasi email di dashboard Supabase, '
        'lalu coba lagi.',
      );
    }

    // No session means the project still requires email confirmation
    // ("Confirm email" is ON). Without a session, `auth.uid()` is null, so
    // every task insert would be rejected by RLS and silently queued offline.
    // Surface it now instead of letting the user think they're logged in.
    if (response.session == null) {
      throw AuthException(
        'Akun dibuat, tapi email perlu dikonfirmasi dulu. '
        'Cek kotak masuk kamu, atau matikan "Confirm email" di Supabase '
        '(Authentication → Providers → Email) untuk mode uji.',
      );
    }

    // Best-effort profile mirror; auth itself already succeeded above.
    try {
      await _client.from('profiles').upsert(<String, dynamic>{
        'id': user.id,
        'name': cleanName,
        'focus': cleanFocus,
      });
    } catch (_) {
      // Ignored: the profile falls back to user metadata below.
    }

    final AuthUser authUser = AuthUser(
      name: cleanName,
      email: (user.email ?? cleanEmail).trim(),
      focus: cleanFocus,
    );
    _cached = authUser;
    return authUser;
  }

  @override
  Future<AuthUser> login({
    required String emailOrUsername,
    required String password,
    required bool rememberMe,
  }) async {
    final String email = emailOrUsername.trim().toLowerCase();
    if (email.isEmpty || password.isEmpty) {
      throw AuthException('Email dan kata sandi wajib diisi.');
    }
    if (!_isEmail(email)) {
      throw AuthException('Masukkan alamat email yang valid.');
    }

    try {
      await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (error) {
      throw AuthException(_friendly(error.message));
    }

    final User? user = _client.auth.currentUser;
    if (user == null) {
      throw AuthException('Email atau kata sandi salah. Coba lagi ya.');
    }
    return _cached = await _loadProfile(user);
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    // 1. Configure the native Google plugin with the Web OAuth client id.
    //    Supabase verifies the returned idToken against this same client.
    final GoogleSignIn googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize(
      clientId: AppConfig.googleIosClientId.isNotEmpty
          ? AppConfig.googleIosClientId
          : null,
      serverClientId: AppConfig.googleWebClientId,
    );

    // 2. Open the native account picker.
    final GoogleSignInAccount account;
    try {
      account = await googleSignIn.authenticate();
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw AuthException('Masuk dengan Google dibatalkan.');
      }
      throw AuthException(
        'Gagal masuk dengan Google. Periksa koneksi lalu coba lagi.',
      );
    }

    // 3. Exchange the Google account for tokens Supabase can validate.
    final GoogleSignInAuthentication googleAuth = account.authentication;
    final String? idToken = googleAuth.idToken;
    if (idToken == null) {
      throw AuthException(
        'Tidak dapat memverifikasi akun Google. Coba lagi ya.',
      );
    }

    // 4. Hand the idToken to Supabase → real session.
    try {
      await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
    } on AuthException catch (error) {
      throw AuthException(_friendly(error.message));
    }

    final User? user = _client.auth.currentUser;
    if (user == null) {
      throw AuthException('Sesi Google tidak terbentuk. Coba lagi ya.');
    }

    final AuthUser authUser = await _loadProfile(user);
    _cached = authUser;

    // 5. Backfill a sensible focus for first-time Google users so the Profile
    //    screen is never blank.
    try {
      await _client.from('profiles').upsert(<String, dynamic>{
        'id': user.id,
        'name': authUser.name,
        'focus': authUser.focus,
      });
    } catch (_) {
      // Ignored — profile falls back to email/metadata.
    }
    return authUser;
  }

  @override
  Future<void> logout() async {
    _cached = null;
    await _client.auth.signOut();
  }

  /// Reads the profile row, falling back to signup metadata / email local part.
  Future<AuthUser> _loadProfile(User user) async {
    String name = (user.userMetadata?['name'] as String?) ?? '';
    String focus = (user.userMetadata?['focus'] as String?) ?? 'Pribadi';

    try {
      final Map<String, dynamic>? row = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      if (row != null) {
        name = (row['name'] as String?) ?? name;
        focus = (row['focus'] as String?) ?? focus;
      }
    } catch (_) {
      // Offline or table missing: metadata fallback is good enough.
    }

    if (name.trim().isEmpty) {
      final String local = (user.email ?? '').split('@').first;
      name = local.isEmpty ? 'Pengguna' : local;
    }
    return AuthUser(
      name: name.trim(),
      email: (user.email ?? '').trim(),
      focus: focus.trim().isEmpty ? 'Pribadi' : focus.trim(),
    );
  }

  /// Maps Supabase's English messages onto the app's Indonesian copy.
  String _friendly(String raw) {
    final String message = raw.toLowerCase();
    if (message.contains('invalid login credentials')) {
      return 'Email atau kata sandi salah. Coba lagi ya.';
    }
    if (message.contains('already registered') ||
        message.contains('already been registered')) {
      return 'Email ini sudah terdaftar. Silakan masuk.';
    }
    if (message.contains('email not confirmed')) {
      return 'Email belum dikonfirmasi. Cek kotak masuk kamu.';
    }
    if (message.contains('rate limit')) {
      return 'Terlalu banyak percobaan. Tunggu sebentar lalu coba lagi.';
    }
    return 'Gagal masuk. Periksa koneksi lalu coba lagi.';
  }

  bool _isEmail(String value) {
    if (!value.contains('@') || !value.contains('.')) return false;
    final List<String> parts = value.split('@');
    return parts.length == 2 &&
        parts[0].isNotEmpty &&
        parts[1].contains('.') &&
        !parts[1].startsWith('.');
  }
}
