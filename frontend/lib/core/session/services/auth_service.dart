import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String baseUrl = 'http://localhost:3000';
  // Test token override: when running tests in Dart VM we cannot use
  // `flutter_secure_storage`. Set this to bypass secure storage in tests.
  static String? _testToken;

  static void setTestToken(String? token) => _testToken = token;

  AuthService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final token = response.data['accessToken'];
      await _storage.write(key: 'token', value: token);

      return response.data;
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
      String fullName, String email, String password) async {
    try {
      final response = await _dio.post('/auth/user', data: {
        'fullName': fullName,
        'email': email,
        'password': password,
      });

      final token = response.data['accessToken'];
      await _storage.write(key: 'token', value: token);

      return response.data;
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
        await _dio.post('/auth/logout',
            options: Options(headers: {'Authorization': 'Bearer $token'}));
      }
    } catch (e) {
      print('Backend logout error: $e');
      // Even if backend logout fails, still clear local
    } finally {
      await _storage.delete(key: 'token');
    }
  }

  Future<String?> getToken() async {
    if (_testToken != null) return _testToken;
    return await _storage.read(key: 'token');
  }
}
