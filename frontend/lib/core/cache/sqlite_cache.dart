import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Simple key-value cache using sqflite.
/// Stores JSON-encoded values with optional expiry (epoch millis).
class SqliteCache {
  static final SqliteCache _instance = SqliteCache._internal();
  factory SqliteCache() => _instance;
  SqliteCache._internal();

  Database? _db;

  /// Initialize the database. If [dbPath] is provided, it will be used
  /// directly (useful for tests, e.g. ':memory:'). Otherwise the
  /// application documents directory is used.
  Future<void> init({String? dbPath}) async {
    if (_db != null) return;
    String path;
    if (dbPath != null && dbPath.isNotEmpty) {
      path = dbPath;
    } else {
      final dir = await getApplicationDocumentsDirectory();
      path = p.join(dir.path, 'frontend_cache.db');
    }
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cache (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL,
            expiry INTEGER
          );
        ''');
      },
    );
  }

  Future<void> set(String key, Object value, {Duration? ttl}) async {
    await init();
    final json = jsonEncode(value);
    final expiry =
        ttl == null ? null : DateTime.now().add(ttl).millisecondsSinceEpoch;
    await _db!.insert(
      'cache',
      {'key': key, 'value': json, 'expiry': expiry},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<T?> get<T>(String key) async {
    await init();
    final rows =
        await _db!.query('cache', where: 'key = ?', whereArgs: [key], limit: 1);
    if (rows.isEmpty) return null;
    final row = rows.first;
    final expiry = row['expiry'] as int?;
    if (expiry != null && DateTime.now().millisecondsSinceEpoch > expiry) {
      // expired
      await delete(key);
      return null;
    }
    final value = row['value'] as String;
    final decoded = jsonDecode(value) as T;
    return decoded;
  }

  Future<void> delete(String key) async {
    await init();
    await _db!.delete('cache', where: 'key = ?', whereArgs: [key]);
  }

  Future<void> clear() async {
    await init();
    await _db!.delete('cache');
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
