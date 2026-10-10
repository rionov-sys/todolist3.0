import 'dart:convert';

import 'auth_backend.dart';

import 'package:shared_preferences/shared_preferences.dart';

/// Simple local auth backed by `shared_preferences`.
///
/// This keeps login/register fully offline-first and dependency-free:
/// users are stored as JSON, the session stores the active email.
/// Passwords are obfuscated (base64) — demo-grade, not for production auth.
class AuthUser {
  const AuthUser({
    required this.name,
    required this.email,
    required this.focus,
  });

  final String name;
  final String email;
  final String focus;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'email': email,
        'focus': focus,
      };

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        name: (json['name'] as String? ?? '').trim(),
        email: (json['email'] as String? ?? '').trim(),
        focus: (json['focus'] as String? ?? 'Pribadi').trim(),
      );
}

class AuthException implements Exception {
  AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

class LocalAuthService implements AuthBackend {
  LocalAuthService(this._prefs);

  final SharedPreferences _prefs;

  static const String _kUsers = 'kg_users_v1';
  static const String _kSession = 'kg_session_v1';
  static const String _kRemember = 'kg_remember_v1';

  Map<String, Map<String, dynamic>> _readUsers() {
    try {
      final String? raw = _prefs.getString(_kUsers);
      if (raw == null || raw.isEmpty) return <String, Map<String, dynamic>>{};
      final Map<String, dynamic> decoded =
          Map<String, dynamic>.from(jsonDecode(raw) as Map);
      return decoded.map(
        (String k, dynamic v) =>
            MapEntry(k.toLowerCase(), Map<String, dynamic>.from(v as Map)),
      );
    } catch (_) {
      return <String, Map<String, dynamic>>{};
    }
  }

  Future<void> _writeUsers(Map<String, Map<String, dynamic>> users) =>
      _prefs.setString(_kUsers, jsonEncode(users));

  String _obfuscate(String input) =>
      base64Encode(utf8.encode('kg::$input'));

  @override
  Future<AuthUser?> currentUser() async {
    final String? email = _prefs.getString(_kSession);
    if (email == null || email.isEmpty) return null;
    final Map<String, Map<String, dynamic>> users = _readUsers();
    final Map<String, dynamic>? raw = users[email.toLowerCase()];
    if (raw == null) return null;
    return AuthUser.fromJson(raw);
  }

  @override
  Future<String?> rememberedEmail() async => _prefs.getString(_kRemember);

  @override
  Future<AuthUser> register({
    required String name,
    required String email,
    required String password,
    required String focus,
  }) async {
    final String cleanName = name.trim();
    final String cleanEmail = email.trim().toLowerCase();
    if (cleanName.length < 3) {
      throw AuthException('Nama lengkap minimal 3 karakter.');
    }
    if (!_isEmail(cleanEmail)) {
      throw AuthException('Masukkan alamat email yang valid.');
    }
    if (password.length < 8) {
      throw AuthException('Kata sandi minimal 8 karakter.');
    }
    final Map<String, Map<String, dynamic>> users = _readUsers();
    if (users.containsKey(cleanEmail)) {
      throw AuthException('Email ini sudah terdaftar. Silakan masuk.');
    }
    users[cleanEmail] = <String, dynamic>{
      'name': cleanName,
      'email': cleanEmail,
      'focus': focus.trim().isEmpty ? 'Pribadi' : focus.trim(),
      'pass': _obfuscate(password),
      'createdAt': DateTime.now().toIso8601String(),
    };
    await _writeUsers(users);
    await _prefs.setString(_kSession, cleanEmail);
    return AuthUser(
      name: cleanName,
      email: cleanEmail,
      focus: focus.trim().isEmpty ? 'Pribadi' : focus.trim(),
    );
  }

  @override
  Future<AuthUser> login({
    required String emailOrUsername,
    required String password,
    required bool rememberMe,
  }) async {
    final String key = emailOrUsername.trim().toLowerCase();
    if (key.isEmpty || password.isEmpty) {
      throw AuthException('Email dan kata sandi wajib diisi.');
    }
    final Map<String, Map<String, dynamic>> users = _readUsers();
    Map<String, dynamic>? raw = users[key];
    // Allow login with name as username fallback.
    raw ??= () {
      for (final Map<String, dynamic> u in users.values) {
        if ((u['name'] as String? ?? '').toLowerCase() == key) return u;
      }
      return null;
    }();
    if (raw == null) {
      throw AuthException('Akun tidak ditemukan. Daftar dulu yuk.');
    }
    if ((raw['pass'] as String? ?? '') != _obfuscate(password)) {
      throw AuthException('Kata sandi salah. Coba lagi ya.');
    }
    final AuthUser user = AuthUser.fromJson(raw);
    await _prefs.setString(_kSession, user.email);
    if (rememberMe) {
      await _prefs.setString(_kRemember, user.email);
    } else {
      await _prefs.remove(_kRemember);
    }
    return user;
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    // Local (offline) mode has no identity provider to delegate to. Throwing a
    // friendly [AuthException] keeps the button honest instead of pretending.
    throw AuthException(
      'Masuk dengan Google butuh koneksi ke Supabase. '
      'Aktifkan mode cloud untuk memakai fitur ini.',
    );
  }

  @override
  Future<void> logout() async => _prefs.remove(_kSession);

  bool _isEmail(String value) {
    if (!value.contains('@') || !value.contains('.')) return false;
    final List<String> parts = value.split('@');
    return parts.length == 2 &&
        parts[0].isNotEmpty &&
        parts[1].contains('.') &&
        !parts[1].startsWith('.');
  }
}
