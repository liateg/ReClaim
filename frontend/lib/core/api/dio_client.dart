import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  static const String baseUrl = 'http://localhost:3000';
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  DioClient() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (e, handler) {
        print('DEBUG: DIO ERROR [${e.response?.statusCode}] => PATH: ${e.requestOptions.path}');
        print('DEBUG: DIO ERROR MESSAGE: ${e.message}');
        print('DEBUG: DIO ERROR DATA: ${e.response?.data}');
        if (e.response?.statusCode == 401) {
          print('Unauthorized request - 401');
        }
        return handler.next(e);
      },
    ));
  }

  Dio get dio => _dio;
}

final dioClientProvider = Provider((ref) => DioClient().dio);
