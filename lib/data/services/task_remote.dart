/// Backend-agnostic contract for remote task storage.
///
/// The offline-first repository (`TaskRepositoryImpl`) only knows this
/// interface, so the exact same cache + outbox logic works whether the remote
/// is the REST [ApiService] or the Supabase implementation. Swap them once in
/// `main.dart` — no state-layer changes required.
///
/// Implementations must normalise every transport failure into an
/// [ApiException] carrying a user-friendly Indonesian message.
abstract interface class TaskRemote {
  Future<dynamic> getList(String path);

  Future<dynamic> post(String path, Map<String, dynamic> body);

  Future<dynamic> patch(String path, Map<String, dynamic> body);

  Future<void> delete(String path);
}
