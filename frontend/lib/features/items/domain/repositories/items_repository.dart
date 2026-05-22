import '../entities/item.dart';

abstract class ItemsRepository {
  Future<List<Item>> getItems();

  Future<Item?> getItemById(String id);

  Future<Item> createItem({
    required String title,
    required String location,
    required String description,
    required String verificationQuestion,
    required String verificationAnswer,
    String category,
    String imageUrl,
  });

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
  });

  Future<bool> deleteItem(String id);

  Future<bool> submitClaim({
    required String id,
    required String answer,
  });
}
