import 'package:test/test.dart';
import 'package:frontend/core/cache/sqlite_cache.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('SqliteCache', () {
    final cache = SqliteCache();

    setUpAll(() async {
      // Initialize ffi implementation for sqflite so tests run in the Dart VM
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      await cache.init(dbPath: inMemoryDatabasePath);
    });

    tearDownAll(() async {
      await cache.close();
    });

    test('set and get', () async {
      await cache.set('k1', {'a': 1});
      final v = await cache.get<Map<String, dynamic>>('k1');
      expect(v, isNotNull);
      expect(v!['a'], 1);
    });

    test('expiry works', () async {
      await cache.set('k2', 'v', ttl: Duration(milliseconds: 100));
      final v1 = await cache.get<String>('k2');
      expect(v1, 'v');
      await Future.delayed(Duration(milliseconds: 150));
      final v2 = await cache.get<String>('k2');
      expect(v2, isNull);
    });

    test('delete and clear', () async {
      await cache.set('k3', 123);
      await cache.delete('k3');
      final v = await cache.get('k3');
      expect(v, isNull);
      await cache.set('k4', 'x');
      await cache.clear();
      final v2 = await cache.get('k4');
      expect(v2, isNull);
    });
  });
}
