// lib/features/reports/riverpod/report_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../reports/data/models/report_model.dart';
import '../../reports/data/services/report_service.dart';

final reportServiceProvider = Provider((ref) => ReportService());

final myReportsProvider = FutureProvider<List<Report>>((ref) async {
  final service = ref.read(reportServiceProvider);
  return await service.getMyReports();
});

final allReportsProvider = FutureProvider<List<Report>>((ref) async {
  final service = ref.read(reportServiceProvider);
  return await service.getAllReports();
});

final reportDetailProvider =
    FutureProvider.family<Report, String>((ref, id) async {
  final service = ref.read(reportServiceProvider);
  return await service.getReportById(id);
});

final createReportProvider =
    FutureProvider.family<void, Map<String, dynamic>>((ref, data) async {
  final service = ref.read(reportServiceProvider);
  await service.createReport(
    itemId: data['itemId'] as int?,
    claimId: data['claimId'] as int?,
    reason: data['reason'],
    description: data['description'],
  );

  ref.invalidate(myReportsProvider);
  ref.invalidate(allReportsProvider);
});

final updateReportStatusProvider =
    FutureProvider.family<void, Map<String, dynamic>>((ref, data) async {
  final service = ref.read(reportServiceProvider);
  await service.updateReportStatus(
    data['id'],
    data['status'],
    adminNote: data['adminNote'],
  );
  ref.invalidate(allReportsProvider);
  ref.invalidate(reportDetailProvider(data['id']));
});
final deleteReportProvider =
    FutureProvider.family<void, String>((ref, id) async {
  final service = ref.read(reportServiceProvider);
  await service.deleteReport(id);
  ref.invalidate(myReportsProvider);
  ref.invalidate(allReportsProvider);
});