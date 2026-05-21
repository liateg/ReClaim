import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String baseUrl = 'http://localhost:3000';

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

      // Save token
      final token = response.data['accessToken'];
      await _storage.write(key: 'token', value: token);

      return response.data;
    } catch (e) {
      throw Exception('Login failed');
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

      // Save token
      final token = response.data['accessToken'];
      await _storage.write(key: 'token', value: token);

      return response.data;
    } catch (e) {
      throw Exception('Registration failed');
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'token');
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }
}
