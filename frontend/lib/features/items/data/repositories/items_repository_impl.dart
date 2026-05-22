import '../../domain/entities/item.dart';
import '../../domain/repositories/items_repository.dart';
import '../datasources/items_local_datasource.dart';

/// Repository implementation. Local-only for now; remote + SQLite cache can plug in here.
class ItemsRepositoryImpl implements ItemsRepository {
  ItemsRepositoryImpl({ItemsLocalDataSource? localDataSource})
      : _local = localDataSource ?? ItemsLocalDataSource();

  final ItemsLocalDataSource _local;

  @override
  Future<List<Item>> getItems() => _local.fetchAll();

  @override
  Future<Item?> getItemById(String id) => _local.fetchById(id);

  @override
  Future<Item> createItem({
    required String title,
    required String location,
    required String description,
    required String verificationQuestion,
    required String verificationAnswer,
    String category = 'Other',
    String imageUrl = 'https://picsum.photos/1200/800',
  }) {
    return _local.create(
      title: title,
      location: location,
      description: description,
      verificationQuestion: verificationQuestion,
      verificationAnswer: verificationAnswer,
      category: category,
      imageUrl: imageUrl,
    );
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
    String? imageUrl,
  }) {
    return _local.update(
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

  @override
  Future<bool> deleteItem(String id) => _local.delete(id);

  @override
  Future<bool> submitClaim({
    required String id,
    required String answer,
  }) {
    return _local.submitClaim(id: id, answer: answer);
  }
}
