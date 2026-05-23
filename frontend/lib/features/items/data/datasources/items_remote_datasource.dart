import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:frontend/core/session/app_session.dart';
import 'package:frontend/core/session/services/auth_service.dart';
import 'package:frontend/features/items/data/datasources/items_api_exception.dart';
import 'package:frontend/features/items/data/mappers/item_api_mapper.dart';

/// Remote items API. Uses [AppSession.getToken] for authenticated requests.
class ItemsRemoteDataSource {
  ItemsRemoteDataSource({Dio? dio}) : _dio = dio ?? _createDio();

  final Dio _dio;

  static Dio _createDio() {
    return Dio(
      BaseOptions(
        baseUrl: AuthService.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
  }

  Future<Map<String, String>> _authHeaders({bool json = true}) async {
    final token = await AppSession.getToken();
    if (token == null || token.isEmpty) {
      throw ItemsApiException('Please sign in to continue.', statusCode: 401);
    }
    final headers = <String, String>{'Authorization': 'Bearer $token'};
    if (json) {
      headers['Content-Type'] = 'application/json';
    }
    return headers;
  }

  Never _throwFromDio(DioException e, String fallback) {
    final data = e.response?.data;
    final message = data is Map && data['message'] != null
        ? data['message'].toString()
        : fallback;
    throw ItemsApiException(message, statusCode: e.response?.statusCode);
  }

  List<Map<String, dynamic>> _parseItemsList(dynamic dataRaw) {
    final list = dataRaw is List
        ? dataRaw
        : (dataRaw as Map<String, dynamic>)['items'] as List<dynamic>? ?? [];
    return list
        .map((e) => ItemApiMapper.apiToUiMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Map<String, dynamic> _parseItemResponse(dynamic dataRaw) {
    if (dataRaw is! Map) {
      throw ItemsApiException('Invalid response from server.');
    }
    final map = Map<String, dynamic>.from(dataRaw);
    final itemRaw = map['item'];
    if (itemRaw is! Map) {
      throw ItemsApiException('Invalid response from server.');
    }
    return ItemApiMapper.apiToUiMap(Map<String, dynamic>.from(itemRaw));
  }

  String _parseUploadedImagePath(dynamic dataRaw) {
    if (dataRaw is! Map) {
      throw ItemsApiException('Invalid upload response from server.');
    }
    final imageUrl = dataRaw['imageUrl']?.toString().trim();
    if (imageUrl == null || imageUrl.isEmpty) {
      throw ItemsApiException('Upload did not return an image URL.');
    }
    return imageUrl;
  }

  /// Uploads image file via multipart field [image].
  Future<String> uploadImage({
    String? filePath,
    Uint8List? bytes,
    String? fileName,
  }) async {
    if ((filePath == null || filePath.isEmpty) &&
        (bytes == null || bytes.isEmpty)) {
      throw ItemsApiException('No image selected to upload.');
    }

    try {
      final MultipartFile filePart;
      if (bytes != null && bytes.isNotEmpty) {
        filePart = MultipartFile.fromBytes(
          bytes,
          filename: fileName ?? 'image.jpg',
        );
      } else if (filePath != null && filePath.isNotEmpty) {
        filePart = await MultipartFile.fromFile(
          filePath,
          filename: fileName ?? 'image.jpg',
        );
      } else {
        throw ItemsApiException('No image selected to upload.');
      }

      final formData = FormData.fromMap({'image': filePart});
      final res = await _dio.post(
        '/items/upload',
        data: formData,
        options: Options(headers: await _authHeaders(json: false)),
      );
      return _parseUploadedImagePath(res.data);
    } on DioException catch (e) {
      _throwFromDio(e, 'Failed to upload image.');
    } on ItemsApiException {
      rethrow;
    } catch (e) {
      throw ItemsApiException('Failed to upload image: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchItems() async {
    try {
      final res = await _dio.get(
        '/items',
        options: Options(headers: await _authHeaders()),
      );
      return _parseItemsList(res.data);
    } on DioException catch (e) {
      _throwFromDio(e, 'Failed to load items.');
    }
  }

  Future<List<Map<String, dynamic>>> fetchAdminItems() async {
    try {
      final res = await _dio.get(
        '/items/admin',
        options: Options(headers: await _authHeaders()),
      );
      return _parseItemsList(res.data);
    } on DioException catch (e) {
      _throwFromDio(e, 'Failed to load your posts.');
    }
  }

  Future<Map<String, dynamic>?> fetchItemById(String id) async {
    try {
      final res = await _dio.get(
        '/items/$id',
        options: Options(headers: await _authHeaders()),
      );
      final dataRaw = res.data;
      final itemJson = dataRaw is Map && dataRaw.containsKey('item')
          ? Map<String, dynamic>.from(dataRaw['item'] as Map)
          : Map<String, dynamic>.from(dataRaw as Map);
      return ItemApiMapper.apiToUiMap(itemJson);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      _throwFromDio(e, 'Failed to load item.');
    }
  }

  Future<Map<String, dynamic>> createItem({
    required String title,
    required String location,
    required String description,
    required String verificationQuestion,
    required String verificationAnswer,
    String category = 'Other',
    String? imageUrl,
    String? imagePath,
    Uint8List? imageBytes,
    String? imageFileName,
  }) async {
    try {
      var resolvedImageUrl = imageUrl ?? '';
      if (resolvedImageUrl.isEmpty &&
          ((imagePath != null && imagePath.isNotEmpty) ||
              (imageBytes != null && imageBytes.isNotEmpty))) {
        resolvedImageUrl = await uploadImage(
          filePath: imagePath,
          bytes: imageBytes,
          fileName: imageFileName,
        );
      }

      final res = await _dio.post(
        '/items',
        data: ItemApiMapper.createBody(
          title: title,
          location: location,
          description: description,
          verificationQuestion: verificationQuestion,
          verificationAnswer: verificationAnswer,
          category: category,
          imageUrl: resolvedImageUrl.isEmpty ? null : resolvedImageUrl,
        ),
        options: Options(headers: await _authHeaders()),
      );
      return _parseItemResponse(res.data);
    } on DioException catch (e) {
      _throwFromDio(e, 'Failed to create item.');
    } on ItemsApiException {
      rethrow;
    } catch (e) {
      throw ItemsApiException('Failed to create item: $e');
    }
  }

  Future<Map<String, dynamic>> updateItem({
    required String id,
    required String title,
    required String location,
    String? description,
    String? category,
    String? verificationQuestion,
    String? verificationAnswer,
    String? status,
    String? imageUrl,
    String? imagePath,
    Uint8List? imageBytes,
    String? imageFileName,
  }) async {
    try {
      String? resolvedImageUrl = imageUrl;
      if ((resolvedImageUrl == null || resolvedImageUrl.isEmpty) &&
          ((imagePath != null && imagePath.isNotEmpty) ||
              (imageBytes != null && imageBytes.isNotEmpty))) {
        resolvedImageUrl = await uploadImage(
          filePath: imagePath,
          bytes: imageBytes,
          fileName: imageFileName,
        );
      }

      final res = await _dio.put(
        '/items/$id',
        data: ItemApiMapper.updateBody(
          title: title,
          location: location,
          description: description,
          category: category,
          verificationQuestion: verificationQuestion,
          verificationAnswer: verificationAnswer,
          status: status,
          imageUrl: resolvedImageUrl,
        ),
        options: Options(headers: await _authHeaders()),
      );
      return _parseItemResponse(res.data);
    } on DioException catch (e) {
      _throwFromDio(e, 'Failed to update item.');
    } on ItemsApiException {
      rethrow;
    } catch (e) {
      throw ItemsApiException('Failed to update item: $e');
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _dio.delete(
        '/items/$id',
        options: Options(headers: await _authHeaders()),
      );
    } on DioException catch (e) {
      _throwFromDio(e, 'Failed to delete item.');
    } catch (e) {
      throw ItemsApiException('Failed to delete item: $e');
    }
  }

  Future<void> submitClaim({
    required String itemId,
    required String answer,
  }) async {
    final parsedId = int.tryParse(itemId);
    if (parsedId == null) {
      throw ItemsApiException('Invalid item id.');
    }
    try {
      await _dio.post(
        '/claims',
        data: {
          'itemId': parsedId,
          'answerAttempt': answer,
          'status': 'pending',
        },
        options: Options(headers: await _authHeaders()),
      );
    } on DioException catch (e) {
      _throwFromDio(e, 'Failed to submit claim.');
    } catch (e) {
      throw ItemsApiException('Failed to submit claim: $e');
    }
  }
}
