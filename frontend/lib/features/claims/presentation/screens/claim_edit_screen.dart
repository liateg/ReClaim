import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/features/claims/Riverpod/claim_provider.dart';
import 'package:frontend/features/claims/data/model/claim_model.dart';
import 'package:frontend/shared/widgets/appbar.dart';
import 'package:frontend/utils/theme/app_theme.dart';

class ClaimEditScreen extends ConsumerStatefulWidget {
  final String claimId;

  const ClaimEditScreen({super.key, required this.claimId});

  @override
  ConsumerState<ClaimEditScreen> createState() => _ClaimEditScreenState();
}

class _ClaimEditScreenState extends ConsumerState<ClaimEditScreen> {
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  late final TextEditingController locationController;
  late final TextEditingController answerAttemptController;

  File? pickedImage;
  final ImagePicker _imagePicker = ImagePicker();
  String? existingImageUrl;

  @override
  void initState() {
    super.initState();
    final claimState = ref.read(claimProvider);
    final claim = claimState.claims.firstWhere((c) => c.id == widget.claimId);
    
    titleController = TextEditingController(text: claim.title);
    descriptionController = TextEditingController(text: claim.description);
    locationController = TextEditingController(text: claim.location);
    answerAttemptController = TextEditingController(text: claim.answerAttempt);
    existingImageUrl = claim.imageUrl;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    answerAttemptController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null && mounted) {
      setState(() {
        pickedImage = File(image.path);
      });
    }
  }

  Future<void> _updateClaim() async {
    try {
      String? imageUrl = existingImageUrl;
      if (pickedImage != null) {
        ref.read(claimProvider.notifier).setLoading(true);
        imageUrl = await ref.read(claimProvider.notifier).uploadImage(pickedImage!.path);
      }

      final claimState = ref.read(claimProvider);
      final claim = claimState.claims.firstWhere((c) => c.id == widget.claimId);
      
      final updatedClaim = claim.copyWith(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        location: locationController.text.trim(),
        answerAttempt: answerAttemptController.text.trim(),
        imageUrl: imageUrl,
      );

      await ref.read(claimProvider.notifier).updateClaim(updatedClaim);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Claim updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.detailScreenBackground,
      appBar: const CustomAppBar(title: 'Edit Claim', back: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.grayBorder),
                ),
                child: pickedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(pickedImage!, fit: BoxFit.cover),
                      )
                    : existingImageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(
                              existingImageUrl!.startsWith('/') 
                                ? 'http://localhost:3000$existingImageUrl' 
                                : existingImageUrl!, 
                              fit: BoxFit.cover
                            ),
                          )
                        : const Icon(Icons.camera_alt_outlined, size: 48, color: AppTheme.grayText),
              ),
            ),
            const SizedBox(height: 20),
            _inputField('Claim Title', titleController),
            const SizedBox(height: 12),
            _inputField('Description', descriptionController, maxLines: 3),
            const SizedBox(height: 12),
            _inputField('Location', locationController),
            const SizedBox(height: 12),
            _inputField('Evidence / Answer', answerAttemptController, maxLines: 3),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateClaim,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.grayText)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
