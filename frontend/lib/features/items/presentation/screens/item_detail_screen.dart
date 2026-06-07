import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/config/api_config.dart';
import 'package:frontend/features/items/Riverpod/items_provider.dart';
import 'package:frontend/features/claims/Riverpod/claims_provider.dart';
import '../widgets/claim_submission_content.dart';


Widget _itemDetailImage(String? imageUrl) {
  final url = ApiConfig.resolveImageUrl(imageUrl);
  if (url.isEmpty) {
    return Container(
      height: 250,
      width: double.infinity,
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }
  return Image.network(
    url,
    height: 250,
    width: double.infinity,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) => Container(
      height: 250,
      width: double.infinity,
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image, color: Colors.grey),
    ),
  );
}

class ClaimDetailScreen extends ConsumerWidget {
  final String claimId;

  const ClaimDetailScreen({super.key, required this.claimId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(itemByIdProvider(claimId));
    final claimsAsync = ref.watch(claimsListProvider);

    return itemAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Failed to load item: $error'),
            TextButton(
              onPressed: () => ref.invalidate(itemByIdProvider(claimId)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (item) {
        if (item == null) {
          return const Center(child: Text('Item not found'));
        }

        final itemId = item['id']?.toString() ?? '';
        final status = (item['status'] as String?) ?? 'available';
        final isAvailable = status == 'available';

        final hasClaimed = claimsAsync.maybeWhen(
          data: (claims) => claims.any((c) {
            final itemIdVal = c['itemId'] ?? c['item_id'];
            return itemIdVal?.toString() == itemId &&
                ['pending', 'approved'].contains((c['status']?.toString() ?? '').toLowerCase());
          }),
          orElse: () => false,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _itemDetailImage(item['image_url'] as String?),
              ),
              const SizedBox(height: 20),
              Text(
                (item['title'] as String?) ?? 'Untitled item',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                (item['location'] as String?) ?? 'Unknown location',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Text((item['description'] as String?) ?? ''),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E3E),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: (!isAvailable || hasClaimed)
                      ? null
                      : () async {
                          await showModalBottomSheet<bool>(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => ClaimSubmissionContent(item: item),
                          );
                        },
                  child: Text(
                    !isAvailable
                        ? status.toUpperCase()
                        : hasClaimed
                            ? "CLAIMED"
                            : "Claim This Item",
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
