import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/report_model.dart';
import '../../Riverpod/report_provider.dart';
import '../../../../shared/widgets/appbar.dart';
import 'feedback_submitted_success.dart';

class SubmitFeedbackScreen extends ConsumerStatefulWidget {
  final String? itemId;
  final String? claimId;

  const SubmitFeedbackScreen({
    super.key,
    this.itemId,
    this.claimId,
  });

  @override
  ConsumerState<SubmitFeedbackScreen> createState() =>
      _SubmitFeedbackScreenState();
}

class _SubmitFeedbackScreenState extends ConsumerState<SubmitFeedbackScreen> {
  static const Color kBg = Color(0xFFFEF9F2);
  static const Color kHeaderBg = Color(0xCCFEF9F2);
  static const Color kDarkGreen = Color(0xFF003925);
  static const Color kCardBg = Color(0xFFF8F3EC);
  static const Color kInputBg = Color(0xFFE6E2DB);
  static const Color kBorder = Color(0x26C0C9C1);
  static const Color kTextDark = Color(0xFF1D1C18);
  static const Color kTextBody = Color(0xFF404943);
  static const Color kHint = Color(0x99404943);
  static const Color kShadow = Color(0x0F1D1C18);
  static const Color kError = Color(0xFFD94040);

  ReportReason? _selectedReason;
  bool _reasonError = false;
  bool _commentError = false;
  bool _isSubmitting = false;

  final TextEditingController _commentsController = TextEditingController();

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  TextStyle _manrope({
    required double size,
    FontWeight weight = FontWeight.w400,
    Color color = kTextDark,
    double height = 1.5,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontFamily: 'Roboto',
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  String _getReasonFromRating(int rating) {
    if (rating <= 2) return 'other';
    if (rating == 3) return 'spam';
    if (rating >= 4) return 'fake';
    return 'other';
  }

  int? _parseId(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return int.tryParse(trimmed);
  }

  Future<void> _onSubmit() async {
    final bool noReason = _selectedReason == null;
    final bool noComment = _commentsController.text.trim().isEmpty;
    final itemId = _parseId(widget.itemId);
    final claimId = _parseId(widget.claimId);

    setState(() {
      _reasonError = noReason;
      _commentError = noComment;
    });

    if (itemId == null && claimId == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Missing item or claim reference for this report.',
                  style: _manrope(size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: kError,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    if (noReason || noComment) {
      final missing = <String>[];
      if (noReason) missing.add('a report reason');
      if (noComment) missing.add('your description');

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Please add ${missing.join(' and ')} before submitting.',
                  style: _manrope(size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: kError,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Call Riverpod to create report
      await ref.read(createReportProvider({
        'itemId': itemId,
        'claimId': claimId,
        'reason': _selectedReason!.name,
        'description': _commentsController.text.trim(),
      }).future);

      if (mounted) {
        // Navigate to success screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const FeedbackSuccessScreen()),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Failed to submit: ${e.toString().replaceAll('Exception: ', '')}',
                  style: _manrope(size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: kError,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _onReasonChanged(ReportReason? value) {
    setState(() {
      _selectedReason = value;
      _reasonError = false;
    });
  }

  void _onCommentChanged(String _) {
    if (_commentError && _commentsController.text.trim().isNotEmpty) {
      setState(() => _commentError = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: const CustomAppBar(title: 'Submit Report', back: true),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 24, right: 24, bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildTargetSection(),
                      const SizedBox(height: 32),
                      _buildReasonSection(),
                      const SizedBox(height: 32),
                      _buildCommentsSection(),
                      const SizedBox(height: 32),
                      _buildSubmitButton(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildAppBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: kHeaderBg,
        boxShadow: [
          BoxShadow(color: kShadow, blurRadius: 32, offset: Offset(0, 12))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(9999)),
                    ),
                  ),
                  child:
                      const Icon(Icons.arrow_back, color: kDarkGreen, size: 20),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Submit Report',
                style: _manrope(
                  size: 20,
                  weight: FontWeight.w600,
                  color: kDarkGreen,
                  height: 1.40,
                  letterSpacing: -0.50,
                ),
              ),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: const ShapeDecoration(
              color: kInputBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(9999)),
              ),
            ),
            child: const Icon(Icons.person, color: kDarkGreen, size: 22),
          ),
        ],
      ),
    );
  }

  String _buildTargetLabel() {
    if (widget.claimId != null && widget.claimId!.trim().isNotEmpty) {
      return 'Claim #${widget.claimId!.trim()}';
    }
    if (widget.itemId != null && widget.itemId!.trim().isNotEmpty) {
      return 'Item #${widget.itemId!.trim()}';
    }
    return 'Unknown report target';
  }
  Widget _buildTargetSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: kCardBg,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: kBorder),
          borderRadius: BorderRadius.circular(12),
        ),
        shadows: const [
          BoxShadow(color: kShadow, blurRadius: 32, offset: Offset(0, 12))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: kInputBg,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Icon(Icons.image_outlined,
                color: Color(0xFF8A9490), size: 36),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Report target',
                  style: _manrope(
                    size: 14,
                    weight: FontWeight.w600,
                    color: kTextBody,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _buildTargetLabel(),
                  style: _manrope(
                    size: 18,
                    weight: FontWeight.w700,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.claimId != null
                      ? 'You are reporting this claim. The signed-in user is used automatically by the backend.'
                      : 'You are reporting this item. The signed-in user is used automatically by the backend.',
                  style: _manrope(
                    size: 13,
                    color: kTextBody,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonSection() {
    final reasons = ReportReason.values;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Reason',
              style: _manrope(
                size: 16,
                weight: FontWeight.w600,
                color: _reasonError ? kError : kTextDark,
              ),
            ),
            if (_reasonError) ...[
              const SizedBox(width: 8),
              Text(
                '— Please select a reason',
                style: _manrope(size: 13, color: kError),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: kInputBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _reasonError ? kError : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ReportReason>(
              isExpanded: true,
              value: _selectedReason,
              hint: Text(
                'Select a reason',
                style: _manrope(size: 16, color: kHint),
              ),
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: kTextBody),
              items: reasons
                  .map(
                    (reason) => DropdownMenuItem<ReportReason>(
                      value: reason,
                      child: Text(reason.displayName,
                          style: _manrope(size: 16, color: kTextDark)),
                    ),
                  )
                  .toList(),
              onChanged: _onReasonChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Description',
              style: _manrope(
                size: 16,
                weight: FontWeight.w600,
                color: _commentError ? kError : kTextDark,
              ),
            ),
            if (_commentError) ...[
              const SizedBox(width: 8),
              Text(
                '— Required',
                style: _manrope(size: 13, color: kError),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: ShapeDecoration(
            color: kInputBg,
            shape: RoundedRectangleBorder(
              side: _commentError
                  ? const BorderSide(color: kError, width: 1.5)
                  : BorderSide.none,
              borderRadius: BorderRadius.circular(12),
            ),
            shadows: const [
              BoxShadow(color: kShadow, blurRadius: 32, offset: Offset(0, 12))
            ],
          ),
          child: TextField(
            controller: _commentsController,
            onChanged: _onCommentChanged,
            minLines: 5,
            maxLines: 8,
            style: _manrope(size: 16, color: kTextBody),
            decoration: InputDecoration(
              hintText: 'Explain why you are reporting this...',
              hintStyle: _manrope(
                size: 16,
                color: _commentError ? kError.withOpacity(0.6) : kHint,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(
                top: 16,
                left: 16,
                right: 16,
                bottom: 88,
              ),
            ),
          ),
        ),
        if (_commentError) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.info_outline, color: kError, size: 14),
              const SizedBox(width: 4),
              Text(
                'Please share your experience before submitting.',
                style: _manrope(size: 12, color: kError),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        width: double.infinity,
        decoration: ShapeDecoration(
          gradient: const LinearGradient(
            begin: Alignment(0.47, 1.47),
            end: Alignment(0.53, -0.47),
            colors: [Color(0xFF003925), Color(0xFF1D503A)],
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          shadows: const [
            BoxShadow(color: kShadow, blurRadius: 32, offset: Offset(0, 12))
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isSubmitting ? null : _onSubmit,
            borderRadius: BorderRadius.circular(12),
            splashColor: Colors.white.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Submit Feedback',
                      textAlign: TextAlign.center,
                      style: _manrope(
                        size: 16,
                        weight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}