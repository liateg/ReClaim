import 'package:flutter/material.dart';
import '../../utils/theme/app_theme.dart';

/// Centered progress indicator with an optional label.
class LoadingIndicator extends StatelessWidget {
  final String? message;

  const LoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppTheme.primaryGreen),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(
              message!,
              style: const TextStyle(color: AppTheme.grayText),
            ),
          ],
        ],
      ),
    );
  }
}
