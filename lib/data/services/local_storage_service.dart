import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

/// Local JSON cache backed by `shared_preferences`.
///
/// Corrupt or missing data never throws — it degrades to `null` so the
/// repository can fall back to the bundled demo set.
class LocalStorageService {
  LocalStorageService(this._prefs);

  final SharedPreferences _prefs;

  static const String _kTasks = 'kg_tasks_v1';
  static const String _kOutbox = 'kg_outbox_v1';

  List<Task>? readTasks() {
    try {
      final String? raw = _prefs.getString(_kTasks);
      if (raw == null || raw.isEmpty) return null;
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map<Task>(
            (dynamic item) =>
                Task.fromJson(item as Map<String, dynamic>),
          )
          .where((Task task) => task.id.isNotEmpty)
          .toList();
    } on Exception {
      return null;
    }
  }

  Future<bool> saveTasks(List<Task> tasks) async {
    try {
      return await _prefs.setString(
        _kTasks,
        jsonEncode(tasks.map((Task t) => t.toJson()).toList()),
      );
    } on Exception catch (error) {
      debugPrint('saveTasks failed: $error');
      return false;
    }
  }

  /// Pending remote mutations waiting for the connection to come back.
  List<Map<String, dynamic>> readOutbox() {
    try {
      final String? raw = _prefs.getString(_kOutbox);
      if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
      return (jsonDecode(raw) as List<dynamic>)
          .map<Map<String, dynamic>>(
            (dynamic item) =>
                Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
          )
          .toList();
    } on Exception {
      return <Map<String, dynamic>>[];
    }
  }

  Future<bool> saveOutbox(List<Map<String, dynamic>> ops) async {
    try {
      if (ops.isEmpty) return await _prefs.remove(_kOutbox);
      return await _prefs.setString(_kOutbox, jsonEncode(ops));
    } on Exception catch (error) {
      debugPrint('saveOutbox failed: $error');
      return false;
    }
  }
}