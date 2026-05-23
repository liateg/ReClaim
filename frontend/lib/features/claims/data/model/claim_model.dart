import '../../enum/claim_status.dart';

class Claim {
  final String id;
  final String itemId;
  final String claimantId;
  final String? answerAttempt;
  final String title;
  final String description;
  final ClaimStatus status;
  final String category;
  final String location;
  final String? imageUrl;
  final DateTime date;

  Claim({
    required this.id,
    required this.itemId,
    required this.claimantId,
    this.answerAttempt,
    required this.title,
    required this.description,
    required this.status,
    required this.category,
    required this.location,
    this.imageUrl,
    required this.date,
  });

  Claim copyWith({
    String? id,
    String? itemId,
    String? claimantId,
    String? answerAttempt,
    String? title,
    String? description,
    ClaimStatus? status,
    String? category,
    String? location,
    String? imageUrl,
    DateTime? date,
  }) {
    return Claim(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      claimantId: claimantId ?? this.claimantId,
      answerAttempt: answerAttempt ?? this.answerAttempt,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      category: category ?? this.category,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      date: date ?? this.date,
    );
  }

  factory Claim.fromJson(Map<String, dynamic> json) {
    return Claim(
      id: json['id']?.toString() ?? '',
      itemId: (json['itemId'] ?? json['item_id'])?.toString() ?? '',
      claimantId: (json['claimantId'] ?? json['claimant_id'])?.toString() ?? '',
      answerAttempt: (json['answerAttempt'] ?? json['answer_attempt'])?.toString(),
      title: json['title'] as String? ?? 'Claim #${json['id']}',
      description: json['description'] as String? ?? '',
      status: _parseStatus(json['status'] as String?),
      category: json['category'] as String? ?? 'Others',
      location: json['location'] as String? ?? 'Unknown',
      imageUrl: (json['imageUrl'] ?? json['image_url']) as String?,
      date: (json['createdAt'] ?? json['created_at']) != null 
          ? DateTime.parse((json['createdAt'] ?? json['created_at']) as String) 
          : (json['date'] != null ? DateTime.parse(json['date'] as String) : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemId': itemId,
      'claimantId': claimantId,
      'answerAttempt': answerAttempt,
      'title': title,
      'description': description,
      'status': status.name,
      'category': category,
      'location': location,
      'imageUrl': imageUrl,
      'date': date.toIso8601String(),
    };
  }

  static ClaimStatus _parseStatus(String? status) {
    if (status == null) return ClaimStatus.pending;
    switch (status.toLowerCase()) {
      case 'approved':
        return ClaimStatus.approved;
      case 'rejected':
        return ClaimStatus.rejected;
      case 'withdrawn':
        return ClaimStatus.withdrawn;
      case 'pending':
      default:
        return ClaimStatus.pending;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Claim &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          itemId == other.itemId &&
          claimantId == other.claimantId;

  @override
  int get hashCode => id.hashCode ^ itemId.hashCode ^ claimantId.hashCode;
}