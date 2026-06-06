import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/cache/sqlite_cache.dart';
import 'package:frontend/features/reports/data/services/report_service.dart';

import '../helpers/test_helpers.dart';

/// Offline report flow: a seeded cache stands in for the API so the service
/// resolves "my reports", "all reports" and a single report deterministically.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SqliteCache cache;
  final service = ReportService();

  // A >=20 char token so the service's substring(0, 20) key is stable.
  const token = 'abcdefghijklmnopqrstuvwxyz';
  final tokenPart = token.substring(0, 20);

  setUpAll(() async {
    cache = await initInMemoryCache();
  });

  setUp(() async {
    mockSecureStorage({'token': token});
    await cache.clear();
  });

  tearDown(clearSecureStorageMock);

  Map<String, dynamic> reportJson(int id, String reason) => {
        'id': id,
        'reporter_id': 1,
        'reason': reason,
        'status': 'pending',
        'description': 'description for $id',
      };

  test('the reporter sees their own submitted reports', () async {
    await cache.set('reports_my_$tokenPart', [
      reportJson(1, 'spam'),
      reportJson(2, 'harassment'),
    ]);

    final mine = await service.getMyReports();

    expect(mine, hasLength(2));
    expect(mine.map((r) => r.id), containsAll([1, 2]));
    expect(mine.first.reason.name, 'spam');
  });

  test('the full list and a single report stay consistent', () async {
    await cache.set('reports_all_$tokenPart', [
      reportJson(10, 'spam'),
      reportJson(11, 'other'),
    ]);
    await cache.set('report_10', reportJson(10, 'spam'));

    final all = await service.getAllReports();
    expect(all, hasLength(2));

    final single = await service.getReportById('10');
    expect(single.id, 10);
    expect(single.description, 'description for 10');
  });
}
