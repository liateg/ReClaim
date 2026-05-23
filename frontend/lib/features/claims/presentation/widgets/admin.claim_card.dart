import 'package:flutter/material.dart';
import '../../../../core/api/dio_client.dart';
import 'package:frontend/utils/theme/app_theme.dart';
import 'package:frontend/features/claims/enum/claim_status.dart';

class AdminClaimCard extends StatelessWidget {
  final String title;
  final String location;
  final String imageUrl;
  final String date;
  final ClaimStatus status;
  final int claimantCount;
  final VoidCallback? onPressed;

  const AdminClaimCard({
    super.key,
    required this.title,
    required this.location,
    required this.imageUrl,
    required this.date,
    required this.status,
    this.claimantCount = 1,
    this.onPressed,
  });

  Color get _statusColor {
    switch (status) {
      case ClaimStatus.approved:
        return const Color(0xFF1B873A);
      case ClaimStatus.rejected:
        return const Color(0xFFB42318);
      case ClaimStatus.withdrawn:
        return const Color(0xFF6B7280);
      case ClaimStatus.pending:
      default:
        return const Color(0xFFD97706);
    }
  }

  String get _statusLabel {
    switch (status) {
      case ClaimStatus.approved:
        return 'Approved';
      case ClaimStatus.rejected:
        return 'Rejected';
      case ClaimStatus.withdrawn:
        return 'Withdrawn';
      case ClaimStatus.pending:
      default:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.adminCardBackground,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with badges overlaid
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                child: imageUrl.isEmpty
                    ? Container(
                        height: 220,
                        width: double.infinity,
                        color: const Color(0xFFE6E2DB),
                        child: const Icon(Icons.image_not_supported_outlined,
                            size: 48, color: Color(0xFF77756F)),
                      )
                    : Image.network(
                        imageUrl.startsWith('http') ? imageUrl : '${DioClient.baseUrl}$imageUrl',
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 220,
                          width: double.infinity,
                          color: const Color(0xFFE6E2DB),
                          child: const Icon(Icons.broken_image_outlined,
                              size: 48, color: Color(0xFF77756F)),
                        ),
                      ),
              ),
              // Status Badge
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              // Multiple claimants badge
              if (claimantCount > 1)
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.people_outline, size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          '$claimantCount claimants',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date.toUpperCase(),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 18, color: AppTheme.adminLocationGreen),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(
                          color: AppTheme.adminLocationGreen,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.adminActionGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Claim Review',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
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
}