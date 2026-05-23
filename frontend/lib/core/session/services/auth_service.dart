import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/api/dio_client.dart';

class AuthService {
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthService(this._dio);

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
      print('DEBUG: AuthService Login Error: $e');
      if (e is DioException) {
        print('DEBUG: Dio Error Type: ${e.type}');
        print('DEBUG: Dio Error Response: ${e.response?.data}');
        if (e.response?.statusCode == 401) {
          throw Exception('Invalid email or password');
        }
        throw Exception(e.response?.data['message'] ?? 'Login failed: ${e.message}');
      }
      rethrow;
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
      if (e is DioException) {
        throw Exception(e.response?.data['message'] ?? 'Registration failed');
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        await _dio.post('/auth/logout');
      }
    } catch (e) {
      print('Backend logout error: $e');
    } finally {
      await _storage.delete(key: 'token');
    }
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }
}
