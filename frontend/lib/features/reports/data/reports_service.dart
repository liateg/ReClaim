import 'package:dio/dio.dart';
import 'package:frontend/core/cache/sqlite_cache.dart';
import 'package:frontend/core/session/services/auth_service.dart';

class ReportsService {
  final Dio _dio = Dio()..options.baseUrl = AuthService.baseUrl;
  final SqliteCache _cache = SqliteCache();

  static final ReportsService _instance = ReportsService._internal();
  factory ReportsService() => _instance;
  ReportsService._internal();

  Future<List<dynamic>> getReports(
      {bool forceRefresh = false, Duration? ttl}) async {
    final cacheKey = 'reports:list';
    if (!forceRefresh) {
      final cached = await _cache.get<List<dynamic>>(cacheKey);
      if (cached != null) return cached;
    }

    final token = await AuthService().getToken();
    try {
      final res = await _dio.get('/reports',
          options: Options(
              headers:
                  token != null ? {'Authorization': 'Bearer $token'} : {}));
      final dataRaw = res.data;
      final data = dataRaw is List
          ? (dataRaw)
          : (dataRaw['reports'] as List<dynamic>);
      await _cache.set(cacheKey, data, ttl: ttl ?? const Duration(minutes: 5));
      return data;
    } catch (e) {
      final cached = await _cache.get<List<dynamic>>(cacheKey);
      if (cached != null) return cached;
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getReportById(String id,
      {bool forceRefresh = false, Duration? ttl}) async {
    final cacheKey = 'reports:$id';
    if (!forceRefresh) {
      final cached = await _cache.get<Map<String, dynamic>>(cacheKey);
      if (cached != null) return cached;
    }

    final token = await AuthService().getToken();
    try {
      final res = await _dio.get('/reports/$id',
          options: Options(
              headers:
                  token != null ? {'Authorization': 'Bearer $token'} : {}));
      final dataRaw = res.data;
      final data = dataRaw is Map && dataRaw.containsKey('report')
          ? Map<String, dynamic>.from(dataRaw['report'] as Map)
          : Map<String, dynamic>.from(dataRaw as Map);
      await _cache.set(cacheKey, data, ttl: ttl ?? const Duration(minutes: 10));
      return data;
    } catch (e) {
      final cached = await _cache.get<Map<String, dynamic>>(cacheKey);
      if (cached != null) return cached;
      rethrow;
    }
  }

  Future<void> invalidateReportsCache({String? id}) async {
    await _cache.delete('reports:list');
    if (id != null) await _cache.delete('reports:$id');
  }
}
