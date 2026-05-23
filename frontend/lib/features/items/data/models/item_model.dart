class ItemModel {
  final String id;
  final String title;
  final String location;
  final String description;
  final String category;
  final int? categoryId;
  final String status;
  final String dateFound;
  final String verificationQuestion;
  final String verificationAnswer;
  final String imageUrl;
  final String? hiddenDetails;
  final int? postedBy;
  final String? createdAt;
  final String? updatedAt;

  const ItemModel({
    required this.id,
    required this.title,
    required this.location,
    required this.description,
    required this.category,
    this.categoryId,
    required this.status,
    required this.dateFound,
    required this.verificationQuestion,
    required this.verificationAnswer,
    required this.imageUrl,
    this.hiddenDetails,
    this.postedBy,
    this.createdAt,
    this.updatedAt,
  });

  static const String keyId = 'id';
  static const String keyTitle = 'title';
  static const String keyDesc = 'description';
  static const String keyLocation = 'location';
  static const String keyCategory = 'category';
  static const String keyCategoryId = 'category_id';
  static const String keyImage = 'image_url';
  static const String keyStatus = 'status';
  static const String keyQuestion = 'verification_question';
  static const String keyAnswer = 'verification_answer';
  static const String keyDate = 'date_found';
  static const String keyHiddenDetails = 'hidden_details';
  static const String keyPostedBy = 'posted_by';
  static const String keyCreatedAt = 'created_at';
  static const String keyUpdatedAt = 'updated_at';

  static String _categoryFromId(dynamic categoryId) {
    final id = categoryId is int ? categoryId : int.tryParse('$categoryId');
    return switch (id) {
      1 => 'Electronics',
      2 => 'Accessories',
      3 => 'Clothing',
      _ => 'Other',
    };
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static String? _stringOrNull(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel.fromMap(json);
  }

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    final categoryId = _parseInt(map[keyCategoryId] ?? map['categoryId']);
    return ItemModel(
      id: map[keyId]?.toString() ?? '',
      title: map[keyTitle]?.toString() ?? '',
      location: map[keyLocation]?.toString() ?? '',
      description: map[keyDesc]?.toString() ?? '',
      category: map[keyCategory]?.toString() ?? _categoryFromId(categoryId),
      categoryId: categoryId,
      status: map[keyStatus]?.toString() ?? 'available',
      dateFound: map[keyDate]?.toString() ?? map['dateFound']?.toString() ?? '',
      verificationQuestion: map[keyQuestion]?.toString() ??
          map['verificationQuestion']?.toString() ??
          '',
      verificationAnswer: map[keyAnswer]?.toString() ??
          map['verificationAnswer']?.toString() ??
          '',
      imageUrl: map[keyImage]?.toString() ?? map['imageUrl']?.toString() ?? '',
      hiddenDetails:
          _stringOrNull(map[keyHiddenDetails] ?? map['hiddenDetails']),
      postedBy: _parseInt(map[keyPostedBy] ?? map['postedBy']),
      createdAt: _stringOrNull(map[keyCreatedAt] ?? map['createdAt']),
      updatedAt: _stringOrNull(map[keyUpdatedAt] ?? map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      keyId: id,
      keyTitle: title,
      keyLocation: location,
      keyDesc: description,
      keyCategory: category,
      keyCategoryId: categoryId,
      keyStatus: status,
      keyDate: dateFound,
      keyQuestion: verificationQuestion,
      keyAnswer: verificationAnswer,
      keyImage: imageUrl,
      keyHiddenDetails: hiddenDetails,
      keyPostedBy: postedBy,
      keyCreatedAt: createdAt,
      keyUpdatedAt: updatedAt,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  static const String placeholderImage =
      'https://via.placeholder.com/400x200?text=No+Image+Available';
}
