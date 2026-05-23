import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/items/presentation/screens/edit_item_screen.dart';
import 'package:frontend/features/items/Riverpod/items_provider.dart';
import 'package:frontend/shared/widgets/appbar.dart';
import 'package:go_router/go_router.dart';

class AdminItemListScreen extends ConsumerStatefulWidget {
  const AdminItemListScreen({super.key});

  @override
  ConsumerState<AdminItemListScreen> createState() =>
      _AdminItemListScreenState();
}

class _AdminItemListScreenState extends ConsumerState<AdminItemListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filterItems(List<Map<String, dynamic>> items) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return items;
    return items.where((item) {
      final title = (item['title'] as String?)?.toLowerCase() ?? '';
      final location = (item['location'] as String?)?.toLowerCase() ?? '';
      return title.contains(query) || location.contains(query);
    }).toList();
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: Color(0xFFEAF6EF),
                child: Icon(Icons.delete_outline, color: Color(0xFF1B5E3E)),
              ),
              const SizedBox(height: 12),
              const Text(
                'Delete Item?',
                style: TextStyle(
                  color: Color(0xFF1B5E3E),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E3E),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Confirm Delete'),
                ),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
    return result ?? false;
  }

  void _showTopSuccessBanner(String text) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(text, textAlign: TextAlign.center),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1B5E3E),
        margin: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).size.height - 110,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _deleteItem(Map<String, dynamic> item) async {
    final id = item['id']?.toString();
    if (id == null) return;

    final confirm = await _showDeleteConfirmationDialog();
    if (!confirm) return;

    try {
      final deleted = await ref.read(deleteItemProvider(id).future);
      if (!mounted) return;
      if (deleted) {
        invalidateItemsState(ref, itemId: id);
        _showTopSuccessBanner('Deleted successfully');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete item.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete item: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(adminItemsListProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: 'All Posted Items', back: false),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: itemsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Failed to load items: $error'),
                TextButton(
                  onPressed: () => ref.invalidate(adminItemsListProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (items) {
            final filtered = _filterItems(items);
            if (filtered.isEmpty && _searchController.text.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 70,
                      color: Color(0xFF1B5E3E),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No items available',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Items created through the app will appear here.',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'All Posted Items',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E3E),
                  ),
                ),
                const Text(
                  'Review every item record returned from the backend.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search items by title or location...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(child: Text('No matching items found'))
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) =>
                              _buildAdminCard(filtered[index], context),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _showPostDetails(Map<String, dynamic> item) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (item['title'] as String?) ?? 'Untitled item',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text((item['description'] as String?) ?? ''),
              const SizedBox(height: 14),
              Text('Status: ${(item['status'] as String?) ?? '-'}'),
              const SizedBox(height: 4),
              Text('Category: ${(item['category'] as String?) ?? '-'}'),
              const SizedBox(height: 4),
              Text('Posted by: ${item['posted_by']?.toString() ?? '-'}'),
              const SizedBox(height: 4),
              Text(
                  'Verification key: ${(item['verification_question'] as String?) ?? '-'}'),
              const SizedBox(height: 4),
              Text(
                  'Possible answer: ${(item['verification_answer'] as String?) ?? '-'}'),
              const SizedBox(height: 18),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openEditScreen(
      Map<String, dynamic> item, BuildContext context) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EditItemScreen(item: item)),
    );

    if (changed == true && mounted) {
      ref.invalidate(myItemsListProvider);
    }
  }

  Widget _adminThumb(String? imageUrl) {
    final url = imageUrl?.trim() ?? '';
    if (url.isEmpty) {
      return Container(
        width: 70,
        height: 70,
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported, size: 20),
      );
    }
    return Image.network(
      url,
      width: 70,
      height: 70,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        width: 70,
        height: 70,
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image, size: 20),
      ),
    );
  }

  Widget _buildAdminCard(Map<String, dynamic> item, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _adminThumb(item['image_url'] as String?),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (item['title'] as String?) ?? 'Untitled item',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  (item['location'] as String?) ?? 'Unknown location',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  'Status: ${(item['status'] as String?) ?? '-'}',
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () => _openEditScreen(item, context),
                      child: const Text('Edit'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => _deleteItem(item),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Color(0xFFC66060)),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _showPostDetails(item),
                      child: const Text('Post details'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
