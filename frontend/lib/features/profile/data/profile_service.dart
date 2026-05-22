import 'package:dio/dio.dart';
import 'package:frontend/core/cache/sqlite_cache.dart';
import 'package:frontend/core/session/services/auth_service.dart';

class ProfileService {
  final Dio _dio = Dio()..options.baseUrl = AuthService.baseUrl;
  final SqliteCache _cache = SqliteCache();

  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  String _keyFor(String email) => 'profile:$email';

  Future<Map<String, dynamic>?> getProfile(String email,
      {bool forceRefresh = false, Duration? ttl}) async {
    final key = _keyFor(email);
    if (!forceRefresh) {
      final cached = await _cache.get<Map<String, dynamic>>(key);
      if (cached != null) return cached;
    }

    final token = await AuthService().getToken();
    try {
      final res = await _dio.get('/profile/$email',
          options: Options(
              headers:
                  token != null ? {'Authorization': 'Bearer $token'} : {}));
      final data = Map<String, dynamic>.from(res.data as Map);
      await _cache.set(key, data, ttl: ttl ?? const Duration(minutes: 10));
      return data;
    } catch (e) {
      final cached = await _cache.get<Map<String, dynamic>>(key);
      if (cached != null) return cached;
      rethrow;
    }
  }

  Future<void> setProfile(String email, Map<String, dynamic> payload,
      {Duration? ttl}) async {
    final key = _keyFor(email);
    await _cache.set(key, payload, ttl: ttl ?? const Duration(minutes: 10));
  }

  Future<void> invalidateProfile({String? email}) async {
    if (email != null) {
      await _cache.delete(_keyFor(email));
    } else {
      // no email provided: clear entire cache (conservative)
      await _cache.clear();
    }
  }
}
