import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/cache/sqlite_cache.dart';
import 'package:frontend/features/reports/data/services/report_service.dart';
import 'package:frontend/features/reports/Riverpod/report_provider.dart';

import '../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SqliteCache cache;
  const token = 'abcdefghijklmnopqrstuvwxy';
  final tokenPart = token.substring(0, 20);

  setUpAll(() async {
    cache = await initInMemoryCache();
  });

  setUp(() async {
    mockSecureStorage({'token': token});
    await cache.clear();
  });

  tearDown(() {
    clearSecureStorageMock();
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  Map<String, dynamic> reportJson(int id) => {
        'id': id,
        'reporter_id': 1,
        'reason': 'fake',
        'status': 'pending',
      };

  test('reportServiceProvider provides a ReportService', () {
    final container = makeContainer();
    expect(container.read(reportServiceProvider), isA<ReportService>());
  });

  test('myReportsProvider resolves cached reports', () async {
    await cache.set('reports_my_$tokenPart', [reportJson(1), reportJson(2)]);
    final container = makeContainer();
    final reports = await container.read(myReportsProvider.future);
    expect(reports, hasLength(2));
    expect(reports.first.id, 1);
  });

  test('allReportsProvider resolves cached reports', () async {
    await cache.set('reports_all_$tokenPart', [reportJson(3)]);
    final container = makeContainer();
    final reports = await container.read(allReportsProvider.future);
    expect(reports.single.id, 3);
  });

  test('reportDetailProvider resolves a cached report by id', () async {
    await cache.set('report_77', reportJson(77));
    final container = makeContainer();
    final report = await container.read(reportDetailProvider('77').future);
    expect(report.id, 77);
  });
}
