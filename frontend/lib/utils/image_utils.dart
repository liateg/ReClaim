class ImageUtils {
  static const String baseUrl = 'http://localhost:3000';

  static String getFullUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    if (path.startsWith('/uploads/')) return '$baseUrl$path';
    return path; // Might be a local file path
  }
}
