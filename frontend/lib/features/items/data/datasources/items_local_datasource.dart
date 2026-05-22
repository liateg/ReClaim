import '../models/item_model.dart';
import '../../domain/entities/item.dart';
import '../mock_data.dart';

/// Local data source backed by in-memory mock data.
/// Replace or complement with SQLite / remote datasource later.
class ItemsLocalDataSource {
  Future<List<Item>> fetchAll() async {
    return mockItems.map(Item.fromMap).toList();
  }

  Future<Item?> fetchById(String id) async {
    final match = mockItems.cast<Map<String, dynamic>?>().firstWhere(
          (item) => item?[ItemModel.keyId]?.toString() == id,
          orElse: () => null,
        );
    if (match == null) return null;
    return Item.fromMap(match);
  }

  Future<Item> create({
    required String title,
    required String location,
    required String description,
    required String verificationQuestion,
    required String verificationAnswer,
    String category = 'Other',
    String imageUrl = 'https://picsum.photos/1200/800',
  }) async {
    addMockItem(
      title: title,
      location: location,
      description: description,
      verificationQuestion: verificationQuestion,
      verificationAnswer: verificationAnswer,
      category: category,
      imageUrl: imageUrl,
    );
    return Item.fromMap(mockItems.first);
  }

  Future<bool> update({
    required String id,
    required String title,
    required String location,
    String? description,
    String? category,
    String? verificationQuestion,
    String? verificationAnswer,
    String? status,
    String? imageUrl,
  }) async {
    return updateMockItem(
      id: id,
      title: title,
      location: location,
      description: description,
      category: category,
      verificationQuestion: verificationQuestion,
      verificationAnswer: verificationAnswer,
      status: status,
      imageUrl: imageUrl,
    );
  }

  Future<bool> delete(String id) async {
    return removeMockItem(id);
  }

  Future<bool> submitClaim({
    required String id,
    required String answer,
  }) async {
    return submitClaimForItem(id: id, answer: answer);
  }
}

