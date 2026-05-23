// lib/features/reports/data/services/report_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/cache/sqlite_cache.dart';
import '../models/report_model.dart';

class ReportService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final SqliteCache _cache = SqliteCache();
  static const String baseUrl = 'http://localhost:3000';

  ReportService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
  }

  Future<String?> _getToken() async {
    return await _storage.read(key: 'token');
  }

  // Create a report (clears related caches)
  Future<Map<String, dynamic>> createReport({
    required int? itemId,
    required int? claimId,
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

    // Clear caches after creating new report
    await _clearReportCaches(token!);

    return response.data;
  }

  // Get my reports (CACHE FIRST)
  Future<List<Report>> getMyReports() async {
    final token = await _getToken();
    final cacheKey =
        'reports_my_${token?.substring(0, 20)}'; // Use part of token as user ID

    //  Try cache first
    final cachedData = await _cache.get<List<dynamic>>(cacheKey);
    if (cachedData != null && cachedData.isNotEmpty) {
      print(' Cache HIT - my reports from cache');
      return cachedData.map((json) => Report.fromJson(json)).toList();
    }

    // Cache miss - fetch from network
    print(' Cache MISS - fetching my reports from backend');
    final response = await _dio.get(
      '/reports',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final List<dynamic> data = response.data['reports'];
    final reports = data.map((json) => Report.fromJson(json)).toList();

    // 3 Save to cache (5 minutes TTL)
    await _cache.set(cacheKey, data, ttl: const Duration(minutes: 5));
    print('💾 Saved ${reports.length} my reports to cache');

    return reports;
  }

  // Get all reports (admin only) - CACHE FIRST
  Future<List<Report>> getAllReports() async {
    final token = await _getToken();
    final cacheKey = 'reports_all_${token?.substring(0, 20)}';

    //  Try cache first
    final cachedData = await _cache.get<List<dynamic>>(cacheKey);
    if (cachedData != null && cachedData.isNotEmpty) {
      print('✅ Cache HIT - all reports from cache');
      return cachedData.map((json) => Report.fromJson(json)).toList();
    }

    //  Cache miss - fetch from network
    print(' Cache MISS - fetching all reports from backend');
    final response = await _dio.get(
      '/reports',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final List<dynamic> data = response.data['reports'];
    final reports = data.map((json) => Report.fromJson(json)).toList();

    //  Save to cache (3 minutes TTL - admin sees fresher data)
    await _cache.set(cacheKey, data, ttl: const Duration(minutes: 3));
    print(' Saved ${reports.length} all reports to cache');

    return reports;
  }

  // Get single report by ID (CACHE FIRST)
  Future<Report> getReportById(String id) async {
    final token = await _getToken();
    final cacheKey = 'report_$id';

    //  Try cache first
    final cachedData = await _cache.get<Map<String, dynamic>>(cacheKey);
    if (cachedData != null) {
      print(' Cache HIT - report $id from cache');
      return Report.fromJson(cachedData);
    }

    // Cache miss - fetch from network
    print(' Cache MISS - fetching report $id from backend');
    final response = await _dio.get(
      '/reports/$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final report = Report.fromJson(response.data['report']);

    //  Save to cache (10 minutes TTL - reports don't change often)
    await _cache.set(cacheKey, response.data['report'],
        ttl: const Duration(minutes: 10));
    print(' Saved report $id to cache');

    return report;
  }

  // Update report status (clears related caches)
  Future<void> updateReportStatus(String id, String status,
      {String? adminNote}) async {
    final token = await _getToken();

    await _dio.put(
      '/reports/$id',
      data: {
        'status': status,
        if (adminNote != null) 'adminNote': adminNote,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    // Clear caches after update
    await _clearReportCaches(token!, id);
  }

  // Delete report (clears related caches)
  Future<void> deleteReport(String id) async {
    final token = await _getToken();

    await _dio.delete(
      '/reports/$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    // Clear caches after delete
    await _clearReportCaches(token!, id);
  }

  // Helper: Clear all report-related caches
  Future<void> _clearReportCaches(String token,
      [String? specificReportId]) async {
    final myReportsKey = 'reports_my_${token.substring(0, 20)}';
    final allReportsKey = 'reports_all_${token.substring(0, 20)}';

    await _cache.delete(myReportsKey);
    await _cache.delete(allReportsKey);

    if (specificReportId != null) {
      await _cache.delete('report_$specificReportId');
    }

    print(' Cleared report caches');
  }
}
