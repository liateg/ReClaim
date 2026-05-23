import 'package:frontend/core/session/services/auth_service.dart';

/// Maps backend item JSON (camelCase) to UI maps (snake_case) used by screens.
class ItemApiMapper {
  ItemApiMapper._();

  static const Map<int, String> categoryIdToName = {
    1: 'Electronics',
    2: 'Accessories',
    3: 'Clothing',
  };

  static const Map<String, int> categoryNameToId = {
    'Electronics': 1,
    'Accessories': 2,
    'Clothing': 3,
  };

  static String formatDateFound(dynamic value) {
    if (value == null) return '';
    final raw = value.toString();
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[parsed.month - 1]} ${parsed.day}, ${parsed.year}';
  }

  static String todayForApi() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }

  static String? categoryNameFromId(dynamic categoryId) {
    if (categoryId == null) return 'Other';
    final id =
        categoryId is int ? categoryId : int.tryParse(categoryId.toString());
    if (id == null) return 'Other';
    return categoryIdToName[id] ?? 'Other';
  }

  static int? categoryIdFromName(String? category) {
    if (category == null || category.isEmpty) return null;
    return categoryNameToId[category];
  }

  /// Turns `/uploads/foo.jpg` into a full URL for [Image.network].
  static String resolveImageUrl(String? imageUrl) {
    final value = imageUrl?.toString().trim();
    if (value == null || value.isEmpty) return '';
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    final base = AuthService.baseUrl.replaceAll(RegExp(r'/$'), '');
    final path = value.startsWith('/') ? value : '/$value';
    return '$base$path';
  }

  static Map<String, dynamic> apiToUiMap(Map<String, dynamic> json) {
    return {
      'id': json['id']?.toString() ?? '',
      'title': json['title']?.toString() ?? '',
      'description': json['description']?.toString() ?? '',
      'location': json['location']?.toString() ?? '',
      'category': categoryNameFromId(json['categoryId']),
      'category_id': json['categoryId'],
      'status': json['status']?.toString() ?? 'available',
      'date_found': formatDateFound(json['dateFound']),
      'image_url': resolveImageUrl(json['imageUrl']?.toString()),
      'verification_question':
          json['verificationQuestion']?.toString() ?? '',
      'verification_answer': json['verificationAnswer']?.toString() ?? '',
      'hidden_details': json['hiddenDetails']?.toString(),
      'posted_by': json['postedBy']?.toString(),
    };
  }

  static Map<String, dynamic> createBody({
    required String title,
    required String location,
    required String description,
    required String verificationQuestion,
    required String verificationAnswer,
    String? category,
    String? imageUrl,
  }) {
    return {
      'title': title,
      'description': description,
      'location': location,
      'dateFound': todayForApi(),
      'verificationQuestion': verificationQuestion,
      'verificationAnswer': verificationAnswer,
      'status': 'available',
      if (categoryIdFromName(category) != null)
        'categoryId': categoryIdFromName(category),
      if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
    };
  }

  static Map<String, dynamic> updateBody({
    required String title,
    required String location,
    String? description,
    String? category,
    String? verificationQuestion,
    String? verificationAnswer,
    String? status,
    String? imageUrl,
  }) {
    return {
      'title': title,
      'location': location,
      if (description != null) 'description': description,
      if (category != null && categoryIdFromName(category) != null)
        'categoryId': categoryIdFromName(category),
      if (verificationQuestion != null)
        'verificationQuestion': verificationQuestion,
      if (verificationAnswer != null)
        'verificationAnswer': verificationAnswer,
      if (status != null) 'status': status,
      if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
      'dateFound': todayForApi(),
    };
  }
}
