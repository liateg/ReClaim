import 'package:dio/dio.dart';
import 'package:frontend/core/session/services/auth_service.dart';
import 'package:frontend/core/cache/sqlite_cache.dart';

class ItemsService {
  final Dio _dio = Dio()..options.baseUrl = AuthService.baseUrl;
  final SqliteCache _cache = SqliteCache();

  static final ItemsService _instance = ItemsService._internal();
  factory ItemsService() => _instance;
  ItemsService._internal();

  /// Fetch list of items. Checks cache first unless [forceRefresh] is true.
  /// Caches results under key 'items:list' for [ttl].
  Future<List<dynamic>> getItems(
      {bool forceRefresh = false, Duration? ttl}) async {
    final cacheKey = 'items:list';
    if (!forceRefresh) {
      final cached = await _cache.get<List<dynamic>>(cacheKey);
      if (cached != null) return cached;
    }

    final token = await AuthService().getToken();
    try {
      final res = await _dio.get('/items',
          options: Options(
              headers:
                  token != null ? {'Authorization': 'Bearer $token'} : {}));
      final data = res.data as List<dynamic>;
      await _cache.set(cacheKey, data, ttl: ttl ?? const Duration(minutes: 5));
      return data;
    } catch (e) {
      // On network failure, try cache as fallback
      final cached = await _cache.get<List<dynamic>>(cacheKey);
      if (cached != null) return cached;
      rethrow;
    }
  }

  /// Fetch single item by id with cache key 'items:{id}'.
  Future<Map<String, dynamic>> getItemById(String id,
      {bool forceRefresh = false, Duration? ttl}) async {
    final cacheKey = 'items:$id';
    if (!forceRefresh) {
      final cached = await _cache.get<Map<String, dynamic>>(cacheKey);
      if (cached != null) return cached;
    }

    final token = await AuthService().getToken();
    try {
      final res = await _dio.get('/items/$id',
          options: Options(
              headers:
                  token != null ? {'Authorization': 'Bearer $token'} : {}));
      final data = Map<String, dynamic>.from(res.data as Map);
      await _cache.set(cacheKey, data, ttl: ttl ?? const Duration(minutes: 10));
      return data;
    } catch (e) {
      final cached = await _cache.get<Map<String, dynamic>>(cacheKey);
      if (cached != null) return cached;
      rethrow;
    }
  }

  /// Invalidate list and single item caches when mutations occur.
  Future<void> invalidateItemCache({String? id}) async {
    await _cache.delete('items:list');
    if (id != null) await _cache.delete('items:$id');
  }
}
