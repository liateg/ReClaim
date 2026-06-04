import 'package:dio/dio.dart';
import 'package:frontend/core/session/app_session.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
  }

  static String messageFromDio(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return 'Cannot reach server at $baseUrl. Is the backend running?';
    }
    return fallback;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email.trim(),
        'password': password,
      });
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw Exception(messageFromDio(e, 'Login failed'));
    } catch (e) {
      print('Login error in service: $e');
      if (e is DioException) {
        // ✅ Extract actual error message from backend
        final errorMsg = e.response?.data['message'] ?? 'Login failed';
        print('Backend error message: $errorMsg');
        throw Exception(errorMsg);
      }
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

      return responseData;
    } catch (e) {
      print('Register error: $e');
      if (e is DioException) {
        print('Dio error response: ${e.response?.data}');
        print('Dio error status: ${e.response?.statusCode}');
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
      // Still clear local session if backend logout fails.
    } finally {
      await _storage.delete(key: 'token');
      await AppSession.clearToken();
    }
  }

  /// Same token store as [AppSession] — keeps teammate services in sync.
  Future<String?> getToken() async {
    if (_testToken != null) return _testToken;
    return AppSession.getToken();
  }
}
