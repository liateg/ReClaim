import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/items/presentation/riverpod/items_provider.dart';
import 'package:frontend/shared/widgets/appbar.dart';
import 'package:image_picker/image_picker.dart';

class CreateItemScreen extends ConsumerStatefulWidget {
  const CreateItemScreen({super.key});

  @override
  ConsumerState<CreateItemScreen> createState() => _CreateItemScreenState();
}

class _CreateItemScreenState extends ConsumerState<CreateItemScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _verificationQuestionController =
      TextEditingController();
  final TextEditingController _verificationAnswerController =
      TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  String _selectedCategory = 'Electronics';
  bool _isSubmitting = false;
  XFile? _pickedImage;
  Uint8List? _pickedImageBytes;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _verificationQuestionController.dispose();
    _verificationAnswerController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      setState(() {
        _pickedImage = file;
        _pickedImageBytes = bytes;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo selected. It will upload when you post.'),
          backgroundColor: Color(0xFF1B5E3E),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not pick image: $e')),
      );
    }
  }

  Future<void> _submitPost() async {
    final title = _titleController.text.trim();
    final location = _locationController.text.trim();
    final description = _descriptionController.text.trim();
    final verificationQuestion = _verificationQuestionController.text.trim();
    final verificationAnswer = _verificationAnswerController.text.trim();

    if (title.isEmpty ||
        location.isEmpty ||
        description.isEmpty ||
        verificationQuestion.isEmpty ||
        verificationAnswer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final params = (
        title: title,
        location: location,
        description: description,
        verificationQuestion: verificationQuestion,
        verificationAnswer: verificationAnswer,
        category: _selectedCategory,
        imagePath: _pickedImage?.path,
        imageBytes: _pickedImageBytes,
        imageFileName: _pickedImage?.name,
      );
      await ref.read(createItemProvider(params).future);

      if (!mounted) return;
      invalidateItemsState(ref);

      _titleController.clear();
      _locationController.clear();
      _descriptionController.clear();
      _verificationQuestionController.clear();
      _verificationAnswerController.clear();
      setState(() {
        _pickedImage = null;
        _pickedImageBytes = null;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item posted successfully.'),
          backgroundColor: Color(0xFF1B5E3E),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post item: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildImagePreview() {
    if (_pickedImageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.memory(
          _pickedImageBytes!,
          height: 150,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.upload_file, color: Colors.grey),
          Text(
            'Tap to select a photo',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Post an Item", back: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Post an Item",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B4332)),
            ),
            const SizedBox(height: 8),
            const Text(
              "Our Digital Concierge helps reunite belongings with their owners. Please provide as much detail as possible.",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _isSubmitting ? null : _pickImage,
              child: _buildImagePreview(),
            ),
            const SizedBox(height: 20),
            _buildInputField(
              "Item Title",
              "e.g., Silver MacBook Air",
              controller: _titleController,
            ),
            _buildInputField(
              "Location",
              "e.g., Central Library, 2nd Floor",
              controller: _locationController,
            ),
            _buildInputField(
              "Description",
              "Describe item features and context",
              controller: _descriptionController,
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Category",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: const [
                DropdownMenuItem(
                    value: 'Electronics', child: Text('Electronics')),
                DropdownMenuItem(
                    value: 'Accessories', child: Text('Accessories')),
                DropdownMenuItem(
                    value: 'Documents', child: Text('Documents')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: _isSubmitting
                  ? null
                  : (value) {
                      if (value == null) return;
                      setState(() => _selectedCategory = value);
                    },
            ),
            const SizedBox(height: 16),
            _buildInputField(
              "Verification key (Admin only)",
              "Ask something only the owner can answer",
              controller: _verificationQuestionController,
            ),
            _buildInputField(
              "Verification key possible answer",
              "e.g., Blue star sticker",
              controller: _verificationAnswerController,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E3E),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isSubmitting ? null : _submitPost,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Post Item →",
                        style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String hint, {
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            enabled: !_isSubmitting,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }
}
