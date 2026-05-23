import 'package:dio/dio.dart';
import '../models/item_model.dart';
import '../../../../core/api/dio_client.dart';

class ItemService {
  final Dio _dio;

  ItemService(this._dio);

  Future<List<Item>> getItems() async {
    try {
      final response = await _dio.get('/items');
      if (response.data['items'] is List) {
        return (response.data['items'] as List)
            .map((json) => Item.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Item>> getAdminItems() async {
    try {
      final response = await _dio.get('/items/admin');
      if (response.data['items'] is List) {
        return (response.data['items'] as List)
            .map((json) => Item.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Item> getItemById(String id) async {
    try {
      final response = await _dio.get('/items/$id');
      return Item.fromJson(response.data['item']);
    } catch (e) {
      rethrow;
    }
  }

  Future<Item> createItem(Item item) async {
    try {
      final response = await _dio.post('/items', data: item.toJson());
      return Item.fromJson(response.data['item']);
    } catch (e) {
      rethrow;
    }
  }

  Future<Item> updateItem(Item item) async {
    try {
      final response = await _dio.put('/items/${item.id}', data: item.toJson());
      return Item.fromJson(response.data['item']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _dio.delete('/items/$id');
    } catch (e) {
      rethrow;
    }
  }

  Future<String> uploadImage(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post('/upload', data: formData);
      return response.data['imageUrl'];
    } catch (e) {
      rethrow;
    }
  }
}
