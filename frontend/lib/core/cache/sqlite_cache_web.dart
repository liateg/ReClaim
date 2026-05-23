import 'dart:convert';

/// Lightweight in-memory cache for web builds.
/// Avoids using `path_provider`/`sqflite` which are not supported on web.
class SqliteCache {
  static final SqliteCache _instance = SqliteCache._internal();
  factory SqliteCache() => _instance;
  SqliteCache._internal();

  final Map<String, Map<String, Object?>> _store = {};

  Future<void> init({String? dbPath}) async {
    // no-op on web
    return;
  }

  Future<void> set(String key, Object value, {Duration? ttl}) async {
    final json = jsonEncode(value);
    final expiry = ttl == null ? null : DateTime.now().add(ttl).millisecondsSinceEpoch;
    _store[key] = {'value': json, 'expiry': expiry};
  }

  Future<T?> get<T>(String key) async {
    final row = _store[key];
    if (row == null) return null;
    final expiry = row['expiry'] as int?;
    if (expiry != null && DateTime.now().millisecondsSinceEpoch > expiry) {
      await delete(key);
      return null;
    }
    final decoded = jsonDecode(row['value'] as String) as T;
    return decoded;
  }

  Future<void> delete(String key) async {
    _store.remove(key);
  }

  Future<void> clear() async {
    _store.clear();
  }

  Future<void> close() async {
    _store.clear();
  }
}
