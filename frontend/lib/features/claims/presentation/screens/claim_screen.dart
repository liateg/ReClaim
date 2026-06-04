import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/shared/widgets/appbar.dart';
import 'package:frontend/utils/theme/app_theme.dart';
import '../../Riverpod/claims_provider.dart';
import './claim_empty.dart';
import '../widgets/claim_card.dart';
import 'claim_withdraw.dart';
import 'claim_delete.dart';

class ClaimsScreen extends ConsumerWidget {
  const ClaimsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final claimsAsync = ref.watch(claimsListProvider);

    return Scaffold(
      backgroundColor: AppTheme.detailScreenBackground,
      appBar: const CustomAppBar(title: 'My Claims', back: false),
      body: claimsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text('Failed to load claims: $error'),
              TextButton(
                onPressed: () => ref.invalidate(claimsListProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (claims) {
          if (claims.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                await ref.read(claimsServiceProvider).invalidateClaimsCache();
                return ref.refresh(claimsListProvider.future);
              },
              child: const SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: 500,
                  child: ClaimEmptyScreen(),
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Text(
                  'Track the status of your lost and found claims here.',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(claimsServiceProvider).invalidateClaimsCache();
                    return ref.refresh(claimsListProvider.future);
                  },
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: claims.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                    final claimData = claims[index];

                    // Parse claim data from backend response
                    final claimMap = {
                      'id': claimData['id']?.toString() ?? '',
                      'title': claimData['title']?.toString() ?? '',
                      'description': claimData['description']?.toString() ?? '',
                      'date':
                          claimData['createdAt']?.toString().split('T')[0] ??
                              claimData['date']?.toString().split(' ')[0] ??
                              '',
                      'status': (claimData['status']?.toString() ?? 'pending')
                          .toUpperCase(),
                      'imageUrl': claimData['imageUrl']?.toString() ?? '',
                      'filedDate':
                          claimData['createdAt']?.toString().split('T')[0] ??
                              claimData['date']?.toString().split(' ')[0] ??
                              '',
                    };

                    final status = claimMap['status'] ?? 'PENDING';
                    final isPending = status == 'PENDING';

                    return ClaimCard(
                      claim: claimMap,
                      onWithdraw: () async {
                        if (isPending) {
                          final confirmed = await showClaimWithdrawDialog(context);
                          if (confirmed == true && context.mounted) {
                            try {
                              await ref.read(claimsServiceProvider).withdrawClaim(claimMap['id']!);
                              ref.invalidate(claimsListProvider);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Claim withdrawn successfully.')),
                              );
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                                );
                              }
                            }
                          }
                        } else {
                          final confirmed = await showClaimDeleteDialog(context);
                          if (confirmed == true && context.mounted) {
                            try {
                              await ref.read(claimsServiceProvider).deleteClaim(claimMap['id']!);
                              ref.invalidate(claimsListProvider);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Claim deleted successfully.')),
                              );
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                                );
                              }
                            }
                          }
                        }
                      },
                      onTap: () => context.go('/claims/${claimMap['id']}'),
                    );
                  },
                ),
              ),
            ),
          ],
        );
        },
      ),
    );
  }
}
