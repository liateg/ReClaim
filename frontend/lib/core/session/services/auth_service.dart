import 'package:dio/dio.dart';
import 'package:frontend/core/session/app_session.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/core/cache/sqlite_cache.dart';

class AuthService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String baseUrl = 'http://localhost:3000';
  static String? _testToken;

  static void setTestToken(String? token) => _testToken = token;

  AuthService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.validateStatus = (status) {
      return status != null && status >= 200 && status < 300;
    };
  }

  static String messageFromDio(DioException e, String fallback) {
    try {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return 'Cannot reach server at $baseUrl. Is the backend running?';
      }
      if (e.response?.statusCode != null) {
        return '$fallback (${e.response!.statusCode})';
      }
    } catch (_) {}
    return fallback;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email.trim(),
        'password': password,
      });
      // Clear cache on login to avoid any stale data from previous sessions/users
      await SqliteCache().clear();
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      final errorMsg = messageFromDio(e, 'Login failed');
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Login failed. Please check your connection.');
    }
  }

  Future<Map<String, dynamic>> register(
    String fullName,
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post('/auth/user', data: {
        'fullName': fullName.trim(),
        'email': email.trim(),
        'password': password,
      });

      final responseData = Map<String, dynamic>.from(response.data as Map);
      final token = responseData['accessToken'] ?? responseData['token'];
      if (token != null) {
        await _storage.write(key: 'token', value: token.toString());
        await AppSession.saveToken(token.toString());
      }
      // Clear cache on registration to avoid any stale data
      await SqliteCache().clear();

      return responseData;
    } catch (e) {
      if (e is DioException) {
        final errorMsg = e.response?.data['message'] ?? 'Registration failed';
        throw Exception(errorMsg);
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        await _dio.post(
          '/auth/logout',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
      }
    } catch (_) {
    } finally {
      await _storage.delete(key: 'token');
      await AppSession.clearToken();
      // Clear the cache on logout
      await SqliteCache().clear();
    }
  }

  /// Same token store as [AppSession] — keeps teammate services in sync.
  Future<String?> getToken() async {
    if (_testToken != null) return _testToken;
    return AppSession.getToken();
  }
}
