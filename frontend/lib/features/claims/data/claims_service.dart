import 'package:dio/dio.dart';
import 'package:frontend/core/cache/sqlite_cache.dart';
import 'package:frontend/core/session/services/auth_service.dart';

class ClaimsService {
  final Dio _dio = Dio()..options.baseUrl = AuthService.baseUrl;
  final SqliteCache _cache = SqliteCache();

  static final ClaimsService _instance = ClaimsService._internal();
  factory ClaimsService() => _instance;
  ClaimsService._internal();

  Future<List<dynamic>> getClaims(
      {bool forceRefresh = false, Duration? ttl}) async {
    final cacheKey = 'claims:list';
    if (!forceRefresh) {
      final cached = await _cache.get<List<dynamic>>(cacheKey);
      if (cached != null) return cached;
    }

    final token = await AuthService().getToken();
    try {
      final res = await _dio.get('/claims',
          options: Options(
              headers:
                  token != null ? {'Authorization': 'Bearer $token'} : {}));
      final dataRaw = res.data;
      final data = dataRaw is List
          ? (dataRaw)
          : (dataRaw['claims'] as List<dynamic>);
      await _cache.set(cacheKey, data, ttl: ttl ?? const Duration(minutes: 5));
      return data;
    } catch (e) {
      final cached = await _cache.get<List<dynamic>>(cacheKey);
      if (cached != null) return cached;
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getClaimById(String id,
      {bool forceRefresh = false, Duration? ttl}) async {
    final cacheKey = 'claims:$id';
    if (!forceRefresh) {
      final cached = await _cache.get<Map<String, dynamic>>(cacheKey);
      if (cached != null) return cached;
    }

    final token = await AuthService().getToken();
    try {
      final res = await _dio.get('/claims/$id',
          options: Options(
              headers:
                  token != null ? {'Authorization': 'Bearer $token'} : {}));
      final dataRaw = res.data;
      final data = dataRaw is Map && dataRaw.containsKey('claim')
          ? Map<String, dynamic>.from(dataRaw['claim'] as Map)
          : Map<String, dynamic>.from(dataRaw as Map);
      await _cache.set(cacheKey, data, ttl: ttl ?? const Duration(minutes: 10));
      return data;
    } catch (e) {
      final cached = await _cache.get<Map<String, dynamic>>(cacheKey);
      if (cached != null) return cached;
      rethrow;
    }
  }

  Future<void> invalidateClaimsCache({String? id}) async {
    await _cache.delete('claims:list');
    if (id != null) await _cache.delete('claims:$id');
  }
}
