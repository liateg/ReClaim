import 'package:dio/dio.dart';
import 'package:frontend/core/session/app_session.dart';

class AuthService {
  final Dio _dio = Dio();

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
      throw Exception('Login failed: $e');
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
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw Exception(messageFromDio(e, 'Registration failed'));
    } catch (e) {
      throw Exception('Registration failed: $e');
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
      await AppSession.clearToken();
    }
  }

  /// Same token store as [AppSession] — keeps teammate services in sync.
  Future<String?> getToken() async {
    if (_testToken != null) return _testToken;
    return AppSession.getToken();
  }
}
