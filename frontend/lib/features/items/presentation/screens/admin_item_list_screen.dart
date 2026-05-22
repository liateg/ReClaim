import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/items/presentation/screens/edit_item_screen.dart';
import 'package:frontend/features/items/presentation/riverpod/items_provider.dart';
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

  List<Map<String, dynamic>> _filterPosts(List<Map<String, dynamic>> items) {
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
    final itemsAsync = ref.watch(itemsListProvider);

    return Scaffold(
      appBar: CustomAppBar(title: "My Posts", back: false),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: itemsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Failed to load posts: $error'),
                TextButton(
                  onPressed: () => ref.invalidate(itemsListProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (items) {
            final filtered = _filterPosts(items);
            if (filtered.isEmpty && _searchController.text.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      size: 70,
                      color: Color(0xFF1B5E3E),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "No Posted Items",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Post your first item to manage it here.",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E3E),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => context.go('/post'),
                      child: const Text('Post New Item'),
                    ),
                  ],
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("My Posts",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E3E))),
                const Text(
                    "Managing your active traces and valued returns.",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search your items...',
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
                      ? const Center(child: Text('No matching posts found'))
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

  Future<void> _openEditScreen(Map<String, dynamic> item, BuildContext context) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EditItemScreen(item: item)),
    );

    if (changed == true && mounted) {
      ref.invalidate(itemsListProvider);
    }
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
              child: Image.network(item['image_url'],
                  width: 70, height: 70, fit: BoxFit.cover)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text((item['title'] as String?) ?? 'Untitled item',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text((item['location'] as String?) ?? 'Unknown location',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
