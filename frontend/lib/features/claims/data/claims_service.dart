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

  Future<bool> withdrawClaim(String id) async {
    final token = await AuthService().getToken();
    try {
      await _dio.put(
        '/claims/$id',
        data: {'status': 'withdrawn'},
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : {},
        ),
      );
      await invalidateClaimsCache(id: id);
      return true;
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map && data['message'] != null
          ? data['message'].toString()
          : 'Failed to withdraw claim.';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to withdraw claim: $e');
    }
  }

  Future<bool> deleteClaim(String id) async {
    final token = await AuthService().getToken();
    try {
      await _dio.delete(
        '/claims/$id',
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : {},
        ),
      );
      await invalidateClaimsCache(id: id);
      return true;
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map && data['message'] != null
          ? data['message'].toString()
          : 'Failed to delete claim.';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to delete claim: $e');
    }
  }
}
