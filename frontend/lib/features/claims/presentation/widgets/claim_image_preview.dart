import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/utils/theme/app_theme.dart';

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
    final url = imageUrl;
    if (url == null || url.isEmpty) {
      return _placeholder();
    }
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return Image.network(url, fit: BoxFit.cover);
    }
    if (url.startsWith('/uploads/')) {
      return Image.network('http://localhost:3000$url', fit: BoxFit.cover);
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
