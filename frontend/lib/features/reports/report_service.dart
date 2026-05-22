// lib/features/reports/data/services/report_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../model/report_model.dart';

class ReportService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String baseUrl = 'http://localhost:3000';

  ReportService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
  }

  Future<String?> _getToken() async {
    return await _storage.read(key: 'token');
  }

  // Create a report
  Future<Map<String, dynamic>> createReport({
    required String? itemId,
    required String? claimId,
    required String reason,
    String? description,
  }) async {
    final token = await _getToken();

    final response = await _dio.post(
      '/reports',
      data: {
        if (itemId != null) 'itemId': itemId,
        if (claimId != null) 'claimId': claimId,
        'reason': reason,
        if (description != null) 'description': description,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data;
  }

  Future<List<Report>> getMyReports() async {
    final token = await _getToken();

    final response = await _dio.get(
      '/reports/my',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final List<dynamic> data = response.data['reports'];
    return data.map((json) => Report.fromJson(json)).toList();
  }

  Future<List<Report>> getAllReports() async {
    final token = await _getToken();

    final response = await _dio.get(
      '/reports/admin',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final List<dynamic> data = response.data['reports'];
    return data.map((json) => Report.fromJson(json)).toList();
  }

  Future<Report> getReportById(String id) async {
    final token = await _getToken();

    final response = await _dio.get(
      '/reports/$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return Report.fromJson(response.data['report']);
  }

  Future<void> updateReportStatus(String id, String status,
      {String? adminNote}) async {
    final token = await _getToken();

    await _dio.put(
      '/reports/$id/status',
      data: {
        'status': status,
        if (adminNote != null) 'adminNote': adminNote,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
