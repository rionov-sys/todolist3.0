import 'package:flutter/foundation.dart';

import '../data/services/auth_backend.dart';
import '../data/services/auth_service.dart' show AuthException, AuthUser;

/// Session state for the login/register flow.
///
/// Kept separate from [TaskProvider] so auth stays testable and the
/// shell can react to login/logout with a single `notifyListeners`.
class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required AuthBackend service,
    this.onSessionChanged,
  }) : _service = service; // ignore: prefer_initializing_formals

  final AuthBackend _service;

  /// Fired with the new signed-in state so the task list can reload (or clear
  /// its cache) the moment the user switches account.
  final void Function(bool isLoggedIn)? onSessionChanged;

  AuthUser? _user;
  bool _busy = false;
  String? _error;

  AuthUser? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get busy => _busy;
  String? get error => _error;

  /// Restores a persisted session on cold start.
  Future<void> bootstrap() async {
    _user = await _service.currentUser();
    notifyListeners();
  }

  /// Email suggested for the "Ingat saya" prefill.
  Future<String?> rememberedEmail() => _service.rememberedEmail();

  Future<bool> login({
    required String emailOrUsername,
    required String password,
    required bool rememberMe,
  }) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      // Small delay so the button loading state is visible (matches mock).
      await Future<void>.delayed(const Duration(milliseconds: 700));
      _user = await _service.login(
        emailOrUsername: emailOrUsername,
        password: password,
        rememberMe: rememberMe,
      );
      onSessionChanged?.call(true);
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String focus,
  }) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      _user = await _service.register(
        name: name,
        email: email,
        password: password,
        focus: focus,
      );
      onSessionChanged?.call(true);
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle() async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _service.signInWithGoogle();
      onSessionChanged?.call(true);
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _service.logout();
    _user = null;
    onSessionChanged?.call(false);
    notifyListeners();
  }
}
