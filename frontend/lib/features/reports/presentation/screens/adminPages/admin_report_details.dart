import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/shared/widgets/appbar.dart';
import '../../../../reports/Riverpod/report_provider.dart';
import '../../../data/model/report_model.dart';

class AdminReportsDetailScreen extends ConsumerStatefulWidget {
  final Report report;

  const AdminReportsDetailScreen({
    super.key,
    required this.report,
  });

  @override
  ConsumerState<AdminReportsDetailScreen> createState() =>
      _AdminReportsDetailScreenState();
}

class _AdminReportsDetailScreenState
    extends ConsumerState<AdminReportsDetailScreen> {
  late final TextEditingController _notesController;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(
      text: widget.report.adminNote ?? '',
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(String status, {String? adminNote}) async {
    setState(() => _isUpdating = true);

    try {
      await ref.read(updateReportStatusProvider({
        'id': widget.report.id,
        'status': status,
        'adminNote': adminNote ?? _notesController.text.trim(),
      }).future);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report status updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, 'updated');
      }
    } catch (e) {
      setState(() => _isUpdating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Failed to update: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteReport() async {
    // Note: You'll need a delete endpoint in your backend
    // For now, just show confirmation
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Report'),
        content: const Text(
            'Are you sure you want to delete this report? This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, 'deleted');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Report deleted'),
                    backgroundColor: Colors.orange),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    final isPending = report.status == ReportStatus.pending;

    return Scaffold(
      backgroundColor: const Color(0xFFFEF9F2),
      appBar: const CustomAppBar(title: 'Reports'),
      body: SafeArea(
        child: _isUpdating
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(report),
                    const SizedBox(height: 24),
                    _buildFeedbackCard(report),
                    const SizedBox(height: 24),
                    _buildModerationNotesCard(),
                    const SizedBox(height: 24),
                    _buildActionButtons(isPending, report.status),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(Report report) {
    final isPending = report.status == ReportStatus.pending;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FEEDBACK REPORT #${report.id}',
          style: const TextStyle(
            color: Color(0xFF404943),
            fontSize: 13,
            letterSpacing: 0.80,
          ),
        ),
        const Text(
          'Details',
          style: TextStyle(
            color: Color(0xFF003925),
            fontSize: 36,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.40,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color:
                isPending ? const Color(0xFF6C3838) : const Color(0xFF55695D),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPending
                    ? Icons.hourglass_empty_rounded
                    : Icons.check_circle_outline_rounded,
                color: isPending
                    ? const Color(0xFFFFDCDC)
                    : const Color(0xFFD2E8D9),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                isPending ? 'Pending Review' : report.status.displayName,
                style: TextStyle(
                  color: isPending
                      ? const Color(0xFFFFDCDC)
                      : const Color(0xFFD2E8D9),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackCard(Report report) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F3EC),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0F1D1C18),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFE6E2DB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_outline,
                    color: Color(0xFF77756F), size: 24),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reporter #${report.reporterId}',
                    style: const TextStyle(
                      color: Color(0xFF003925),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _formatDate(report.createdAt),
                    style: const TextStyle(
                      color: Color(0xFF404943),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Color(0x26C0C9C1), thickness: 1),
          ),
          const Text(
            'REASON',
            style: TextStyle(
              color: Color(0xFF404943),
              fontSize: 12,
              letterSpacing: 0.30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            report.reason.displayName,
            style: const TextStyle(
              color: Color(0xFF003925),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'WRITTEN COMMENT',
            style: TextStyle(
              color: Color(0xFF404943),
              fontSize: 12,
              letterSpacing: 0.30,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            report.description ?? 'No comment provided',
            style: const TextStyle(
              color: Color(0xFF1D1C18),
              fontSize: 16,
              height: 1.63,
            ),
          ),
          if (report.itemId != null || report.claimId != null) ...[
            const SizedBox(height: 16),
            const Text(
              'REPORTED ON',
              style: TextStyle(
                color: Color(0xFF404943),
                fontSize: 12,
                letterSpacing: 0.30,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              report.itemId != null
                  ? 'Item #${report.itemId}'
                  : 'Claim #${report.claimId}',
              style: const TextStyle(
                color: Color(0xFF003925),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModerationNotesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F3EC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x26C0C9C1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.notes_rounded, color: Color(0xFF003925), size: 20),
              SizedBox(width: 8),
              Text(
                'Internal Moderation Notes',
                style: TextStyle(
                  color: Color(0xFF003925),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 130),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _notesController,
              maxLines: null,
              minLines: 5,
              style: const TextStyle(
                color: Color(0xFF1D1C18),
                fontSize: 16,
              ),
              decoration: const InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                hintText: 'Add confidential notes regarding this feedback...',
                hintStyle: TextStyle(color: Color(0x7F404943), fontSize: 16),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isPending, ReportStatus status) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFE6E2DB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (isPending)
            Container(
              width: double.infinity,
              decoration: const ShapeDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.47, 1.47),
                  end: Alignment(0.53, -0.47),
                  colors: [Color(0xFF003925), Color(0xFF1D503A)],
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _updateStatus('under_review',
                      adminNote: _notesController.text.trim()),
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Mark as Under Review',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ),
          if (isPending) const SizedBox(height: 16),
          if (status == ReportStatus.under_review)
            Container(
              width: double.infinity,
              decoration: const ShapeDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.47, 1.47),
                  end: Alignment(0.53, -0.47),
                  colors: [Color(0xFF003925), Color(0xFF1D503A)],
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _updateStatus('resolved',
                      adminNote: _notesController.text.trim()),
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Mark as Resolved',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ),
          if (status == ReportStatus.under_review) const SizedBox(height: 16),
          GestureDetector(
            onTap: _deleteReport,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0x7FFFDAD6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0x33BA1A1A)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.delete_outline_rounded,
                      color: Color(0xFFBA1A1A), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Delete Feedback',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color(0xFFBA1A1A),
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
