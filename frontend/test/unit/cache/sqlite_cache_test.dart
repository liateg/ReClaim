import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/cache/sqlite_cache.dart';

import '../../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SqliteCache cache;

  setUpAll(() async {
    cache = await initInMemoryCache();
  });

  setUp(() async {
    await cache.clear();
  });

  tearDownAll(() async {
    await cache.close();
  });

  group('SqliteCache set/get', () {
    test('stores and retrieves a map', () async {
      await cache.set('m', {'a': 1, 'b': 'two'});
      final value = await cache.get<Map<String, dynamic>>('m');
      expect(value, isNotNull);
      expect(value!['a'], 1);
      expect(value['b'], 'two');
    });

    test('stores and retrieves a list', () async {
      await cache.set('list', [1, 2, 3]);
      final value = await cache.get<List<dynamic>>('list');
      expect(value, [1, 2, 3]);
    });

    test('returns null for missing keys', () async {
      expect(await cache.get('missing'), isNull);
    });

    test('replaces existing values on conflict', () async {
      await cache.set('k', 'first');
      await cache.set('k', 'second');
      expect(await cache.get<String>('k'), 'second');
    });
  });

  group('SqliteCache expiry', () {
    test('honors a TTL', () async {
      await cache.set('temp', 'v', ttl: const Duration(milliseconds: 80));
      expect(await cache.get<String>('temp'), 'v');
      await Future<void>.delayed(const Duration(milliseconds: 130));
      expect(await cache.get<String>('temp'), isNull);
    });

    test('values without TTL never expire', () async {
      await cache.set('persist', 'v');
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(await cache.get<String>('persist'), 'v');
    });
  });

  group('SqliteCache delete/clear', () {
    test('delete removes a single key', () async {
      await cache.set('a', 1);
      await cache.set('b', 2);
      await cache.delete('a');
      expect(await cache.get('a'), isNull);
      expect(await cache.get<int>('b'), 2);
    });

    test('clear removes everything', () async {
      await cache.set('a', 1);
      await cache.set('b', 2);
      await cache.clear();
      expect(await cache.get('a'), isNull);
      expect(await cache.get('b'), isNull);
    });
  });
}
