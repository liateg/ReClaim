class ItemModel {
  final int id;
  final String title;
  final String description;
  final int? categoryId;
  final String location;
  final DateTime? dateFound;
  final String? imageUrl;
  final String verificationQuestion;
  final String? verificationAnswer; // server usually omits this in public payloads
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

    return ItemModel(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      categoryId: json['category_id'] is int ? json['category_id'] as int : (json['category_id'] == null ? null : int.parse(json['category_id'].toString())),
      location: json['location']?.toString() ?? '',
      dateFound: parseDate(json['date_found'] ?? json['date_found']),
      imageUrl: json['image_url'] as String?,
      verificationQuestion: json['verification_question']?.toString() ?? '',
      verificationAnswer: json['verification_answer'] as String?,
      hiddenDetails: json['hidden_details'] as String?,
      status: json['status']?.toString() ?? '',
      postedBy: json['posted_by'] is int ? json['posted_by'] as int : (json['posted_by'] == null ? null : int.parse(json['posted_by'].toString())),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
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

  static const String placeholderImage = "https://via.placeholder.com/400x200?text=No+Image+Available";
}
