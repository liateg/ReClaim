import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _overrideBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');

  static String get baseUrl {
    if (_overrideBaseUrl.isNotEmpty) {
      return _overrideBaseUrl;
    }

    if (kIsWeb) {
      return 'http://localhost:3000';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:3000';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return 'http://localhost:3000';
    }
  }

  /// Resolves a stored image reference into a fully-qualified URL that
  /// [Image.network] can load.
  ///
  /// The backend stores uploaded images as relative paths (e.g.
  /// `/uploads/123.jpg`) and serves them from `<baseUrl>/uploads`. Relative
  /// paths are prefixed with [baseUrl]; absolute http(s) URLs are returned
  /// unchanged; blank values return an empty string.
  static String resolveImageUrl(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) return '';
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    final base =
        baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final path = value.startsWith('/') ? value : '/$value';
    return '$base$path';
  }
}
