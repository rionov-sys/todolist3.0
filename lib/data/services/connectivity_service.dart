import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Reports connectivity changes so the app can show an offline banner and
/// auto-resynchronise when the connection returns.
class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  /// Emits the current state first, then every change.
  ///
  /// Never throws: platforms without connectivity support optimistically
  /// report "online" and let the HTTP layer decide.
  Stream<bool> onlineStream() async* {
    yield await isOnline();
    yield* _connectivity.onConnectivityChanged
        .map((List<ConnectivityResult> results) => _anyOnline(results))
        .distinct();
  }

  Future<bool> isOnline() async {
    try {
      final List<ConnectivityResult> results =
          await _connectivity.checkConnectivity();
      return _anyOnline(results);
    } on Exception catch (error) {
      debugPrint('Connectivity check failed: $error');
      return true;
    }
  }

  bool _anyOnline(List<ConnectivityResult> results) =>
      results.isNotEmpty && results.any((ConnectivityResult r) => r != ConnectivityResult.none);
}