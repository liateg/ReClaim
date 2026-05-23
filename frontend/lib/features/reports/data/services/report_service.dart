import 'package:dio/dio.dart';
import '../models/report_model.dart';

class ReportService {
  final Dio _dio;

  ReportService(this._dio);

  Future<List<Report>> getMyReports() async {
    try {
      final response = await _dio.get('/reports/my');
      if (response.data['reports'] is List) {
        return (response.data['reports'] as List)
            .map((json) => Report.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Report>> getAllReports() async {
    try {
      final response = await _dio.get('/reports');
      if (response.data['reports'] is List) {
        return (response.data['reports'] as List)
            .map((json) => Report.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Report> getReportById(String id) async {
    try {
      final response = await _dio.get('/reports/$id');
      return Report.fromJson(response.data['report']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createReport({
    int? itemId,
    int? claimId,
    required String reason,
    String? description,
  }) async {
    try {
      await _dio.post('/reports', data: {
        'itemId': itemId,
        'claimId': claimId,
        'reason': reason,
        'description': description,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateReportStatus(
    String id,
    String status, {
    String? adminNote,
  }) async {
    try {
      await _dio.put('/reports/$id/status', data: {
        'status': status,
        'adminNote': adminNote,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteReport(String id) async {
    try {
      await _dio.delete('/reports/$id');
    } catch (e) {
      rethrow;
    }
  }
}
