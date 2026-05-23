import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/utils/theme/app_theme.dart';
import 'package:frontend/utils/helpers/image_helper.dart';

/// Displays a claim image from a network URL or local file path.
class ClaimImagePreview extends StatelessWidget {
  final String? imageUrl;
  final double aspectRatio;
  final double placeholderIconSize;

  const ClaimImagePreview({
    super.key,
    this.imageUrl,
    this.aspectRatio = 16 / 10,
    this.placeholderIconSize = 44,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: _buildImage(),
    );
  }

  Widget _buildImage() {
    final url = ImageHelper.getValidUrl(imageUrl);
    if (url.isEmpty) {
      return _placeholder();
    }
    
    if (url.startsWith('http')) {
      return Image.network(
        url, 
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _placeholder(),
      );
    }
    
    final file = File(url);
    if (file.existsSync()) {
      return Image.file(file, fit: BoxFit.cover);
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: AppTheme.grayBorder.withValues(alpha: 0.45),
      child: Icon(
        Icons.image_outlined,
        size: placeholderIconSize,
        color: AppTheme.grayText,
      ),
    );
  }
}
