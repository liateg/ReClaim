import 'dart:typed_data';

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

/// My Posts tab — items posted by the current user.
final myItemsListProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final items = await ref.read(itemsRepositoryProvider).getMyPostedItems();
  return items.map((item) => item.toMap()).toList();
});

final itemByIdProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, id) async {
  final item = await ref.read(itemsRepositoryProvider).getItemById(id);
  return item?.toMap();
});

/// Refresh lists after create/update/delete/claim (call from UI, not autoDispose providers).
void invalidateItemsState(WidgetRef ref, {String? itemId}) {
  ref.invalidate(itemsListProvider);
  ref.invalidate(myItemsListProvider);
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
  String? imagePath,
  Uint8List? imageBytes,
  String? imageFileName,
});

final createItemProvider = FutureProvider.autoDispose
    .family<void, CreateItemParams>((ref, params) async {
  await ref.read(itemsRepositoryProvider).createItem(
        title: params.title,
        location: params.location,
        description: params.description,
        verificationQuestion: params.verificationQuestion,
        verificationAnswer: params.verificationAnswer,
        category: params.category,
        imagePath: params.imagePath,
        imageBytes: params.imageBytes,
        imageFileName: params.imageFileName,
      );
});

typedef UpdateItemParams = ({
  String id,
  String title,
  String location,
  String description,
  String category,
  String verificationQuestion,
  String verificationAnswer,
  String? imagePath,
  Uint8List? imageBytes,
  String? imageFileName,
});

final updateItemProvider = FutureProvider.autoDispose
    .family<bool, UpdateItemParams>((ref, params) async {
  return ref.read(itemsRepositoryProvider).updateItem(
        id: params.id,
        title: params.title,
        location: params.location,
        description: params.description,
        category: params.category,
        verificationQuestion: params.verificationQuestion,
        verificationAnswer: params.verificationAnswer,
        imagePath: params.imagePath,
        imageBytes: params.imageBytes,
        imageFileName: params.imageFileName,
      );
});

final deleteItemProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, id) async {
  return ref.read(itemsRepositoryProvider).deleteItem(id);
});

typedef SubmitClaimParams = ({
  String id,
  String answer,
});

final submitClaimProvider = FutureProvider.autoDispose
    .family<bool, SubmitClaimParams>((ref, params) async {
  await ref.read(itemsRepositoryProvider).submitClaim(
        id: params.id,
        answer: params.answer,
      );
  return true;
});
