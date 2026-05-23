import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/dio_client.dart';
import '../../data/models/item_model.dart';
import '../../data/services/item_service.dart';

class ItemState {
  final List<Item> items;
  final bool isLoading;
  final String? errorMessage;

  ItemState({
    required this.items,
    this.isLoading = false,
    this.errorMessage,
  });

  ItemState copyWith({
    List<Item>? items,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ItemState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ItemNotifier extends StateNotifier<ItemState> {
  final ItemService _service;

  ItemNotifier(this._service) : super(ItemState(items: [])) {
    loadItems();
  }

  Future<void> loadItems() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final items = await _service.getItems();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> loadAdminItems() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final items = await _service.getAdminItems();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> addItem(Item item) async {
    try {
      state = state.copyWith(isLoading: true);
      final newItem = await _service.createItem(item);
      state = state.copyWith(items: [newItem, ...state.items], isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> updateItem(Item item) async {
    try {
      state = state.copyWith(isLoading: true);
      final updatedItem = await _service.updateItem(item);
      state = state.copyWith(
        items: state.items.map((i) => i.id == updatedItem.id ? updatedItem : i).toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      state = state.copyWith(isLoading: true);
      await _service.deleteItem(id);
      state = state.copyWith(
        items: state.items.where((i) => i.id != id).toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<String> uploadImage(String filePath) async {
    return await _service.uploadImage(filePath);
  }
}

final itemServiceProvider = Provider((ref) {
  final dio = ref.watch(dioClientProvider);
  return ItemService(dio);
});

final itemProvider = StateNotifierProvider<ItemNotifier, ItemState>((ref) {
  final service = ref.watch(itemServiceProvider);
  return ItemNotifier(service);
});
