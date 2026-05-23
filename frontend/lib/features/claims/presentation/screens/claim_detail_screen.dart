import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/utils/theme/app_theme.dart';
import 'package:frontend/shared/widgets/appbar.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/claims/Riverpod/claim_provider.dart';
import 'package:frontend/features/claims/enum/claim_status.dart';
import '../widgets/claim_image_preview.dart';

class ClaimDetailScreen extends ConsumerWidget {
  final String claimId;

  const ClaimDetailScreen({super.key, required this.claimId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final claimState = ref.watch(claimProvider);
    final claim = claimState.claims.firstWhere(
      (c) => c.id == claimId,
      orElse: () => claimState.claims.first,
    );

    final isApproved = claim.status.name.toLowerCase() == 'approved';
    final status = claim.status.name.toUpperCase();

    return Scaffold(
      backgroundColor: AppTheme.detailScreenBackground,
      appBar: CustomAppBar(title: 'Claim Details', back: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: ClaimImagePreview(
                imageUrl: claim.imageUrl,
                placeholderIconSize: 60,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          claim.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => context.go('/claims/${claim.id}/edit'),
                        icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryGreen),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: claim.status == ClaimStatus.approved
                              ? AppTheme.statusApprovedLight
                              : claim.status == ClaimStatus.withdrawn
                                  ? Colors.grey.shade200
                                  : AppTheme.statusPendingLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: claim.status == ClaimStatus.approved
                                ? AppTheme.primaryGreen
                                : claim.status == ClaimStatus.withdrawn
                                    ? Colors.grey.shade700
                                    : Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    claim.description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppTheme.descriptionText,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    "REPORT ID",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.grayText,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "#RC-992-${claim.id.padLeft(4, '0')}",
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  if (isApproved) ...[
                    const SizedBox(height: 20),
                    const Text(
                      "FOUNDER CONTACT INFO",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.grayText,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.grayBorder),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "elenaaati@gmail.com",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                  const SizedBox(height: 25),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppTheme.feedbackCardBackground,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 40,
                          color: AppTheme.primaryGreen,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "How was your experience?",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Your feedback helps us improve the lost and found process for everyone on campus.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.feedbackText,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              "Leave a Feedback",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final success = await ref.read(claimProvider.notifier).withdrawClaim(claimId);
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Claim withdrawn')),
                              );
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.orange),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            "Withdraw",
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Claim'),
                                content: const Text('Are you sure you want to delete this claim?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                  TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              final success = await ref.read(claimProvider.notifier).deleteClaim(claimId);
                              if (success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Claim deleted')),
                                );
                                context.go('/claims');
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade400,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            "Delete",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
