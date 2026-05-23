import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/items/Riverpod/items_provider.dart';
import 'package:frontend/shared/widgets/appbar.dart';
import 'package:image_picker/image_picker.dart';

class EditItemScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> item;
  const EditItemScreen({super.key, required this.item});

  @override
  ConsumerState<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends ConsumerState<EditItemScreen> {
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  late TextEditingController _verificationQuestionController;
  late TextEditingController _verificationAnswerController;
  late String _selectedCategory;
  late String _existingImageUrl;
  bool _isSaving = false;
  XFile? _pickedImage;
  Uint8List? _pickedImageBytes;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: (widget.item['title'] as String?) ?? '');
    _locationController =
        TextEditingController(text: (widget.item['location'] as String?) ?? '');
    _descriptionController = TextEditingController(
      text: (widget.item['description'] as String?) ?? '',
    );
    _verificationQuestionController = TextEditingController(
      text: (widget.item['verification_question'] as String?) ?? '',
    );
    _verificationAnswerController = TextEditingController(
      text: (widget.item['verification_answer'] as String?) ?? '',
    );
    _selectedCategory = (widget.item['category'] as String?) ?? 'Other';
    _existingImageUrl = (widget.item['image_url'] as String?) ?? '';
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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not pick image: $e')),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _verificationQuestionController.dispose();
    _verificationAnswerController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final id = widget.item['id']?.toString();
    final title = _titleController.text.trim();
    final location = _locationController.text.trim();
    final description = _descriptionController.text.trim();
    final verificationQuestion = _verificationQuestionController.text.trim();
    final verificationAnswer = _verificationAnswerController.text.trim();

    if (id == null ||
        title.isEmpty ||
        location.isEmpty ||
        description.isEmpty ||
        verificationQuestion.isEmpty ||
        verificationAnswer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final params = (
        id: id,
        title: title,
        location: location,
        description: description,
        category: _selectedCategory,
        verificationQuestion: verificationQuestion,
        verificationAnswer: verificationAnswer,
        imagePath: _pickedImage?.path,
        imageBytes: _pickedImageBytes,
        imageFileName: _pickedImage?.name,
      );
      final updated = await ref.read(updateItemProvider(params).future);

      if (!mounted) return;
      if (updated) {
        invalidateItemsState(ref, itemId: id);
      }
      if (!updated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update item.')),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saved successfully'),
          backgroundColor: Color(0xFF1B5E3E),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update item: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildImagePreview() {
    if (_pickedImageBytes != null) {
      return Image.memory(
        _pickedImageBytes!,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
    final url = _existingImageUrl.trim();
    if (url.isEmpty) {
      return Container(
        height: 180,
        width: double.infinity,
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported),
      );
    }
    return Image.network(
      url,
      height: 180,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        height: 180,
        width: double.infinity,
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Edit Item", back: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Edit Item Details",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _isSaving ? null : _pickImage,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: _buildImagePreview(),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _isSaving ? null : _pickImage,
                child: const Text(
                  'Change photo',
                  style: TextStyle(color: Color(0xFF1B5E3E)),
                ),
              ),
            ),
            TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Title")),
            const SizedBox(height: 16),
            TextField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: "Location")),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: const [
                DropdownMenuItem(
                    value: 'Electronics', child: Text('Electronics')),
                DropdownMenuItem(
                    value: 'Accessories', child: Text('Accessories')),
                DropdownMenuItem(value: 'Documents', child: Text('Documents')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: _isSaving
                  ? null
                  : (value) {
                      if (value == null) return;
                      setState(() => _selectedCategory = value);
                    },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _verificationQuestionController,
              decoration: const InputDecoration(
                labelText: "Verification key (Admin only)",
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _verificationAnswerController,
              decoration: const InputDecoration(
                labelText: "Verification key possible answer",
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E3E),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 46),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text("Save Changes"),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  "Cancel edits",
                  style: TextStyle(color: Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
