import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/cache/sqlite_cache.dart';
import 'package:frontend/features/reports/data/services/report_service.dart';

import '../../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SqliteCache cache;
  final service = ReportService();

  // A 25-char token so substring(0, 20) is stable.
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

  Map<String, dynamic> sampleReportJson(int id) => {
        'id': id,
        'reporter_id': 1,
        'reason': 'spam',
        'status': 'pending',
        'description': 'desc $id',
      };

  group('getMyReports', () {
    test('returns parsed reports from cache without hitting network', () async {
      await cache.set('reports_my_$tokenPart', [
        sampleReportJson(1),
        sampleReportJson(2),
      ]);

      final reports = await service.getMyReports();

      expect(reports, hasLength(2));
      expect(reports.first.id, 1);
      expect(reports.first.reason.name, 'spam');
    });
  });

  group('getAllReports', () {
    test('returns parsed reports from cache', () async {
      await cache.set('reports_all_$tokenPart', [sampleReportJson(9)]);

      final reports = await service.getAllReports();

      expect(reports, hasLength(1));
      expect(reports.first.id, 9);
    });
  });

  group('getReportById', () {
    test('returns a single report from cache', () async {
      await cache.set('report_42', sampleReportJson(42));

      final report = await service.getReportById('42');

      expect(report.id, 42);
      expect(report.description, 'desc 42');
    });
  });
}
