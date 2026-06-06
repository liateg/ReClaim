import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/cache/sqlite_cache.dart';

import '../helpers/test_helpers.dart';

/// Exercises the shared [SqliteCache] across the kinds of keys every feature
/// relies on: write, read back, honour TTL expiry, and clear everything.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SqliteCache cache;

  setUpAll(() async {
    cache = await initInMemoryCache();
  });

  setUp(() async {
    await cache.clear();
  });

  test('stores and reads back feature payloads of different shapes', () async {
    await cache.set('items:list', [
      {'id': '1', 'title': 'Wallet'},
    ]);
    await cache.set('claims:list', [
      {'id': 1, 'status': 'pending'},
    ]);
    await cache.set('report_5', {'id': 5, 'reason': 'spam'});

    final items = await cache.get<List>('items:list');
    final claims = await cache.get<List>('claims:list');
    final report = await cache.get<Map>('report_5');

    expect(items, isNotNull);
    expect((items!.first as Map)['title'], 'Wallet');
    expect((claims!.first as Map)['status'], 'pending');
    expect(report!['reason'], 'spam');
  });

  test('a freshly written key with no TTL survives reads', () async {
    await cache.set('items:1', {'id': '1'});
    expect(await cache.get('items:1'), isNotNull);
  });

  test('expired entries are evicted on read', () async {
    await cache.set(
      'short:lived',
      {'id': 'x'},
      ttl: const Duration(milliseconds: 1),
    );
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(await cache.get('short:lived'), isNull);
  });

  test('delete removes a single key while leaving others intact', () async {
    await cache.set('items:list', [
      {'id': '1'}
    ]);
    await cache.set('claims:list', [
      {'id': 1}
    ]);

    await cache.delete('items:list');

    expect(await cache.get('items:list'), isNull);
    expect(await cache.get('claims:list'), isNotNull);
  });

  test('clear wipes every key', () async {
    await cache.set('items:list', [
      {'id': '1'}
    ]);
    await cache.set('claims:list', [
      {'id': 1}
    ]);
    await cache.set('report_1', {'id': 1});

    await cache.clear();

    expect(await cache.get('items:list'), isNull);
    expect(await cache.get('claims:list'), isNull);
    expect(await cache.get('report_1'), isNull);
  });
}
