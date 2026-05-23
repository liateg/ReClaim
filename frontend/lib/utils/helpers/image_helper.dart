import 'package:frontend/core/api/dio_client.dart';

class ImageHelper {
  /// Processes an image URL to ensure it has a valid protocol and base URL if needed.
  static String getValidUrl(String? url) {
    if (url == null || url.isEmpty) {
      return '';
    }

    // If it's already a full URL, return it
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    // If it's a relative back-end path, prepend the base URL
    if (url.startsWith('/uploads/')) {
      return '${DioClient.baseUrl}$url';
    }

    // For any other relative path, also try prepending the base URL
    if (url.startsWith('/')) {
        return '${DioClient.baseUrl}$url';
    }

    return url;
  }
}
