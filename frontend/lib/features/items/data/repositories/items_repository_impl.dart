import 'dart:typed_data';

import 'package:frontend/core/session/app_session.dart';
import 'package:frontend/features/items/data/items_service.dart';

import '../../domain/entities/item.dart';
import '../../domain/repositories/items_repository.dart';
import '../datasources/items_remote_datasource.dart';

/// Repository: remote API only (backend is source of truth).
/// Invalidates teammate [ItemsService] SQLite cache after mutations.
class ItemsRepositoryImpl implements ItemsRepository {
  ItemsRepositoryImpl({ItemsRemoteDataSource? remoteDataSource})
      : _remote = remoteDataSource ?? ItemsRemoteDataSource();

  final ItemsRemoteDataSource _remote;

  @override
  Future<List<Item>> getItems() async {
    final maps = await _remote.fetchItems();
    return maps.map(Item.fromMap).toList();
  }

  @override
  Future<List<Item>> getMyPostedItems() async {
    final userId = AppSession.userId;
    final maps = AppSession.isAdmin
        ? await _remote.fetchAdminItems()
        : await _remote.fetchItems();
    if (userId == null) {
      return maps.map(Item.fromMap).toList();
    }
    final filtered = maps.where((map) {
      final postedBy = int.tryParse(map['posted_by']?.toString() ?? '');
      return postedBy == userId;
    }).toList();
    return filtered.map(Item.fromMap).toList();
  }

  @override
  Future<Item?> getItemById(String id) async {
    final map = await _remote.fetchItemById(id);
    return map == null ? null : Item.fromMap(map);
  }

  @override
  Future<Item> createItem({
    required String title,
    required String location,
    required String description,
    required String verificationQuestion,
    required String verificationAnswer,
    String category = 'Other',
    String? imagePath,
    Uint8List? imageBytes,
    String? imageFileName,
  }) async {
    final map = await _remote.createItem(
      title: title,
      location: location,
      description: description,
      verificationQuestion: verificationQuestion,
      verificationAnswer: verificationAnswer,
      category: category,
      imagePath: imagePath,
      imageBytes: imageBytes,
      imageFileName: imageFileName,
    );
    await ItemsService().invalidateItemCache();
    return Item.fromMap(map);
  }

  @override
  Future<bool> updateItem({
    required String id,
    required String title,
    required String location,
    String? description,
    String? category,
    String? verificationQuestion,
    String? verificationAnswer,
    String? status,
    String? imagePath,
    Uint8List? imageBytes,
    String? imageFileName,
  }) async {
    await _remote.updateItem(
      id: id,
      title: title,
      location: location,
      description: description,
      category: category,
      verificationQuestion: verificationQuestion,
      verificationAnswer: verificationAnswer,
      status: status,
      imagePath: imagePath,
      imageBytes: imageBytes,
      imageFileName: imageFileName,
    );
    await ItemsService().invalidateItemCache(id: id);
    return true;
  }

  @override
  Future<bool> deleteItem(String id) async {
    await _remote.deleteItem(id);
    await ItemsService().invalidateItemCache(id: id);
    return true;
  }

  @override
  Future<bool> submitClaim({
    required String id,
    required String answer,
  }) async {
    await _remote.submitClaim(itemId: id, answer: answer);
    await ItemsService().invalidateItemCache(id: id);
    return true;
  }
}
