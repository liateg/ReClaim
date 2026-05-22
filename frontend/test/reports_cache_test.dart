import 'package:test/test.dart';
import 'package:frontend/core/cache/sqlite_cache.dart';
import 'package:frontend/features/reports/data/reports_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('ReportsService cache', () {
    final cache = SqliteCache();
    final service = ReportsService();

    setUpAll(() async {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      await cache.init(dbPath: inMemoryDatabasePath);
    });

    tearDownAll(() async {
      await cache.close();
    });

    test('returns cached reports list when present', () async {
      final sample = [
        {'id': 'r1', 'title': 'R1'},
        {'id': 'r2', 'title': 'R2'},
      ];
      await cache.set('reports:list', sample);
      final res = await service.getReports();
      expect(res, isA<List<dynamic>>());
      expect(res.length, 2);
      expect(res[0]['id'], 'r1');
    });

    test('invalidateReportsCache clears list cache', () async {
      await cache.set('reports:list', [
        {'id': 'x'}
      ]);
      await service.invalidateReportsCache();
      final after = await cache.get<List<dynamic>>('reports:list');
      expect(after, isNull);
    });
  });
}
