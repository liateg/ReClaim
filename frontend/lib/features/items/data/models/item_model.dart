class ItemModel {
  final int id;
  final String title;
  final String description;
  final int? categoryId;
  final String location;
  final DateTime? dateFound;
  final String? imageUrl;
  final String verificationQuestion;
  final String?
      verificationAnswer; // server usually omits this in public payloads
  final String? hiddenDetails;
  final String status;
  final int? postedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ItemModel({
    required this.id,
    required this.title,
    required this.description,
    this.categoryId,
    required this.location,
    this.dateFound,
    this.imageUrl,
    required this.verificationQuestion,
    this.verificationAnswer,
    this.hiddenDetails,
    required this.status,
    this.postedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(Object? v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    int parseInt(dynamic v) {
      if (v == null) throw FormatException('Missing integer value');
      if (v is int) return v;
      final s = v.toString();
      return int.parse(s);
    }

    final idVal = json['id'] ?? json['Id'];
    final categoryVal = json['categoryId'] ?? json['category_id'];
    final dateVal = json['dateFound'] ?? json['date_found'];
    final imageVal = json['imageUrl'] ?? json['image_url'];
    final verificationQuestionVal =
        json['verificationQuestion'] ?? json['verification_question'];
    final verificationAnswerVal =
        json['verificationAnswer'] ?? json['verification_answer'];
    final hiddenDetailsVal = json['hiddenDetails'] ?? json['hidden_details'];
    final postedByVal = json['postedBy'] ?? json['posted_by'];
    final createdVal = json['createdAt'] ?? json['created_at'];
    final updatedVal = json['updatedAt'] ?? json['updated_at'];

    return ItemModel(
      id: parseInt(idVal),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      categoryId: categoryVal == null ? null : parseInt(categoryVal),
      location: (json['location'] ?? '').toString(),
      dateFound: parseDate(dateVal),
      imageUrl: imageVal as String?,
      verificationQuestion: (verificationQuestionVal ?? '').toString(),
      verificationAnswer: verificationAnswerVal as String?,
      hiddenDetails: hiddenDetailsVal as String?,
      status: (json['status'] ?? '').toString(),
      postedBy: postedByVal == null ? null : parseInt(postedByVal),
      createdAt: parseDate(createdVal),
      updatedAt: parseDate(updatedVal),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category_id': categoryId,
        'location': location,
        'date_found': dateFound?.toIso8601String(),
        'image_url': imageUrl,
        'verification_question': verificationQuestion,
        'verification_answer': verificationAnswer,
        'hidden_details': hiddenDetails,
        'status': status,
        'posted_by': postedBy,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  static const String keyId = 'id';
  static const String keyTitle = 'title';
  static const String keyDesc = 'description';
  static const String keyLocation = 'location';
  static const String keyImage = 'image_url';
  static const String keyStatus = 'status';
  static const String keyQuestion = 'verification_question';
  static const String keyAnswer = 'verification_answer';
  static const String keyDate = 'date_found';

  static const String placeholderImage =
      "https://via.placeholder.com/400x200?text=No+Image+Available";
}
