import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/items/presentation/riverpod/item_provider.dart';
import 'package:frontend/features/claims/Riverpod/claim_provider.dart';
import 'package:frontend/core/api/dio_client.dart';
import '../widgets/claim_submission_content.dart';
import 'package:frontend/features/items/data/models/item_model.dart';

class ItemDetailScreen extends ConsumerWidget {
  final String itemId; 

  const ItemDetailScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsState = ref.watch(itemProvider);
    final claimState = ref.watch(claimProvider);

    final item = itemsState.items.cast<Item?>().firstWhere(
      (e) => e?.id == itemId,
      orElse: () => null,
    );

    // Check if user already has an active (non-withdrawn) claim for this item
    final alreadyClaimed = claimState.claims.any(
      (c) => c.itemId == itemId && c.status.name != 'withdrawn',
    );

    if (item == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Item not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  item.imageUrl != null && item.imageUrl!.startsWith('http')
                      ? item.imageUrl!
                      : '${DioClient.baseUrl}${item.imageUrl}',
                  height: 350,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 350,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported, size: 50),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        item.location,
                        style: const TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Description",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: alreadyClaimed
                        ? Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F4F0),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF1B5E3E).withOpacity(0.3)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline,
                                    color: Color(0xFF1B5E3E), size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Already Claimed',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1B5E3E),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1B5E3E),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              await showModalBottomSheet<bool>(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20)),
                                ),
                                builder: (context) => Padding(
                                  padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context).viewInsets.bottom,
                                  ),
                                  child: ClaimSubmissionContent(item: item),
                                ),
                              );
                            },
                            child: const Text(
                              'Claim This Item',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}