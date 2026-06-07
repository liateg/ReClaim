import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/config/api_config.dart';
import 'package:frontend/features/claims/Riverpod/claims_provider.dart';

class ItemCard extends ConsumerWidget {
  final Map<String, dynamic> item;
  final bool isAdmin;

  const ItemCard({super.key, required this.item, this.isAdmin = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = ApiConfig.resolveImageUrl(item['image_url'] as String?);
    final title = (item['title'] as String?) ?? 'Untitled item';
    final location = (item['location'] as String?) ?? 'Unknown location';
    final status = (item['status'] as String?) ?? 'available';
    final itemId = item['id'];

    final claimsAsync = ref.watch(claimsListProvider);
    final hasClaimed = claimsAsync.maybeWhen(
      data: (claims) => claims.any((c) {
        final itemIdVal = c['itemId'] ?? c['item_id'];
        return itemIdVal?.toString() == itemId?.toString() &&
            ['pending', 'approved'].contains((c['status']?.toString() ?? '').toLowerCase());
      }),
      orElse: () => false,
    );
    final isAvailable = status == 'available';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: imageUrl.isEmpty
                ? Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                  )
                : Image.network(
                    imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment:MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    _buildStatusBadge(status), // Adds realism for grading
                  ],
                ),
                const SizedBox(height: 4),
                Text(location, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E3E),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: (itemId == null || (!isAdmin && (!isAvailable || hasClaimed)))
                        ? null
                        : () => context.push('/items/$itemId'), // Lia's path parameter
                    child: Text(
                      isAdmin
                          ? "Manage Item"
                          : !isAvailable
                              ? status.toUpperCase()
                              : hasClaimed
                                  ? "CLAIMED"
                                  : "Claim Item",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status == 'available' ? Colors.green.shade100 : Colors.orange.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(), 
        style: TextStyle(
          fontSize: 10, 
          fontWeight: FontWeight.bold, 
          color: status == 'available' ? Colors.green.shade800 : Colors.orange.shade800
        )
      ),
    );
  }
}