import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/features/items/presentation/riverpod/item_provider.dart';
import 'package:frontend/shared/widgets/appbar.dart';
import 'package:frontend/features/items/data/models/item_model.dart';

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
  String _selectedCategory = 'Electronics';
  File? _pickedImage;
  final ImagePicker _imagePicker = ImagePicker();

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
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null && mounted) {
      setState(() {
        _pickedImage = File(image.path);
      });
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

    try {
      String? remoteImageUrl;
      if (_pickedImage != null) {
        remoteImageUrl = await ref.read(itemProvider.notifier).uploadImage(_pickedImage!.path);
      }

      final newItem = Item(
        id: '', // Backend will generate
        title: title,
        location: location,
        description: description,
        category: _selectedCategory,
        dateFound: DateTime.now(),
        imageUrl: remoteImageUrl,
        verificationQuestion: verificationQuestion,
        verificationAnswer: verificationAnswer,
        status: 'available',
      );

      await ref.read(itemProvider.notifier).addItem(newItem);

      _titleController.clear();
      _locationController.clear();
      _descriptionController.clear();
      _verificationQuestionController.clear();
      _verificationAnswerController.clear();
      setState(() {
        _pickedImage = null;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item posted successfully.')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post item: $e')),
      );
    }
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
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1B4332)),
            ),
            const SizedBox(height: 8),
            const Text(
              "Our Digital Concierge helps reunite belongings with their owners. Please provide as much detail as possible.",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: _pickedImage == null 
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload_file, color: Colors.grey),
                        Text("Upload Item Image", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(_pickedImage!, fit: BoxFit.cover),
                    ),
              ),
            ),
            const SizedBox(height: 20),
            _buildInputField(
              "Item Title",
              "e.g., Silver MacBook Air",
              _titleController,
            ),
            _buildInputField(
              "Location",
              "e.g., Central Library, 2nd Floor",
              _locationController,
            ),
            _buildInputField(
              "Description",
              "Describe item features and context",
              _descriptionController,
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
              value: _selectedCategory,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'Electronics', child: Text('Electronics')),
                DropdownMenuItem(value: 'Accessories', child: Text('Accessories')),
                DropdownMenuItem(value: 'Documents', child: Text('Documents')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedCategory = value);
              },
            ),
            const SizedBox(height: 16),
            _buildInputField(
              "Verification key (Admin only)",
              "Ask something only the owner can answer",
              _verificationQuestionController,
            ),
            _buildInputField(
              "Verification key possible answer",
              "e.g., Blue star sticker",
              _verificationAnswerController,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E3E),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _submitPost,
                child: const Text("Post Item →", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String hint,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }
}