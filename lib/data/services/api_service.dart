import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import 'task_remote.dart';

/// Error surfaced by [ApiService] with a user-friendly Indonesian message.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Thin REST wrapper around `package:http`.
///
/// * every call is capped by [AppConfig.httpTimeout] so the UI never hangs
/// * transport errors (offline, DNS, refused connection, TLS…) are normalised
///   into a single [ApiException] with a human-readable message
/// * non-2xx responses are mapped to contextual messages
///
/// Implements [TaskRemote] so the repository can swap in a Supabase backend
/// without any change to its offline-first logic.
class ApiService implements TaskRemote {
  ApiService({required String baseUrl, http.Client? client})
      : _baseUrl =
            baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl,
        _client = client ?? http.Client();

  final String _baseUrl;
  final http.Client _client;

  Uri _uri(String path) =>
      Uri.parse('$_baseUrl/${path.startsWith('/') ? path.substring(1) : path}');

  @override
  Future<dynamic> getList(String path) async =>
      _decode(await _send(() => _client.get(_uri(path))));

  @override
  Future<dynamic> post(String path, Map<String, dynamic> body) async =>
      _decode(await _send(
        () => _client.post(
          _uri(path),
          headers: const <String, String>{'Content-Type': 'application/json'},
          body: jsonEncode(body),
        ),
      ));

  @override
  Future<dynamic> patch(String path, Map<String, dynamic> body) async =>
      _decode(await _send(
        () => _client.patch(
          _uri(path),
          headers: const <String, String>{'Content-Type': 'application/json'},
          body: jsonEncode(body),
        ),
      ));

  @override
  Future<void> delete(String path) async {
    await _send(() => _client.delete(_uri(path)));
  }

  Future<http.Response> _send(
    Future<http.Response> Function() request,
  ) async {
    try {
      final http.Response response =
          await request().timeout(AppConfig.httpTimeout);
      return _validate(response);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException('Koneksi terlalu lambat. Periksa jaringanmu.');
    } on http.ClientException {
      throw ApiException(
          'Tidak dapat terhubung ke server. Periksa koneksi internetmu.');
    } on FormatException {
      throw ApiException('Respons server tidak valid.');
    } on Exception catch (error) {
      // Covers dart:io SocketException on VM targets without importing
      // dart:io (which would break the web build).
      debugPrint('API transport error: $error');
      throw ApiException('Koneksi terputus. Periksa jaringan internetmu.');
    }
  }

  http.Response _validate(http.Response response) {
    final int code = response.statusCode;
    if (code >= 200 && code < 300) return response;
    if (code == 401 || code == 403) {
      throw ApiException('Sesi berakhir. Silakan masuk kembali.',
          statusCode: code);
    }
    if (code == 404) {
      throw ApiException('Data tidak ditemukan di server.', statusCode: code);
    }
    if (code >= 500) {
      throw ApiException('Server sedang bermasalah. Coba lagi nanti.',
          statusCode: code);
    }
    throw ApiException('Permintaan gagal (HTTP $code).', statusCode: code);
  }

  dynamic _decode(http.Response response) {
    if (response.body.isEmpty) return <dynamic>[];
    try {
      return jsonDecode(response.body);
    } on FormatException {
      throw ApiException('Respons server tidak dapat dibaca.');
    }
  }
}