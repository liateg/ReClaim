import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/items/presentation/riverpod/items_provider.dart';

class ClaimSubmissionContent extends ConsumerStatefulWidget {
  final Map<String, dynamic> item;
  const ClaimSubmissionContent({super.key, required this.item});

  @override
  ConsumerState<ClaimSubmissionContent> createState() =>
      _ClaimSubmissionContentState();
}

class _ClaimSubmissionContentState
    extends ConsumerState<ClaimSubmissionContent> {
  final TextEditingController _answerController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _submitClaim() async {
    final id = widget.item['id']?.toString();
    final answer = _answerController.text.trim();
    if (id == null || answer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter verification answer.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final params = (id: id, answer: answer);
      await ref.read(submitClaimProvider(params).future);

      if (!mounted) return;

      invalidateItemsState(ref, itemId: id);
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Claim submitted successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit claim: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = (widget.item['image_url'] as String?)?.trim() ?? '';
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Claim Management",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E3E),
              ),
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: imageUrl.isEmpty
                  ? Container(
                      height: 120,
                      width: 120,
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported),
                    )
                  : Image.network(
                      imageUrl,
                      height: 120,
                      width: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 120,
                        width: 120,
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            _infoBox(theme, widget.item),
            const SizedBox(height: 20),
            Text(
              "Verification key: ${widget.item['verification_question'] ?? 'Not provided'}",
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _answerController,
              decoration: const InputDecoration(hintText: "Your answer..."),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E3E),
                  foregroundColor: Colors.white,
                ),
                onPressed: _isSubmitting ? null : _submitClaim,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Submit Claim"),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBox(ThemeData theme, Map<String, dynamic> item) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: theme.primaryColor, borderRadius: BorderRadius.circular(15)),
        child: Column(children: [
          _row(Icons.location_on,
              (item['location'] as String?) ?? 'Unknown location'),
          const Divider(color: Colors.white24),
          _row(Icons.calendar_today,
              (item['date_found'] as String?) ?? 'Unknown date'),
        ]),
      );

  Widget _row(IconData icon, String val) => Row(children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Text(val,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ]);
}
