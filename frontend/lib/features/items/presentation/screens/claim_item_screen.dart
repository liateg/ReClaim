import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/items/Riverpod/items_provider.dart';
import 'package:frontend/features/items/presentation/widgets/item_card.dart';
import 'package:frontend/features/items/presentation/widgets/discovery_top_bar.dart';
import 'package:frontend/shared/widgets/appbar.dart';
import 'package:frontend/features/items/presentation/widgets/category_chip.dart';

class ClaimsScreen extends ConsumerStatefulWidget {
  const ClaimsScreen({super.key});

  @override
  ConsumerState<ClaimsScreen> createState() => _ClaimsScreenState();
}

class _ClaimsScreenState extends ConsumerState<ClaimsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filterItems(List<Map<String, dynamic>> items) {
    final query = _searchController.text.trim().toLowerCase();
    return items.where((item) {
      final title = (item['title'] as String?)?.toLowerCase() ?? '';
      final location = (item['location'] as String?)?.toLowerCase() ?? '';
      final category = (item['category'] as String?) ?? 'Other';
      final matchesQuery =
          query.isEmpty || title.contains(query) || location.contains(query);
      final matchesCategory =
          _selectedCategory == 'All' || category == _selectedCategory;
      return matchesQuery && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(itemsListProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Discover Items',
        back: false,
      ),
      body: Column(
        children: [
          DiscoveryTopBar(
            searchController: _searchController,
            onSearchChanged: (_) => setState(() {}),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                CategoryChip(
                  label: 'All',
                  isSelected: _selectedCategory == 'All',
                  onTap: () => setState(() => _selectedCategory = 'All'),
                ),
                CategoryChip(
                  label: 'Electronics',
                  isSelected: _selectedCategory == 'Electronics',
                  onTap: () =>
                      setState(() => _selectedCategory = 'Electronics'),
                ),
                CategoryChip(
                  label: 'Accessories',
                  isSelected: _selectedCategory == 'Accessories',
                  onTap: () =>
                      setState(() => _selectedCategory = 'Accessories'),
                ),
                CategoryChip(
                  label: 'Documents',
                  isSelected: _selectedCategory == 'Documents',
                  onTap: () => setState(() => _selectedCategory = 'Documents'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: itemsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text('Failed to load items: $error'),
                    TextButton(
                      onPressed: () => ref.invalidate(itemsListProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (items) {
                final filtered = _filterItems(items);
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off,
                            size: 60, color: Colors.grey),
                        const SizedBox(height: 12),
                        const Text('No items found'),
                        TextButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _selectedCategory = 'All');
                          },
                          child: const Text('Reset filters'),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) =>
                      ItemCard(item: filtered[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
