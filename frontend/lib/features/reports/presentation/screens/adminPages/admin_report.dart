// lib/features/reports/presentation/screens/adminPages/admin_report.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/shared/widgets/appbar.dart';
import '../../../Riverpod/report_provider.dart';
import '../../../data/models/report_model.dart';

class AdminReportsScreen extends ConsumerWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(allReportsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFEF9F2),
      appBar: const CustomAppBar(title: 'Reports', back: false),
      body: SafeArea(
        child: reportsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $err'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(allReportsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (reports) {
            // ✅ Fixed: Add null check for reports
            final safeReports = reports ?? [];

            final pendingCount = safeReports
                .where((r) => r != null && r.status == ReportStatus.pending)
                .length;
            final reviewedCount = safeReports
                .where(
                    (r) => r != null && r.status == ReportStatus.under_review)
                .length;
            final totalCount = safeReports.length;

            return SingleChildScrollView(
              padding: const EdgeInsets.only(
                  left: 16, right: 16, top: 16, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard Overview',
                    style: GoogleFonts.manrope(
                      color: const Color(0xFF003925),
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.75,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'System health and recent activity.',
                    style: GoogleFonts.manrope(
                      color: const Color(0xFF404943),
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Total Reports Card
                  _TotalReportsCard(value: totalCount.toString()),
                  const SizedBox(height: 16),
                  _StatCard(
                    label: 'Pending Reports',
                    value: pendingCount.toString(),
                    subtitle: '$pendingCount require immediate review',
                    subtitleColor: const Color(0xFF404943),
                    iconBgColor: const Color(0xFFD2E8D9),
                    icon: Icons.check_box_outlined,
                    iconColor: const Color(0xFF003925),
                  ),
                  const SizedBox(height: 16),
                  _StatCard(
                    label: 'Active Reports',
                    value: reviewedCount.toString(),
                    subtitle: '$reviewedCount under review',
                    subtitleColor: const Color(0xFFBA1A1A),
                    iconBgColor: const Color(0xFFFFDAD6),
                    icon: Icons.flag_outlined,
                    iconColor: const Color(0xFFBA1A1A),
                  ),
                  const SizedBox(height: 32),

                  // Recent Feedback Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Feedback',
                        style: GoogleFonts.manrope(
                          color: const Color(0xFF003925),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/admin/reports/all'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF003925),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: const Text(
                            'View all reports',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ✅ Fixed: Cast to Report and handle null
                  ...safeReports.take(2).map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _FeedbackCard(
                          report: r as Report,
                          onTap: () =>
                              context.push('/admin/reports/${r.id}', extra: r),
                        ),
                      )),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// Helper widgets
class _TotalReportsCard extends StatelessWidget {
  final String value;
  const _TotalReportsCard({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F3EC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Reports',
                  style: GoogleFonts.inter(
                      color: const Color(0xFF404943), fontSize: 14)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                    color: Color(0xFFE6E2DB), shape: BoxShape.circle),
                child: const Icon(Icons.archive_outlined,
                    size: 16, color: Color(0xFF404943)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value,
              style: GoogleFonts.manrope(
                  color: const Color(0xFF003925),
                  fontSize: 36,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, subtitle;
  final Color subtitleColor, iconBgColor, iconColor;
  final IconData icon;
  const _StatCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.subtitleColor,
    required this.iconBgColor,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: const Color(0xFFF8F3EC),
          borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: GoogleFonts.inter(
                      color: const Color(0xFF404943), fontSize: 14)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration:
                    BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
                child: Icon(icon, size: 16, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(value,
              style: GoogleFonts.manrope(
                  color: const Color(0xFF003925),
                  fontSize: 36,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          Row(children: [
            Text(subtitle,
                style: GoogleFonts.inter(color: subtitleColor, fontSize: 12))
          ]),
        ],
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final Report report;
  final VoidCallback onTap;
  const _FeedbackCard({required this.report, required this.onTap});

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown date';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isPending = report.status == ReportStatus.pending;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: const Color(0xFFF8F3EC),
            borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                      color: Color(0xFFE6E2DB), shape: BoxShape.circle),
                  child: const Icon(Icons.person_outline,
                      size: 16, color: Color(0xFF404943)),
                ),
                const SizedBox(width: 8),
                Text('Reporter #${report.reporterId}',
                    style: GoogleFonts.inter(
                        color: const Color(0xFF1D1C18), fontSize: 14)),
                const SizedBox(width: 8),
                Text('• ${_formatDate(report.createdAt)}',
                    style: GoogleFonts.inter(
                        color: const Color(0xFF404943), fontSize: 12)),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: report.status.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(2)),
                  child: Text(report.status.displayName.toUpperCase(),
                      style:
                          TextStyle(color: report.status.color, fontSize: 10)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (report.description != null && report.description!.isNotEmpty)
              Text(report.description!,
                  style: GoogleFonts.manrope(fontSize: 15)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                  color: const Color(0xFFE6E2DB),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(isPending ? 'Review' : 'Details',
                  style: GoogleFonts.inter(color: const Color(0xFF003925))),
            ),
          ],
        ),
      ),
    );
  }
}
