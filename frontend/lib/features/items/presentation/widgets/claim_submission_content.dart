import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/Riverpod/auth_provider.dart';
import 'package:frontend/features/claims/Riverpod/claim_provider.dart';
import 'package:frontend/features/claims/data/model/claim_model.dart';
import 'package:frontend/features/claims/enum/claim_status.dart';
import 'package:frontend/features/items/data/models/item_model.dart';

class ClaimSubmissionContent extends ConsumerStatefulWidget {
  final Item item;
  const ClaimSubmissionContent({super.key, required this.item});

  @override
  ConsumerState<ClaimSubmissionContent> createState() => _ClaimSubmissionContentState();
}

class _ClaimSubmissionContentState extends ConsumerState<ClaimSubmissionContent> {
  final TextEditingController _answerController = TextEditingController();

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _submitClaim() async {
    final itemId = widget.item.id;
    final answer = _answerController.text.trim();
    if (answer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter verification answer.')),
      );
      return;
    }

    try {
      final user = ref.read(userProvider);
      if (user['id'] == null || user['id'].isEmpty) {
        throw Exception('User not authenticated');
      }

      final newClaim = Claim(
        id: '', // Backend generated
        itemId: itemId,
        claimantId: user['id'],
        answerAttempt: answer,
        title: widget.item.title,
        description: widget.item.description,
        status: ClaimStatus.pending,
        category: widget.item.category,
        location: widget.item.location,
        imageUrl: widget.item.imageUrl,
        date: DateTime.now(),
      );

      await ref.read(claimProvider.notifier).addClaim(newClaim);

      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Claim submitted successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit claim: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = widget.item.imageUrl ?? '';
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
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
              child: Image.network(
                imageUrl,
                height: 120,
                width: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 120,
                  width: 120,
                  color: Colors.grey.shade200,
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _infoBox(theme, widget.item),
            const SizedBox(height: 20),
            Text(
              "Verification key: ${widget.item.verificationQuestion}",
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _answerController,
              decoration: const InputDecoration(hintText: "Your answer..."),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E3E),
                  foregroundColor: Colors.white,
                ),
                onPressed: _submitClaim,
                child: const Text("Submit Claim"),
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

  Widget _infoBox(ThemeData theme, Item item) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: theme.primaryColor, borderRadius: BorderRadius.circular(15)),
    child: Column(children: [
      _row(Icons.location_on, item.location),
      const Divider(color: Colors.white24),
      _row(Icons.calendar_today, item.dateFound.toLocal().toString().split(' ')[0]),
    ]),
  );

  Widget _row(IconData icon, String val) => Row(children: [
    Icon(icon, color: Colors.white, size: 18),
    const SizedBox(width: 10),
    Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
  ]);
}