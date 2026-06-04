import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/appbar.dart';
import '../../utils/theme/app_theme.dart';
import '../claims/data/model/claim_model.dart' as ui_claim;
import '../claims/enum/claim_status.dart';
import 'data/admin_claims_repository.dart';


class AdminClaimDetailScreen extends StatefulWidget {
  final String claimId;

  const AdminClaimDetailScreen({super.key, required this.claimId});

  @override
  State<AdminClaimDetailScreen> createState() => _AdminClaimDetailScreenState();
}

class _AdminClaimDetailScreenState extends State<AdminClaimDetailScreen> {
  final AdminClaimsRepository _repository = AdminClaimsRepository();
  late Future<AdminClaimRecord?> _recordFuture;

  @override
  void initState() {
    super.initState();
    _recordFuture = _repository.getClaimById(widget.claimId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF9F2),
      appBar: const CustomAppBar(title: 'Claimed Items', back: true),
      body: FutureBuilder<AdminClaimRecord?>(
        future: _recordFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final record = snapshot.data;
          if (record == null) {
            return const Center(child: Text('Claim not found'));
          }

          final claim = record.toUiClaim();
          final statusLabel = switch (claim.status) {
            ClaimStatus.pending => 'PENDING REVIEW',
            ClaimStatus.approved => 'APPROVED',
            ClaimStatus.rejected => 'REJECTED',
          };

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Claims › Review #${record.reviewCode}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF404943),
                          height: 1.35,
                        ),
                      ),
                    ),
                    _statusChip(statusLabel, claim.status),
                  ],
                ),
                const SizedBox(height: 20),
                _heroImage(claim, record.itemIdBadge),
                const SizedBox(height: 18),
                Text(
                  claim.title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF003925),
                    height: 1.2,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  record.recoveredNote,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF404943),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: record.tags
                      .map(
                        (t) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6E2DB),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            t,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF404943),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 20),
                _foundInfoCard(claim),
                const SizedBox(height: 24),
                const Text(
                  'Claimant Identity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF003925),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xFFD2E8D9),
                      child: Text(
                        record.claimantInitials,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF003925),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.claimantName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1D1C18),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            record.claimantEmail,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF404943),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Verified ID: ${record.verifiedIdReference}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF55695D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF003925),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'INTERNAL KEY'.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        record.reviewCode,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Matching Evidence',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF003925),
                  ),
                ),
                const SizedBox(height: 12),
                _evidenceBlock(record.evidenceQuestion1, record.evidenceAnswer1),
                const SizedBox(height: 14),
                _evidenceBlock(record.evidenceQuestion2, record.evidenceAnswer2),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F3EC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x26C0C9C1)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.shield_outlined,
                          color: AppTheme.primaryGreen, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          record.securityProtocolText,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.45,
                            color: Color(0xFF404943),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () async {
                          try {
                            await _repository.updateClaimStatus(
                              widget.claimId,
                              'approved',
                              reviewNote: 'Approved by admin manually.',
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Claim confirmed successfully.'),
                                  backgroundColor: Color(0xFF003925),
                                ),
                              );
                              context.pop(true);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error confirming claim: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF003925),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.check_rounded, size: 20),
                        label: const Text(
                          'Confirm Claim',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          try {
                            await _repository.updateClaimStatus(
                              widget.claimId,
                              'rejected',
                              reviewNote: 'Denied by admin manually.',
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Claim denied successfully.'),
                                  backgroundColor: Colors.grey.shade800,
                                ),
                              );
                              context.pop(true);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error denying claim: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF003925),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0x26C0C9C1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          backgroundColor: const Color(0xFFE6E2DB),
                        ),
                        child: const Text(
                          'Deny Claim',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statusChip(String label, ClaimStatus status) {
    final bg = switch (status) {
      ClaimStatus.pending => const Color(0xFFD2E8D9),
      ClaimStatus.approved => const Color(0xFFB9EFD0),
      ClaimStatus.rejected => const Color(0xFFFFDAD6),
    };
    final fg = switch (status) {
      ClaimStatus.pending => const Color(0xFF55695D),
      ClaimStatus.approved => const Color(0xFF003925),
      ClaimStatus.rejected => const Color(0xFF93000A),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: fg,
        ),
      ),
    );
  }

  Widget _heroImage(ui_claim.Claim claim, String itemBadge) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Stack(
          fit: StackFit.expand,
          children: [
            claim.imageUrl == null || claim.imageUrl!.isEmpty
                ? Container(
                    color: const Color(0xFFE6E2DB),
                    child: const Icon(Icons.image_not_supported_outlined,
                        size: 56, color: Color(0xFF77756F)),
                  )
                : Image.network(
                    claim.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFE6E2DB),
                      child: const Icon(Icons.broken_image_outlined,
                          size: 56, color: Color(0xFF77756F)),
                    ),
                  ),
            Positioned(
              left: 12,
              top: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF003925),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'ITEM ID: $itemBadge',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _foundInfoCard(ui_claim.Claim claim) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final d = claim.date;
    final dateStr =
        '${months[d.month - 1]} ${d.day}, ${d.year} · ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF003925),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.place_outlined,
                  color: Colors.white.withValues(alpha: 0.9), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Found Location'.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      claim.location,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.calendar_today_outlined,
                  color: Colors.white.withValues(alpha: 0.9), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Found Date'.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _evidenceBlock(String question, String answer) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x26C0C9C1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: Color(0xFF55695D),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F3EC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              answer,
              style: const TextStyle(
                fontSize: 14,
                height: 1.45,
                color: Color(0xFF1D1C18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
