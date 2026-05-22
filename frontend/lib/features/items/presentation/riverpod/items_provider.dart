import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/items_repository_impl.dart';
import '../../domain/repositories/items_repository.dart';

final itemsRepositoryProvider = Provider<ItemsRepository>((ref) {
  return ItemsRepositoryImpl();
});

final itemsListProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final items = await ref.read(itemsRepositoryProvider).getItems();
  return items.map((item) => item.toMap()).toList();
});

final itemByIdProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, id) async {
  final item = await ref.read(itemsRepositoryProvider).getItemById(id);
  return item?.toMap();
});

void _invalidateItemsCache(Ref ref, {String? itemId}) {
  ref.invalidate(itemsListProvider);
  if (itemId != null) {
    ref.invalidate(itemByIdProvider(itemId));
  }
}

typedef CreateItemParams = ({
  String title,
  String location,
  String description,
  String verificationQuestion,
  String verificationAnswer,
  String category,
});

final createItemProvider =
    FutureProvider.family<void, CreateItemParams>((ref, params) async {
  await ref.read(itemsRepositoryProvider).createItem(
        title: params.title,
        location: params.location,
        description: params.description,
        verificationQuestion: params.verificationQuestion,
        verificationAnswer: params.verificationAnswer,
        category: params.category,
      );
  _invalidateItemsCache(ref);
});

typedef UpdateItemParams = ({
  String id,
  String title,
  String location,
  String description,
  String category,
  String verificationQuestion,
  String verificationAnswer,
});

final updateItemProvider =
    FutureProvider.family<bool, UpdateItemParams>((ref, params) async {
  final updated = await ref.read(itemsRepositoryProvider).updateItem(
        id: params.id,
        title: params.title,
        location: params.location,
        description: params.description,
        category: params.category,
        verificationQuestion: params.verificationQuestion,
        verificationAnswer: params.verificationAnswer,
      );
  _invalidateItemsCache(ref, itemId: params.id);
  return updated;
});

final deleteItemProvider = FutureProvider.family<bool, String>((ref, id) async {
  final deleted = await ref.read(itemsRepositoryProvider).deleteItem(id);
  _invalidateItemsCache(ref, itemId: id);
  return deleted;
});

typedef SubmitClaimParams = ({
  String id,
  String answer,
});

final submitClaimProvider =
    FutureProvider.family<bool, SubmitClaimParams>((ref, params) async {
  final success = await ref.read(itemsRepositoryProvider).submitClaim(
        id: params.id,
        answer: params.answer,
      );
  _invalidateItemsCache(ref, itemId: params.id);
  return success;
});
