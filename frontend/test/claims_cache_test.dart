import 'package:test/test.dart';
import 'package:frontend/core/cache/sqlite_cache.dart';
import 'package:frontend/features/claims/data/claims_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('ClaimsService cache', () {
    final cache = SqliteCache();
    final service = ClaimsService();

    setUpAll(() async {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      await cache.init(dbPath: inMemoryDatabasePath);
    });

    tearDownAll(() async {
      await cache.close();
    });

    test('returns cached claims list when present', () async {
      final sample = [
        {'id': 'a', 'title': 'A'},
        {'id': 'b', 'title': 'B'},
      ];
      await cache.set('claims:list', sample);
      final res = await service.getClaims();
      expect(res, isA<List<dynamic>>());
      expect(res.length, 2);
      expect(res[0]['id'], 'a');
    });

    test('invalidateClaimsCache clears list cache', () async {
      await cache.set('claims:list', [
        {'id': 'x'}
      ]);
      await service.invalidateClaimsCache();
      final after = await cache.get<List<dynamic>>('claims:list');
      expect(after, isNull);
    });
  });
}
