import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:frontend/core/cache/sqlite_cache.dart';
import 'package:frontend/core/session/app_session.dart';
import 'package:frontend/core/session/services/auth_service.dart';

import 'models/item_model.dart';

class ItemsService {
  final Dio _dio = Dio()..options.baseUrl = AuthService.baseUrl;
  final SqliteCache _cache = SqliteCache();

  static final ItemsService _instance = ItemsService._internal();
  factory ItemsService() => _instance;
  ItemsService._internal();

  static const Map<int, String> _categoryIdToName = {
    1: 'Electronics',
    2: 'Accessories',
    3: 'Clothing',
  };

  static const Map<String, int> _categoryNameToId = {
    'Electronics': 1,
    'Accessories': 2,
    'Clothing': 3,
  };

  Future<Map<String, String>> _authHeaders({bool json = true}) async {
    final token = await AuthService().getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Please sign in to continue.');
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
    throw Exception(message);
  }

  static String _formatDateFound(dynamic value) {
    if (value == null) return '';
    final raw = value.toString();
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[parsed.month - 1]} ${parsed.day}, ${parsed.year}';
  }

  static String _todayForApi() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }

  static String _resolveImageUrl(dynamic imageUrl) {
    final value = imageUrl?.toString().trim();
    if (value == null || value.isEmpty) return '';
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    final base = AuthService.baseUrl.replaceAll(RegExp(r'/$'), '');
    final path = value.startsWith('/') ? value : '/$value';
    return '$base$path';
  }

  static String _categoryNameFromId(dynamic categoryId) {
    final id = categoryId is int ? categoryId : int.tryParse('$categoryId');
    return _categoryIdToName[id] ?? 'Other';
  }

  static int? _categoryIdFromName(String? category) {
    if (category == null || category.isEmpty) return null;
    return _categoryNameToId[category];
  }

  static Map<String, dynamic> _apiToUiMap(Map<String, dynamic> json) {
    return {
      ItemModel.keyId: json['id']?.toString() ?? '',
      ItemModel.keyTitle: json['title']?.toString() ?? '',
      ItemModel.keyDesc: json['description']?.toString() ?? '',
      ItemModel.keyLocation: json['location']?.toString() ?? '',
      ItemModel.keyCategoryId: json['categoryId'],
      ItemModel.keyCategory: _categoryNameFromId(json['categoryId']),
      ItemModel.keyStatus: json['status']?.toString() ?? 'available',
      ItemModel.keyDate: _formatDateFound(json['dateFound']),
      ItemModel.keyImage: _resolveImageUrl(json['imageUrl']),
      ItemModel.keyQuestion: json['verificationQuestion']?.toString() ?? '',
      ItemModel.keyAnswer: json['verificationAnswer']?.toString() ?? '',
      ItemModel.keyHiddenDetails: json['hiddenDetails']?.toString(),
      ItemModel.keyPostedBy: json['postedBy']?.toString(),
      ItemModel.keyCreatedAt: json['createdAt']?.toString(),
      ItemModel.keyUpdatedAt: json['updatedAt']?.toString(),
    };
  }

  static ItemModel _fromApiJson(Map<String, dynamic> json) {
    return ItemModel.fromMap(_apiToUiMap(json));
  }

  List<ItemModel> _parseItemsList(dynamic dataRaw) {
    final list = dataRaw is List
        ? dataRaw
        : (dataRaw as Map<String, dynamic>)['items'] as List<dynamic>? ?? [];
    return list
        .map((e) => _fromApiJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  ItemModel _parseItemResponse(dynamic dataRaw) {
    if (dataRaw is! Map) {
      throw Exception('Invalid response from server.');
    }
    final map = Map<String, dynamic>.from(dataRaw);
    final itemRaw = map['item'];
    if (itemRaw is! Map) {
      throw Exception('Invalid response from server.');
    }
    return _fromApiJson(Map<String, dynamic>.from(itemRaw));
  }

  String _parseUploadedImagePath(dynamic dataRaw) {
    if (dataRaw is! Map) {
      throw Exception('Invalid upload response from server.');
    }
    final imageUrl = dataRaw['imageUrl']?.toString().trim();
    if (imageUrl == null || imageUrl.isEmpty) {
      throw Exception('Upload did not return an image URL.');
    }
    return imageUrl;
  }

  Future<String> uploadImage({
    String? filePath,
    Uint8List? bytes,
    String? fileName,
  }) async {
    if ((filePath == null || filePath.isEmpty) &&
        (bytes == null || bytes.isEmpty)) {
      throw Exception('No image selected to upload.');
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
        throw Exception('No image selected to upload.');
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
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<List<ItemModel>> getItems({
    bool forceRefresh = false,
    Duration? ttl,
  }) async {
    const cacheKey = 'items:list';
    if (!forceRefresh) {
      final cached = await _cache.get<List<dynamic>>(cacheKey);
      if (cached != null) {
        return cached
            .whereType<Map>()
            .map((item) => ItemModel.fromMap(Map<String, dynamic>.from(item)))
            .toList();
      }
    }

    final token = await AuthService().getToken();
    try {
      final res = await _dio.get(
        '/items',
        options: Options(
            headers: token != null ? {'Authorization': 'Bearer $token'} : {}),
      );
      final items = _parseItemsList(res.data);
      await _cache.set(
        cacheKey,
        items.map((item) => item.toMap()).toList(),
        ttl: ttl ?? const Duration(minutes: 5),
      );
      return items;
    } on DioException catch (e) {
      final cached = await _cache.get<List<dynamic>>(cacheKey);
      if (cached != null) {
        return cached
            .whereType<Map>()
            .map((item) => ItemModel.fromMap(Map<String, dynamic>.from(item)))
            .toList();
      }
      _throwFromDio(e, 'Failed to load items.');
    }
  }

  Future<List<ItemModel>> getMyPostedItems() async {
    final userId = AppSession.userId;
    final items = AppSession.isAdmin ? await getAdminItems() : await getItems();

    if (userId == null) {
      return items;
    }

    return items.where((item) => item.postedBy == userId).toList();
  }

  Future<List<ItemModel>> getAdminItems({
    bool forceRefresh = false,
    Duration? ttl,
  }) async {
    const cacheKey = 'items:admin';
    if (!forceRefresh) {
      final cached = await _cache.get<List<dynamic>>(cacheKey);
      if (cached != null) {
        return cached
            .whereType<Map>()
            .map((item) => ItemModel.fromMap(Map<String, dynamic>.from(item)))
            .toList();
      }
    }

    final token = await AuthService().getToken();
    try {
      final res = await _dio.get(
        '/items/admin',
        options: Options(
            headers: token != null ? {'Authorization': 'Bearer $token'} : {}),
      );
      final items = _parseItemsList(res.data);
      await _cache.set(
        cacheKey,
        items.map((item) => item.toMap()).toList(),
        ttl: ttl ?? const Duration(minutes: 5),
      );
      return items;
    } on DioException catch (e) {
      final cached = await _cache.get<List<dynamic>>(cacheKey);
      if (cached != null) {
        return cached
            .whereType<Map>()
            .map((item) => ItemModel.fromMap(Map<String, dynamic>.from(item)))
            .toList();
      }
      _throwFromDio(e, 'Failed to load your posts.');
    }
  }

  Future<ItemModel?> getItemById(
    String id, {
    bool forceRefresh = false,
    Duration? ttl,
  }) async {
    final cacheKey = 'items:$id';
    if (!forceRefresh) {
      final cached = await _cache.get<Map<String, dynamic>>(cacheKey);
      if (cached != null) {
        return ItemModel.fromMap(cached);
      }
    }

    final token = await AuthService().getToken();
    try {
      final res = await _dio.get(
        '/items/$id',
        options: Options(
            headers: token != null ? {'Authorization': 'Bearer $token'} : {}),
      );
      final dataRaw = res.data;
      final itemJson = dataRaw is Map && dataRaw.containsKey('item')
          ? Map<String, dynamic>.from(dataRaw['item'] as Map)
          : Map<String, dynamic>.from(dataRaw as Map);
      final item = _fromApiJson(itemJson);
      await _cache.set(cacheKey, item.toMap(),
          ttl: ttl ?? const Duration(minutes: 10));
      return item;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      final cached = await _cache.get<Map<String, dynamic>>(cacheKey);
      if (cached != null) {
        return ItemModel.fromMap(cached);
      }
      _throwFromDio(e, 'Failed to load item.');
    }
  }

  Future<ItemModel> createItem({
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
        data: {
          'title': title,
          'description': description,
          'location': location,
          'dateFound': _todayForApi(),
          'verificationQuestion': verificationQuestion,
          'verificationAnswer': verificationAnswer,
          'status': 'available',
          if (_categoryIdFromName(category) != null)
            'categoryId': _categoryIdFromName(category),
          if (resolvedImageUrl.isNotEmpty) 'imageUrl': resolvedImageUrl,
        },
        options: Options(headers: await _authHeaders()),
      );
      final item = _parseItemResponse(res.data);
      await invalidateItemCache();
      return item;
    } on DioException catch (e) {
      _throwFromDio(e, 'Failed to create item.');
    } catch (e) {
      throw Exception('Failed to create item: $e');
    }
  }

  Future<bool> updateItem({
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

      await _dio.put(
        '/items/$id',
        data: {
          'title': title,
          'location': location,
          if (description != null) 'description': description,
          if (category != null && _categoryIdFromName(category) != null)
            'categoryId': _categoryIdFromName(category),
          if (verificationQuestion != null)
            'verificationQuestion': verificationQuestion,
          if (verificationAnswer != null)
            'verificationAnswer': verificationAnswer,
          if (status != null) 'status': status,
          if (resolvedImageUrl != null && resolvedImageUrl.isNotEmpty)
            'imageUrl': resolvedImageUrl,
          'dateFound': _todayForApi(),
        },
        options: Options(headers: await _authHeaders()),
      );

      await invalidateItemCache(id: id);
      return true;
    } on DioException catch (e) {
      _throwFromDio(e, 'Failed to update item.');
    } catch (e) {
      throw Exception('Failed to update item: $e');
    }
  }

  Future<bool> deleteItem(String id) async {
    try {
      await _dio.delete(
        '/items/$id',
        options: Options(headers: await _authHeaders()),
      );
      await invalidateItemCache(id: id);
      return true;
    } on DioException catch (e) {
      _throwFromDio(e, 'Failed to delete item.');
    } catch (e) {
      throw Exception('Failed to delete item: $e');
    }
  }

  Future<bool> submitClaim({
    required String itemId,
    required String answer,
  }) async {
    final parsedId = int.tryParse(itemId);
    if (parsedId == null) {
      throw Exception('Invalid item id.');
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
      await invalidateItemCache(id: itemId);
      return true;
    } on DioException catch (e) {
      _throwFromDio(e, 'Failed to submit claim.');
    } catch (e) {
      throw Exception('Failed to submit claim: $e');
    }
  }

  /// Invalidate list and single item caches when mutations occur.
  Future<void> invalidateItemCache({String? id}) async {
    try {
      await _cache.delete('items:list');
      await _cache.delete('items:admin');
      if (id != null) await _cache.delete('items:$id');
    } catch (e) {
      // Cache is best-effort. Do not let cache failures bubble to UI.
      // ignore: avoid_print
      print('Warning: failed to invalidate item cache: $e');
    }
  }
}
