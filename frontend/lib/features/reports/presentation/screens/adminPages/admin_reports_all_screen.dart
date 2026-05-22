import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/shared/widgets/appbar.dart';
import '../../../Riverpod/report_provider.dart';
import '../../../data/model/report_model.dart';

class AdminReportsAllScreen extends ConsumerStatefulWidget {
  const AdminReportsAllScreen({super.key});

  @override
  ConsumerState<AdminReportsAllScreen> createState() =>
      _AdminReportsAllScreenState();
}

class _AdminReportsAllScreenState extends ConsumerState<AdminReportsAllScreen> {
  static const Color kBg = Color(0xFFFEF9F2);
  static const Color kGreen = Color(0xFF003925);

  final TextEditingController _search = TextEditingController();
  String _tab = 'All';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Report> get _filteredReports {
    final reports = ref.read(allReportsProvider).value ?? [];
    final q = _search.text.trim().toLowerCase();
    var items = List<Report>.from(reports);

    // Filter by tab
    if (_tab == 'Pending') {
      items = items.where((e) => e.status == ReportStatus.pending).toList();
    } else if (_tab == 'Reviewed') {
      items = items
          .where((e) =>
              e.status == ReportStatus.under_review ||
              e.status == ReportStatus.resolved)
          .toList();
    }

    // Filter by search
    if (q.isNotEmpty) {
      items = items
          .where((e) =>
              e.id.toLowerCase().contains(q) ||
              e.reason.displayName.toLowerCase().contains(q) ||
              (e.description?.toLowerCase().contains(q) ?? false) ||
              e.reporterId.toLowerCase().contains(q))
          .toList();
    }

    return items;
  }

  void _showTopBanner(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: kGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(allReportsProvider);

    return Scaffold(
      backgroundColor: kBg,
      appBar: const CustomAppBar(title: 'All Reports', back: true),
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
            final filtered = _filteredReports;

            return Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: _SearchBar(
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                // Tabs
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                  child: _Tabs(
                    value: _tab,
                    onChanged: (v) => setState(() => _tab = v),
                  ),
                ),
                // Report List
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox_outlined,
                                  size: 48, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('No reports found'),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, i) {
                            final report = filtered[i];
                            return _ReportCard(
                              report: report,
                              onTap: () async {
                                final result = await context.push(
                                    '/admin/reports/${report.id}',
                                    extra: report);
                                if (result == 'updated') {
                                  _showTopBanner('Report updated successfully');
                                  ref.invalidate(allReportsProvider);
                                }
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}


class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFE6E2DB),
        borderRadius: BorderRadius.circular(999),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(Icons.search, size: 18, color: Color(0xFF77756F)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: const InputDecoration(
                hintText: 'Search feedback...',
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _Tabs extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _Tabs({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    Widget chip(String label) {
      final selected = value == label;
      return GestureDetector(
        onTap: () => onChanged(label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF003925) : const Color(0xFFFEF9F2),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
                color: selected
                    ? const Color(0xFF003925)
                    : const Color(0xFFE6E2DB)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : const Color(0xFF404943),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        chip('All'),
        const SizedBox(width: 10),
        chip('Pending'),
        const SizedBox(width: 10),
        chip('Reviewed'),
      ],
    );
  }
}


class _ReportCard extends StatelessWidget {
  final Report report;
  final VoidCallback onTap;

  const _ReportCard({
    required this.report,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = report.status == ReportStatus.pending;
    final primaryLabel = isPending ? 'Review Feedback' : 'View Details';
    final primaryBg =
        isPending ? const Color(0xFF003925) : const Color(0xFFE6E2DB);
    final primaryFg = isPending ? Colors.white : const Color(0xFF003925);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8F3EC),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6E2DB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.report_outlined,
                      size: 20, color: Color(0xFF77756F)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.reason.displayName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1D1C18),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Reported: ${_formatDate(report.createdAt)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF404943),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: report.status.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    report.status.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: report.status.color,
                    ),
                  ),
                ),
              ],
            ),
            if (report.description != null &&
                report.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                report.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1D1C18),
                  height: 1.45,
                ),
              ),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: primaryBg,
                  foregroundColor: primaryFg,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  primaryLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
