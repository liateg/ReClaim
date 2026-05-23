class Item {
  final String id;
  final String title;
  final String description;
  final String location;
  final String? imageUrl;
  final String status;
  final String verificationQuestion;
  final String verificationAnswer;
  final DateTime dateFound;
  final String category;

  Item({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    this.imageUrl,
    this.status = 'available',
    required this.verificationQuestion,
    required this.verificationAnswer,
    required this.dateFound,
    this.category = 'Other',
  });

  Item copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    String? imageUrl,
    String? status,
    String? verificationQuestion,
    String? verificationAnswer,
    DateTime? dateFound,
    String? category,
  }) {
    return Item(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      verificationQuestion: verificationQuestion ?? this.verificationQuestion,
      verificationAnswer: verificationAnswer ?? this.verificationAnswer,
      dateFound: dateFound ?? this.dateFound,
      category: category ?? this.category,
    );
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled item',
      description: json['description']?.toString() ?? '',
      location: json['location']?.toString() ?? 'Unknown location',
      imageUrl: (json['imageUrl'] ?? json['image_url'])?.toString(),
      status: json['status']?.toString() ?? 'available',
      verificationQuestion: (json['verificationQuestion'] ?? json['verification_question'])?.toString() ?? '',
      verificationAnswer: (json['verificationAnswer'] ?? json['verification_answer'])?.toString() ?? '',
      dateFound: (json['dateFound'] ?? json['date_found']) != null
          ? DateTime.tryParse((json['dateFound'] ?? json['date_found']).toString()) ?? DateTime.now()
          : DateTime.now(),
      category: json['category']?.toString() ?? 'Other',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'imageUrl': imageUrl,
      'status': status,
      'verificationQuestion': verificationQuestion,
      'verificationAnswer': verificationAnswer,
      'dateFound': dateFound.toIso8601String(),
      'category': category,
    };
  }
}