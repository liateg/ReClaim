import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/utils/theme/app_theme.dart';
import 'package:frontend/shared/widgets/appbar.dart';
import '../../Riverpod/claims_provider.dart';
import '../../../reports/presentation/screens/submit_feedback_screen.dart';

Widget _buildClaimImage(String? imageUrl) {
  if (imageUrl == null || imageUrl.isEmpty) {
    return Container(
      color: AppTheme.grayBorder.withValues(alpha: 0.4),
      child: const Icon(
        Icons.image_outlined,
        size: 60,
        color: AppTheme.grayText,
      ),
    );
  }

  // Check if it's a network image
  if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: AppTheme.grayBorder.withValues(alpha: 0.4),
        child: const Icon(
          Icons.broken_image,
          size: 60,
          color: AppTheme.grayText,
        ),
      ),
    );
  }

  // Otherwise treat as local file
  return Image.file(
    File(imageUrl),
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) => Container(
      color: AppTheme.grayBorder.withValues(alpha: 0.4),
      child: const Icon(
        Icons.broken_image,
        size: 60,
        color: AppTheme.grayText,
      ),
    ),
  );
}

class ClaimDetailScreen extends ConsumerWidget {
  final String claimId;

  const ClaimDetailScreen({super.key, required this.claimId});

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return AppTheme.statusPendingLight;
      case 'APPROVED':
        return AppTheme.statusApprovedLight;
      case 'REJECTED':
        return AppTheme.statusRejectedLight;
      default:
        return AppTheme.statusPendingLight;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return const Color(0xFF2E7D32);
      case 'APPROVED':
        return AppTheme.primaryGreen;
      case 'REJECTED':
        return Colors.black;
      default:
        return const Color(0xFF2E7D32);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final claimAsync = ref.watch(claimProvider(claimId));

    return Scaffold(
      backgroundColor: AppTheme.detailScreenBackground,
      appBar: CustomAppBar(title: 'Claim Details', back: true),
      body: claimAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text('Failed to load claim: $error'),
              TextButton(
                onPressed: () => ref.invalidate(claimProvider(claimId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (claim) {
          final isApproved =
              (claim['status']?.toString() ?? 'pending').toUpperCase() ==
                  'APPROVED';
          final status =
              (claim['status']?.toString() ?? 'pending').toUpperCase();
          final imageUrl = claim['imageUrl']?.toString().trim();
          final title = claim['title']?.toString() ?? 'Untitled Item';
          final description =
              claim['description']?.toString() ?? 'No description';
          final location = claim['location']?.toString() ?? '';

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: _buildClaimImage(imageUrl),
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
                              title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getStatusTextColor(status),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: AppTheme.descriptionText,
                        ),
                      ),
                      if (location.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          'Location: $location',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.grayText,
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      const Text(
                        "CLAIM ID",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.grayText,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '#$claimId',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
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
                          child: Text(
                            claim['founderEmail']?.toString() ??
                                'Contact not available',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                      const SizedBox(height: 25),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6E2DB),
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
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => SubmitFeedbackScreen(
                                                claimId: claimId,
                                              )));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryGreen,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
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
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
