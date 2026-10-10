import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'api_service.dart';
import 'task_remote.dart';

/// Supabase (PostgREST) implementation of [TaskRemote].
///
/// * rows are scoped per user by Row Level Security, so no `user_id` filter is
///   needed in the query — only attached on insert
/// * snake_case columns are translated to the camelCase shape expected by
///   [Task.fromJson]
/// * every Supabase/transport failure is funnelled through [_guard] so the
///   repository's existing `on ApiException` fallback keeps working untouched
class SupabaseRemote implements TaskRemote {
  SupabaseRemote(this._client);

  final SupabaseClient _client;

  static const String _table = 'tasks';

  @override
  Future<dynamic> getList(String path) async {
    return _guard<List<Map<String, dynamic>>>(() async {
      final List<dynamic> rows = await _client
          .from(_table)
          .select()
          .order('date', ascending: true);
      return rows
          .map<Map<String, dynamic>>(
            (dynamic row) => _fromRow(Map<String, dynamic>.from(row as Map)),
          )
          .toList();
    });
  }

  @override
  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    return _guard<Map<String, dynamic>>(() async {
      final Map<String, dynamic> row = await _client
          .from(_table)
          .insert(_toRow(body))
          .select()
          .single();
      return _fromRow(row);
    });
  }

  @override
  Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    final String id = (body['id'] as String?) ?? _idFromPath(path);
    return _guard<Map<String, dynamic>>(() async {
      final Map<String, dynamic> row = await _client
          .from(_table)
          .update(_toRow(body))
          .eq('id', id)
          .select()
          .single();
      return _fromRow(row);
    });
  }

  @override
  Future<void> delete(String path) async {
    final String id = _idFromPath(path);
    await _guard<void>(() async {
      await _client.from(_table).delete().eq('id', id);
    });
  }

  /// Extracts the trailing id from a `tasks/<uuid>` style path.
  String _idFromPath(String path) {
    final String trimmed =
        path.startsWith('/') ? path.substring(1) : path;
    final int slash = trimmed.lastIndexOf('/');
    return slash >= 0 ? trimmed.substring(slash + 1) : trimmed;
  }

  Map<String, dynamic> _toRow(Map<String, dynamic> body) {
    final Map<String, dynamic> row = <String, dynamic>{
      'title': body['title'],
      'description': body['description'] ?? '',
      'category': body['category'],
      'status': body['status'],
      'date': body['date'],
      'time': body['time'],
      'estimate_minutes': body['estimateMinutes'],
      'progress': body['progress'],
      'high_priority': body['highPriority'],
      'tag': body['tag'],
      'meta': body['meta'],
      'points': body['points'],
      'updated_at': body['updatedAt'] ?? DateTime.now().toIso8601String(),
    };
    // RLS enforces ownership; we still stamp the owner so the policy has the
    // value it checks against.
    final String? userId = _client.auth.currentUser?.id;
    if (userId != null) row['user_id'] = userId;
    return row;
  }

  Map<String, dynamic> _fromRow(Map<String, dynamic> row) {
    return <String, dynamic>{
      'id': row['id'] as String? ?? '',
      'title': row['title'],
      'description': row['description'],
      'category': row['category'],
      'status': row['status'],
      'date': row['date'],
      'time': row['time'],
      'estimateMinutes': row['estimate_minutes'],
      'progress': row['progress'],
      'highPriority': row['high_priority'],
      'tag': row['tag'],
      'meta': row['meta'],
      'points': row['points'],
      'updatedAt': row['updated_at'],
    };
  }

  /// Normalises every failure mode into [ApiException].
  ///
  /// `dart:io` is deliberately *not* imported so the web build keeps working —
  /// socket failures land in the final `catch` branch instead.
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException {
      rethrow;
    } on AuthApiException {
      throw ApiException(
        'Sesi berakhir. Silakan masuk kembali.',
        statusCode: 401,
      );
    } on AuthException {
      throw ApiException(
        'Sesi berakhir. Silakan masuk kembali.',
        statusCode: 401,
      );
    } on PostgrestException catch (error) {
      throw ApiException(
        error.message.isNotEmpty
            ? error.message
            : 'Gagal menyimpan data ke server.',
        statusCode: error.code == '23505' ? 409 : 400,
      );
    } on TimeoutException {
      throw ApiException('Koneksi terlalu lambat. Periksa jaringanmu.');
    } on http.ClientException {
      throw ApiException(
        'Tidak dapat terhubung ke server. Periksa koneksi internetmu.',
      );
    } catch (error) {
      debugPrint('Supabase remote error: $error');
      throw ApiException('Koneksi terputus. Periksa jaringan internetmu.');
    }
  }
}
